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
          }
      }
      if ! defined(Package[$ovs_module_req_pkg]) {
        package{ $ovs_module_req_pkg: ensure => present }
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
    hasstatus   => false, # the supplied command returns true even if it's not running
    # Not perfect - should spot if either service is not running - but it'll do
    status      => "/etc/init.d/openvswitch-switch status | fgrep 'is running'",
  }

  Service['openvswitch-switch'] -> Vs_port<||>
  Service['openvswitch-switch'] -> Vs_bridge<||>
}
