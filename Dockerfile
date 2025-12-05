FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    unzip \
    git \
    curl

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

# Copy all project files
COPY . .

# Install PHP extensions needed by Laravel
RUN docker-php-ext-install pdo_mysql

# Install dependencies
RUN composer install --no-dev --optimize-autoloader

# Set permissions (biar storage bisa nulis)
RUN chmod -R 775 storage bootstrap/cache

CMD ["php-fpm"]
