FROM php:8.2

# Install PHP extensions & dependencies
RUN apt-get update && apt-get install -y \
    git curl zip unzip libpng-dev libonig-dev libxml2-dev libzip-dev \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copy project
COPY . .

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader --no-interaction

# ===== Tambahin STEP NODEJS & VITE BUILD =====
# Install NodeJS & NPM
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# Install JS dependencies & build assets
RUN npm install
RUN npm run build
# ============================================

# Buat folder storage & cache
RUN mkdir -p storage/framework/cache \
    storage/framework/sessions \
    storage/framework/views \
    bootstrap/cache \
    && chmod -R 777 storage bootstrap/cache

# Bikin storage link
RUN php artisan storage:link || true

# Generate APP_KEY kalo belum ada
RUN php artisan key:generate --force || true

EXPOSE 8080

CMD php artisan serve --host=0.0.0.0 --port=${PORT}