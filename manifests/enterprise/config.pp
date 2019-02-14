# Class splunk::enterprise::config
#
class splunk::enterprise::config(
){

  if $::splunk::enterprise::manage_password {
    file { $::splunk::enterprise::password_config_file:
      ensure  => file,
      owner   => $::splunk::enterprise::splunk_user,
      group   => $::splunk::enterprise::splunk_user,
      content => $::splunk::enterprise::password_content,
    }

    file { $::splunk::enterprise::secret_file:
      ensure  => file,
      owner   => $::splunk::enterprise::splunk_user,
      group   => $::splunk::enterprise::splunk_user,
      content => $::splunk::enterprise::secret,
    }
  }

  # Remove init.d file if the service provider is systemd
  if $facts['service_provider'] == 'systemd' and versioncmp($::splunk::enterprise::version, '7.2.2') >= 0 {
    file { '/etc/init.d/splunk':
      ensure => 'absent',
    }
  }

  if $facts['virtual'] == 'docker' {
    ini_setting { 'OPTIMISTIC_ABOUT_FILE_LOCKING':
      ensure  => present,
      section => '',
      setting => 'OPTIMISTIC_ABOUT_FILE_LOCKING',
      value   => '1',
      path    => "${::splunk::enterprise::enterprise_homedir}/etc/splunk-launch.conf",
    }
  }

  file { ["${::splunk::enterprise::enterprise_homedir}/etc/system/local/alert_actions.conf",
          "${::splunk::enterprise::enterprise_homedir}/etc/system/local/authentication.conf",
          "${::splunk::enterprise::enterprise_homedir}/etc/system/local/authorize.conf",
          "${::splunk::enterprise::enterprise_homedir}/etc/system/local/deploymentclient.conf",
          "${::splunk::enterprise::enterprise_homedir}/etc/system/local/distsearch.conf",
          "${::splunk::enterprise::enterprise_homedir}/etc/system/local/indexes.conf",
          "${::splunk::enterprise::enterprise_homedir}/etc/system/local/inputs.conf",
          "${::splunk::enterprise::enterprise_homedir}/etc/system/local/limits.conf",
          "${::splunk::enterprise::enterprise_homedir}/etc/system/local/outputs.conf",
          "${::splunk::enterprise::enterprise_homedir}/etc/system/local/props.conf",
          "${::splunk::enterprise::enterprise_homedir}/etc/system/local/server.conf",
          "${::splunk::enterprise::enterprise_homedir}/etc/system/local/serverclass.conf",
          "${::splunk::enterprise::enterprise_homedir}/etc/system/local/transforms.conf",
          "${::splunk::enterprise::enterprise_homedir}/etc/system/local/ui-prefs.conf",
          "${::splunk::enterprise::enterprise_homedir}/etc/system/local/web.conf",
          "${::splunk::enterprise::enterprise_homedir}/etc/system/metadata/local.meta"]:
    ensure => file,
    tag    => 'splunk_enterprise',
    owner  => $::splunk::enterprise::splunk_user,
    group  => $::splunk::enterprise::splunk_user,
    mode   => '0600',
  }

  if $::splunk::enterprise::use_default_config {
    splunk_input { 'default_host':
      section => 'default',
      setting => 'host',
      value   => $::splunk::enterprise::input_default_host,
      tag     => 'splunk_server',
    }
    splunk_input { 'default_splunktcp':
      section => "splunktcp://:${::splunk::enterprise::logging_port}",
      setting => 'connection_host',
      value   => $::splunk::enterprise::input_connection_host,
      tag     => 'splunk_server',
    }
    splunk_web { 'splunk_server_splunkd_port':
      section => 'settings',
      setting => 'mgmtHostPort',
      value   => "${::splunk::enterprise::splunkd_listen}:${::splunk::enterprise::splunkd_port}",
      tag     => 'splunk_server',
    }
    splunk_web { 'splunk_server_web_port':
      section => 'settings',
      setting => 'httpport',
      value   => $::splunk::enterprise::web_httpport,
      tag     => 'splunk_server',
    }
  }

  File <| tag == 'splunk_enterprise' |>
  -> Splunk_alert_actions    <| tag == 'splunk_enterprise' |>
  ~> Class['::splunk::enterprise::service']

  File <| tag == 'splunk_enterprise' |>
  -> Splunk_authentication   <| tag == 'splunk_enterprise' |>
  ~> Class['::splunk::enterprise::service']

  File <| tag == 'splunk_enterprise' |>
  -> Splunk_authorize        <| tag == 'splunk_enterprise' |>
  ~> Class['::splunk::enterprise::service']

  File <| tag == 'splunk_enterprise' |>
  -> Splunk_deploymentclient <| tag == 'splunk_enterprise' |>
  ~> Class['::splunk::enterprise::service']

  File <| tag == 'splunk_enterprise' |>
  -> Splunk_distsearch       <| tag == 'splunk_enterprise' |>
  ~> Class['::splunk::enterprise::service']

  File <| tag == 'splunk_enterprise' |>
  -> Splunk_indexes          <| tag == 'splunk_enterprise' |>
  ~> Class['::splunk::enterprise::service']

  File <| tag == 'splunk_enterprise' |>
  -> Splunk_input            <| tag == 'splunk_enterprise' |>
  ~> Class['::splunk::enterprise::service']

  File <| tag == 'splunk_enterprise' |>
  -> Splunk_limits           <| tag == 'splunk_enterprise' |>
  ~> Class['::splunk::enterprise::service']

  File <| tag == 'splunk_enterprise' |>
  -> Splunk_output           <| tag == 'splunk_enterprise' |>
  ~> Class['::splunk::enterprise::service']

  File <| tag == 'splunk_enterprise' |>
  -> Splunk_props            <| tag == 'splunk_enterprise' |>
  ~> Class['::splunk::enterprise::service']

  File <| tag == 'splunk_enterprise' |>
  -> Splunk_server           <| tag == 'splunk_enterprise' |>
  ~> Class['::splunk::enterprise::service']

  File <| tag == 'splunk_enterprise' |>
  -> Splunk_serverclass      <| tag == 'splunk_enterprise' |>
  ~> Class['::splunk::enterprise::service']

  File <| tag == 'splunk_enterprise' |>
  -> Splunk_transforms       <| tag == 'splunk_enterprise' |>
  ~> Class['::splunk::enterprise::service']

  File <| tag == 'splunk_enterprise' |>
  -> Splunk_uiprefs          <| tag == 'splunk_enterprise' |>
  ~> Class['::splunk::enterprise::service']

  File <| tag == 'splunk_enterprise' |>
  -> Splunk_web              <| tag == 'splunk_enterprise' |>
  ~> Class['::splunk::enterprise::service']

}
