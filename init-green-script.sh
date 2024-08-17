#!/bin/bash

sudo yum update -y
sudo yum install httpd -y
sudo systemctl enable httpd
sudo systemctl start httpd
echo "green v1.2" > /var/www/html/index.html