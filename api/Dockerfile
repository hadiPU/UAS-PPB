FROM php:8.2-apache

# Install mysqli extension
RUN docker-php-ext-install mysqli

# Enable mod_rewrite (optional, but good practice for API/web apps)
RUN a2enmod rewrite

# Copy API files to root web directory
COPY api/ /var/www/html/

# Copy Assets to assets directory
COPY assets/ /var/www/html/assets/

# Set working directory
WORKDIR /var/www/html