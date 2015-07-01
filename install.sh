read -p "What is the main domain of your site? e.g. example.com: " DOMAIN

# MAKE NECESSARY DIRECTORIES
mkdir -p /var/www/$DOMAIN/htdocs
mkdir -p /var/www/$DOMAIN/log
mkdir -p /var/www/staging.$DOMAIN/htdocs
mkdir -p /var/www/staging.$DOMAIN/log

# SETUP SITE CONFIG
sed -i -e "s/\${DOMAIN}/$DOMAIN/g" files/site.main
sed -i -e "s/\${DOMAIN}/$DOMAIN/g" files/site.staging
mv files/site.main /etc/nginx/sites-available/$DOMAIN
mv files/site.staging /etc/nginx/sites-available/staging.$DOMAIN

# ENABLE SITES
sudo rm /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/staging.$DOMAIN /etc/nginx/sites-enabled/

read -p "Uncomment line `server_names_hash_bucket_size 64;` in following file and save when complete. " OK
sudo nano /etc/nginx/nginx.conf

# COPY MODIFYIED PHP INI
cp files/php.ini /etc/php5/fpm/php.ini

# RESTART SERVER
sudo service nginx restart

# SECURE SERVER

# INSTALL BASICS
#sudo apt-get update



#sed -i -e "s/\${NAME}/$NAME/g" files/test.txt