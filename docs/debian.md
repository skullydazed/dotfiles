# Things I Always Want To Know About Debian

## Set Console Resolution

Set in `/etc/default/grub`:

```
GRUB_CMDLINE_LINUX_DEFAULT="video=1280x1024 consoleblank=600"
GRUB_GFXMODE=1280x1024
GRUB_GFXPAYLOAD_LINUX=keep
```

Then run: `sudo update-grub`

## Basic Things I Like

* `su - -c "apt install sudo"`
* Add my user to all the groups, relogin
* `sudo apt install net-tools vim`
* `sudo update-alternatives --set editor /usr/bin/vim.basic`

## Stop Clearing My Screen

From <http://mywiki.wooledge.org/SystemdNoClear>.

```
rm ~/.bash_logout
sudo mkdir /etc/systemd/system/getty@.service.d
cat << EOF | sudo tee /etc/systemd/system/getty@.service.d/noclear.conf
[Service]
TTYVTDisallocate=no
EOF
sudo systemctl daemon-reload
```

## NAT/Firewall setup

You'll need to collect the following information:

* `__WAN_INTERFACE__`: The interface name for the external (WAN) NIC
* `__LAN_INTERFACE__`: The interface name for the internal (LAN) NIC
* `__LAN_IP__`: The IP for this router on the lan, EG `172.16.0.1`
* `__LAN_IP_MASK__`: The Network/Mask for the lan, EG `172.16.0.0/24`.
* `__DOMAINNAME__`: The DNS domainname for this network
* `__DHCP_RANGE_START__`: The starting IP for dynamically assigned IPs
* `__DHCP_RANGE_END__`: The ending IP for dynamically assigned IPs

And install the following software:

* `apt install dnsmasq`

### Setup network interfaces in `/etc/network/interfaces`:

```
# Configure the WAN interface.
allow-hotplug __WAN_INTERFACE__
iface __WAN_INTERFACE__ inet dhcp
iface __WAN_INTERFACE__ inet6 auto

# Configure the internal network.
allow-hotplug __LAN_INTERFACE__
iface __LAN_INTERFACE__ inet static
    address __LAN_IP_MASK__
iface __LAN_INTERFACE__ inet6 manual
```

### Setup firewall loader in `/etc/network/ip-pre-up.d/iptables`:

```
#!/bin/sh
/sbin/iptables-restore < /etc/network/iptables
```

### Setup basic firewall rules in `/etc/network/iptables`

```
## Reload with: /sbin/iptables-restore < /etc/network/iptables
*nat
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]

# __WAN_INTERFACE__ is WAN interface, __LAN_INTERFACE__ is LAN interface
-A POSTROUTING -o __WAN_INTERFACE__ -j MASQUERADE

COMMIT

*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]

## Service rules

# basic global accept rules - ICMP, loopback, traceroute, established all accepted
-A INPUT -i lo -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -m state --state ESTABLISHED -j ACCEPT

# accept from LAN
-A INPUT -i __LAN_INTERFACE__ -j ACCEPT

# enable traceroute rejections to get sent out
-A INPUT -p udp -m udp --dport 33434:33523 -j REJECT --reject-with icmp-port-unreachable

# accept specific services
# ssh
-A INPUT -i __WAN_INTERFACE__ -p tcp --dport 22 -j ACCEPT

# drop all other inbound traffic
-A INPUT -j REJECT

## Forwarding rules

# forward packets along established/related connections
-A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

# forward from LAN (__LAN_INTERFACE__) to WAN (__WAN_INTERFACE__)
-A FORWARD -i __LAN_INTERFACE__ -o __WAN_INTERFACE__ -j ACCEPT

# forward from LAN (__LAN_INTERFACE__) to VPN (tun0) and back
-A FORWARD -i __LAN_INTERFACE__ -o tun0 -j ACCEPT
-A FORWARD -i tun0 -o __LAN_INTERFACE__ -j ACCEPT

# drop all other forwarded traffic
-A FORWARD -j DROP

COMMIT
```

### Setup dnsmasq blocklist with automatic updates

#### Create /etc/cron.daily/update-dnsmasq-blacklist.sh

```
#!/bin/sh

curl -L https://github.com/notracking/hosts-blocklists/raw/master/dnsmasq/dnsmasq.blacklist.txt > /etc/dnsmasq.d/blacklist.conf
systemctl restart dnsmasq
```

#### Build `/etc/dnsmasq.d/local.conf`

```
# Never forward plain names (without a dot or domain part)
domain-needed
# Never forward addresses in the non-routed address spaces.
bogus-priv

# If you don't want dnsmasq to read /etc/resolv.conf or any other
# file, getting its servers from this file instead (see below), then
# uncomment this.
no-resolv

# If you don't want dnsmasq to poll /etc/resolv.conf or other resolv
# files for changes and re-read them then uncomment this.
no-poll

# Add other name servers here, with domain specs if they are for
# non-public domains.
server=1.1.1.2
server=1.0.0.2

# If you want dnsmasq to listen for DHCP and DNS requests only on
# specified interfaces (and the loopback) give the name of the
# interface (eg eth0) here.
# Repeat the line for more than one interface.
interface=__LAN_INTERFACE__

# Set this (and domain: see below) if you want to have a domain
# automatically added to simple names in a hosts-file.
expand-hosts

# Set the domain for dnsmasq. this is optional, but if it is set, it
# does the following things.
# 1) Allows DHCP hosts to have fully qualified domain names, as long
#     as the domain part matches this setting.
# 2) Sets the "domain" DHCP option thereby potentially setting the
#    domain of all systems configured by DHCP
# 3) Provides the domain part for "expand-hosts"
domain=__DOMAINNAME__

# Set the DHCP server to authoritative mode. In this mode it will barge in
# and take over the lease for any client which broadcasts on the network,
# whether it has a record of the lease or not. This avoids long timeouts
# when a machine wakes up on a new network. DO NOT enable this if there's
# the slightest chance that you might end up accidentally configuring a DHCP
# server for your campus/company accidentally. The ISC server uses
# the same option, and this URL provides more information:
# http://www.isc.org/files/auth.html
dhcp-authoritative
```

#### Build `/etc/dnsmasq.d/dhcp.conf`

```
### Reload server: sudo servicectl reload dnsmasq

# DHCP configuration
dhcp-range=__DHCP_RANGE_START__,__DHCP_RANGE_END__,24h
dhcp-option=option:ntp-server,__LAN_IP__

# Run an executable when a DHCP lease is created or destroyed.
# The arguments sent to the script are:
# <add|del> <mac_address> <ip_address> [hostname]
dhcp-script=/home/zwhite/dnsmasq2mqtt

# Static host entries
#dhcp-host=__MAC_ADDR__,__HOSTNAME__,__HOST_IP_ADDR__,24h
```
