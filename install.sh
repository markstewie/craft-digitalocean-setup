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

read -p "Uncomment line -> 'server_names_hash_bucket_size 64;' in following file and save when complete... " OK
sudo nano /etc/nginx/nginx.conf

# COPY MODIFYIED PHP INI
cp files/php.ini /etc/php5/fpm/php.ini

# SECURE SERVER
read -p "Set new root password, make a note of it! " OK
passwd

read -p "Add 'deploy' user " OK
adduser deploy

read -p "Add 'deploy    ALL=(ALL:ALL) ALL' in # User privilege specification section " OK
visudo

# ADD USER TO SUDO GROUP
gpasswd -a deploy sudo

# CHANGE WEB ROOT PERMISSIONS
chown -R deploy:deploy /var/www/$DOMAIN
chown -R deploy:deploy /var/www/staging.$DOMAIN
sudo chmod -R g+s /var/www/$DOMAIN
sudo chmod -R g+s /var/www/staging.$DOMAIN

# SSH
read -p "==== ADD YOUR PERSONAL SSH KEY ====\nCopy your ssh public key from your computer using 'cat ~/.ssh/id_rsa.pub' and paste it in file that opens..." OK
mkdir /home/deploy/.ssh
chmod 700 /home/deploy/.ssh
nano /home/deploy/.ssh/authorized_keys

chmod 600 /home/deploy/.ssh/authorized_keys
chown -R deploy:deploy /home/deploy/.ssh

# CREATE SSH KEY FOR DEPLOY
read -p "==== CREATE NEW SSH KEY FOR DEPLOYMENT====\nCreate a server ssh key for deployment. Copy when needed using 'cat ~/.ssh/id_rsa.pub :'" OK
sudo -u deploy ssh-keygen -t rsa

# WANT A SPECIAL PORT?
read -p "==== SSH PORT ====\nWhat port do you want to SSH in with? I use a random 5 digit number for super security. (Will be left as 22 by default) :" PORT
PORT=${PORT:-22}
sed -i -e "s/\${PORT}/$PORT/g" files/sshd_config
sudo cp files/sshd_config /etc/ssh/sshd_config

sudo service ssh restart

read -p "==== DATABASE ====\nSecure your database. Make notes of passwords." OK
mysql_secure_installation


# INSTALL BASICS
sudo apt-get update
sudo apt-get install php5-cli
sudo apt-get install php5-mcrypt
sudo php5enmod mcrypt

sudo service nginx restart

#sed -i -e "s/\${NAME}/$NAME/g" files/test.txt