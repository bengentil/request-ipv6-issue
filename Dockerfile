FROM node:latest

WORKDIR /app

RUN npm install request

COPY * /app/

ENTRYPOINT ["./entrypoint.sh"]