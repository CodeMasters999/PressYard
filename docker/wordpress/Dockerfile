ARG WORDPRESS_BASE_IMAGE=wordpress:php8.2-apache
FROM ${WORDPRESS_BASE_IMAGE}

COPY docker/wordpress/pressyard-apache-entrypoint.sh /usr/local/bin/pressyard-apache-entrypoint.sh

RUN chmod +x /usr/local/bin/pressyard-apache-entrypoint.sh

ENTRYPOINT ["pressyard-apache-entrypoint.sh"]
CMD ["apache2-foreground"]
