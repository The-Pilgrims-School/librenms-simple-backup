# Supports a very simple backup process, stopping the containers, dumping the files and
# starting the containers again.
class librenmssimplebackup {

  package { 'jq':
    ensure => latest
  }

  # folder to store backups
  file { '/var/backups/librenms':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0750'
  }

  # backup script
  file { '/usr/local/bin/librenms-simple-backup':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => ('puppet:///modules/librenmssimplebackup/librenms-simple-backup.sh')
  }

  # file { '/etc/cron.d/librenms-simple-backup':
  #   ensure => file,
  #   owner  => 'root',
  #   group  => 'root',
  #   mode   => '0644',
  #   source => ('puppet:///modules/librenmssimplebackup/librenms-simple-backup.cron')
  # }

  file { '/etc/cron.daily/librenms-simple-backup':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => ('puppet:///modules/librenmssimplebackup/librenms-simple-backup.sh')   
  }

}
