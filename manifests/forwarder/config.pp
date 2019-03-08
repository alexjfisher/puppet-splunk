# Class splunk::forwarder::config
#
class splunk::forwarder::config {

  if $splunk::forwarder::manage_password {
    file { $splunk::forwarder::password_config_file:
      ensure  => file,
      owner   => $splunk::forwarder::splunk_user,
      group   => $splunk::forwarder::splunk_user,
      content => $splunk::forwarder::password_content,
    }

    file { $splunk::forwarder::secret_file:
      ensure  => file,
      owner   => $splunk::forwarder::splunk_user,
      group   => $splunk::forwarder::splunk_user,
      content => $splunk::forwarder::secret,
    }
  }

  $_forwarder_file_mode = $facts['kernel'] ? {
    'windows' => undef,
    default   => '0600',
  }

  file { ["${splunk::forwarder::forwarder_homedir}/etc/system/local/deploymentclient.conf",
          "${splunk::forwarder::forwarder_homedir}/etc/system/local/outputs.conf",
          "${splunk::forwarder::forwarder_homedir}/etc/system/local/inputs.conf",
          "${splunk::forwarder::forwarder_homedir}/etc/system/local/props.conf",
          "${splunk::forwarder::forwarder_homedir}/etc/system/local/transforms.conf",
          "${splunk::forwarder::forwarder_homedir}/etc/system/local/web.conf",
          "${splunk::forwarder::forwarder_homedir}/etc/system/local/limits.conf",
          "${splunk::forwarder::forwarder_homedir}/etc/system/local/server.conf"]:
    ensure => file,
    tag    => 'splunk_forwarder',
    owner  => $splunk::forwarder::splunk_user,
    group  => $splunk::forwarder::splunk_user,
    mode   => $_forwarder_file_mode,
  }

  if $splunk::forwarder::use_default_config {
    splunkforwarder_web { 'forwarder_splunkd_port':
      section => 'settings',
      setting => 'mgmtHostPort',
      value   => "${splunk::forwarder::splunkd_listen}:${splunk::forwarder::splunkd_port}",
      tag     => 'splunk_forwarder',
    }
  }

  # Declare addons
  create_resources('splunk::addon', $splunk::forwarder::addons)

  # Declare inputs and outputs specific to the forwarder profile
  $_tag_resources = { tag => 'splunk_forwarder' }
  if $splunk::forwarder::forwarder_input {
    create_resources( 'splunkforwarder_input', $splunk::forwarder::forwarder_input, $_tag_resources)
  }
  if $splunk::forwarder::forwarder_output {
    create_resources( 'splunkforwarder_output', $splunk::forwarder::forwarder_output, $_tag_resources)
  }

  File <| tag == 'splunk_forwarder' |>
  -> Splunkforwarder_deploymentclient <| tag == 'splunk_forwarder' |>
  ~> Class['splunk::forwarder::service']

  File <| tag == 'splunk_forwarder' |>
  -> Splunkforwarder_input            <| tag == 'splunk_forwarder' |>
  ~> Class['splunk::forwarder::service']

  File <| tag == 'splunk_forwarder' |>
  -> Splunkforwarder_output           <| tag == 'splunk_forwarder' |>
  ~> Class['splunk::forwarder::service']

  File <| tag == 'splunk_forwarder' |>
  -> Splunkforwarder_props            <| tag == 'splunk_forwarder' |>
  ~> Class['splunk::forwarder::service']

  File <| tag == 'splunk_forwarder' |>
  -> Splunkforwarder_transforms       <| tag == 'splunk_forwarder' |>
  ~> Class['splunk::forwarder::service']

  File <| tag == 'splunk_forwarder' |>
  -> Splunkforwarder_web              <| tag == 'splunk_forwarder' |>
  ~> Class['splunk::forwarder::service']

  File <| tag == 'splunk_forwarder' |>
  -> Splunkforwarder_limits           <| tag == 'splunk_forwarder' |>
  ~> Class['splunk::forwarder::service']

  File <| tag == 'splunk_forwarder' |>
  -> Splunkforwarder_server           <| tag == 'splunk_forwarder' |>
  ~> Class['splunk::forwarder::service']

}
