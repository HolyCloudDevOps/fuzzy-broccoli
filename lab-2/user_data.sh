#! /bin/bash
apt update -y
apt install apache2 -y

MYIP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

echo "<h2>Webserver with Private IP: $MYIP</h2>" > /var/www/html/index.html

systemctl start apache2
systemctl enable apache2