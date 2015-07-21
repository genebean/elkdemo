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
