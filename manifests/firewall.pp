class dopuppetdashboard::firewall (

  # class arguments
  # ---------------
  # setup defaults

  $port = 8080,

  # end of class arguments
  # ----------------------
  # begin class

) {

  @docommon::fireport { "0${port} Puppet Dashboard service":
    protocol => 'tcp',
    port     => $port,
  }

}
