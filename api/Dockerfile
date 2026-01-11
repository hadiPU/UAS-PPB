FROM php:8.2-apache

# Install mysqli extension
RUN docker-php-ext-install mysqli

# Enable mod_rewrite
RUN a2enmod rewrite

# Copy API files
COPY api/ /var/www/html/

# Copy Assets
COPY assets/ /var/www/html/assets/

# Permissions: Give www-data access to html and assets
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html \
    && chmod -R 775 /var/www/html/assets

WORKDIR /var/www/html