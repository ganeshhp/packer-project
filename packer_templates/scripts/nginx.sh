#!/bin/bash -e
echo "*** starting Nginx Configuration ***"
sudo cp /tmp/nginx.conf /etc/nginx/sites-enabled/
sudo cp /tmp/index.html /var/www/
sudo service nginx reload
