# Stage 1: Compile and Build angular codebase

# Use official node image as the base image
FROM node:lts-alpine3.18 as build

# Set the working directory
WORKDIR /usr/app

COPY ./angular.json /usr/app/angular.json
COPY ./tsconfig.json /usr/app/tsconfig.json
COPY ./tsconfig.app.json /usr/app/tsconfig.app.json
COPY ./tsconfig.spec.json /usr/app/tsconfig.spec.json

# Install all the dependencies
COPY ./package.json /usr/app/package.json
RUN npm install

# Add the source code to app
COPY ./src /usr/app/src

# Generate the build of the application
RUN npm run build

# Stage 2: Serve app with nginx server

# Use official nginx image as the base image
FROM nginx:latest

# Copy the build output to replace the default nginx contents.
COPY --from=build /usr/app/dist/open-umbrella /usr/share/nginx/html
COPY ./my.conf /etc/nginx/conf.d/my.conf

# Expose port 80
EXPOSE 80