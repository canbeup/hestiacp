#!/bin/bash

# load hestia.conf
source /usr/local/hestia/conf/hestia.conf

# Reset backend port
if [ ! -z "$BACKEND_PORT" ]; then
    /usr/local/hestia/bin/v-change-sys-port $BACKEND_PORT
fi

# Update Office 365 DNS templates
if [ -f /usr/local/hestia/data/templates/dns/o365.tpl ]; then
    rm -f /usr/local/hestia/data/templates/dns/o365.tpl 
    cp -f /usr/local/hestia/install/ubuntu/18.04/templates/dns/office365.tpl /usr/local/hestia/data/templates/dns/
fi

# Update default page templates
echo '************************************************************************'
echo "Upgrading default page templates..."
echo "Existing templates have been backed up to /root/hestia_backup/templates/"
echo '************************************************************************'

if [ -d /usr/local/hestia/data/templates/ ]; then
    # Back up old template set
    mkdir -p /root/hestia_backup/templates/
    cp -rf /usr/local/hestia/data/templates/* /root/hestia_backup/templates/
    cp -rf /var/www/html/index.html /root/hestia_backup/templates/

    # Remove old default page templates
    rm -rf /usr/local/hestia/data/templates/web/skel/*
    rm -rf /usr/local/hestia/data/templates/web/suspend/*
    rm -rf /var/www/html/index.html
    mkdir -p /usr/local/hestia/data/templates/web/unassigned/

    # Copy new default templates to Hestia installation
    cp -rf /usr/local/hestia/install/ubuntu/18.04/templates/web/skel/* /usr/local/hestia/data/templates/web/skel/
    cp -rf /usr/local/hestia/install/ubuntu/18.04/templates/web/suspend/* /usr/local/hestia/data/templates/web/suspend/
    cp -rf /usr/local/hestia/install/ubuntu/18.04/templates/web/unassigned/* /usr/local/hestia/data/templates/web/unassigned/
    cp -rf /usr/local/hestia/install/ubuntu/18.04/templates/web/unassigned/* /var/www/html/

    # Correct permissions on CSS, JavaScript, and Font dependencies for unassigned hosts
    chmod 644 /var/www/html/*
    chmod 751 /var/www/html/css
    chmod 751 /var/www/html/js
    chmod 751 /var/www/html/webfonts
    
    # Correct permissions on CSS, JavaScript, and Font dependencies for default templates
    chmod 751 /usr/local/hestia/data/templates/web/skel/document_errors/css
    chmod 751 /usr/local/hestia/data/templates/web/skel/document_errors/js
    chmod 751 /usr/local/hestia/data/templates/web/skel/document_errors/webfonts
    chmod 751 /usr/local/hestia/data/templates/web/skel/public_*html/css
    chmod 751 /usr/local/hestia/data/templates/web/skel/public_*html/js
    chmod 751 /usr/local/hestia/data/templates/web/skel/public_*html/webfonts
    chmod 751 /usr/local/hestia/data/templates/web/suspend/css
    chmod 751 /usr/local/hestia/data/templates/web/suspend/js
    chmod 751 /usr/local/hestia/data/templates/web/suspend/webfonts
    chmod 751 /usr/local/hestia/data/templates/web/unassigned/css
    chmod 751 /usr/local/hestia/data/templates/web/unassigned/js
    chmod 751 /usr/local/hestia/data/templates/web/unassigned/webfonts
fi

# == Updated fix for https://goo.gl/3Nja3u ==
# Set Purge to false in roundcube config
if [ -f /etc/roundcube/config.inc.php ]; then
    sed -i "s/\['flag_for_deletion'] = 'Purge';/\['flag_for_deletion'] = false;/gI" /etc/roundcube/config.inc.php
fi
if [ -f /etc/roundcube/defaults.inc.php ]; then
    sed -i "s/\['flag_for_deletion'] = 'Purge';/\['flag_for_deletion'] = false;/gI" /etc/roundcube/defaults.inc.php
fi
if [ -f /etc/roundcube/main.inc.php ]; then
    sed -i "s/\['flag_for_deletion'] = 'Purge';/\['flag_for_deletion'] = false;/gI" /etc/roundcube/main.inc.php
fi

# Enable spell-check exception dictionary for Roundcube users
if [ -f /etc/roundcube/config.inc.php ]; then
    sed -i "s/\['spellcheck_dictionary'] = false;/\['spellcheck_dictionary'] = true;/gI" /etc/roundcube/config.inc.php
fi
if [ -f /etc/roundcube/defaults.inc.php ]; then
    sed -i "s/\['spellcheck_dictionary'] = false;/\['spellcheck_dictionary'] = true;/gI" /etc/roundcube/defaults.inc.php
fi
if [ -f /etc/roundcube/main.inc.php ]; then
    sed -i "s/\['spellcheck_dictionary'] = false;/\['spellcheck_dictionary'] = true;/gI" /etc/roundcube/main.inc.php
fi