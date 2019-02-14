# Class splunk::forwarder
#
class splunk::forwarder(
  String $server                     = $::splunk::params::server,
  String $version                    = $::splunk::params::version,
  String $package_name               = $::splunk::params::forwarder_package_name,
  String $package_ensure             = $::splunk::params::forwarder_package_ensure,
  String $staging_subdir             = $::splunk::params::staging_subdir,
  String $path_delimiter             = $::splunk::params::path_delimiter,
  String $forwarder_package_src      = $::splunk::params::forwarder_package_src,
  Optional[String] $package_provider = $::splunk::params::package_provider,
  Boolean $manage_package_source     = false,
  Optional[String] $package_source   = undef,
  String $splunk_user                = $::splunk::params::splunk_user,
  String $forwarder_homedir          = $::splunk::params::forwarder_homedir,
  String $forwarder_confdir          = $::splunk::params::forwarder_confdir,
  String $service_name               = $::splunk::params::forwarder_service,
  String $service_file               = $::splunk::params::forwarder_service_file,
  Boolean $boot_start                = $::splunk::params::boot_start,
  Boolean $use_default_config        = true,
  String $splunkd_listen             = '127.0.0.1',
  Stdlib::Port $splunkd_port         = $::splunk::params::splunkd_port,
  Stdlib::Port $logging_port         = $::splunk::params::logging_port,
  Boolean $purge_deploymentclient    = false,
  Boolean $purge_outputs             = false,
  Boolean $purge_inputs              = false,
  Boolean $purge_props               = false,
  Boolean $purge_transforms          = false,
  Boolean $purge_web                 = false,
  Hash $forwarder_output             = $::splunk::params::forwarder_output,
  Hash $forwarder_input              = $::splunk::params::forwarder_input,
  Boolean $manage_password           = $::splunk::params::manage_password,
  String $password_config_file       = $::splunk::params::forwarder_password_config_file,
  String $password_content           = $::splunk::params::password_content,
  String $secret_file                = $::splunk::params::forwarder_secret_file,
  String $secret                     = $::splunk::params::secret,
  Hash $addons                       = {},
) inherits ::splunk {

  if (defined(Class['splunk::enterprise'])) {
    fail('Splunk Universal Forwarder provides a subset of Splunk Enterprise capabilities, and has potentially conflicting resources when included with Splunk Enterprise on the same node.  Do not include splunk::forwarder on the same node as splunk::enterprise.  Configure Splunk Enterprise to meet your forwarding needs.'
    )
  }

  include '::splunk::forwarder::install'
  include '::splunk::forwarder::config'
  include '::splunk::forwarder::service'

  Class['::splunk::forwarder::install']
  -> Class['::splunk::forwarder::config']
  ~> Class['::splunk::forwarder::service']

  Splunk_config['splunk'] {
    forwarder_confdir                => $forwarder_confdir,
    purge_forwarder_deploymentclient => $purge_deploymentclient,
    purge_forwarder_outputs          => $purge_outputs,
    purge_forwarder_inputs           => $purge_inputs,
    purge_forwarder_props            => $purge_props,
    purge_forwarder_transforms       => $purge_transforms,
    purge_forwarder_web              => $purge_web,
  }

}
