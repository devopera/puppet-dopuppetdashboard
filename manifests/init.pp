class dopuppetdashboard (

  # class arguments
  # ---------------
  # setup defaults

  $user = 'web',
  $group_name = 'www-data',
  $port = 3000,
  $puppetserver = 'localhost',

  $db_host = 'localhost',
  $db_name = 'puppetdash',
  $db_user = 'puppetdash',
  $db_pass = 'x90si2j47fgw',

  # by default, open this port in the firewall
  $firewall = true,

  # end of class arguments
  # ----------------------
  # begin class

) {


  # open up firewall ports 
  if ($firewall) {
    class { 'dopuppetdashboard::firewall' :
      port => $port,
    }
  }

  # install required packages using OS package manager
  if ! defined(Package['rubygems']) {
    package { 'rubygems' :
      ensure => present,
      before => Anchor['dopuppetdashboard-deps-ready'],
    }
  }
  if ! defined(Package['rubygem-rake']) {
    package { 'rubygem-rake' : 
      ensure => present,
      before => Anchor['dopuppetdashboard-deps-ready'],
    }
  }
  if ! defined(Package['ruby-mysql']) {
    package { 'ruby-mysql' : 
      ensure => present,
      before => Anchor['dopuppetdashboard-deps-ready'],
    }
  }
  anchor { 'dopuppetdashboard-deps-ready' : }

  # install puppet dashboard package
  #if ! defined(Package['puppet-dashboard']) {
  #  package { 'puppet-dashboard' :
  #    ensure => present,
  #    require => Anchor['dopuppetdashboard-deps-ready'],
  #    before => Anchor['dopuppetdashboard-package-ready'],
  #  }
  #}
  #anchor { 'dopuppetdashboard-package-ready' : }

  mysql::db { "${db_name}":
    user     => $db_user,
    password => $db_pass,
    host     => $db_host,
    grant    => ['SELECT', 'UPDATE'],
  }->

  exec { 'puppetdashboard_dbmigrate':
    path      => '/usr/bin:/bin:/usr/sbin:/sbin',
    command   => 'rake RAILS_ENV=production gems:refresh_specs && rake RAILS_ENV=production db:migrate',
    cwd       => '/usr/share/puppet-dashboard/',
  }->
 
  # install dashboard
  class { 'puppetdashboard':
    db_host => $db_host,
    db_port => 3306,
    db_name => $db_name,
    db_user => $db_user,
    db_password => $db_pass,
    setup_mysql => false,
    ca_server => $puppetserver,
    inventory_server => $puppetserver,
    filebucket_server => $puppetserver,
    port => $port,
  }

  # if we've got a message of the day, include it
  @domotd::register { "Puppet-Dashboard(${port})" : }

}
