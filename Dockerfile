FROM php:8.2

RUN apt-get update && apt-get install -y \
    git curl zip unzip libpng-dev libonig-dev libxml2-dev libzip-dev \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copy project
COPY . .

RUN chmod -R 777 storage bootstrap/cache

RUN composer install --no-dev --optimize-autoloader

# Storage symlink
RUN php artisan storage:link || true

# Clear cache (biar ga ngambek)
RUN php artisan optimize:clear

EXPOSE 8080

CMD ["php", "-S", "0.0.0.0:8080", "-t", "public"]
