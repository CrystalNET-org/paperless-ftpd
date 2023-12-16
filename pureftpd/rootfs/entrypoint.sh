#!/bin/bash

mkfifo /tmp/pureftpd.log
tail -f /tmp/pureftpd.log &

/opt/pureftpd/sbin/pure-ftpd /opt/pureftpd/etc/pureftpd.conf