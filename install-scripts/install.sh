#!/bin/bash

######################
####  INSTALLER   ####
######################
#### Version 0.02 ####
######################

# Install needed packages
apt update && apt install curl git zip unzip fuse man -y

# Install Rclone
if [ -x "$(command -v rclone)" ]; then
    echo "Rclone already installed..."
else
    curl https://rclone.org/install.sh |  bash -s beta
fi

# Install Mergerfs
id="$(grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')"
version_codename="$(grep -oP '(?<=^VERSION_CODENAME=).+' /etc/os-release | tr -d '"')"
mergerfs="/tmp/mergerfs.deb"
mergerfs_latest="$(curl -s -o /dev/null -I -w "%{redirect_url}\n" https://github.com/trapexit/mergerfs/releases/latest | grep -oP "[0-9]+(\.[0-9]+)+$")"
url="https://github.com/trapexit/mergerfs/releases/download/$mergerfs_latest/mergerfs_$mergerfs_latest.$id-${version_codename}_amd64.deb"
if [ -x "$(command -v mergerfs)" ]; then
    echo
    echo "Mergerfs already installed..."
    read -p "Install/Update anyway (y/n)? " answer </dev/tty
    if [ "$answer" != "${answer#[Yy]}" ]; then
        rm -rf /usr/bin/mergerfs
        curl -fsSL $url -o $mergerfs
        chmod +x $mergerfs
        dpkg -i $mergerfs
        chown root /usr/bin/mergerfs
        chmod u+s /usr/bin/mergerfs
    fi
else
    curl -fsSL $url -o $mergerfs
    chmod +x $mergerfs
    dpkg -i $mergerfs
    chown root /usr/bin/mergerfs
    chmod u+s /usr/bin/mergerfs
fi
rm $mergerfs 2>/dev/null

# Install Docker
if [ -x "$(command -v docker)" ]; then
    echo
    echo "Docker already installed..."
    read -p "Run anyway (y/n)? " answer </dev/tty
    if [ "$answer" != "${answer#[Yy]}" ]; then
        rm -f /mnt/cloudstorage/install-scripts/install-docker.sh
        curl -fsSL https://get.docker.com -o /mnt/cloudstorage/install-scripts/install-docker.sh
        sh /mnt/cloudstorage/install-scripts/install-docker.sh
    fi
else
    mkdir -p /mnt/cloudstorage/install-scripts
    curl -fsSL https://get.docker.com -o /mnt/cloudstorage/install-scripts/install-docker.sh
    sh /mnt/cloudstorage/install-scripts/install-docker.sh 2>/dev/null
fi

# Install docker-compose
dockercompose="/usr/local/bin/docker-compose"
compose_ver="$(curl -s -o /dev/null -I -w "%{redirect_url}\n" https://github.com/docker/compose/releases/latest | grep -oP "[0-9]+(\.[0-9]+)+$")"
compose_url="https://github.com/docker/compose/releases/download/${compose_ver}/docker-compose-$(uname -s)-$(uname -m)"
if [ -f "$dockercompose" ]; then
    echo
    echo "docker-compose already installed..."
    read -p "Install/Update anyway (y/n)? " answer </dev/tty
    if [ "$answer" != "${answer#[Yy]}" ]; then
        rm -rf $dockercompose
        curl -L $compose_url -o $dockercompose
        chmod +x $dockercompose
        docker-compose --version
    fi
else
    curl -L $compose_url -o $dockercompose
    chmod +x $dockercompose
fi

# Install Portainer
portainercheck="portainer"
if  docker ps -a --format '{{.Names}}' | grep -Eq "^${portainercheck}\$"; then
    echo
    echo "Portainer already installed..."
else
    echo "Installing Portainer..."
    docker volume create portainer_data
    docker run -d \
    -p 8000:8000 -p 9000:9000 \
    --name=portainer --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    portainer/portainer
fi

# Install WatchTower
watchtowercheck="watchtower"
if docker ps -a --format '{{.Names}}' | grep -Eq "^${watchtowercheck}\$"; then
    echo
    echo "WatchTower already installed..."
else
    echo "Installing WatchTower..."
    docker run -d \
    --name=watchtower \
    -v /var/run/docker.sock:/var/run/docker.sock \
    containrrr/watchtower \
    --cleanup --schedule "0 */6 * * *"
fi

# Install Rclone Scripts and create directories
cloudstorage="/mnt/cloudstorage"
rclonescripts="/mnt/cloudstorage/rclone"
installscripts="/mnt/cloudstorage/install-scripts"
extras="/mnt/cloudstorage/extras"
bin="/usr/local/bin"
mkdir -p $cloudstorage $rclonescripts $installscripts $extras
if [ -f "$cloudstorage/.update" ]; then
    echo
    echo "CloudStorage scripts already installed"
    read -p "Overwrite/Update current scripts (y/n)? " answer </dev/tty
    if [ "$answer" != "${answer#[Yy]}" ]; then
        rm $bin/rclone-mount $bin/rclone-unmount $bin/rclone-upload 2>/dev/null
        rm -rf $rclonescripts/* $installscripts/* $extras/* 2>/dev/null
        curl -fsSL https://raw.githubusercontent.com/SenpaiBox/CloudStorage/master/rclone/rclone-mount.sh -o $rclonescripts/rclone-mount 2>/dev/null
        curl -fsSL https://raw.githubusercontent.com/SenpaiBox/CloudStorage/master/rclone/rclone-unmount.sh -o $rclonescripts/rclone-unmount 2>/dev/null
        curl -fsSL https://raw.githubusercontent.com/SenpaiBox/CloudStorage/master/rclone/rclone-upload.sh -o $rclonescripts/rclone-upload 2>/dev/null
        curl -fsSL https://raw.githubusercontent.com/SenpaiBox/CloudStorage/master/install-scripts/install.sh -o $installscripts/install.sh 2>/dev/null
        curl -fsSL https://raw.githubusercontent.com/SenpaiBox/CloudStorage/master/extras/add-to-cron.sh -o $extras/add-to-cron.sh 2>/dev/null
        curl -fsSL https://raw.githubusercontent.com/SenpaiBox/CloudStorage/master/extras/watchtower-notification.sh -o $extras/watchtower-notification.sh 2>/dev/null
        curl -fsSL https://raw.githubusercontent.com/SenpaiBox/CloudStorage/master/extras/docker-memory-tweak.sh -o $extras/docker-memory-tweak.sh 2>/dev/null
        ln $rclonescripts/rclone-mount $rclonescripts/rclone-unmount $rclonescripts/rclone-upload /usr/local/bin 2>/dev/null
        echo
        echo "================================"
        echo "Scripts have been overwritten!"
        echo "You need to reconfigure your Rclone scripts"
        echo
    fi
else
    touch $cloudstorage/.update
    curl -fsSL https://raw.githubusercontent.com/SenpaiBox/CloudStorage/master/rclone/rclone-mount.sh -o $rclonescripts/rclone-mount 2>/dev/null
    curl -fsSL https://raw.githubusercontent.com/SenpaiBox/CloudStorage/master/rclone/rclone-unmount.sh -o $rclonescripts/rclone-unmount 2>/dev/null
    curl -fsSL https://raw.githubusercontent.com/SenpaiBox/CloudStorage/master/rclone/rclone-upload.sh -o $rclonescripts/rclone-upload 2>/dev/null
    curl -fsSL https://raw.githubusercontent.com/SenpaiBox/CloudStorage/master/install-scripts/install.sh -o $installscripts/install.sh 2>/dev/null
    curl -fsSL https://raw.githubusercontent.com/SenpaiBox/CloudStorage/master/extras/add-to-cron.sh -o $extras/add-to-cron.sh 2>/dev/null
    curl -fsSL https://raw.githubusercontent.com/SenpaiBox/CloudStorage/master/extras/watchtower-notification.sh -o $extras/watchtower-notification.sh 2>/dev/null
    curl -fsSL https://raw.githubusercontent.com/SenpaiBox/CloudStorage/master/extras/docker-memory-tweak.sh -o $extras/docker-memory-tweak.sh 2>/dev/null
    ln $rclonescripts/rclone-mount $rclonescripts/rclone-unmount $rclonescripts/rclone-upload /usr/local/bin 2>/dev/null
fi

# Apply permissions
currentuser=$(who | awk '{print $1}')}
chmod -R 775 /mnt 2>/dev/null
chown -R ${currentuser}:${currentuser} /mnt 2>/dev/null

# Install complete
tee <<-EOF

======= INSTALL COMPLETE =======
================================
EOF
mergerfs -v
tee <<-EOF
================================
EOF
rclone --version
tee <<-EOF
================================
EOF
docker -v
docker-compose --version
tee <<-EOF

NOTE: First time install
    To run Docker without root do the following:
    [1] "usermod -aG docker $USER"
    [2] Relog afterwards

Rclone scripts have been added to Path. You can run them from any directory.
For updates please visit: https://github.com/SenpaiBox/CloudStorage

EOF
exit