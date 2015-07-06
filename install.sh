echo "============================================================";
echo "=== WELCOME TO THE FASTEST DIGITAL OCEAN SETUP FOR CRAFT ===";
echo "============================================================";
echo " ";
echo "Answer the questions and fill in the blanks... let's get started!";
echo " ";
echo "_________________________________________";
echo "=>> Your domain.";
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

# echo "_________________________________________";
# echo "=>> We need to make a small change to a nginx setup file.";
# read -p "    Uncomment line -> 'server_names_hash_bucket_size 64;' in following file and save when complete... " OK
# sudo nano /etc/nginx/nginx.conf

# COPY MODIFYIED PHP INI
cp files/php.ini /etc/php5/fpm/php.ini

# SECURE SERVER
echo "_________________________________________";
echo "=>> Next we need to secure the server.";
read -p "    Set new root/sudo password, be sure to make a note of it! " OK
passwd

echo "_________________________________________";
echo "=>> Next we need to add the new 'deploy' user who will also require a strong password";
read -p "    Add a strong password and enter through prompts that follow... " OK
adduser deploy

echo "_________________________________________";
echo "=>> Add 'deploy' to the list of sudoers";
read -p "    Add 'deploy   ALL=(ALL:ALL) ALL' in # User privilege specification section " OK
visudo

# ADD USER TO SUDO GROUP
gpasswd -a deploy sudo

# CHANGE WEB ROOT PERMISSIONS
chown -R deploy:deploy /var/www/$DOMAIN
chown -R deploy:deploy /var/www/staging.$DOMAIN
sudo chmod -R g+s /var/www/$DOMAIN
sudo chmod -R g+s /var/www/staging.$DOMAIN
mkdir -p /var/www/$DOMAIN/htdocs/shared/craft/app
mkdir -p /var/www/$DOMAIN/htdocs/shared/craft/storage
mkdir -p /var/www/staging.$DOMAIN/htdocs/shared/craft/app
mkdir -p /var/www/staging.$DOMAIN/htdocs/shared/craft/storage
sudo chmod -R 777 /var/www/$DOMAIN/htdocs/shared/craft/
sudo chmod -R 777 /var/www/staging.$DOMAIN/htdocs/shared/craft/

# SSH
echo "_________________________________________";
echo "=>> Add your personal ssh key";
read -p "    Copy your ssh public key from your computer using 'cat ~/.ssh/id_rsa.pub' and paste it in file that opens..." OK
mkdir /home/deploy/.ssh
chmod 700 /home/deploy/.ssh
nano /home/deploy/.ssh/authorized_keys

chmod 600 /home/deploy/.ssh/authorized_keys
chown -R deploy:deploy /home/deploy/.ssh

# CREATE SSH KEY FOR DEPLOY
echo "_________________________________________";
echo "=>> Create a new SSH key for deployment";
read -p "    Create a server ssh key for deployment. Copy when needed using 'cat ~/.ssh/id_rsa.pub when logged in as deploy:'" OK
sudo -u deploy ssh-keygen -t rsa

# COPY SSH CONFIG -> SSH LOGIN ONLY
sudo cp files/sshd_config /etc/ssh/sshd_config
sudo service ssh restart

echo "_________________________________________";
echo "=>> Run mysql_secure_installation, it's recommended to change the password."
read -p "    The current mysql password is shown when you first ssh'd into the droplet. (scroll up!)" OK
mysql_secure_installation

echo "_________________________________________";
echo "=>> Install additional packages";
read -p "    Type 'Y' when prompted... " OK
# INSTALL BASICS
sudo apt-get update
sudo apt-get install php5-cli
sudo apt-get install php5-mcrypt
sudo apt-get install unzip
sudo php5enmod mcrypt

sudo service nginx restart

echo " ";
echo " ";
echo "====================================================";
echo "=== ALL DONE. You should be able to ssh in with  ===";
echo "===    ssh deploy@yourdomain.com -p yourport     ==="
echo "====================================================";
echo " ";

