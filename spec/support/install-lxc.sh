#!/bin/bash
apt-get -qq update
cat <<EOF | tee /usr/sbin/policy-rc.d
#!/bin/sh
exit 101
EOF
chmod 755 /usr/sbin/policy-rc.d
apt-get -qq install lxc
