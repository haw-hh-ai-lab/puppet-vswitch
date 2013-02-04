class vswitch::ovs(
  $package_ensure = 'present'
) {
  case $::osfamily {
    Debian: {
      case $::operatingsystem {
        'Ubuntu': {
             $ovs_module_req_pkg = "linux-image-extra-$::kernelversion"
           }
        default: {
             # OVS doesn't build unless the kernel headers are present.
             $ovs_module_req_pkg = "linux-headers-$::kernelrelease"

             exec { 'rebuild-ovsmod':
               command => "/usr/sbin/dpkg-reconfigure openvswitch-datapath-dkms > /tmp/reconf-log",
               creates => "/lib/modules/$::kernelrelease/updates/dkms/openvswitch_mod.ko",
               require => [Package['openvswitch-datapath-dkms', $ovs_module_req_pkg]],
               before  => Package['openvswitch-switch'],
             }

          }
      }
      if ! defined(Package[$ovs_module_req_pkg]) {
        package{ $ovs_module_req_pkg: ensure => $package_ensure }
      }
    
      package {["openvswitch-common",
                "openvswitch-switch"]:
        ensure  => $package_ensure,
        require => Package[$ovs_module_req_pkg],
        before  => Service['openvswitch-switch'],
      }
    }
  }

  service {"openvswitch-switch":
    ensure      => true,
    enable      => true,
    hasstatus   => false
    # Not perfect - should spot if either service is not running - but it'll do
    # will only apply if $hasstatus is false
    status      => "/usr/sbin/service openvswitch-switch status",
  }

  Service['openvswitch-switch'] -> Vs_port<||>
  Service['openvswitch-switch'] -> Vs_bridge<||>
}
