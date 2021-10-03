---
layout: post
title: Keeping API keys and environment-specifics out of your OpenTelemetry config
date: 2021-10-03
published: false
---

When I was setting up [Honeycomb](https://www.honeycomb.io/) with my Lambda functions there was something that bothered me: the [OpenTelemetry](https://opentelemetry.io/) config file contained my API keys and environment-specific details. I needed to keep my bundle environment-agnostic, and I really didn't want to be committing API keys to version control. You can read more about the adventure itself in [my other post](/writings/getting-honeycomb-working-with-my-aws-lambda-functions), or continue reading this post for my solution.

OpenTelemetry supports environment variables to override parts of the config file, such as `OTEL_EXPORTER_OTLP_ENDPOINT` and `OTEL_EXPORTER_OTLP_HEADERS`. In theory, you could use these to customise your config file. Unfortunately, the AWS Distro for OpenTelemetry on AWS Lambda doesn't seem to honour these variables.

Fortunately, the [OpenTelemetry Collector documentation](https://opentelemetry.io/docs/collector/configuration) has a section on [environment variables](https://opentelemetry.io/docs/collector/configuration/#configuration-environment-variables) which says "the use and expansion of environment variables is supported in the Collector configuration".

If you update your config file to reference other environment variables, you can keep the config file environment-agnostic and remove the need to embed API keys. For example, with Honeycomb you can configure your exporter like so:

```yaml
exporters:
  otlp:
    endpoint: "api.honeycomb.io:443"
    headers:
      "x-honeycomb-team": "$HONEYCOMB_TEAM_KEY"
      "x-honeycomb-dataset": "$HONEYCOMB_DATASET$"
```

I'd prefer if I didn't have to store a sensitive key in an environment variable either, but it's a step in the right direction and is better than committing it to version control. There's an [open design document on external secret management in OpenTelemetry](https://github.com/open-telemetry/opentelemetry-collector/issues/2469) which I'll be keeping an eye on. I'd be much happier if I could just reference an AWS Secrets Manager secret by name in the config, one can dream. Until then, I think this is the best I can do.