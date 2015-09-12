Vagrant.configure(2) do |config|
  config.vm.box = "genebean/centos6-puppet-64bit"

  if Vagrant.has_plugin?("vagrant-cachier")
    # Configure cached packages to be shared between instances of the same base box.
    # More info on http://fgrehm.viewdocs.io/vagrant-cachier/usage
    config.cache.scope = :box
  end

  config.vm.define "server" do |server|
    server.vm.provider "virtualbox" do |v|
      v.memory = 2048
    end

    server.vm.hostname = "server.localdomain"
    server.vm.network "private_network", ip: "172.28.128.100"
    server.vm.network "forwarded_port", guest: 9200, host: 9200
    server.vm.network "forwarded_port", guest: 5601, host: 5601

    server.vm.provision "shell", inline: "ln -sf /vagrant/hiera.yaml /etc/hiera.yaml"
    server.vm.provision "shell", inline: "ln -sf /vagrant/hiera.yaml /etc/puppet/hiera.yaml"
    server.vm.provision "shell", inline: "puppet module install elasticsearch-elasticsearch"
    server.vm.provision "shell", inline: "puppet module install lesaux-kibana4"
    server.vm.provision "puppet" do |puppet|
      puppet.hiera_config_path = "hiera.yaml"
    end

    server.vm.provision "shell", inline: "ln -sf /vagrant/logstash/server.conf /etc/logstash/conf.d/server.conf"
    server.vm.provision "shell", inline: "service logstash restart"

    server.vm.post_up_message = "Kibana 4 should be available at http://localhost:5601"


  end

  config.vm.define "broker" do |broker|
    broker.vm.hostname = "broker.localdomain"
    broker.vm.network "private_network", ip: "172.28.128.101"

    broker.vm.provision "shell", inline: "ln -sf /vagrant/ssl/logstash-forwarder.crt /etc/pki/tls/certs/logstash-forwarder.crt"
    broker.vm.provision "shell", inline: "ln -sf /vagrant/ssl/logstash-forwarder.key /etc/pki/tls/private/logstash-forwarder.key"

    broker.vm.provision "shell", inline: "ln -sf /vagrant/hiera.yaml /etc/hiera.yaml"
    broker.vm.provision "shell", inline: "ln -sf /vagrant/hiera.yaml /etc/puppet/hiera.yaml"
    broker.vm.provision "shell", inline: "puppet module install dwerder-redis"
    broker.vm.provision "puppet" do |puppet|
      puppet.hiera_config_path = "hiera.yaml"
    end

    broker.vm.provision "shell", inline: "ln -sf /vagrant/logstash/broker.conf /etc/logstash/conf.d/broker.conf"
    broker.vm.provision "shell", inline: "service logstash restart"

    # this is a workaround for a bug listed at https://github.com/elastic/logstash/issues/3776 on logstash-1.5.4
    broker.vm.provision "shell", inline: "/opt/logstash/bin/plugin update logstash-input-lumberjack"
    broker.vm.provision "shell", inline: "service logstash restart"

  end

  config.vm.define "client" do |client|
    client.vm.hostname = "client.localdomain"
    client.vm.network "private_network", ip: "172.28.128.102"

    client.vm.provision "shell", inline: "ln -sf /vagrant/ssl/logstash-forwarder.crt /etc/pki/tls/certs/logstash-forwarder.crt"

    client.vm.provision "shell", inline: "ln -sf /vagrant/hiera.yaml /etc/hiera.yaml"
    client.vm.provision "shell", inline: "ln -sf /vagrant/hiera.yaml /etc/puppet/hiera.yaml"
    client.vm.provision "puppet" do |puppet|
      puppet.hiera_config_path = "hiera.yaml"
    end

  end

end
