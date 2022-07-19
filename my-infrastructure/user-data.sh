#! /bin/bash
sudo apt update
sudo apt install -y apache2
hostname=$(hostname -I)
echo "<html>" > index.html
echo "<p>Hello world ${hostname}</p>" >> index.html
echo "</html>" >> index.html
sudo cp index.html /var/www/html/index.html