---
layout: post
title: Getting Honeycomb working with my AWS Lambda functions
date: 2021-10-03
published: true
---

I have several existing Lambda functions which are all built on Node.js which I wanted to connect to [Honeycomb](https://www.honeycomb.io/). I spent some time over the weekend working through it, and this is my stream-of-consciousness.

<!-- more -->

If you'd like to read just the solution you can jump to [Honeycomb and OpenTelemetry with Lambda and Node.js (reference)](/writings/honeycomb-and-opentelemetry-with-aws-lambda-and-nodejs-reference), and if you want to keep your API keys outside of your OpenTelemetry config you can reference environment variables like I describe in [Keeping API keys and environment-specifics out of your OpenTelemetry config](/writings/keeping-api-keys-and-environment-specifics-out-of-your-opentelemetry-config).

So, where do I start connecting these Lambdas to Honeycomb?

## Starting with OpenTelemetry

Honeycomb [encourage you to use OpenTelemetry](https://docs.honeycomb.io/getting-data-in/opentelemetry/beelines-and-otel/) to send data to them. It's nice to see a vendor encourage the use of open standards over their own client libraries (which they also have if you need them).

So I start look at the [OpenTelemetry documentation for Node.js](https://opentelemetry.io/docs/js/getting_started/nodejs/) and it's apparent that they are stateful application oriented, the usual set of Express web servers with their easy opportunities to run code before the server launches. Anyone who's worked with Lambda for a while has a natural spidey-sense when you see things like this. Is this going to work in Lambda?

This is my first point of confusion. I pause here for a bit and reach out to a couple of people on Twitter, and [Liz Fong-Jones](https://twitter.com/lizthegrey) [points me](https://twitter.com/lizthegrey/status/1443588721018748936) at the [AWS Distro for OpenTelemetry on Lambda](https://aws.amazon.com/blogs/opensource/aws-distro-for-opentelemetry-adds-lambda-layers-for-more-languages-and-collector/).

My confusion about Node.js support will return later, but for now Liz's suggestion sends me off in a positive direction.

## AWS Distro for OpenTelemetry

[AWS Distro for OpenTelemetry](https://aws.amazon.com/otel) (aka ADOT, just rolls off the tongue) provides several pre-built [Lambda Layers](https://aws-otel.github.io/docs/getting-started/lambda/lambda-js) which you can add to your Lambda functions to configure OpenTelemetry for you. There's a Node.js one, so that's positive.

Naturally, the Lambda Layer is pre-configured to export traces to X-Ray by default (which I already have in place, so not particularly helpful) but I figure it's still valuable to see OpenTelemetry working first.

I add the Lambda Layer and set the environment variables and... 💥bang💥, it falls over.

I seem to have hit a [known issue](https://github.com/aws-observability/aws-otel-lambda/issues/99) where one of the underlying OpenTelemetry JavaScript libraries seems to do something clever and try to find your `package.json` file which I'm not including in my bundle. I update my bundler to include the `package.json` in my Lambdas and... partial success?

Most of my Lambdas are working, but there's a handful which I've deployed with the [AWS CDK](https://docs.aws.amazon.com/cdk/latest/guide/home.html) that are still failing. It turns out I've hit [a different issue](https://github.com/aws-observability/aws-otel-lambda/issues/99), something about how CDK uses esbuild to package the Lambdas prevents the Lambda Layer from being able to do some meta-programming to rewire the Lambda's handler function. I'm not really sure why this is a problem because all my other functions are also bundled with esbuild. Anyway, there's a workaround in the Github issue and away I go. One more redeploy and...

If I look in the Lambda's logs, there's signs of an OpenTelemetry Collector running and it's printing about receiving traces. The traces are still going to X-Ray but it's a step in the right direction.

## Connecting to Honeycomb

Now to actually get the traces to Honeycomb. The AWS Distro for OpenTelemetry comes pre-packaged with a config file for the Collector which points to X-Ray. If you want your telemetry to go anywhere else you need to provide your own config file.

> I'm not 100% happy with the config file approach, which I'll come back to later.

I place an `otpl.yaml` in the root of each of my Lambda functions which looks something like this:

```yaml
receivers:
  otlp:
    protocols:
      grpc:
      http:

exporters:
  otlp:
    endpoint: "api.honeycomb.io:443"
    headers:
      "x-honeycomb-team": "my-api-key"
      "x-honeycomb-dataset": "environment-name"

service:
  pipelines:
    traces:
      receivers: [otlp]
      exporters: [otlp]
```

...and I set the appropriate environment variable to let the Lambda Layer know I'm providing my own config and redeploy. I invoke my function and a few seconds later data starts appearing in Honeycomb! 🎉

That wasn't so hard. Ok it wasn't easy either, but you don't use Node.js without expecting every new thing you try to fail with some half-baked library *laughcry*.

At this point I have auto-instrumented code sending traces to Honeycomb. The final step is to get manual instrumentation working.

## Manual instrumentation with OpenTelemetry

This is the bit that I was stuck on for the longest, I think.

So far, all of my code is auto-instrumented and there's no sign of OpenTelemetry in my application code. Whilst this is a great start, I also want to be able to manually instrument certain aspects of my code-bases.

The examples weren't very helpful here:

1. The [simple manual setups](https://github.com/open-telemetry/opentelemetry-js/tree/main/examples/basic-tracer-node) rely on being able to execute code at application start time
2. Similarly the more complex [application servers](https://opentelemetry.io/docs/js/getting_started/nodejs/#setup) examples do the same
3. Any Lambda examples I could find relied on [using auto-instrumentation](https://github.com/open-telemetry/opentelemetry-lambda/blob/2a9c393f1fa0cc873bbe8dc8d5aa32d9eb46c158/nodejs/sample-apps/aws-sdk/src/index.ts) and had no use of the OpenTelemetry SDK.
4. Similarly, Honecomb's examples are of [the stateful variety](https://docs.honeycomb.io/getting-data-in/javascript/opentelemetry/#initialization) for Node.js
5. And Honeycomb's docs on AWS Lambda are [about their own Lambda Layer](https://docs.honeycomb.io/getting-data-in/integrations/aws/aws-lambda/).

I went around in circles for a bit here. Do I need to initialise the NodeSDK like the examples are doing? If I do, how am I supposed to do that in a Lambda function (assuming I don't want to initialise on every invocation)?

Eventually, I thought I'd dig through how the Lambda Layer actually works to see if that reveals anything.

1. Starting at the AWS Distro for OpenTelemetry entrypoint: [otel-handler](https://github.com/aws-observability/aws-otel-lambda/blob/main/nodejs/scripts/otel-handler). This script is invoked instead of your Lambda's entrypoint. It doesn't do much except pass-on to the base OpenTelemetry Layer.
2. In the base OpenTelemetry Layer there's an entrypoint too: [otel-handler](https://github.com/open-telemetry/opentelemetry-lambda/blob/2a9c393f1fa0cc873bbe8dc8d5aa32d9eb46c158/nodejs/packages/layer/scripts/otel-handler) and this one looks a little more interesting, it requires an `/opt/wrapper.js` before it invokes your own Lambda handler. So this `wrapper.js` will be the first thing to execute (which is a common requirement of setting instrumentation, so this is getting interesting)
3. If we dig into the [wrapper.js](https://github.com/open-telemetry/opentelemetry-lambda/blob/2a9c393f1fa0cc873bbe8dc8d5aa32d9eb46c158/nodejs/packages/layer/src/wrapper.ts)... we've struck gold. A whole lot of calls to the OpenTelemetry JavaScript SDK.  Setting up a provider. Configuring the tracer etc...

Once I'd seen that wrapper script I thought, perhaps if OpenTelemetry has already been initialised all I need to do is just start using the OpenTelemetry API in my code and it'll all just magically work? And I was correct! I can grab the active context with `opentelemetry.context.active()` and start adding spans to it. No further configuration needed.

My Lambda functions now just need the Lambda Layer attached and configured, and then my instrumentation code calls the OpenTelemetry API and the rest is as you'd expect. Now I have auto-instrumented code and manual instrumented code, all going via OpenTelemetry and being pushed to Honeycomb. Nice 👍

But there is one last thing on my mind. The config file that AWS Distro needs you to create. That config file is where you put your API Keys and other exporter settings. That's not ideal.

## Making the OpenTelemetry config free of API keys and environment-specifics

To add some extra context, it's important to understand that I bundle my Lambda functions *once* and only once. I don't build environment-specific bundles, instead the one bundle is "promoted" to different environments. Where this becomes an issue is OpenTelemetry needs me to embed the Honeycomb settings in the config file.

The first problem is the Honeycomb Dataset setting which controls how your data is bucketed in Honeycomb, and ideally should be unique for each environment. This Dataset setting has to be defined as a header on the Exporter config.

I initially resolved this by creating multiple config files, one per environment, and bundling them all into the Lambda environment-agnostic package. I could then choose which file to use by setting a different `OPENTELEMETRY_COLLECTOR_CONFIG_FILE` environment variable value per-environment. This approach wasn't viable long-term as I have ephemeral environments and can't really create a config file for each environment ahead of time.

The second problem is the API Key itself. I don't want to be embedding that in a config file and committing it to my Git repo. I could generate the config file dynamically at build time and inject the API key only in the build step, but that sounded like hard work (especially if I had one file per environment).

I thought there must be a way to customise the config file at runtime somehow, but the examples are _sparse_ for anything beyond the most basic use of the AWS Distro for OpenTelemetry.

After a bit of searching I came across a reference to an `OTEL_EXPORTER_OTLP_ENDPOINT` environment variable in an [open Github issue](https://github.com/aws-observability/aws-otel-collector/issues/646) which sent me off down a rabbit hole. If there's one environment variable, there must be more, right? Turns out there are, there's [quite a lot of them](https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/protocol/exporter.md). One environment variable which looked particularly promising was `OTEL_EXPORTER_OTLP_HEADERS` which you can set to provide a list of key-value pairs which are used as the HTTP Headers in any Exporter requests; this sounds perfect as those headers are where you set the Honeycomb Team API Key and the Dataset name. Perfect!

Unfortunately, I could not get any of those environment variables to work with the AWS Distro for OpenTelemetry Lambda Layer. No combination of them seemed to make any difference. As far as I can tell, these environment variables are ignored in the Lambda Layer.

The idea of environment variables stuck in my head though, and I wondered if perhaps the config parser had handling for referencing other environment variables. I found my way to the [OpenTelemetry Collector documentation](https://opentelemetry.io/docs/collector/configuration) which has a section on [environment variables](https://opentelemetry.io/docs/collector/configuration/#configuration-environment-variables) and contained these magic words:

> The use and expansion of environment variables is supported in the Collector configuration.

This is sounding promising. I updated my Exporter config to reference some custom environment variables which I can set per Lambda without changing the bundled config file:

```yaml
exporters:
  otlp:
    endpoint: "api.honeycomb.io:443"
    headers:
      "x-honeycomb-team": "$HONEYCOMB_TEAM_KEY"
      "x-honeycomb-dataset": "$HONEYCOMB_DATASET$"
```

...and it works! Success.

I can now revert to a single config file which has no secrets or environment-specific information in. Each lambda then has a couple of additional environment variables which set the API key and the Dataset.

I'm not a big fan of storing secrets in environment variables, but until there's support for [external secret management in OpenTelemetry](https://github.com/open-telemetry/opentelemetry-collector/issues/2469) I think this is the best I'm going to get.

That's it. All done. I can rest now.

## Conclusion

To summarise:

1. Use the [AWS Distro for OpenTelemetry Lambda Layer](https://aws-otel.github.io/docs/getting-started/lambda/lambda-js)
2. Resolve any awkward issues with the newness of Node.js support ([bundle your package.json](https://github.com/aws-observability/aws-otel-lambda/issues/99) and [resolve any CDK issues](https://github.com/aws-observability/aws-otel-lambda/issues/99))
3. Use the OpenTelemetry API library directly, no need to initialise it yourself as the layer does it for you. Just grab the tracer and start creating spans.
4. Create a custom config file pointing to Honeycomb, and use environment variable expansion to [keep the config file environment-agnostic and API keys](/writings/keeping-api-keys-and-environment-specifics-out-of-your-opentelemetry-config) out of your version control.
