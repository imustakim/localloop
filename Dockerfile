# Base image for PHP 8.3 with FPM
FROM php:8.3-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    nginx \
    mariadb-client \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    zip unzip git curl \
    && docker-php-ext-install pdo pdo_mysql mysqli gd xml mbstring opcache

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy app source code
COPY . .

# Install Drupal dependencies (from composer.json)
RUN composer install --no-dev --optimize-autoloader

# Set correct file permissions for Drupal
RUN chown -R www-data:www-data /var/www/html

# Copy custom nginx config
COPY ./docker/nginx.conf /etc/nginx/nginx.conf

# Expose port 80
EXPOSE 80

# Start PHP-FPM and Nginx together
CMD service php8.3-fpm start && nginx -g 'daemon off;'
