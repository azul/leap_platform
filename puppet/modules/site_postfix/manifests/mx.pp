class site_postfix::mx {

  $domain_hash         = hiera ('domain')
  $domain              = $domain_hash['full_suffix']
  $mx_hash             = hiera('mx')

  $root_mail_recipient = $mx_hash['contact']
  $postfix_smtp_listen = 'all'

  postfix::config {
    'mydestination':
      value => "\$myorigin, localhost, localhost.\$mydomain, ${domain}";
    'smtpd_recipient_restrictions':
      value => 'check_recipient_access hash:/etc/postfix/recipient,reject_unauth_destination';
    'mailbox_size_limit':
      value => '0';
    'home_mailbox':
      value => 'Maildir/';
    'virtual_alias_maps':
      value => 'hash:/etc/postfix/virtual';
  }

  postfix::hash { '/etc/postfix/virtual': }
  postfix::hash { '/etc/postfix/recipient': }

  # for now, accept all mail
  line {'deliver to vmail':
    file    => '/etc/postfix/recipient',
    line    => "@${domain} vmail",
    notify  => Exec['generate /etc/postfix/recipient.db'],
    require => Package['postfix'],
  }

  postfix::virtual { "@${domain}": destination => 'vmail'; }
  #postfix::mailalias { 'vmail': recipient => 'vmail' }

  user { 'vmail':
    ensure     => present,
    comment    => 'Leap Mailspool',
    home       => '/var/mail/vmail',
    shell      => '/bin/false',
    managehome => true,
  }

  class { 'postfix':
    root_mail_recipient => $root_mail_recipient,
    smtp_listen         => 'all'
  }
}
