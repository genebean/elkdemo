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

  $packages = ['htop', 'java-1.8.0-openjdk', 'logstash',]

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

  service { 'logstash':
    ensure  => running,
    enable  => true,
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

  $sslip = hiera('server::broker::ip')

  file { '/etc/pki/tls/openssl.cnf':
    ensure  => file,
    content => template('/vagrant/templates/openssl.cnf.erb'),
    notify  => Exec['create cert'],
  }

  exec { 'create cert':
    cwd         => '/etc/pki/tls',
    command     => '/usr/bin/openssl req -config /etc/pki/tls/openssl.cnf -x509 -days 3650 -batch -nodes -newkey rsa:2048 -keyout /vagrant/ssl/logstash-forwarder.key -out /vagrant/ssl/logstash-forwarder.crt',
    refreshonly => true,
    notify      => Service['logstash'],
  }

  yumrepo { 'logstash':
    ensure    => present,
    baseurl   => 'http://packages.elasticsearch.org/logstash/1.5/centos',
    enabled   => '1',
    gpgcheck  => '1',
    gpgkey    => 'http://packages.elasticsearch.org/GPG-KEY-elasticsearch',
  }

  $packages = ['htop', 'java-1.8.0-openjdk', 'logstash',]

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

  service { 'logstash':
    ensure  => running,
    enable  => true,
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

  $packages = ['htop', 'logstash-forwarder']

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

  file { '/vagrant/ssl/logstash-forwarder.crt':
    ensure => present,
    notify => Service['logstash-forwarder'],
  }

  file { '/etc/logstash-forwarder.conf':
    ensure  => file,
    owner   => 'logstash-forwarder',
    group   => 'logstash-forwarder',
    source  => 'file:/vagrant/logstash/logstash-forwarder.conf',
    notify  => Service['logstash-forwarder'],
    require => Package['logstash-forwarder'],
  }

  service { 'logstash-forwarder':
    ensure  => running,
    enable  => true,
    require => Package['logstash-forwarder'],
  }
}
