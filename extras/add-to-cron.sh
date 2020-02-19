#!/bin/bash
# This will add rclone scripts to crontab
# You can only run this script once
# To view your cronjobs type in terminal "sudo crontab -l"
# If you need to edit the schedule type in terminal "sudo crontab -e"
# Logs are located in "/mnt/user/logs"

# CONFIGURE
media="googlevps" # VPS share name NOTE: The name you want to give your share mount

#########################################
#### DO NOT EDIT ANYTHING BELOW THIS ####
#########################################

appdata="/mnt/user/rclonedata/$media"
mkdir -p $appdata
if [ -f "$appdata/cron_job_added" ]; then
    echo "INFO: $(date "+%m/%d/%Y %r") - Cronjob already added please edit with \""crontab -e\"""
    exit
else
    echo "INFO: $(date "+%m/%d/%Y %r") - Added rclone scripts to crontab"
    touch $appdata/cron_job_added
    (crontab -l 2>/dev/null; echo "# Rclone scripts for \""${media}\""") | crontab -
    (crontab -l 2>/dev/null; echo "0 */1 * * * /mnt/user/vpscloudstorage/rclone/vps-mount.sh > /mnt/user/logs/vps-mount.log 2>&1") | crontab -
    (crontab -l 2>/dev/null; echo "*/15 * * * * /mnt/user/vpscloudstorage/rclone/vps-upload.sh > /mnt/user/logs/vps-upload.log 2>&1") | crontab -
    (crontab -l 2>/dev/null; echo "@reboot /mnt/user/vpscloudstorage/rclone/vps-unmount.sh > /mnt/user/logs/vps-unmount.log 2>&1") | crontab -
    /etc/init.d/cron reload
fi
exit