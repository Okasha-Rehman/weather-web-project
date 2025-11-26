#!/bin/bash
sudo systemctl start tomcat.service
sudo systemctl enable tomcat.service
sudo systemctl start httpd.service
sudo systemctl enable httpd.service
echo "Tomcat and Apache HTTP Server have been started and enabled to start on boot."