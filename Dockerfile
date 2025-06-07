FROM opensuse/tumbleweed

WORKDIR /configuration

COPY . /configuration

RUN chmod +x setup-tmbl.sh && ./setup-tmbl.sh

ENTRYPOINT ["/usr/bin/zsh", "-c"]

CMD ["exec zsh"]
