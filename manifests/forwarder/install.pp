# Class splunk::forwarder::install
#
class splunk::forwarder::install {

  $_package_source = $::splunk::forwarder::manage_package_source ? {
    true  => $::splunk::forwarder::forwarder_package_src,
    false => $::splunk::forwarder::package_source
  }

  if $::splunk::forwarder::package_provider != undef and $::splunk::forwarder::package_provider != 'yum' and $::splunk::forwarder::package_provider != 'apt' and $::splunk::forwarder::package_provider != 'chocolatey' {
    include ::archive::staging
    $_src_package_filename = basename($_package_source)
    $_package_path_parts   = [$archive::path, $::splunk::forwarder::staging_subdir, $_src_package_filename]
    $_staged_package       = join($_package_path_parts, $::splunk::forwarder::path_delimiter)

    archive { $_staged_package:
      source  => $_package_source,
      extract => false,
      before  => Package[$::splunk::forwarder::forwarder_package_name],
    }
  } else {
    $_staged_package = undef
  }

  Package  {
    source         => $::splunk::forwarder::package_provider ? {
      'chocolatey' => undef,
      default      => $::splunk::forwarder::manage_package_source ? {
        true  => pick($_staged_package, $_package_source),
        false => $_package_source,
      }
    },
  }

  if $facts['kernel'] == 'SunOS' {
    $_responsefile = "${archive::path}/${::splunk::forwarder::staging_subdir}/response.txt"
    $_adminfile    = '/var/sadm/install/admin/splunk-noask'

    file { 'splunk_adminfile':
      ensure => file,
      path   => $_adminfile,
      owner  => 'root',
      group  => 'root',
      source => 'puppet:///modules/splunk/splunk-noask',
    }

    file { 'splunk_pkg_response_file':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      path    => $_responsefile,
      content => "BASEDIR=/opt\n",
    }

    # Collect any Splunk packages and give them an admin and response file.
    Package {
      adminfile    => $_adminfile,
      responsefile => $_responsefile,
    }
  }

  #TODO: this should ensure on specified version
  package { $::splunk::forwarder::forwarder_package_name:
    ensure          => $::splunk::forwarder::forwarder_package_ensure,
    provider        => $::splunk::forwarder::package_provider,
    install_options => $::splunk::forwarder::install_options,
  }

}
