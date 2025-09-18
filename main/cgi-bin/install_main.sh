chmod 755 *.cgi *.pl
chmod 666 *.txt XFileConfig.pm ../htdocs/emb.html Templates/static/*
chmod 777 ../htdocs/captchas ../htdocs/upload-data Templates/static

wget https://sibsoft.net/xvideosharing/dbip-country-lite-2021-10.mmdb.gz -O GeoLite2-Country.mmdb.gz;gzip -d GeoLite2-Country.mmdb.gz

chown -R apache:apache ../*
