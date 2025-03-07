FROM kalilinux/kali-rolling
# Install packages and set locale
RUN apt-get update \
    && apt-get install -y locales nano ssh sudo unzip python3 curl libkf5config-bin  wget \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

# Configure SSH tunnel using ngrok
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.utf8


WORKDIR /root
ENV LANG en_US.UTF-8 
ENV LC_ALL C.UTF-8

# Start up commands

EXPOSE 80 22533 8888 8080 443 5130-5135 3306 7860 53 9050
CMD ["/bin/bash"]
