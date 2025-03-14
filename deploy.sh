#!/bin/bash

echo "=== Iniciando Deployment do Site Extra Limpo ==="
echo ""

# Verificar se Docker está rodando
if ! docker info > /dev/null 2>&1; then
  echo "ERRO: O serviço Docker não parece estar rodando. Inicie o Docker primeiro."
  exit 1
fi

# Verificar e atualizar do repositório Git
echo "Verificando atualizações do repositório Git..."
if [ -d ".git" ]; then
  echo "Repositório Git encontrado. Atualizando código..."
  git pull
  if [ $? -ne 0 ]; then
    echo "⚠️ Aviso: Não foi possível atualizar o código do repositório."
    echo "Continuar mesmo assim? (s/n)"
    read resposta
    if [ "$resposta" != "s" ] && [ "$resposta" != "S" ]; then
      echo "Deployment cancelado pelo usuário."
      exit 1
    fi
  else
    echo "✅ Código atualizado com sucesso!"
  fi
else
  echo "⚠️ Diretório .git não encontrado. Pulando a atualização do código."
fi

# Limpar containers existentes
if docker ps -a | grep -q "extralimpo-site"; then
  echo "Parando e removendo containers existentes..."
  docker stop extralimpo-site > /dev/null 2>&1
  docker rm extralimpo-site > /dev/null 2>&1
fi

# Construir nova imagem
echo "Reconstruindo a imagem do container..."
docker-compose -f docker-compose-final.yml build

# Subir com docker-compose
echo "Iniciando container com configuração estável..."
docker-compose -f docker-compose-final.yml up -d

echo "Aguardando inicialização..."
sleep 5

# Verificar status
if docker ps | grep -q "extralimpo-site" && docker ps | grep -q "Up"; then
  echo "✅ Container iniciado com sucesso!"
  echo ""
  echo "Site acessível em: http://localhost:5467"
  echo ""
  
  # Mostrar logs iniciais
  echo "Logs iniciais:"
  docker logs extralimpo-site
  
  # Verificar saúde
  echo ""
  echo "Verificando endpoint de saúde..."
  curl -s http://localhost:5467/health || echo "Não foi possível acessar o endpoint de saúde"
  
  echo ""
  echo "Para monitorar logs em tempo real, execute:"
  echo "docker logs -f extralimpo-site"
  
  echo ""
  echo "Para parar o serviço, execute:"
  echo "docker-compose -f docker-compose-final.yml down"
else
  echo "❌ ERRO: Container não iniciou corretamente."
  echo "Verificando logs:"
  docker logs extralimpo-site
fi 