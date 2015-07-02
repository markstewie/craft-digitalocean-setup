# craft-digitalocean-setup
A super fast way to get a DigitalOcean server up and running, customised for Craft CMS and deploying with Capistrano

## Instructions

1. Create a DigitalOcean droplet
2. Point your domain to the IP for that new droplet
3. ssh into your new droplet

Once you have ssh'd in... run the following commands

  ```
  apt-get update
  apt-get install git-core
  git clone https://github.com/markstewie/craft-digitalocean-setup.git
  cd craft-digitalocean-setup

  # TO BEGIN...
  bash install.sh
  ```

Then simply follow the instructions
