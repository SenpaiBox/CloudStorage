#!/bin/bash
# Author: SenpaiBox
# URL: https://github.com/SenpaiBox/sbcloud
# Description: Automate uploading to your cloud storage. This uses "Mergerfs" for compatiability with
# Sonarr, Radarr, and streaming to Plex/Emby. Automate uploading from a local or
# remote machine running Ubuntu 18.04 or Debian 9/10.

if [ `whoami` != root ]; then
    echo "Warning! Please run as sudo/root"
    exit
fi
tee <<-NOTICE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
INSTALLER: SBCloud v0.07.5-Lite
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DISCLAIMER:
I am not responsible for anything that could go wrong.
I am not responsible for any data loss that could potentialy happen.
You agree to use these scripts at your own risk.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
NOTICE
sleep 3

tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
INFO: Rclone-Beta, MergerFS, and SBCloud scripts
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[1] Install/Update
[2] Update - Rclone Scripts Only
[3] Reinstall - Remove and reset
[4] Uninstall - Remove all

[5] Exit
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF

sbcloud="/mnt/sbcloud"
rclonescripts="$sbcloud/rclone"
installscripts="$sbcloud/install-scripts"
extras="$sbcloud/extras"
localbin="/usr/local/bin"
currentuser="$(who | awk '{print $1}')"
github="https://raw.githubusercontent.com/SenpaiBox/SBCloud/master"

read -p "Type a Number | Press [ENTER]: " answer </dev/tty
if [ "$answer" == "1" ]; then
    echo "Continue with install.."
    elif [ "$answer" == "2" ]; then
    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Downloading and installing Rclone scripts..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    mkdir -p $rclonescripts
    read -p "Overwrite/Update current scripts (y/n)? " answer </dev/tty
    if [ "$answer" != "${answer#[Yy]}" ]; then
        rm -rf $rclonescripts/*
        rm $localbin/rclone-mount $localbin/rclone-unmount $localbin/rclone-upload 2>/dev/null
        curl -fsSL $github/rclone/rclone-mount.sh -o $rclonescripts/rclone-mount 2>/dev/null
        curl -fsSL $github/rclone/rclone-unmount.sh -o $rclonescripts/rclone-unmount 2>/dev/null
        curl -fsSL $github/rclone/rclone-upload.sh -o $rclonescripts/rclone-upload 2>/dev/null
        chmod -R 755 $sbcloud 2>/dev/null
        chown -R ${currentuser}:${currentuser} $sbcloud 2>/dev/null
        echo "Applying hardlinks to rclone-mount, rclone-unmount, rclone-upload..."
        ln $rclonescripts/rclone-mount $rclonescripts/rclone-unmount $rclonescripts/rclone-upload $localbin 2>/dev/null
    fi
    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Rclone Scripts updated"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit
    elif [ "$answer" == "3" ]; then
    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Reinstall/Reset..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Uninstalling Rclone, MergerFS, and resetting SBCloud scripts..."
    sleep 2
    apt-get purge mergerfs -y && apt-get autoremove -y
    rm -rf $localbin/docker-compose /usr/bin/rclone $sbcloud 2>/dev/null
    rm $localbin/rclone-mount $localbin/rclone-unmount $localbin/rclone-upload $localbin/docker-manager $localbin/rclone-cron $localbin/sbcloud 2>/dev/null
    elif [ "$answer" == "4" ]; then
    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Uninstall/Remove all..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    read -p "Are you sure you want to Uninstall (y/n)? " answer </dev/tty
    if [ "$answer" != "${answer#[Yy]}" ]; then
        echo
        echo "Uninstalling Rclone, MergerFS, SBCloud scripts..."
        sleep 2
        rm -rf /usr/bin/rclone $sbcloud 2>/dev/null
        apt-get purge mergerfs -y && apt-get autoremove -y
        rm $localbin/rclone-mount $localbin/rclone-unmount $localbin/rclone-upload $localbin/docker-manager $localbin/rclone-cron $localbin/sbcloud 2>/dev/null
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "UNINSTALL COMPLETE"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        exit
    else
        exit
    fi
    elif [ "$answer" == "5" ]; then
    exit
fi

tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Installing prerequesites...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
apt-get update && apt-get upgrade -y && apt-get install curl git p7zip-full fuse man-db -y

tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Installing Rclone-Beta...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
sleep 2
if [ -x "$(command -v rclone)" ]; then
    echo
    echo "Rclone already installed..."
    read -p "Install/Update anyway (y/n)? " answer </dev/tty
    if [ "$answer" != "${answer#[Yy]}" ]; then
        rm -rf /usr/bin/rclone
        curl https://rclone.org/install.sh | bash -s beta
        mkdir -p $HOME/.config/rclone
        touch $HOME/.config/rclone/rclone.conf
        chown -R ${currentuser}:${currentuser} $HOME/.config/rclone 2>/dev/null
    fi
else
    curl https://rclone.org/install.sh |  bash -s beta
    mkdir -p $HOME/.config/rclone
    touch $HOME/.config/rclone/rclone.conf
    chown -R ${currentuser}:${currentuser} $HOME/.config/rclone 2>/dev/null
fi

tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Install MergerFS...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
sleep 2
id="$(grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')"
version_codename="$(grep -oP '(?<=^VERSION_CODENAME=).+' /etc/os-release | tr -d '"')"
mergerfs="/tmp/mergerfs.deb"
mergerfs_latest="$(curl -s -o /dev/null -I -w "%{redirect_url}\n" https://github.com/trapexit/mergerfs/releases/latest | grep -oP "[0-9]+(\.[0-9]+)+$")"
url="https://github.com/trapexit/mergerfs/releases/download/${mergerfs_latest}/mergerfs_${mergerfs_latest}.${id}-${version_codename}_amd64.deb"
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
find="$(cat /etc/fuse.conf | grep -c "#user_allow_other")"
if [ $find != 0 ]; then
    echo "Modifiying /etc/fuse.conf to user_allow_other"
    sed -i "s/#user_allow_other/user_allow_other/g" /etc/fuse.conf
else
    echo "Fuse is already set to user_allow_other"
fi

tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Setup SBCloud...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
sleep 2
mkdir -p $sbcloud $installscripts $extras
if [ -f "$sbcloud/.update" ]; then
    echo
    echo "SBCloud scripts already installed"
    read -p "Overwrite/Update current scripts (y/n)? " answer </dev/tty
    if [ "$answer" != "${answer#[Yy]}" ]; then
        rm $localbin/docker-manager $localbin/rclone-cron $localbin/sbcloud 2>/dev/null
        rm -rf $installscripts/* $extras/* 2>/dev/null
        curl -fsSL $github/install-scripts/sbcloud.sh -o $installscripts/sbcloud 2>/dev/null
        curl -fsSL $github/extras/rclone-cron.sh -o $extras/rclone-cron 2>/dev/null
        curl -fsSL $github/extras/docker-manager.sh -o $extras/docker-manager 2>/dev/null
        curl -fsSL $github/extras/docker-memory-tweak.sh -o $extras/docker-memory-tweak.sh 2>/dev/null
        echo "Applying hardlinks to docker-manager, rclone-cron"
        ln $extras/docker-manager $extras/rclone-cron $localbin 2>/dev/null
        echo "Applying hardlinks to sbcloud"
        ln $installscripts/sbcloud $localbin 2>/dev/null
        echo
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "SBCloud scripts updated!"
    fi
else
    echo
    echo "Downloading and installing SBCloud scripts..."
    sleep 2
    mkdir -p $sbcloud $installscripts $extras $rclonescripts
    touch $sbcloud/.update
    curl -fsSL $github/rclone/rclone-mount.sh -o $rclonescripts/rclone-mount 2>/dev/null
    curl -fsSL $github/rclone/rclone-unmount.sh -o $rclonescripts/rclone-unmount 2>/dev/null
    curl -fsSL $github/rclone/rclone-upload.sh -o $rclonescripts/rclone-upload 2>/dev/null
    curl -fsSL $github/install-scripts/sbcloud.sh -o $installscripts/sbcloud 2>/dev/null
    curl -fsSL $github/extras/rclone-cron.sh -o $extras/rclone-cron 2>/dev/null
    curl -fsSL $github/extras/docker-manager.sh -o $extras/docker-manager 2>/dev/null
    curl -fsSL $github/extras/docker-memory-tweak.sh -o $extras/docker-memory-tweak.sh 2>/dev/null
    sleep 1
    echo "Applying hardlinks to rclone-mount, rclone-unmount, rclone-upload..."
    ln $rclonescripts/rclone-mount $rclonescripts/rclone-unmount $rclonescripts/rclone-upload $localbin 2>/dev/null
    sleep 1
    echo "Applying hardlinks to docker-manager, rclone-cron"
    ln $extras/docker-manager $extras/rclone-cron $localbin 2>/dev/null
    sleep 1
    echo "Applying hardlinks to sbcloud"
    ln $installscripts/sbcloud $localbin 2>/dev/null
fi

# Apply permissions
chmod -R 755 $sbcloud 2>/dev/null
chown ${currentuser}:${currentuser} /mnt 2>/dev/null
chown -R ${currentuser}:${currentuser} $sbcloud 2>/dev/null
chown -R ${currentuser}:${currentuser} $HOME/.config/rclone 2>/dev/null

tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
INSTALL COMPLETE!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
mergerfs -v
tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
rclone --version
tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
For updates please visit: https://github.com/SenpaiBox/SBCloud

The following have been added to PATH:
rclone-mount - Mount your Cloud Drive
rclone-unmount - Unmount your Cloud Drive
rclone-upload - Upload to your Cloud Drive
rclone-cron - Add Rclone Scripts to Cron Tasks
docker-manager - Backup and Start/Stop containers
sbcloud - Runs this script again

Rclone Scripts Location: "/mnt/sbcloud/rclone"

EOF
exit