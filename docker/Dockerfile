FROM node:7.10.0

RUN mkdir /Code
COPY Code/api /Code/api
COPY Code/node_modules /Code/node_modules
COPY Code/package.json /Code/package.json
COPY Code/server.js /Code/server.js

RUN mkdir /Code/webapp
COPY Code/webapp/css /Code/webapp/css
COPY Code/webapp/features /Code/webapp/features
COPY Code/webapp/img /Code/webapp/img
COPY Code/webapp/lib /Code/webapp/lib
COPY Code/webapp/node_modules /Code/webapp/node_modules
COPY Code/webapp/app.js /Code/webapp/app.js
COPY Code/webapp/index.html /Code/webapp/index.html
COPY Code/webapp/routes.js /Code/webapp/routes.js

COPY entrypoint.bash /entrypoint.bash

EXPOSE 3000

CMD ["/entrypoint.bash"]