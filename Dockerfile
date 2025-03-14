# Use a imagem Alpine do Nginx que é mais leve e segura
FROM nginx:stable-alpine

# Adicione metadados ao container
LABEL maintainer="Extra Limpo <contato@extralimpo.com.br>"
LABEL version="1.0"
LABEL description="Site da Extra Limpo - Limpeza de estofados em Aracaju"

# Configure o fuso horário
ENV TZ=America/Recife

# Remova a configuração padrão do Nginx que não usamos
RUN rm -f /etc/nginx/conf.d/default.conf.default

# Criar configuração otimizada do Nginx diretamente
RUN echo 'server { \
    listen 80; \
    server_name _; \
    root /usr/share/nginx/html; \
    index index.html; \
    \
    # Configurações de buffer para melhor performance \
    client_body_buffer_size 10K; \
    client_header_buffer_size 1k; \
    client_max_body_size 8m; \
    large_client_header_buffers 2 1k; \
    \
    # Configurações de timeout \
    client_body_timeout 12; \
    client_header_timeout 12; \
    keepalive_timeout 15; \
    send_timeout 10; \
    \
    # Compressão gzip para melhorar a velocidade de carregamento \
    gzip on; \
    gzip_vary on; \
    gzip_min_length 10240; \
    gzip_proxied expired no-cache no-store private auth; \
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml; \
    gzip_disable "MSIE [1-6]\\."; \
    \
    # Cache para arquivos estáticos \
    location ~* \\.(jpg|jpeg|png|webp|gif|ico|svg|css|js|ttf|woff|woff2)$ { \
        expires 30d; \
        add_header Cache-Control "public, no-transform"; \
        access_log off; \
    } \
    \
    # Configuração principal \
    location / { \
        try_files $uri $uri/ /index.html; \
        \
        # Headers de segurança \
        add_header X-Frame-Options "SAMEORIGIN" always; \
        add_header X-XSS-Protection "1; mode=block" always; \
        add_header X-Content-Type-Options "nosniff" always; \
        add_header Referrer-Policy "strict-origin-when-cross-origin" always; \
        add_header Permissions-Policy "camera=(), microphone=(), geolocation=()"; \
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always; \
    } \
    \
    # Endpoint para health-check simples \
    location /health { \
        access_log off; \
        add_header Content-Type text/plain; \
        return 200 "OK"; \
    } \
    \
    # Endpoint para monitoramento (acessível apenas internamente) \
    location /stub_status { \
        stub_status on; \
        access_log off; \
        allow 127.0.0.1; \
        allow 172.16.0.0/12; \
        deny all; \
    } \
    \
    # Impedir acesso a arquivos ocultos \
    location ~ /\\.(?!well-known) { \
        deny all; \
        access_log off; \
        log_not_found off; \
    } \
    \
    # Configurações de log \
    access_log /var/log/nginx/access.log; \
    error_log /var/log/nginx/error.log warn; \
}' > /etc/nginx/conf.d/default.conf

# Desativar completamente os scripts de entrypoint originais
RUN rm -rf /docker-entrypoint.d/* && \
    rm -f /docker-entrypoint.sh

# Modifique arquivo principal do nginx.conf para remover diretiva "user"
RUN sed -i '/user  nginx;/d' /etc/nginx/nginx.conf && \
    echo "daemon off;" >> /etc/nginx/nginx.conf

# Crie diretórios necessários e configure permissões corretas
RUN mkdir -p /usr/share/nginx/html/assets && \
    mkdir -p /var/cache/nginx/client_temp && \
    mkdir -p /var/cache/nginx/proxy_temp && \
    mkdir -p /var/cache/nginx/fastcgi_temp && \
    mkdir -p /var/cache/nginx/uwsgi_temp && \
    mkdir -p /var/cache/nginx/scgi_temp && \
    mkdir -p /var/log/nginx && \
    chown -R nginx:nginx /usr/share/nginx && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    chmod -R 755 /var/cache/nginx && \
    chmod -R 755 /usr/share/nginx && \
    chmod -R 755 /var/log/nginx

# Copie o arquivo index.html para o diretório do Nginx
COPY ./index.html /usr/share/nginx/html/

# Copie a pasta assets para o diretório de recursos do Nginx
COPY ./assets /usr/share/nginx/html/assets/

# Adicione nosso script de entrada personalizado
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Corrija as permissões para todos os arquivos copiados
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html

# Limpe arquivos temporários e cache para reduzir o tamanho da imagem
RUN rm -rf /var/cache/apk/* && \
    rm -rf /tmp/*

# Configure um healthcheck menos agressivo e com mais tempo para inicialização
HEALTHCHECK --interval=60s --timeout=10s --start-period=30s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:80/health || exit 1

# Exponha a porta 80, que é a porta padrão do Nginx
EXPOSE 80

# Use nosso script de entrada personalizado
ENTRYPOINT ["/entrypoint.sh"]
