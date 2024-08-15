#!/bin/bash

sudo yum update -y
sudo yum install httpd -y
sudo systemctl enable httpd
sudo systemctl start httpd
echo "blue v1.0" > /var/www/html/index.html