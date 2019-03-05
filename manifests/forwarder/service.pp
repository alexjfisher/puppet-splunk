# Class splunk::forwarder::service
#
class splunk::forwarder::service {

  # This is a module that supports multiple platforms. For some platforms
  # there is non-generic configuration that needs to be declared in addition
  # to the agnostic resources declared here.
  if $facts['kernel'] == 'Linux' or $facts['kernel'] == 'SunOS' {
    include ::splunk::forwarder::service::nix
  }

  service { $::splunk::forwarder::service_name:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

}
