# Container images list

 - ubuntu/nvidia-driver is an ubuntu image with nvidia driver note that the driver must match the system, there is nvidia container that provide a way to support different driver from host but there seems to have different license from the regular driver from ubuntu repo.
 - ubuntu/nvidia-driver-steam is an ubuntu image with nvidia driver and dependencies for steam, we can use this to run steam.
 - ubuntu/nvidia-driver-pycharm is an ubuntu image with nvidia driver and dependencies for pycharm, we can use this to run pycharm.

# How to use

For a container with graphics and audio do the following steps, we use steam as an example in this case.

To be able to connect with x11 and pulseaudio server for audio and graphics, we need to share x11 and pulseaudio socket.

First create a socket for pulseaudio.

```
pactl load-module module-native-protocol-unix socket=/tmp/pulseaudio.socket
cat <<EOF > /tmp/pulseaudio.client.conf
default-server = unix:/tmp/pulseaudio.socket
# Prevent a server running in the container
autospawn = no
daemon-binary = /bin/true
# Prevent the use of shared memory
enable-shm = false
EOF
```

*I am not sure where am I getting this from but this repo `https://github.com/TheBiggerGuy/docker-pulseaudio-example` seems to be the same thing*

Check for x11 socket, it should be avaliable at `/tmp/.X11-unix`.

After that we tie this all up together

```
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
    ghcr.io/bacillococcus/dockerfiles/ubuntu/nvidia-driver-steam:470
```

Explaining each arguments:

 - `--rm` is done to destroy container after exit.
 - `--it` for interactive (in this case you actually wont need it because it is a stream).
 - `--gpus all` to share gpus to container.
 - `-v /tmp/pulseaudio.socket:/tmp/pulseaudio.socket` share pulseaudio socket with the container.
 - `-v /tmp/pulseaudio.client.conf:/etc/pulse/client.conf` share pulseaudio config with the container.
 - `-v /home/yourhomedirectory:/home/developer` share a home folder that you specified to the container (could be completely new and empty folder for first time use and mount the same folder for later use).
 - `-v /yourstreamlibary:/streamlibary` share a folder that contain steam library.
 - `-e PULSE_SERVER=unix:/tmp/pulseaudio.socket` set pulseaudio socket location.
 - `-e DISPLAY=:0.0` output to display `:0.0`.
 - `--shm-size=2G` the default shm-size might be to low and cause issue with some applications, set it to 2G seems to be OK.
 - `--security-opt seccomp=unconfined` this is recent addition, it seems like steam start to use some kind of containerization in their own application and games. In the past steam used to use LD_LIBRARY_PATH hacking or something. This allow container that we spawn to use some of the permission which was blocked by seccomp or apparmor, we drop root privilege instead when we run a container (well you should do when apps does not require root) and should be reasonably safe. If any people have suggestion, please help.
 - `--security-opt apparmor=unconfined` same reason as above.
 - `--entrypoint steam` told it to launch steam as an entrypoint.

There's some caveats since you are sharing x11 and pulseaudio server applications inside this container will be able to access to your mic and other GUI apps meaning it can still read your clipboard and grab your screen or record your mic. This might be good and bad for some user, since you can pretty seamlessly use this as if it is applications on your host (well a part from file sharing and other things),but this is still a good trade off between having steam directly on your system since that would make it hard to move around between system and steam itself have access to files on your system.

The container itself build up and using a user with id of `1000:1000` so you might need to make sure that the folder or anything that was mount to the container you got enough permission to operate on those.
