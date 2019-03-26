# Class splunk::enterprise::install
#
class splunk::enterprise::install {

  if $facts['kernel'] == 'Linux' or $facts['kernel'] == 'SunOS' {
    include splunk::enterprise::install::nix
  }

  $_package_source = $splunk::enterprise::manage_package_source ? {
    true  => $splunk::enterprise::enterprise_package_src,
    false => $splunk::enterprise::package_source
  }

  if $splunk::enterprise::package_provider != undef and $splunk::enterprise::package_provider != 'yum' and $splunk::enterprise::package_provider != 'apt' and $splunk::enterprise::package_provider != 'chocolatey' {
    include archive::staging
    $_src_package_filename = basename($_package_source)
    $_package_path_parts   = [$archive::path, $splunk::enterprise::staging_subdir, $_src_package_filename]
    $_staged_package       = join($_package_path_parts, $splunk::enterprise::path_delimiter)

    archive { $_staged_package:
      source  => $_package_source,
      extract => false,
      before  => Package[$splunk::enterprise::enterprise_package_name],
    }
  } else {
    $_staged_package = undef
  }

  Package  {
    source         => $splunk::enterprise::package_provider ? {
      'chocolatey' => undef,
      default      => $splunk::enterprise::manage_package_source ? {
        true  => pick($_staged_package, $_package_source),
        false => $_package_source,
      }
    },
  }

  package { $splunk::enterprise::enterprise_package_name:
    ensure          => $splunk::enterprise::enterprise_package_ensure,
    provider        => $splunk::enterprise::package_provider,
    install_options => $splunk::enterprise::install_options,
  }

}
