# Class: mysqlenc
#
#
class ca_autosign (
  $enable = true,
  $dbuser = 'encrw',
  $dbpass = 'rwsecret',
  $dbhost = 'localhost',
  $dbname = 'encdb',
  $install_dir = '/opt/puppet/bin',
  $manage_deps = false,
) {
  if $manage_deps {
    package { ['gcc','mysql-devel']:
      ensure => present,
    }
    package { ['mysql2','syslog_logger']:
      ensure   => present,
      provider => pe_gem,
    }
  }

  file { "${install_dir}/mysql-cert-autosign.rb":
    ensure => file,
    source => "puppet:///modules/${module_name}/mysql-cert-autosign.rb",
    mode   => '0755',
    owner  => 'pe-puppet',
    group  => 'pe-puppet',
    require => File["${install_dir}/mysql-cert-autosign.yaml"],
  }
  file { "${install_dir}/mysql-cert-autosign.yaml":
    ensure  => file,
    content => template("${module_name}/mysql-cert-autosign.yaml.erb"),
    mode    => '0600',
    owner   => 'pe-puppet',
    group   => 'pe-puppet',
  }

  ini_setting { 'Puppet CA Autosign':
    ensure  => present,
    path    => "${::pe::puppetmaster::confdir}/puppet.conf",
    section => "master",
    setting => "autosign",
    value   => "${install_dir}/mysql-cert-autosign.rb",
    require => File["${install_dir}/mysql-cert-autosign.rb"],
    notify  => Service['pe-httpd'],
  }

}