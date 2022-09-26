if [ ! -f /tmp/pulseaudio.client.conf ]; then
    create_pulse_socket_and_config.sh
fi

sudo docker run --rm -it \
    --gpus all \
    -v /tmp/pulseaudio.socket:/tmp/pulseaudio.socket \
    -v /tmp/pulseaudio.client.conf:/etc/pulse/client.conf \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v /home/yourhomedirectory:/home/developer \
    -v /yourstreamlibary:/streamlibary \
    -e PULSE_SERVER=unix:/tmp/pulseaudio.socket \
    -e PULSE_COOKIE=/tmp/pulseaudio.cookie \
    -e DISPLAY=:0.0 \
    --shm-size=2G \
    --security-opt seccomp=unconfined \
    --security-opt apparmor=unconfined \
    --entrypoint steam \
    ghcr.io/bacillococcus/dockerfiles/ubuntu/nvidia-driver-steam:latest
