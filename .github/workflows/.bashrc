# linux-run.sh LINUX_USER_PASSWORD NGROK_AUTH_TOKEN LINUX_USERNAME LINUX_MACHINE_NAME
#!/bin/bash
# /home/runner/.ngrok2/ngrok.yml

sudo useradd -m $LINUX_USERNAME
sudo adduser $LINUX_USERNAME sudo
echo "$LINUX_USERNAME:$LINUX_USER_PASSWORD" | sudo chpasswd
sed -i 's/\/bin\/sh/\/bin\/bash/g' /etc/passwd
sudo hostname $LINUX_MACHINE_NAME

if [[ -z "$NGROK_AUTH_TOKEN" ]]; then
  echo "No se ha detectado ningún 'NGROK_AUTH_TOKEN' por favor colocalo para poder seguir."
  exit 2
fi

if [[ -z "$LINUX_USER_PASSWORD" ]]; then
  echo "No se ha detectado ningun 'LINUX_USER_PASSWORD' por favor colocalo para poder seguir: $USER"
  exit 3
fi

if [[ -z "$GIT_EMAIL" ]]; then
echo "El correo de github es obligatorio, y no se ha encontrado por ninguna parte."
exit 4
fi

if [[ -z "$GIT_NAME" ]]; then
echo "El nombre es obligatorio, y no se ha encotrado por ninguna parte"
exit 5
fi

bash linux-ssh.sh 

echo "### Instalando ngrok para el tunel ###"

wget -q https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-386.zip
unzip ngrok-stable-linux-386.zip
chmod +x ./ngrok

echo "### Actualizando contraseña de: $USER ###"
echo -e "$LINUX_USER_PASSWORD\n$LINUX_USER_PASSWORD" | sudo passwd "$USER"
echo sshpass -p $LINUX_USER_PASSWORD ssh $LINUX_USERNAME@$LINUX_MACHINE_NAME

echo "### Iniciando el servidor vps. ###"


rm -f .ngrok.log
./ngrok authtoken "$NGROK_AUTH_TOKEN"
./ngrok tcp 22 --log ".ngrok.log" &

sleep 10
HAS_ERRORS=$(grep "Lo sentimos, pero ha ocurrido un error insperado." < .ngrok.log)

if [[ -z "$HAS_ERRORS" ]]; then
  echo ""
  echo "=========================================="
  echo "Para conectarte utiliza: $(grep -o -E "tcp://(.+)" < .ngrok.log | sed "s/tcp:\/\//ssh $USER@/" | sed "s/:/ -p /")"
  echo "o para conectar con $(grep -o -E "tcp://(.+)" < .ngrok.log | sed "s/tcp:\/\//ssh $USER@/" | sed "s/:/ -p /")"
  echo "=========================================="
  
  
else
  echo "$HAS_ERRORS"
  exit 4
fi
