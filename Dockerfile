# Get the newest nginx 
FROM nginx:latest

# Create the www directory within /usr/share/nginx/html
RUN mkdir -p /usr/share/nginx/html/www

# Copy the _site directory into the newly created www directory
COPY _site /usr/share/nginx/html/www/_site

# Copy the custom nginx configuration file
COPY default.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80
