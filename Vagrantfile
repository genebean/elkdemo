Vagrant.configure(2) do |config|
  config.vm.box = "genebean/centos6-puppet-64bit"

  config.vm.define "server" do |server|
    server.vm.provider "virtualbox" do |v|
      v.memory = 2048
    end

    server.vm.hostname = "server.localdomain"
    server.vm.network "private_network", ip: "172.28.128.100"

    server.vm.provision "shell", inline: "ln -sf /vagrant/hiera.yaml /etc/hiera.yaml"
    server.vm.provision "shell", inline: "ln -sf /vagrant/hiera.yaml /etc/puppet/hiera.yaml"
    server.vm.provision "puppet" do |puppet|
      puppet.hiera_config_path = "hiera.yaml"
    end

    server.vm.provision "shell", inline: "ln -sf /vagrant/logstash/server.conf /etc/logstash/conf.d/server.conf"

    server.vm.post_up_message = "Run ' sudo -u logstash /opt/logstash/bin/logstash -f /etc/logstash/conf.d/server.conf ' to test logstash"


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

    broker.vm.provision :reload

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
