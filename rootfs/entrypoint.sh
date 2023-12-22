#!/bin/bash

# WHY U NO LOG TO STDOUT?!?
# fucking ugly workaround to get our logs acessible within k8s and a readonly root with nonroot permissions
# Feel free to submit a PR if you have a better idea ;)
mkfifo /tmp/pureftpd.log
tail -f /tmp/pureftpd.log &

/opt/pureftpd/sbin/pure-authd -s /tmp/ftpd.sock -r /opt/pureftpd/sbin/paperless_auth &
/opt/pureftpd/sbin/pure-ftpd /opt/pureftpd/etc/pureftpd.conf