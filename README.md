# docker-alp-dnsmasq
Installs dnsmasq into an Alpine Linux container

![dnsmasq](http://www.thekelleys.org.uk/dnsmasq/images/icon.png)

## Description
Dnsmasq provides network infrastructure for small networks: DNS, DHCP, router advertisement and network boot. It is designed to be lightweight and have a small footprint, suitable for resource constrained routers and firewalls.

http://www.thekelleys.org.uk/dnsmasq/doc.html

## Usage

    docker create --name=dnsmasq  \
      -v /etc/localtime:/etc/localtime:ro \
      -v <path to dnsmasq config>:/etc/dnsmasq.d \
      -e DOCKUID=<UID default:10015> \
      -e DOCKGID=<GID default:10015> \
      -e DOCKDROPRIV=<0|1 default:0> \
      -e DOCKDNSCACHE=<integer default:150> \
      -e DOCKDNS1=<ip default:8.8.8.8> \
      -e DOCKDNS2=<ip default:8.8.4.4> \
      -p 53:<53 or 5353 default:53>/udp digrouz/docker-alp-dnsmasq dnsmasq

## Environment Variables

When you start the `dnsmasq` image, you can adjust the configuration of the `dnsmasq` instance by passing one or more environment variables on the `docker run` command line.

### `DOCKUID`

This variable is not mandatory and specifies the user id that will be set to run the application. It has default value `10015`.

### `DOCKGID`

This variable is not mandatory and specifies the group id that will be set to run the application. It has default value `10015`.

### `DOCKDROPRIV`

This variable allows to run dnsmasq with an unprivilegied user inside the container. Due to what unprivilegied run means, if this variable set to `1`, dnsmasq will listen to
port `5353` otherwise the default port `53` will be used. It has default value `0`.

### `DOCKDNSCACHE`

This variable is not mandatory and specifies the size of dnsmasq's cache. Setting the cache size to zero disables caching. The default is `150`.

### `DOCKDNS1`

This variable is not mandatory and specifies the primary name server that will be use to foward requests. It has default value `8.8.8.8`.

### `DOCKDNS2`

This variable is not mandatory and specifies the secondary name server that will be use to foward requests. It has default value `8.8.4.4`.

## Notes

* The docker entrypoint will upgrade operating system at each startup.
