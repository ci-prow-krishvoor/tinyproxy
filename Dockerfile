FROM fedora:34

RUN dnf install -y tinyproxy

USER tinyproxy
EXPOSE 8888
COPY tinyproxy.conf /etc/tinyproxy/
ENTRYPOINT tinyproxy -d
