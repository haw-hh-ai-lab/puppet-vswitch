class vswitch::ovs(
  $package_ensure = 'present'
) {
  case $::osfamily {
    Debian: {
      if ! defined(Package["linux-image-extra-$::kernelversion"]) {
        package { "linux-image-extra-$::kernelversion": ensure => present }
      }
      package {["openvswitch-common",
                "openvswitch-switch"]:
        ensure  => $package_ensure,
        require => Package["linux-image-extra-$::kernelversion"],
        before  => Service['openvswitch-switch'],
      }
    }
  }

  service {"openvswitch-switch":
    ensure      => true,
    enable      => true,
    hasstatus   => false, # the supplied command returns true even if it's not running
    # Not perfect - should spot if either service is not running - but it'll do
    status      => "/etc/init.d/openvswitch-switch status | fgrep 'is running'",
  }

  Service['openvswitch-switch'] -> Vs_port<||>
  Service['openvswitch-switch'] -> Vs_bridge<||>
}
