---
layout: post
title: 'InfluxDB Kapacitor subscription errors'
date: 2017-03-29
---

    Post http://kapacitor.default:9092/write?consistency=&db=telegraf&precision=ns&rp=autogen: dial tcp: lookup kapacitor.default on 100.1.1.1:53: no such host service=subscriber

If you're seeing something like this error in your [InfluxDB](https://github.com/influxdata/influxdb) logs, and don't know what it means: [Kapacitor](https://github.com/influxdata/kapacitor) has created one or more subscriptions in your InfluxDB database, and InfluxDB is trying to POST to the Kapacitor endpoint; however, Kapacitor is unreachable. Kapacitor might be unreachable because it's down, or you have a network partition or other connectivity issue, or in my case you've actually just destroyed your Kapacitor instance.

<!-- more -->

To fix this error, you need to remove the subscriptions; you can remove subscriptions by issuing a few commands to InfluxDB via your favourite interface (for me, it's `exec` into a container and running the `influx` cli tool, but you can also use the API).

First, find the subscription(s) you need to remove.

    SHOW SUBSCRIPTIONS

    name: telegraf
    retention_policy name          mode destinations
    ---------------- ----          ---- ------------
    autogen          kapacitor-abc ANY  [http://kapacitor.default:9092]

Then just drop the subscription (you might need to drop a few, if you have multiple databases).

    DROP SUBSCRIPTION kapacitor-abc ON telegraf.autogen

The format of the command is: `DROP SUBSCRIPTION <subscription> ON <database>.<retention_policy>`.

That's it, the error should stop occurring now. If you destroy a Kapacitor instance, remember to remove it's subscriptions until there's resolution on [subscription cleanups](https://github.com/influxdata/kapacitor/issues/870).
