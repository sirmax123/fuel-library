# Configuration of HAProxy for OpenStack
class openstack::ha::haproxy (
  $controllers              = [],
  $public_virtual_ip        = undef,
  $internal_virtual_ip      = undef,
  $horizon_use_ssl          = false,
  $neutron                  = false,
  $queue_provider           = 'rabbitmq',
  $custom_mysql_setup_class = 'galera',
  $swift_proxies            = undef,
  $rgw_servers              = undef,
  $ceilometer               = undef,
  $sahara                   = undef,
  $is_primary_controller    = false,
) {

  Haproxy::Service        { use_include => true }
  Haproxy::Balancermember { use_include => true }

  Openstack::Ha::Haproxy_service {
    server_names        => filter_hash($controllers, 'name'),
    ipaddresses         => filter_hash($controllers, 'internal_address'),
    public_virtual_ip   => $public_virtual_ip,
    internal_virtual_ip => $internal_virtual_ip,
  }

  class { 'openstack::ha::horizon': use_ssl => $horizon_use_ssl }
  class { 'openstack::ha::keystone': }
  class { 'openstack::ha::nova': }
  class { 'openstack::ha::glance': }
  class { 'openstack::ha::cinder': }

  if $neutron { class { 'openstack::ha::neutron': } }
  if $queue_provider == 'rabbitmq' { class { 'openstack::ha::rabbitmq': } }
  if $custom_mysql_setup_class == 'galera' { class { 'openstack::ha::mysqld': is_primary_controller => $is_primary_controller} }

  if $swift_proxies { class { 'openstack::ha::swift':   servers => $swift_proxies } }
  if $rgw_servers   { class { 'openstack::ha::radosgw': servers => $rgw_servers } }
  if $ceilometer    { class { 'openstack::ha::ceilometer': } }
  if $sahara        { class { 'openstack::ha::sahara': } }
}
