# Class splunk::enterprise
#
class splunk::enterprise (
  String[1] $version                         = $splunk::params::version,
  String[1] $package_name                    = $splunk::params::enterprise_package_name,
  String[1] $package_ensure                  = $splunk::params::enterprise_package_ensure,
  String $staging_subdir                     = $splunk::params::staging_subdir,
  String[1] $path_delimiter                  = $splunk::params::path_delimiter,
  String[1] $enterprise_package_src          = $splunk::params::enterprise_package_src,
  Optional[String] $package_provider         = $splunk::params::package_provider,
  Boolean $manage_package_source             = true,
  Optional[String] $package_source           = undef,
  Array[String] $install_options             = $splunk::params::enterprise_install_options,
  String[1] $splunk_user                     = $splunk::params::splunk_user,
  Stdlib::Absolutepath $enterprise_homedir   = $splunk::params::enterprise_homedir,
  Stdlib::Absolutepath $enterprise_confdir   = $splunk::params::enterprise_confdir,
  String[1] $service_name                    = $splunk::params::enterprise_service,
  Stdlib::Absolutepath $service_file         = $splunk::params::enterprise_service_file,
  Boolean $boot_start                        = $splunk::params::boot_start,
  Boolean $use_default_config                = true,
  String[1] $input_default_host              = $facts['fqdn'],
  String[1] $input_connection_host           = 'dns',
  Stdlib::IP::Address $splunkd_listen        = '127.0.0.1',
  Stdlib::Port $splunkd_port                 = $splunk::params::splunkd_port,
  Stdlib::Port $logging_port                 = $splunk::params::logging_port,
  Stdlib::Port $web_httpport                 = 8000,
  Boolean $purge_alert_actions               = false,
  Boolean $purge_authentication              = false,
  Boolean $purge_authorize                   = false,
  Boolean $purge_deploymentclient            = false,
  Boolean $purge_distsearch                  = false,
  Boolean $purge_indexes                     = false,
  Boolean $purge_inputs                      = false,
  Boolean $purge_limits                      = false,
  Boolean $purge_outputs                     = false,
  Boolean $purge_props                       = false,
  Boolean $purge_server                      = false,
  Boolean $purge_serverclass                 = false,
  Boolean $purge_transforms                  = false,
  Boolean $purge_uiprefs                     = false,
  Boolean $purge_web                         = false,
  Boolean $manage_password                   = $splunk::params::manage_password,
  Stdlib::Absolutepath $password_config_file = $splunk::params::enterprise_password_config_file,
  String $password_content                   = $splunk::params::password_content,
  Stdlib::Absolutepath $secret_file          = $splunk::params::enterprise_secret_file,
  String $secret                             = $splunk::params::secret,

) inherits splunk {

  if (defined(Class['splunk::forwarder'])) {
    fail('Splunk Universal Forwarder provides a subset of Splunk Enterprise capabilities, and has potentially conflicting resources when included with Splunk Enterprise on the same node.  Do not include splunk::forwarder on the same node as splunk::enterprise.  Configure Splunk Enterprise to meet your forwarding needs.'
    )
  }

  include 'splunk::enterprise::install'
  include 'splunk::enterprise::config'
  include 'splunk::enterprise::service'

  Class['splunk::enterprise::install']
  -> Class['splunk::enterprise::config']
  ~> Class['splunk::enterprise::service']

  # Purge resources if option set
  Splunk_config['splunk'] {
    purge_alert_actions    => $purge_alert_actions,
    purge_authentication   => $purge_authentication,
    purge_authorize        => $purge_authorize,
    purge_deploymentclient => $purge_deploymentclient,
    purge_distsearch       => $purge_distsearch,
    purge_indexes          => $purge_indexes,
    purge_inputs           => $purge_inputs,
    purge_limits           => $purge_limits,
    purge_outputs          => $purge_outputs,
    purge_props            => $purge_props,
    purge_server           => $purge_server,
    purge_serverclass      => $purge_serverclass,
    purge_transforms       => $purge_transforms,
    purge_uiprefs          => $purge_uiprefs,
    purge_web              => $purge_web
  }

}
