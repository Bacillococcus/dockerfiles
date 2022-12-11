#!/usr/bin/env bash

function rand_pass(){
 head /dev/urandom | tr -dc A-Za-z0-9 | head -c "$1" ; echo "";
}
export -f rand_pass

image_name=ghcr.io/bacillococcus/dockerfiles/ubuntu/openssh-server:latest
name=local_ssh
password=$(rand_pass 16)
port="2244"
echo "use password: $password"
echo "use port: $port"

if [ "$( sudo docker container inspect -f '{{.State.Status}}' "$name" )" != "running" ]; then
    sudo docker run --rm -it -d --name "$name" \
        -v "$1":/mount_drive \
        -p "$port":"$port" \
        -e port="$port" \
        "$image_name"
    change_port="echo \"    Port ${port}\" >> /etc/ssh/sshd_config"
    change_password_command="echo "developer:$password" | chpasswd"
    sudo docker exec --user=root "$name" bash -c "$change_port"
    sudo docker exec --user=root "$name" bash -c "$change_password_command"
    sudo docker exec --user=root "$name" bash -c "service ssh restart"

fi

ipaddress="$(sudo docker inspect -f '{{.NetworkSettings.Networks.bridge.IPAddress}}' "$name")"
ssh -p "$port" developer@"$ipaddress" #-L 9898:localhost:9898

while true; do
    read -p "Do you wish to stop the container? " yn
    case $yn in
        [Yy]* ) sudo docker stop "$name"; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
