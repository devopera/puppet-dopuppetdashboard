class dopuppetdashboard (

  # class arguments
  # ---------------
  # setup defaults

  $user = 'web',
  $group_name = 'www-data',
  $port = 8080,

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
  package { ['rubygems', 'rubygem-rake', 'ruby-mysql']:
    ensure => present,
  }->
  package { 'puppet-dashboard' :
    ensure => present,
  }
  
  # tell dashboard not to create a user/group
  include 'dashboard::params'
  User <| title == "${dashboard::params::dashboard_user}" |> {
    noop => true,
  }
  Group <| title == "${dashboard::params::dashboard_group}" |> {
    noop => true,
  }
  
  # install dashboard
  class { 'dashboard':
    dashboard_port => $port,
    dashboard_user => $user,
    dashboard_group => $group,
  }

  # if we've got a message of the day, include it
  @domotd::register { "Puppet-Dashboard(${port})" : }

}
