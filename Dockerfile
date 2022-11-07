# FROM nginx:1.15.2-alpine
# COPY build /var/www
# COPY nginx.conf /etc/nginx/nginx.conf
# EXPOSE 80
# ENTRYPOINT ["nginx","-g","daemon off;"]




FROM mhart/alpine-node:11 AS builder
WORKDIR /app
COPY . /app
RUN npm install
RUN npm run build


FROM nginx:1.15.2-alpine
COPY --from=builder /app/build /var/www/
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 8080
CMD ["nginx","-g","daemon off;"]




















































#FROM mhart/alpine-node:11 AS builder
#WORKDIR /app
#COPY . .
#RUN yarn run build

#FROM mhart/alpine-node
#RUN yarn global add serve
#WORKDIR /app
#COPY --from=builder /app/build .
#CMD ["serve", "-p", "80", "-s", "."]
