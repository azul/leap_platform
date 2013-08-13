class site_couchdb {
  tag 'leap_service'

  $x509                   = hiera('x509')
  $key                    = $x509['key']
  $cert                   = $x509['cert']
  $ca                     = $x509['ca_cert']

  $couchdb_config         = hiera('couch')
  $couchdb_users          = $couchdb_config['users']
  $couchdb_admin          = $couchdb_users['admin']
  $couchdb_admin_pw       = $couchdb_admin['password']
  $couchdb_admin_salt     = $couchdb_admin['salt']


  $bigcouch_config        = $couchdb_config['bigcouch']
  $bigcouch_cookie        = $bigcouch_config['cookie']

  $ednp_port              = $bigcouch_config['ednp_port']

  class { 'couchdb':
    bigcouch        => true,
    admin_pw        => $couchdb_admin_pw,
    admin_salt      => $couchdb_admin_salt,
    bigcouch_cookie => $bigcouch_cookie,
    ednp_port       => $ednp_port
  }

  class { 'couchdb::bigcouch::package::cloudant': }

  Class ['couchdb::bigcouch::package::cloudant']
    -> Service ['couchdb']
    -> Class ['site_couchdb::bigcouch::add_nodes']
    -> Couchdb::Create_db['users']
    -> Couchdb::Create_db['tokens']
    -> Couchdb::Add_user['webapp']
    -> Couchdb::Add_user['soledad']

  class { 'site_couchdb::stunnel':
    key  => $key,
    cert => $cert,
    ca   => $ca
  }

  class { 'site_couchdb::bigcouch::add_nodes': }

  couchdb::query::setup { 'localhost':
    user  => 'admin',
    pw    => $couchdb_admin_pw,
  }

  # Populate couchdb
  create_resources(couchdb::add_user, $couchdb_users)

  couchdb::create_db { 'users':
    readers => "{ \"names\": [\"$couchdb_webapp_user\"], \"roles\": [] }"
  }

  couchdb::create_db { 'tokens':
    readers => "{ \"names\": [], \"roles\": [\"auth\"] }"
  }

  include site_shorewall::couchdb
  include site_shorewall::couchdb::bigcouch
}
