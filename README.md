# docker-alp-dnsmasq
Installs dnsmasq into an Alpine Linux container

![dnsmasq](http://www.thekelleys.org.uk/dnsmasq/images/icon.png)

## Description
Dnsmasq provides network infrastructure for small networks: DNS, DHCP, router advertisement and network boot. It is designed to be lightweight and have a small footprint, suitable for resource constrained routers and firewalls.

http://www.thekelleys.org.uk/dnsmasq/doc.html

## Usage

    docker create --name=dnsmasq  \
      -v /etc/localtime:/etc/localtime:ro \
      -v <path to dnsmasq config>:/etc/dnsmasq.conf \
      -e DOCKUID=<UID default:10015> \
      -e DOCKGID=<GID default:10015> \
      -p 53:53/UDP digrouz/docker-alp-dnsmasq dnsmasq

## Environment Variables

When you start the `dnsmasq` image, you can adjust the configuration of the `dnsmasq` instance by passing one or more environment variables on the `docker run` command line.

### `DOCKUID`

This variable is not mandatory and specifies the user id that will be set to run the application. It has default value `10015`.

### `DOCKGID`

This variable is not mandatory and specifies the group id that will be set to run the application. It has default value `10015`.

## Notes

* The docker entrypoint will upgrade operating system at each startup.
