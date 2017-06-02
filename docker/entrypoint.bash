#! /bin/bash

echo "Waiting for mongo to be ready"
#no way to really know how long mongo will take to be ready
sleep 120

#configure the application
sed -i "s/app.set(\"host\",.*;/app.set(\"host\", \"$VIP_WEB.ignorelist.com\");/" "/Code/server.js"
sed -i "s/'callbackURL':.*/'callbackURL':'http:\/\/$VIP_WEB.ignorelist.com\/auth\/google\/callback',/" "/Code/api/config/auth.js"
sed -i "s/'clientID':.*/'clientID':'119517664477-gcj01c4hrda64jlhihfmoq3ponn83nd8.apps.googleusercontent.com',/" "/Code/api/config/auth.js"
sed -i "s/'clientSecret':.*/'clientSecret':'yi_x_6QiScR2nq1M8e2L8nLx',/" "/Code/api/config/auth.js"
sed -i "s/'database':.*/'database':'mongodb:\/\/mongo\/admin',/" "/Code/api/config/config"

node /Code/server.js