
#!/bin/bash
#
# Credit to original author: sam https://github.com/nikzad-avasam/block-torrent-on-server
# GitHub:   https://github.com/nikzad-avasam/block-torrent-on-server
# Author:   sam nikzad
# Modify: LantosBro (https://github.com/lantosbro)

echo -n "Blocking all torrent traffic on your server. Please wait... "
wget -q -O/etc/trackers https://raw.githubusercontent.com/LantosBro/block-torrent-on-server/main/domains
wget -q -O- https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all.txt | awk -F'[:/]' '{print $4}' | sort -u >> /etc/trackers
wget -q -O- https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all_ip.txt | awk -F'[:/]' '{print $2}' | sort -u > /etc/tracker_ips
cat >/etc/cron.daily/denypublic<<'EOF'
#!/bin/bash
rm /etc/trackers
rm /etc/tracker_ips
wget -q -O/etc/trackers https://raw.githubusercontent.com/LantosBro/block-torrent-on-server/main/domains
wget -q -O- https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all.txt | awk -F'[:/]' '{print $4}' | sort -u >> /etc/trackers
wget -q -O- https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all_ip.txt | awk -F'[:/]' '{print $2}' | sort -u > /etc/tracker_ips
IFS=$'\n'
L=$(/usr/bin/sort /etc/trackers | /usr/bin/uniq)
for fn in $L; do
        IPs=$(timeout 5 dig +short $fn)
        if [ $? -eq 124 ]; then
                echo "Timeout occurred for domain: $fn"
                continue
        fi
        if [ -z "$IPs" ]; then
                echo "No IP found for domain: $fn"
                continue
        fi
        for IP in $IPs; do
                /usr/sbin/ufw delete deny out to $IP
                /usr/sbin/ufw delete deny in from $IP
                /usr/sbin/ufw delete deny forward to $IP
                /usr/sbin/ufw deny out to $IP
                /usr/sbin/ufw deny in from $IP
                /usr/sbin/ufw deny forward to $IP
        done
done

L=$(/usr/bin/sort /etc/tracker_ips | /usr/bin/uniq)
for IP in $L; do
        /usr/sbin/ufw delete deny out to $IP
        /usr/sbin/ufw delete deny in from $IP
        /usr/sbin/ufw delete deny forward to $IP
        /usr/sbin/ufw deny out to $IP
        /usr/sbin/ufw deny in from $IP
        /usr/sbin/ufw deny forward to $IP
done

curl -s -LO https://raw.githubusercontent.com/LantosBro/block-torrent-on-server/main/Thosts
cat Thosts >> /etc/hosts
wget -q -O- https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all.txt | awk -F'[:/]' '{print "0.0.0.0", $4}' >> /etc/hosts
sort -uf /etc/hosts > /etc/hosts.uniq && mv /etc/hosts{.uniq,}
EOF
chmod +x /etc/cron.daily/denypublic
curl -s -LO https://raw.githubusercontent.com/LantosBro/block-torrent-on-server/main/Thosts
cat Thosts >> /etc/hosts
wget -q -O- https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all.txt | awk -F'[:/]' '{print "0.0.0.0", $4}' >> /etc/hosts
sort -uf /etc/hosts > /etc/hosts.uniq && mv /etc/hosts{.uniq,}
echo "Done."
