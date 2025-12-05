FROM php:8.2-fpm

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    zip \
    unzip \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libxml2-dev \
    libonig-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copy composer and install dependencies
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader

# Copy all project files
COPY . .

# Fix permissions (important)
RUN chmod -R 775 storage bootstrap/cache

# Create storage symlink
RUN php artisan storage:link || true

# Generate key if missing
RUN if [ ! -f .env ]; then cp .env.example .env; fi \
    && php artisan key:generate

EXPOSE 8000
CMD php artisan serve --host=0.0.0.0 --port=$PORT