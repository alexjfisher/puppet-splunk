# Class: splunk::params
#
# This class takes a small number of arguments (can be set through Hiera) and
# generates sane default values installation media names and locations. Default
# ports can also be specified here. This is a parameters class, and contributes
# no resources to the graph. Rather, it only sets values for parameters to be
# consumed by child classes.
#
# @param version
#   The version of Splunk to install. This will be in the form x.y.z; e.g.
#   "4.3.2".
#
# @param build
#   Splunk packages are typically named based on the platform, architecture,
#   version, and build. Puppet can determine the platform information
#   automatically but a build number must be supplied in order to correctly
#   construct the path to the packages. A build number will be six digits;
#   e.g. "123586".
#
# @param splunkd_port
#   The splunkd port. Used as a default for both splunk and splunk::forwarder.
#
# @param logging_port
#   The port on which to send logs, and listen for logs. Used as a default for
#   splunk and splunk::forwarder.
#
# @param server
#   Optional fqdn or IP of the Splunk Enterprise server.  Used for setting up
#   the default TCP output and input.
#
# @param splunk_user
#   The user that splunk runs as.
#
# @param src_root
#   The root URL at which to find the splunk packages. The sane-default logic
#   assumes that the packages are located under this URL in the same way that
#   they are placed on download.splunk.com. The URL can be any protocol that
#   the puppet/archive module supports. This includes both puppet:// and
#   http://.  The expected directory structure is:
#
#
#     $root_url/
#     └── products/
#         ├── universalforwarder/
#         │   └── releases/
#         |       └── $version/
#         |           └── $platform/
#         |               └── splunkforwarder-${version}-${build}-${additl}
#         └── splunk/
#             └── releases/
#                 └── $version/
#                     └── $platform/
#                         └── splunk-${version}-${build}-${additl}
#
#
#   A semi-populated example src_root then contain:
#
#     $root_url/
#     └── products/
#         ├── universalforwarder/
#         │   └── releases/
#         |       └── 7.2.4.2/
#         |           ├── linux/
#         |           |   ├── splunkforwarder-7.2.4.2-fb30470262e3-linux-2.6-amd64.deb
#         |           |   ├── splunkforwarder-7.2.4.2-fb30470262e3-linux-2.6-intel.deb
#         |           |   └── splunkforwarder-7.2.4.2-fb30470262e3-linux-2.6-x86_64.rpm
#         |           ├── solaris/
#         |           └── windows/
#         |               └── splunkforwarder-7.2.4.2-fb30470262e3-x64-release.msi
#         └── splunk/
#             └── releases/
#                 └── 7.2.4.2/
#                     └── linux/
#                         ├── splunk-7.2.4.2-fb30470262e3-linux-2.6-amd64.deb
#                         ├── splunk-7.2.4.2-fb30470262e3-linux-2.6-intel.deb
#                         └── splunk-7.2.4.2-fb30470262e3-linux-2.6-x86_64.rpm
#
# @param boot_start
#   Enable Splunk to start at boot, create a system service file.
#
#   WARNING: Toggling boot_start `false` to `true` will cause a restart of the
#   splunk Enterprise and Forwarder services.
#
#   Defaults to true
#
# @param forwarder_installdir
#   Optional directory in which to install and manage Splunk Forwarder
#
# @param enterprise_installdir
#   Optional directory in which to install and manage Splunk Enterprise
#
# Actions:
#
#   Declares parameters to be consumed by other classes in the splunk module.
#
# Requires: nothing
#
class splunk::params (
  String[1] $version                         = '7.2.4.2',
  String[1] $build                           = 'fb30470262e3',
  String[1] $src_root                        = 'https://download.splunk.com',
  Stdlib::Port $splunkd_port                 = 8089,
  Stdlib::Port $logging_port                 = 9997,
  String[1] $server                          = 'splunk',
  Optional[String[1]] $forwarder_installdir  = undef,
  Optional[String[1]] $enterprise_installdir = undef,
  Boolean $boot_start                        = true,
  String[1] $splunk_user                     = $facts['os']['family'] ? {
    'Windows' => 'Administrator',
    default => 'root'
  },
) {

  # Based on the small number of inputs above, we can construct sane defaults
  # for pretty much everything else.

  # Settings common to everything
  $staging_subdir = 'splunk'

  # To generate password_content, change the password on enterprise or
  # forwarder, then distribute the contents of the splunk.secret and passwd
  # files accross all nodes.
  # By default the parameters provided are for admin/changeme password.
  $manage_password  = false
  $secret           = 'hhy9DOGqli4.aZWCuGvz8stcqT2/OSJUZuyWHKc4wnJtQ6IZu2bfjeElgYmGHN9RWIT3zs5hRJcX1wGerpMNObWhFue78jZMALs3c3Mzc6CzM98/yGYdfcvWMo1HRdKn82LVeBJI5dNznlZWfzg6xdywWbeUVQZcOZtODi10hdxSJ4I3wmCv0nmkSWMVOEKHxti6QLgjfuj/MOoh8.2pM0/CqF5u6ORAzqFZ8Qf3c27uVEahy7ShxSv2K4K41z'
  $password_content = ':admin:$6$pIE/xAyP9mvBaewv$4GYFxC0SqonT6/x8qGcZXVCRLUVKODj9drDjdu/JJQ/Iw0Gg.aTkFzCjNAbaK4zcCHbphFz1g1HK18Z2bI92M0::Administrator:admin:changeme@example.com::'

  if $::osfamily == 'Windows' {
    $enterprise_homedir = pick($enterprise_installdir, 'C:/Program Files/Splunk')
    $forwarder_homedir  = pick($forwarder_installdir, 'C:\\Program Files\\SplunkUniversalForwarder')
  } else {
    $enterprise_homedir = pick($enterprise_installdir, '/opt/splunk')
    $forwarder_homedir  = pick($forwarder_installdir, '/opt/splunkforwarder')
  }

  # Settings common to a kernel
  case $::kernel {
    'Linux': {
      $path_delimiter                      = '/'
      $forwarder_src_subdir                = 'linux'
      $forwarder_password_config_file      = "${forwarder_homedir}/etc/passwd"
      $enterprise_password_config_file     = "${enterprise_homedir}/etc/passwd"
      $forwarder_secret_file               = "${forwarder_homedir}/etc/splunk.secret"
      $enterprise_secret_file              = "${enterprise_homedir}/etc/splunk.secret"
      $forwarder_confdir                   = "${forwarder_homedir}/etc"
      $enterprise_src_subdir               = 'linux'
      $enterprise_confdir                  = "${enterprise_homedir}/etc"
      $forwarder_install_options           = []
      $enterprise_install_options           = []
      # Systemd not supported until Splunk 7.2.2
      if $facts['service_provider'] == 'systemd' and versioncmp($version, '7.2.2') >= 0 {
        $enterprise_service      = 'Splunkd'
        $forwarder_service       = 'SplunkForwarder'
        $enterprise_service_file = '/etc/systemd/system/multi-user.target.wants/Splunkd.service'
        $forwarder_service_file  = '/etc/systemd/system/multi-user.target.wants/SplunkForwarder.service'
      }
      else {
        $enterprise_service      = 'splunk'
        $forwarder_service       = 'splunk'
        $enterprise_service_file = '/etc/init.d/splunk'
        $forwarder_service_file  = '/etc/init.d/splunk'
      }
    }
    'SunOS': {
      $path_delimiter        = '/'
      $forwarder_src_subdir  = 'solaris'
      $password_config_file  = "${forwarder_homedir}/etc/passwd"
      $secret_file           = "${forwarder_homedir}/etc/splunk.secret"
      $forwarder_confdir     = "${forwarder_homedir}/etc"
      $enterprise_src_subdir = 'solaris'
      $enterprise_confdir    = "${enterprise_homedir}/etc"
      $forwarder_install_options = []
      $enterprise_install_options = []
      # Systemd not supported until Splunk 7.2.2
      if $facts['service_provider'] == 'systemd' and versioncmp($version, '7.2.2') >= 0 {
        $enterprise_service      = 'Splunkd'
        $forwarder_service       = 'SplunkForwarder'
        $enterprise_service_file = '/etc/systemd/system/multi-user.target.wants/Splunkd.service'
        $forwarder_service_file  = '/etc/systemd/system/multi-user.target.wants/SplunkForwarder.service'
      }
      else {
        $enterprise_service      = 'splunk'
        $forwarder_service       = 'splunk'
        $enterprise_service_file = '/etc/init.d/splunk'
        $forwarder_service_file  = '/etc/init.d/splunk'
      }
    }
    'Windows': {
      $path_delimiter        = '\\'
      $forwarder_src_subdir  = 'windows'
      $password_config_file  = 'C:/Program Files/SplunkUniversalForwarder/etc/passwd'
      $secret_file           =  'C:/Program Files/SplunkUniversalForwarder/etc/splunk.secret'
      $forwarder_service     = 'SplunkForwarder' # UNKNOWN
      $forwarder_confdir     = "${forwarder_homedir}/etc"
      $enterprise_src_subdir = 'windows'
      $enterprise_service    = 'splunkd' # UNKNOWN
      $enterprise_confdir    = "${enterprise_homedir}/etc"
      $forwarder_install_options = [
        'AGREETOLICENSE=Yes',
        'LAUNCHSPLUNK=0',
        'SERVICESTARTTYPE=auto',
        'WINEVENTLOG_APP_ENABLE=1',
        'WINEVENTLOG_SEC_ENABLE=1',
        'WINEVENTLOG_SYS_ENABLE=1',
        'WINEVENTLOG_FWD_ENABLE=1',
        'WINEVENTLOG_SET_ENABLE=1',
        'ENABLEADMON=1',
        { 'INSTALLDIR' => $forwarder_homedir },
      ]
      $enterprise_install_options = [
        'LAUNCHSPLUNK=1',
        'WINEVENTLOG_APP_ENABLE=1',
        'WINEVENTLOG_SEC_ENABLE=1',
        'WINEVENTLOG_SYS_ENABLE=1',
        'WINEVENTLOG_FWD_ENABLE=1',
        'WINEVENTLOG_SET_ENABLE=1',
      ]
    }
    default: { fail("splunk module does not support kernel ${::kernel}") }
  }
  # default splunk agent settings in a hash so that the cya be easily parsed to other classes

  $forwarder_output = {
    'tcpout_defaultgroup'          => {
      section                      => 'default',
      setting                      => 'defaultGroup',
      value                        => "${server}_${logging_port}",
      tag                          => 'splunk_forwarder',
    },
    'defaultgroup_server' => {
      section             => "tcpout:${server}_${logging_port}",
      setting             => 'server',
      value               => "${server}:${logging_port}",
      tag                 => 'splunk_forwarder',
    },
  }
  $forwarder_input = {
    'default_host' => {
      section      => 'default',
      setting      => 'host',
      value        => $::clientcert,
      tag          => 'splunk_forwarder',
    },
  }
  # Settings common to an OS family
  case $::osfamily {
    'RedHat':  { $package_provider = 'rpm'  }
    'Debian':  { $package_provider = 'dpkg' }
    'Solaris': { $package_provider = 'sun'  }
    default:   { $package_provider = undef  } # Don't define a $package_provider
  }

  # Settings specific to an architecture as well as an OS family
  case "${::osfamily} ${::architecture}" {
    'RedHat i386': {
      $package_suffix          = "${version}-${build}.i386.rpm"
      $forwarder_package_name  = 'splunkforwarder'
      $enterprise_package_name = 'splunk'
    }
    'RedHat x86_64': {
      $package_suffix          = "${version}-${build}-linux-2.6-x86_64.rpm"
      $forwarder_package_name  = 'splunkforwarder'
      $enterprise_package_name = 'splunk'
    }
    'Debian i386': {
      $package_suffix          = "${version}-${build}-linux-2.6-intel.deb"
      $forwarder_package_name  = 'splunkforwarder'
      $enterprise_package_name = 'splunk'
    }
    'Debian amd64': {
      $package_suffix          = "${version}-${build}-linux-2.6-amd64.deb"
      $forwarder_package_name  = 'splunkforwarder'
      $enterprise_package_name = 'splunk'
    }
    /^(W|w)indows (x86|i386)$/: {
      $package_suffix          = "${version}-${build}-x86-release.msi"
      $forwarder_package_name  = 'UniversalForwarder'
      $enterprise_package_name = 'Splunk'
    }
    /^(W|w)indows (x64|x86_64)$/: {
      $package_suffix          = "${version}-${build}-x64-release.msi"
      $forwarder_package_name  = 'UniversalForwarder'
      $enterprise_package_name = 'Splunk'
    }
    'Solaris i86pc': {
      $package_suffix          = "${version}-${build}-solaris-10-intel.pkg"
      $forwarder_package_name  = 'splunkforwarder'
      $enterprise_package_name = 'splunk'
    }
    'Solaris sun4v': {
      $package_suffix          = "${version}-${build}-solaris-8-sparc.pkg"
      $forwarder_package_name  = 'splunkforwarder'
      $enterprise_package_name = 'splunk'
    }
    default: { fail("unsupported osfamily/arch ${::osfamily}/${::architecture}") }
  }

  $forwarder_src_package  = "splunkforwarder-${package_suffix}"
  $enterprise_src_package = "splunk-${package_suffix}"

  $enterprise_package_ensure = 'installed'
  $enterprise_package_src    = "${src_root}/products/splunk/releases/${version}/${enterprise_src_subdir}/${enterprise_src_package}"
  $forwarder_package_ensure = 'installed'
  $forwarder_package_src = "${src_root}/products/universalforwarder/releases/${version}/${forwarder_src_subdir}/${forwarder_src_package}"


  # A meta resource so providers know where splunk is installed:
  splunk_config { 'splunk':
    forwarder_installdir => $forwarder_homedir,
    forwarder_confdir    => $forwarder_confdir,
    server_installdir    => $enterprise_homedir,
    server_confdir       => $enterprise_confdir,
  }
}
