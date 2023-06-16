#!/usr/bin/env bash
set -xe

export DEBIAN_FRONTEND=noninteractive

sudo apt install -y fail2ban auditd re2c gcc pyzor make unzip

# DCC
wget -O /tmp/dcc.tar.Z wget http://www.dcc-servers.net/dcc/source/dcc.tar.Z
tar xzvf /tmp/dcc.tar.Z
cd dcc-* && ./configure && make && sudo make install
sudo tee /lib/systemd/system/dcc.service > /dev/null << EOL 
[Unit]
Description=DCC (Distributed Checksum Clearinghouses) interface daemon
After=remote-fs.target systemd-journald-dev-log.socket

[Service]
Type=forking
PermissionsStartOnly=true
RuntimeDirectory=dcc
ExecStart=/var/dcc/libexec/dccifd
User=root
Group=root
Nice=1

#DCC writes pid file with "-" at the beginning which confuses systemd
#PIDFile=/run/dcc/dccifd.pid

[Install]
WantedBy=multi-user.target
EOL
sudo systemctl daemon-reload
sudo systemctl enable dcc

# geolocation and re2c
sudo wget -O /etc/cron.hourly/sa-update sa.schaal-it.net/sa-update \
  && chown root.root /etc/cron.hourly/sa-update \
  && chmod 755 /etc/cron.hourly/sa-update
sudo sed -i 's/sa.schaal-it.net/sa.schaal-it.net\nupdates.spamassassin.org\nspamassassin.heinlein-support.de/' /etc/cron.hourly/sa-update

sudo wget -O /etc/cron.hourly/geoip_update \
  https://mailfud.org/geoip-legacy/geoip_update.sh \
  && chown root.root /etc/cron.hourly/geoip_update \
  && chmod 755 /etc/cron.hourly/geoip_update

sudo /etc/cron.hourly/geoip_update

sudo mkdir /etc/pmg/templates/
sudo cp /var/lib/pmg/templates/init.pre.in /etc/pmg/templates/
sudo cp /var/lib/pmg/templates/main.cf.in /etc/pmg/templates/main.cf.in
sudo tee -a /etc/pmg/templates/init.pre.in > /dev/null << EOL
loadplugin Mail::SpamAssassin::Plugin::Pyzor
use_pyzor 1

loadplugin Mail::SpamAssassin::Plugin::DCC
dcc_path /usr/local/bin/dccproc
dcc_home /var/dcc
dcc_dccifd_path /var/dcc/dccifd
dcc_body_max 999999
dcc_fuz1_max 999999
dcc_fuz2_max 999999
use_dcc 1
dcc_timeout 10

loadplugin Mail::SpamAssassin::Plugin::RelayCountry
EOL

sudo tee -a /etc/mail/spamassassin/custom.cf > /dev/null << EOL
ifplugin Mail::SpamAssassin::Plugin::RelayCountry
add_header all Relay-Country _RELAYCOUNTRY_
header RELAYCOUNTRY_BAD X-Relay-Countries =~ /(CN|RU|UA|RO|VN)/
describe RELAYCOUNTRY_BAD Relayed through spammy country at some point
score RELAYCOUNTRY_BAD 2.0
header RELAYCOUNTRY_GOOD X-Relay-Countries =~ /^(CO|AT|CH)/
describe RELAYCOUNTRY_GOOD First untrusted GW is CO, AT or CH
score RELAYCOUNTRY_GOOD -0.5
endif # Mail::SpamAssassin::Plugin::RelayCountry

header RCVD_IN_BRBL eval:check_rbl('brbl-lastexternal', 'b.barracudacentral.org.', '127.0.0.2')
describe RCVD_IN_BRBL Received via a relay in Barracuda RBL
tflags RCVD_IN_BRBL net
score RCVD_IN_BRBL 1.4

header RCVD_IN_NIX_SPAM eval:check_rbl('nix-spam-lastexternal', 'ix.dnsbl.manitu.net.')
describe RCVD_IN_NIX_SPAM Listed in NiX Spam DNSBL (heise.de)
tflags RCVD_IN_NIX_SPAM net
score RCVD_IN_NIX_SPAM 1.4

header RCVD_IN_WPBL eval:check_rbl('wpbl-lastexternal', 'db.wpbl.info.', '127.0.0.2')
describe RCVD_IN_WPBL Listed in WPBL
tflags RCVD_IN_WPBL net
score RCVD_IN_WPBL 1.4

EOL

sudo pmgconfig sync --restart 1 \
  && spamassassin -D --lint \
  && systemctl restart pmg-smtp-filter \

sudo tee /etc/postfix/header_checks > /dev/null << EOL
/^From:/ INFO
/^To:/ INFO
/^Subject:/ INFO
EOL

# clamav unoffical
sudo mkdir -p /etc/clamav-unofficial-sigs/ \
  /var/lib/clamav-unofficial-sigs/ \
  /var/log/clamav-unofficial-sigs/ \
  && sudo chown clamav:clamav /var/lib/clamav-unofficial-sigs \
  && sudo curl https://raw.githubusercontent.com/extremeshok/clamav-unofficial-sigs/master/clamav-unofficial-sigs.sh \
    -o /usr/local/sbin/clamav-unofficial-sigs \
  && sudo curl https://raw.githubusercontent.com/extremeshok/clamav-unofficial-sigs/master/config/master.conf \
    -o /etc/clamav-unofficial-sigs/master.conf \
  && sudo curl https://raw.githubusercontent.com/extremeshok/clamav-unofficial-sigs/master/config/user.conf \
    -o /etc/clamav-unofficial-sigs/user.conf \
  && sudo curl https://raw.githubusercontent.com/extremeshok/clamav-unofficial-sigs/master/config/os/debian.conf \
    -o /etc/clamav-unofficial-sigs/os.conf \
  && sudo chmod 755 /usr/local/sbin/clamav-unofficial-sigs

sudo /usr/local/sbin/clamav-unofficial-sigs.sh --install-cron \
  && sudo /usr/local/sbin/clamav-unofficial-sigs.sh --install-logrotate \
  && sudo usr/local/sbin/clamav-unofficial-sigs.sh --install-man \
  && sudo /usr/local/sbin/clamav-unofficial-sigs.sh

sudo curl https://raw.githubusercontent.com/extremeshok/clamav-unofficial-sigs/master/systemd/clamav-unofficial-sigs.service \
    -o /etc/systemd/clamav-unofficial-sigs.service \
  && sudo curl https://raw.githubusercontent.com/extremeshok/clamav-unofficial-sigs/master/systemd/clamav-unofficial-sigs.timer \
    -o /etc/systemd/clamav-unofficial-sigs.service \
  && sudo curl https://raw.githubusercontent.com/extremeshok/clamav-unofficial-sigs/master/systemd/clamd.scan.service \
    -o /etc/systemd/clamd.scan.service

sudo systemctl daemon-reload
# EBL
sudo tee -a /etc/mail/spamassassin/v342.pre > /dev/null << EOL
loadplugin Mail::SpamAssassin::Plugin::HashBL
EOL

sudo tee -a /etc/mail/spamassassin/custom.cf > /dev/null << EOL
ifplugin Mail::SpamAssassin::Plugin::HashBL
header HASHBL_EMAIL eval:check_hashbl_emails('ebl.msbl.org')
describe HASHBL_EMAIL Message contains email address found on EBL
score HASHBL_EMAIL 1.0
endif
EOL

sudo tee -a /etc/pmg/templates/main.cf.in > /dev/null << EOL
disable_vrfy_command = yes
EOL

# fail2ban
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

sudo tee /etc/fail2ban/filter.d/postfix-auth.conf >/dev/null <<EOL
# Fail2ban postfix-auth filter
[INCLUDES]
before = common.conf

[Definition]
_daemon = postfix/smtpd
failregex = ^%(__prefix_line)slost connection after .*\[<HOST>\]$
ignoreregex =
EOL

sudo tee  /etc/fail2ban/filter.d/postfix-hangup.conf >/dev/null <<EOL
[Definition]

failregex = postscreen\[\d+\]: HANGUP .* from \[<HOST>\]:\d+

ignoreregex =
EOL

sudo wget -O /etc/fail2ban/filter.d/postfix-pregreet.iredmail.conf \
  https://raw.githubusercontent.com/iredmail/iRedMail/master/samples/fail2ban/filter.d/postfix-pregreet.iredmail.conf

sudo tee -a /etc/fail2ban/jail.local >/dev/null << EOL

[postfix-auth]
enabled  = true
port     = smtp,ssmtp,28,27
filter   = postfix-auth
action   = iptables[name=SMTP-auth, port=smtp, protocol=tcp]
logpath  = /var/log/mail.info
maxretry = 2
bantime = 36000
findtime = 300

[postfix-pregreet-iredmail]
enabled     = true
filter      = postfix-pregreet.iredmail
logpath     = /var/log/syslog
maxretry    = 1
action      = iptables-multiport[name=postfix, port="25", protocol=tcp]

[postfix-hangup]
enabled = true
port = smtp
filter = postfix-hangup
action = iptables[name=postfix-hangup, port=smtp, protocol=tcp]
logpath = /var/log/mail.log
bantime = 172800
findtime = 86400
maxretry = 2
EOL

# auditd

sudo apt purge -y gcc make
sudo apt autoremove -y
