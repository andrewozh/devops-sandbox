#!/bin/bash -ex

tee /etc/yum.repos.d/mongodb-org-4.4.repo << EOF
[mongodb-org-4.4]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/8/mongodb-org/4.4/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-4.4.asc
EOF

tee /etc/yum.repos.d/pritunl.repo << EOF
[pritunl]
name=Pritunl Repository
baseurl=https://repo.pritunl.com/stable/yum/oraclelinux/8/
gpgcheck=1
enabled=1
EOF

rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-oracle
yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

yum -y remove iptables-services
systemctl stop firewalld.service
systemctl disable firewalld.service

gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 7568D9BB55FF9E5287D586017AE645C0CF8E292A
gpg --armor --export 7568D9BB55FF9E5287D586017AE645C0CF8E292A > key.tmp; rpm --import key.tmp; rm -f key.tmp

yum -y install pritunl mongodb-org
yum --allowerasing -y install pritunl-openvpn

dnf -y install dnf-automatic
sed -i \
  -e 's/apply_updates.*/apply_updates = yes/' \
  -e 's/download_updates.*/download_updates = yes/' \
  -e 's/upgrade_type.*/upgrade_type = security/' \
  /etc/dnf/automatic.conf

systemctl enable mongod pritunl dnf-automatic.timer
systemctl disable dnf-makecache.timer

cat <<EOF > /etc/logrotate.d/pritunl
/var/log/mongodb/*.log {
  daily
  missingok
  rotate 30
  compress
  delaycompress
  copytruncate
  notifempty
}
EOF

dnf install -y snapd
systemctl enable --now snapd.socket
systemctl start snapd
ln -s /var/lib/snapd/snap /snap
snap install core
snap refresh core

snap install --classic certbot
snao install certbot-dns-route53
ln -s /snap/bin/certbot /usr/bin/certbot

yum -y install unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o ~ec2-user/awscliv2.zip
unzip ~ec2-user/awscliv2.zip -d ~ec2-user
~ec2-user/aws/install -b /usr/bin
ln -s /usr/bin/aws /usr/local/bin/aws

yum -y install cronie
crontab -l | { cat; echo "0 0 10 * * /home/ec2-user/certbot/renew-cert.sh"; } | crontab -

reboot

