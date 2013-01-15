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
    hasstatus   => true,
    status      => "/etc/init.d/openvswitch-switch status",
  }
}
