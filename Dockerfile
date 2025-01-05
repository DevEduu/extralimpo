# Use a imagem base do Nginx
FROM nginx:latest

# Copie o arquivo index.html para o diretório padrão do Nginx
COPY ./site/index.html /usr/share/nginx/html/

# Copie a pasta assets para o diretório de recursos do Nginx
COPY ./site/assets /usr/share/nginx/html/assets/

# Exponha a porta 80, que é a porta padrão do Nginx
EXPOSE 80

# Comando para iniciar o Nginx no container
CMD ["nginx", "-g", "daemon off;"]
