#!/usr/bin/env sh

MYUSER="dnsmasq"
MYGID="10015"
MYUID="10015"
MYDNS1="8.8.8.8"
MYDNS2="8.8.4.4"
MYCACHE=150
MYPORT=53
MYSTARTCMD="exec"
OS=""

DectectOS(){
  if [ -e /etc/alpine-release ]; then
    OS="alpine"
  elif [ -e /etc/os-release ]; then
    if /bin/grep -q "NAME=\"Ubuntu\"" /etc/os-release ; then 
      OS="ubuntu"
    fi
  fi
}

AutoUpgrade(){
  if [ "${OS}" == "alpine" ]; then
    /sbin/apk --no-cache upgrade
    /bin/rm -rf /var/cache/apk/*
  elif [ "${OS}" == "ubuntu" ]; then
    export DEBIAN_FRONTEND=noninteractive
    /usr/bin/apt-get update
    /usr/bin/apt-get -y --no-install-recommends dist-upgrade
    /usr/bin/apt-get -y autoclean
    /usr/bin/apt-get -y clean 
    /usr/bin/apt-get -y autoremove
    /bin/rm -rf /var/lib/apt/lists/*
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
  if /bin/grep -q "${MYUSER}" /etc/passwd; then
    OLDUID=$(/usr/bin/id -u "${MYUSER}")
    OLDGID=$(/usr/bin/id -g "${MYUSER}")
    if [ "${DOCKUID}" != "${OLDUID}" ]; then
      OLDHOME=$(/bin/grep "$MYUSER" /etc/passwd | /usr/bin/awk -F: '{print $6}')
      /usr/sbin/deluser "${MYUSER}"
      /usr/bin/logger "Deleted user ${MYUSER}"
    fi
    if /bin/grep -q "${MYUSER}" /etc/group; then
      local OLDGID=$(/usr/bin/id -g "${MYUSER}")
      if [ "${DOCKGID}" != "${OLDGID}" ]; then
        /usr/sbin/delgroup "${MYUSER}"
        /usr/bin/logger "Deleted group ${MYUSER}"
      fi
    fi
  fi
  if ! /bin/grep -q "${MYUSER}" /etc/group; then
    /usr/sbin/addgroup -S -g "${MYGID}" "${MYUSER}"
  fi
  if ! /bin/grep -q "${MYUSER}" /etc/passwd; then
    /usr/sbin/adduser -S -D -H -s /sbin/nologin -G "${MYUSER}" -h "${OLDHOME}" -u "${MYUID}" "${MYUSER}"
  fi
  if [ -n "${OLDUID}" ] && [ "${DOCKUID}" != "${OLDUID}" ]; then
    /usr/bin/find / -user "${OLDUID}" -exec /bin/chown ${MYUSER} {} \;
  fi
  if [ -n "${OLDGID}" ] && [ "${DOCKGID}" != "${OLDGID}" ]; then
    /usr/bin/find / -group "${OLDGID}" -exec /bin/chgrp ${MYUSER} {} \;
  fi
}

DectectOS
AutoUpgrade
ConfigureUser

if [ "$1" = 'dnsmasq' ]; then
  if [ ! -d /etc/dnsmasq.d ]; then
    /bin/mkdir /etc/dnsmasq.d
  fi
  cat << EOF > /etc/dnsmasq.d/00-base.conf
#log all dns queries
log-queries
#dont use hosts nameservers
no-resolv
EOF
  if [ -n "${DOCKDNS1}" ]; then
    MYDNS1="${DOCKDNS1}"
  fi
  if [ -n "${DOCKDNS2}" ]; then
    MYDNS2="${DOCKDNS2}"
  fi
  cat << EOF > /etc/dnsmasq.d/02-nameservers.conf
#use User defined nameservers
server=${MYDNS1}
server=${MYDNS2}
EOF
  if [ -n "${DOCKDNSCACHE}" ]; then
    MYCACHE="${DOCKDNSCACHE}"
  fi
  cat << EOF > /etc/dnsmasq.d/01-cache.conf
#Define cache Size
cache-size=${MYCACHE}
EOF
  if [ $DOCKDROPPRIV -eq 1 ]; then
    MYPORT=5353
    MYSTARTCMD="su-exec ${MYUSER}"
    cat << EOF > /etc/dnsmasq.d/03-user.conf
#Define user
user=${MYUSER}
group=${MYUSER}
EOF
  else
    /bin/rm -rf /etc/dnsmasq.d/03-user.conf
  fi
  cat << EOF > /etc/dnsmasq.d/04-port.conf
#Define port
port=${MYPORT}
EOF
  if [ -d /etc/dnsmasq.d ]; then
    /bin/chmod 0775 /etc/dnsmasq.d
    /bin/chmod 0664 /etc/dnsmasq.d/*
    /bin/chown -R "${MYUSER}:${MYUSER}" /etc/dnsmasq.d
  fi
  
  exec "${MYSTARTCMD}" /usr/sbin/dnsmasq --conf-dir=/etc/dnsmasq.d --no-daemon
else
  exec "$@"
fi


