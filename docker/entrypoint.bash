#! /bin/bash

echo "Waiting for mongo to be ready"
#no way to really know how long mongo will take to be ready
sleep 120

#configure the application
sed -i "s/app.set(\"host\",.*;/app.set(\"host\", \"$VIP_WEB.ignorelist.com\");/" "/Code/server.js"
sed -i "s/'callbackURL':.*/'callbackURL':'htt\/\/$VIP_WEB:3000\/auth\/google\/callback'/" "/Code/api/config/auth.js"
sed -i "s/'database':.*/'database':'mongodb:\/\/mongo\/admin',/" "/Code/api/config/config"

node /Code/server.js