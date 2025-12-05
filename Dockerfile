FROM php:8.2

RUN apt-get update && apt-get install -y \
    git curl zip unzip libpng-dev libonig-dev libxml2-dev libzip-dev \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY . .

# Install dependencies
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Buat folder storage & cache setelah composer selesai
RUN mkdir -p storage/framework/cache \
    storage/framework/sessions \
    storage/framework/views \
    bootstrap/cache \
    && chmod -R 777 storage bootstrap/cache

# Bikin storage link (kalau gagal, lanjut saja)
RUN php artisan storage:link || true

# Laravel butuh key kalau APP_KEY belum ada
RUN php artisan key:generate --force || true

EXPOSE 8080

CMD php artisan serve --host=0.0.0.0 --port=${PORT}