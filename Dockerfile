FROM php:8.2-apache

# 1. Install System Dependencies & PHP Extensions
RUN apt-get update && apt-get install -y \
    libpng-dev libjpeg-dev libfreetype6-dev zip unzip git libzip-dev libpq-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql pdo_pgsql pgsql zip bcmath \
    && a2enmod rewrite

# 2. Set Document Root to Laravel's Public Directory
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf

# 3. Copy Application Code & Install Composer
COPY . /var/www/html
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
WORKDIR /var/www/html

RUN composer install --no-interaction --optimize-autoloader --no-dev

# 4. Set Correct Permissions for Storage
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 80
CMD ["apache2-foreground"]
