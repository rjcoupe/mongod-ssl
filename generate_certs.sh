mongo_cert=`mktemp`
mongo_key=`mktemp`
openssl req -new -x509 -days 36500 -nodes -subj '/CN=localhost/O=Comuglobalhypermeganet/C=UK' -out $mongo_cert -keyout $mongo_key
sh -c "mkdir -p /etc/ssl && cat $mongo_cert $mongo_key > /etc/ssl/mongo.pem"
