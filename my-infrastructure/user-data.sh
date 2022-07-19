#! /bin/bash
sudo apt-get update
sudo apt install apache2 --fix-missing -y
hostname=$(hostname -I)
echo "<html>" > index.html
echo "<p>Hello world ${hostname}</p>" >> index.html
echo "</html>" >> index.html
sudo cp index.html /var/www/html/index.html