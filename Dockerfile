FROM php:8.2-apache

# Install mysqli extension
RUN docker-php-ext-install mysqli

# Enable mod_rewrite (optional, but good practice for API/web apps)
RUN a2enmod rewrite

# Copy local code to the container image.
# We copy the 'api' directory contents to /var/www/html
COPY . /var/www/html/

# Set working directory
WORKDIR /var/www/html