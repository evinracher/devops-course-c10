hostname=$(hostname -I)
echo "<html>" > index.html
echo "<p>Hello world ${hostname}</p>" >> index.html
echo "</html>" >> index.html