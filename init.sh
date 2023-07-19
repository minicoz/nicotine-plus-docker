#!/bin/sh
set -e
[ -f /tmp/.X1-lock ] && rm /tmp/.X1-lock
PGID=${PGID:-0}
PUID=${PUID:-0}
umask ${UMASK:-0000}
[ "$PGID" != 0 ] && [ "$PUID" != 0 ] && \
 groupmod -o -g "$PGID" nicotine && \
 usermod  -o -u "$PUID" nicotine 1> /dev/null && \
 chown -R nicotine:nicotine /app && \
 chown -R nicotine:sonicotineulseek /data

[ ! -z "${VNCPWD}" ] && echo "$VNCPWD" | vncpasswd -f > /tmp/passwd
[ -z "${VNCPWD}" ] && rm -f /tmp/passwd && noauth="-SecurityTypes None"

touch /tmp/.Xauthority
chown nicotine:nicotine /tmp/.Xauthority

[ -n "$TZ" ] && [ -f "/usr/share/zoneinfo/$TZ" ] && ln -sf "/usr/share/zoneinfo/$TZ" /etc/localtime

NOVNC_PORT=${NOVNC_PORT:-6080}

[ ! -f /etc/supervisord.conf ] && username=$(getent passwd "$PUID" | cut -d: -f1) && echo "[supervisord]
user=$username
nodaemon=true
logfile = /tmp/supervisord.log
pidfile = /tmp/supervisord.pid
directory = /tmp
childlogdir = /tmp

[program:tigervnc]
user=$username
environment=HOME="/tmp",DISPLAY=":1",USER="$username"
command=/usr/bin/Xtigervnc -desktop nicotine -auth /tmp/.Xauthority -rfbport 5900 -nopn -rfbauth /tmp/passwd -quiet -AlwaysShared $noauth :1
autorestart=true
priority=100

[program:openbox]
user=$username
environment=HOME="/tmp",DISPLAY=":1",USER="$username"
command=/usr/bin/openbox
autorestart=true
priority=200

[program:novnc]
user=$username
environment=HOME="/tmp",DISPLAY=":1",USER="$username"
command=/usr/share/novnc/utils/novnc_proxy --listen ${NOVNC_PORT}
autorestart=true
priority=300

[program:nicotine]
user=$username
environment=HOME="/data",DISPLAY=":1",USER="$username"
command=/usr/bin/nicotine
autorestart=true
priority=400" > /etc/supervisord.conf
exec /usr/bin/supervisord -c /etc/supervisord.conf
