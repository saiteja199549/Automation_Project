#!/bin/bash


timestamp=$(date '+%d%m%Y-%H%M%S')
s3_bucket=upgrad-saiteja
myname=saiteja


sudo apt update -y #update the package information

apache2 -v > /dev/null

if [ $? -eq 0 ]
then
echo "apache2 is alraedy installed"
else
sudo apt install apache2 -y
fi


sudo apt install awscli -y

var=$(systemctl is-enabled apache2)
var1=$(systemctl is-active apache2)


if [ $var1 != "active" ]
then
sudo systemctl start apache2
else
echo "Apache2 already active"
fi


if [ $var != "enabled" ]
then
sudo systemctl enable apache2
else
echo "Apache2 Already enabled"
fi


cd /var/log/apache2/

tar -cvf /tmp/saiteja-httpd-logs-${timestamp}.tar *log



aws s3 cp /tmp/${myname}-httpd-logs-${timestamp}.tar s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar

size=`ls -lh /tmp/saiteja-httpd-logs-${timestamp}.tar |tr -s " " | cut -d " " -f5`


if [ -e "/var/www/html/inventory.html" ]
then

OUT=`echo -e '<tr> <td>httpd-logs</td> <td>'"${timestamp}"'</td> <td>tar</td>  <td>'"${size}"'</td> </tr>'`

sed -i -e '/<!-- insert here -->/ a '"${OUT}"'' /var/www/html/inventory.html

else

#create the format for inventory.html and add the data

touch /var/www/html/inventory.html
cd /var/www/html/
cat > inventory.html << EOF
<html>
<head>
<style>
table {
  font-family: arial, sans-serif;
  border-collapse: collapse;
  width: 100%;
}

td, th {
  border: 1px solid #dddddd;
  text-align: left;
  padding: 8px;
}

tr:nth-child(even) {
  background-color: #dddddd;

}
</style>
</head>

<body>

<h2>Inventory</h2>

<table>
  <tr>
    <th><b>Log Type</b></th>
    <th><b>Date Created</b></th>
    <th><b>type</b></th>
    <th><b>size</b></th>
  </tr>
<!-- insert here -->
  <tr>
    <td>httpd-logs</td>
    <td>${timestamp}</td>
    <td>tar</td>
    <td>${size}</td>
  </tr>

</table>

</body>
</html>
EOF


fi

if [ -e "/etc/cron.d/automation" ]
then

echo "CronJob already scheduled"

else

sudo echo "00 01 * * * root /root/Automation_Project/automation.sh" > /etc/cron.d/automation

sudo chmod 600 /etc/cron.d/automation

fi

