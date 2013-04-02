# set a default exec path
Exec { path => '/usr/bin:/usr/sbin/:/bin:/sbin:/usr/local/bin:/usr/local/sbin' }

$custom_key_dir = 'puppet:///modules/site_apt/keys'

# parse services for host
$services=hiera_array('services')
notice("Services for ${fqdn}: ${services}")

# make sure apt is updated before any packages are installed
include apt::update
Package { require => Exec['apt_updated'] }

include stdlib

import 'common'
include site_config::default
include site_config::slow


# configure eip
if 'openvpn' in $services {
  include site_openvpn
}

if 'couchdb' in $services {
  class {'site_couchdb':
    bigcouch => true
  }
}

if 'webapp' in $services {
  include site_webapp
}

if 'ca' in $services {
  include site_ca_daemon
}

if 'monitor' in $services {
  include site_nagios
}

if 'tor' in $services {
  include site_tor
}

if 'ipsec' in $services {
  include site_strongswan
}
