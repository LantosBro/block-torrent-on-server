
#!/bin/bash
#
# Credit to original author: sam https://github.com/nikzad-avasam/block-torrent-on-server
# GitHub:   https://github.com/nikzad-avasam/block-torrent-on-server
# Author:   sam nikzad
# Modify: LantosBro (https://github.com/lantosbro)

echo -n "Blocking all torrent traffic on your server. Please wait... "
wget -q -O/etc/trackers https://raw.githubusercontent.com/LantosBro/block-torrent-on-server/main/domains
cat >/etc/cron.daily/denypublic<<'EOF'
IFS=$'\n'
L=$(/usr/bin/sort /etc/trackers | /usr/bin/uniq)
for fn in $L; do
        /usr/sbin/ufw delete deny out to $fn
        /usr/sbin/ufw delete deny in to $fn
        /usr/sbin/ufw delete deny forward to $fn
        /usr/sbin/ufw deny out to $fn
        /usr/sbin/ufw deny in to $fn
        /usr/sbin/ufw deny forward to $fn
done
EOF
chmod +x /etc/cron.daily/denypublic
curl -s -LO https://raw.githubusercontent.com/LantosBro/block-torrent-on-server/main/Thosts
cat Thosts >> /etc/hosts
sort -uf /etc/hosts > /etc/hosts.uniq && mv /etc/hosts{.uniq,}
echo "Done."
