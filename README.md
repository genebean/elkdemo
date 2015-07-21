# ELK Demo

This repo is a demonstration of a 3 node ELK stack:
* server: runs Elasticsearch, Logstash, and Kibana. Logstash pulls from Redis
  on the broker vm and from /var/log/messages
* broker: runs Logstash and Redis. No filtering is done here. Inputs are setup
  for Logstash Forwarder (lumberjack), syslog via udp, NXLog(tcp json_lines),
  and /var/log/messages
* client: runs Logstash Forwarder and ships logs to the broker vm

## Dependency

As part of the setup the broker vm needs rebooting. This is handled by a Vagrant
plugin called "[Vagrant Reload](https://github.com/aidanns/vagrant-reload)."
If you don't have the plugin installed already just run the following:

```bash
$ vagrant plugin install vagrant-reload
```

As a byproduct of the type of setup this is, more memory is required than with
most Vagrant setups... server uses 2G and the others each use 1G for a total of
4G.

## Running the demo

To get started all you need to do is run

```bash
$ vagrant up
```

Once all machines are up you can go to the following URL's:
* Elasticsearch: http://localhost:9200
* kopf plugin to see info about this Elasticsearch setup:
  http://localhost:9200/_plugin/kopf/
* Kibana: http://localhost:5601

You can easily generate a bunch of log entries by running `yum -y upgrade`
on the client.

Both the broker and the server also log to stdout. By running

```bash
$ tail -f /var/log/logstash/logstash.stdout
```

you can see logs in Ruby format like this one:

```ruby
{
       "message" => "Jul 20 22:31:06 localhost yum[3791]: Updated: dracut-kernel-004-356.el6_6.3.noarch",
      "@version" => "1",
    "@timestamp" => "2015-07-21T02:31:13.196Z",
          "type" => "syslog",
          "tags" => [
        [0] "lumberjack",
        [1] "redis"
    ],
          "file" => "/var/log/messages",
          "host" => "client.localdomain",
        "offset" => "87573"
}
```
