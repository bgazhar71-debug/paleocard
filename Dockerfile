FROM php:8.2

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libzip-dev \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set workdir
WORKDIR /var/www/html

# Copy composer files first (biar cache ga boros)
COPY composer.json composer.lock ./

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Copy the rest of the project
COPY . .

# Pastikan storage writable
RUN chmod -R 775 storage/ bootstrap/cache

# DO NOT generate app key here — biar runtime yang handle
# Nanti di Railway pakai:
# railway variables set APP_KEY=$(php artisan key:generate --show)

# Expose port (Railway pakai PORT var)
EXPOSE ${PORT}

# Start Laravel
CMD php artisan serve --host=0.0.0.0 --port=${PORT}
