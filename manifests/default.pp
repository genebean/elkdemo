Package {
  allow_virtual => false,
}

node 'server' {
  notice("Running code in /vagrant/manifests/default.pp's server node block")

  yumrepo { 'logstash':
    ensure    => present,
    baseurl   => 'http://packages.elasticsearch.org/logstash/1.5/centos',
    enabled   => '1',
    gpgcheck  => '1',
    gpgkey    => 'http://packages.elasticsearch.org/GPG-KEY-elasticsearch',
  }

  $packages = ['java-1.8.0-openjdk', 'logstash',]

  package { $packages:
    ensure  => latest,
    require => Yumrepo['logstash'],
  }

  $logs = [ '/var/log/messages']
  file { $logs:
    ensure  => file,
    group   => 'logstash',
    mode    => '644',
    owner   => 'root',
    require => Package['logstash'],
  }
}

node 'broker' {
  notice("Running code in /vagrant/manifests/default.pp's broker node block")

  include ::redis::install

  $redis_instances = hiera_hash('redis_instances', undef)

  if ($redis_instances) {
    create_resources('::redis::server', $redis_instances)
  }

  yumrepo { 'logstash':
    ensure    => present,
    baseurl   => 'http://packages.elasticsearch.org/logstash/1.5/centos',
    enabled   => '1',
    gpgcheck  => '1',
    gpgkey    => 'http://packages.elasticsearch.org/GPG-KEY-elasticsearch',
  }

  $packages = ['java-1.8.0-openjdk', 'logstash',]

  package { $packages:
    ensure  => latest,
    require => Yumrepo['logstash'],
  }

  $logs = [ '/var/log/messages']
  file { $logs:
    ensure  => file,
    group   => 'logstash',
    mode    => '644',
    owner   => 'root',
    require => Package['logstash'],
  }
}

node 'client' {
  notice("Running code in /vagrant/manifests/default.pp's client node block")

  yumrepo { 'logstash-forwarder':
    ensure    => present,
    baseurl   => 'http://packages.elasticsearch.org/logstashforwarder/centos',
    enabled   => '1',
    gpgcheck  => '1',
    gpgkey    => 'http://packages.elasticsearch.org/GPG-KEY-elasticsearch',
  }

  $packages = ['logstash-forwarder']

  package { $packages:
    ensure  => latest,
    require => Yumrepo['logstash-forwarder'],
  }

  $logs = [ '/var/log/messages']
  file { $logs:
    ensure  => file,
    group   => 'logstash-forwarder',
    mode    => '644',
    owner   => 'root',
    require => Package['logstash-forwarder'],
  }
}
