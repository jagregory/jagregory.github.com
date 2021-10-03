---
layout: post
title: Honeycomb and OpenTelemetry with AWS Lambda and Node.js (reference)
date: 2021-10-03
published: true
---

This is a condensed guide to how I configured AWS Lambda to work with
[Honeycomb](https://honeycomb.io) and [OpenTelemetry](https://opentelemetry.io).

<!-- more -->

I had a few struggles when getting [Honeycomb](https://www.honeycomb.io/) and [OpenTelemetry](https://opentelemetry.io/) working with my existing Node.js Lambda functions, which rely on automatic and manual instrumentation. You can read more about that [over here](/writings/getting-honeycomb-working-with-my-aws-lambda-functions) and the page you're on right now is the condensed version with my working solution.

## Step 1: Get auto-instrumentation working with your Lambda function

The first part is getting auto-instrumentation working with OpenTelemetry. This is pretty easy, although I did hit a couple of issues related to bundling.

Use the [Lambda Layer](https://aws-otel.github.io/docs/getting-started/lambda/lambda-js) provided by [AWS Distro for OpenTelemetry Lambda](https://aws-otel.github.io/docs/getting-started/lambda). Add the layer to your Lambda function and set an environment variable to enable OpenTelemetry. Invoke your function and you should see in your CloudWatch logs a heap of new logs from the OpenTelemetry Collector.

> Or if you're like me you'll hit a [known issue](https://github.com/aws-observability/aws-otel-lambda/issues/99) and have to tweak your bundling config, and [another one](https://github.com/aws-observability/aws-otel-lambda/issues/99) about CDK and esbuild.

At this point you have made no modifications to your application code and auto-instrumentation should be working. The traces will be sent to X-Ray by default, so next is to configure OpenTelemetry to send data to Honeycomb.

## Step 2: Customise your configuration to point to Honeycomb

To customise AWS Distro for OpenTelemetry you have to add your own config file to your Lambda functions and set an environment variable to tell OpenTelemetry to use your overriden config file. Read [custom configuration for the ADOT Collector on Lambda](https://aws-otel.github.io/docs/getting-started/lambda#custom-configuration-for-the-adot-collector-on-lambda) for more information. There's also [instructions for Honeycomb](https://aws-otel.github.io/docs/components/otlp-exporter#honeycomb) on the AWS Distro site.

If you redeploy your Lambda function now you should start seeing traces appear in Honeycomb.

At this point, I wasn't very happy with having API Keys and environment-specific information in the OpenTelemetry config file. If you're feeling like that, have a read of my [Keeping API keys and environment-specifics out of your OpenTelemetry config](/writings/keeping-api-keys-and-environment-specifics-out-of-your-opentelemetry-config) post.

## Step 3: Manual instrumentation support

Until now you haven't made any changes to your application code; however, if you want to create your own spans and add extra metadata to your traces you're going to need to add the OpenTelemetry libraries to your application.

This was a source of confusion for me. It wasn't clear how you were supposed to use the NodeSDK with the AWS Distro for OpenTelemetry Lambda Layer. The examples either demonstrated a non-Lambda Node setup (with clear application start and end hooks) or an auto-instrumented Lambda function.

After a bit of trial and error what I realised is: you don't need to initialise the OpenTelemetry SDK or configure any providers. The AWS Distro for OpenTelemetry Lambda Layer has done all the configuration and loaded the relevant libraries for you already. Instead, in your application code you can immediately start using the OpenTelemetry API.

Add `@opentelemetry/api` to your application and use the `context.active()` and `trace.getSpan` and `trace.setSpan` functions. No other configuration needed.

Scatter a few custom traces around your functions and redeploy. You should now start seeing these in Honeycomb too. Done.

## Conclusion

In hindsight there's not a lot involved in setting all this up, and it's quite impressive once I got over a few little hurdles.

The biggest challenge was that there's a _lot of documentation_, but nothing that fit exactly what I needed. There's documentation on AWS Distro for OpenTelemetry with Lambda, manual instrumentation of Node.js with OpenTelemetry, auto-instrumentation of Node.js lambdas etc... and it all overlaps, but nothing gave the full picture.
