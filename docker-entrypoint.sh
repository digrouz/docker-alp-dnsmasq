#!/bin/sh

MYUSER="dnsmasq"
MYGID="10015"
MYUID="10015"

AutoUpgrade(){
  if [ -e /etc/alpine-release ]; then
    /sbin/apk --no-cache upgrade
    /bin/rm -rf /var/cache/apk/*
  elif [ -e /etc/os-release ]; then
    if /bin/grep -q "NAME=\"Ubuntu\"" /etc/os-release ; then 
      export DEBIAN_FRONTEND=noninteractive
      /usr/bin/apt-get update
      /usr/bin/apt-get -y --no-install-recommends dist-upgrade
      /usr/bin/apt-get -y autoclean
      /usr/bin/apt-get -y clean 
      /usr/bin/apt-get -y autoremove
      /bin/rm -rf /var/lib/apt/lists/*
    fi
  fi
}

ConfigureUser () {
  # Managing user
  if [ -n "${DOCKUID}" ]; then
    MYUID="${DOCKUID}"
  fi
  # Managing group
  if [ -n "${DOCKGID}" ]; then
    MYGID="${DOCKGID}"
  fi
  local OLDHOME
  local OLDGID
  local OLDUID
  /bin/grep -q "${MYUSER}" /etc/passwd
  if [ $? -eq 0 ]; then
    OLDUID=$(/usr/bin/id -u "${MYUSER}")
    OLDGID=$(/usr/bin/id -g "${MYUSER}")
    if [ "${DOCKUID}" != "${OLDUID}" ]; then
      OLDHOME=$(/bin/echo "~${MYUSER}")
      /usr/sbin/deluser "${MYUSER}"
      /usr/bin/logger "Deleted user ${MYUSER}"
    fi
    /bin/grep -q "${MYUSER}" /etc/group
    if [ $? -eq 0 ]; then
      local OLDGID=$(/usr/bin/id -g "${MYUSER}")
      if [ "${DOCKGID}" != "${OLDGID}" ]; then
        /usr/sbin/delgroup "${MYUSER}"
        /usr/bin/logger "Deleted group ${MYUSER}"
      fi
    fi
  fi
  /usr/sbin/addgroup -S -g "${MYGID}" "${MYUSER}"
  /usr/sbin/adduser -S -D -H -s /sbin/nologin -G "${MYUSER}" -h "${OLDHOME}" -u "${MYUID}" "${MYUSER}"
  if [ -n "${OLDUID}" ] && [ "${DOCKUID}" != "${OLDUID}" ]; then
    /usr/bin/find / -user "${OLDUID}" -exec /bin/chown ${MYUSER} {} \;
  fi
  if [ -n "${OLDGID}" ] && [ "${DOCKGID}" != "${OLDGID}" ]; then
    /usr/bin/find / -group "${OLDGID}" -exec /bin/chgrp ${MYUSER} {} \;
  fi
}

AutoUpgrade
ConfigureUser

if [ "$1" = 'dnsmasq' ]; then
    if [ -d /var/log/dnsmasq ]; then
      /bin/rm -rf /var/log/dnsmasq
      /bin/ln -snf /logs /var/log/dnsmasq
    fi
    if [ -d /logs ]; then
      /bin/chown -R "${MYUSER}":"${MYUSER}" /logs /var/lib/dnsmasq
      /bin/chmod 0775 /logs
      /bin/chmod 0664 /logs/*
    fi
    exec /usr/sbin/dnsmasq -c /config/dnsmasq.conf -g 'daemon off;pid /logs/dnsmasq.pid;' 
fi

exec "$@"
