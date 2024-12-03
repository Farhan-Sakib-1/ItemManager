# Stage 1: Build the Angular app
FROM node:20 AS build

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json to install dependencies
COPY package*.json ./

# Install the npm dependencies
RUN npm install

# Copy the rest of the application code to the container
COPY . .

# Build the Angular app for production
RUN npm run build

# Debugging Step: List contents of the build output directory
RUN echo "Contents of /app/dist/item-management-angular/browser/" && ls -l /app/dist/item-management-angular/browser/

# Stage 2: Serve the app using Nginx
FROM nginx:alpine

# Remove the default Nginx static files
RUN rm -rf /usr/share/nginx/html/*

# Debugging Step: List contents before copying
RUN echo "Contents of /usr/share/nginx/html before copying:" && ls -l /usr/share/nginx/html/

# Copy the Angular build output from the build stage to the Nginx web directory
COPY --from=build /app/dist/item-management-angular/browser/. /usr/share/nginx/html/

# Debugging Step: List contents after copying
RUN echo "Contents of /usr/share/nginx/html after copying:" && ls -l /usr/share/nginx/html/

# Copy a custom Nginx configuration file (optional)
COPY nginx.conf /etc/nginx/nginx.conf

# Ensure proper permissions (optional step for permissions)
RUN chmod -R 755 /usr/share/nginx/html

# Expose port 80 to the outside world
EXPOSE 80

# Start Nginx in the foreground (prevent it from running as a daemon)
CMD ["nginx", "-g", "daemon off;"]
