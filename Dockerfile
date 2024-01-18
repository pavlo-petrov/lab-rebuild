FROM node:14
USER node
WORKDIR /app

COPY ./app/package*.json ./app/yarn.lock* ./
RUN npm install 

COPY ./app/process.json ./app/server.js ./

EXPOSE 3000

CMD ["bash"]