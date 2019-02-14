#
# Defined type: splunk::addon
#
# This define sets up a TA (Technology Addon) for Splunk.  It (optionally)
# installed a package, and configures input forwarders in
# $SPLUNK_HOME/etc/apps/<app name>/local/inputs.conf
#
# Examples
#
# splunk::addon { 'search':
#   package_manage => false,
# }
#
# splunk::addon::input { 'monitor:///var/log/messages':
#   attributes => {
#     'index' => 'server_t',
#   },
# }
#
# Alternatively you can feed inputs directly into splunk::addon using the
# inputs parameter (useful if you are configuring from Hiera)
#
#
# splunk::addon { 'search':
#   package_manage => false,
#   inputs          => {
#     'monitor:///var/log/messages' => {
#       'attributes' => {
#         'index' => 'server_t',
#       }
#     }
#   }
# }
#

define splunk::addon (
  $splunk_home                   = undef,
  $package_manage                = true,
  Optional[String] $package_name = undef,
  $inputs                        = {},
) {

  include '::splunk::params'

  if !defined($splunk_home) {
    $_splunk_home = $::splunk::params::forwarder_homedir
  }
  else {
    $_splunk_home = $splunk_home
  }

  if $package_manage {
    package { $package_name:
      ensure => installed,
      before => File["${_splunk_home}/etc/apps/${name}/local"],
    }
  }

  file { "${_splunk_home}/etc/apps/${name}/local":
    ensure => directory,
  }

  if $inputs {
    concat { "splunk::addon::inputs_${name}":
      path    => "${_splunk_home}/etc/apps/${name}/local/inputs.conf",
      require => File["${_splunk_home}/etc/apps/${name}/local"],
    }

    create_resources('splunk::addon::input', $inputs, {'addon' =>  $name })
  }

}

