# == Class: vms
#
# Full description of class vms here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { 'vms':
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2017 Your name here, unless otherwise noted.
#
class sol_vms {
zone { 'myserver':
ensure  => 'running',
name    => 'myserver',
iptype       => 'shared',
ip           => 'igb13001:10.10.1.18',
sysidcfg     => template('sol_vms/sysidcfg.erb'),
autoboot => 'true',
path    => '/zone/myserver',
realhostname  => 'myserver.isj.hd.edu.ro',
}







exec { 'puppet_agent':
path        => ['/usr/bin', '/usr/sbin'],
command => 'zlogin myserver svccfg import /var/opt/csw/svc/manifest/network/cswpuppetd.xml',
unless   => 'zlogin myserver svcs -a | grep -i puppet 2>/dev/null',
require    => Zone['myserver'],

}


file {'puppet_conf':
ensure  => 'present',
path => '/zone/myserver/root/etc/puppet/puppet.conf',
source => ["puppet:///modules/sol_vms/puppet.conf"],
require => [
             Zone['myserver'], 
             Exec['puppet_agent'],
],
}

file{'/etc/hosts':
ensure   => 'present',
path => '/zone/myserver/root/etc/hosts',
source => ["puppet:///modules/sol_vms/hosts"],
require    => Zone['myserver'],
}



exec { 'start_agent':
path        => ['/usr/bin', '/usr/sbin'],
command => 'zlogin myserver svcadm enable cswpuppetd',
unless   => 'zlogin myserver svcs -a | grep -i puppet | grep -i enabled 2>/dev/null',
require    => [
               Zone['myserver'],
               Exec['puppet_agent'],
],

}






}
