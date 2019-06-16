#!/usr/bin/env sh

{
eval $(echo ${PROVISION_DIRECTORIES} | sed -r 's#([0-9]+):([0-9]+):([0-9]+):([^:;]+);?#install -d -o \1 -g \2 -m \3 \4 ; ls -dhn \4 ;#g')
} || {
echo "Invalid volume provision config (${PROVISION_DIRECTORIES})
expecting uid:gid:mode:dir(s) e.g. 1000:1000:0755:/var/www
Can contain multiple directories separated by space and/or multiple configs separated by ;
e.g.
1000:1000:0755:/var/www/html
1000:1000:0755:/var/www /var/www/html
1000:1000:0755:/var/www /var/www/html;1001:1001:0755:/var/app /var/app/cache"
exit 1
}
