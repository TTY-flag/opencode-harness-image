FROM smanx/opencode:latest

USER root

RUN mkdir -p /scan/project /scan/output /scan/opencode /scan/auth

WORKDIR /scan
EXPOSE 4096

ENTRYPOINT ["bash", "/entrypoint.sh"]
