mkdir temp
mkdir uploads

if [ $1 ]; then

echo "Special folder $1"
mkdir $1/temp
mkdir $1/uploads
mkdir $1/i
chmod 777 $1/*
ln -s $1/temp temp/01
ln -s $1/uploads uploads/01
ln -s $1/i ../htdocs/i/01

else

mkdir temp/01
mkdir uploads/01
mkdir ../htdocs/i/01

fi


chmod -R 777 temp uploads logs ../htdocs/i/01 ../htdocs/i

wget https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-linux64-gpl.tar.xz
tar -xf ffmpeg-master-latest-linux64-gpl.tar.xz
mv -f ffmpeg-*/bin/ffmpeg ./
mv -f ffmpeg-*/bin/ffprobe ./
rm -rf ffmpeg-*

chmod 755 *.cgi *.pl *.sh ffmpeg ffprobe
chmod 666 XFSConfig.pm
chown -R apache:apache ../*

./ffmpeg

if [ -d "/var/www/conf" ]
then
	mv /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.conf_bakk
	mv -f /var/www/conf/* /usr/local/nginx/conf/
	rm -rf /var/www/conf/
fi

echo -e "Enter \033[1;32mdl_key\033[m from your Admin Settings page:"
read dlkey
perl -pi -e "s/replace_with_dl_key/$dlkey/s;" /usr/local/nginx/conf/sites/xvs-fs.conf

echo -e "Enter file server \033[1;32mdomain name\033[m:"
read dom

sed -i "s/s1.xvs.tt/$dom/g" "/usr/local/nginx/conf/sites/xvs-fs.conf"

certbot --nginx --non-interactive --agree-tos --redirect --nginx-server-root /usr/local/nginx/conf --nginx-ctl /usr/local/nginx/sbin/nginx --register-unsafely-without-email --domains $dom
(crontab -l ; echo "0 0,12 * * * python3 -c 'import random; import time; time.sleep(random.random() * 3600)' && certbot renew") | crontab -
