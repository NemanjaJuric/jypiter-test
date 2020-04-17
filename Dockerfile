FROM python:3.7-slim as builder
RUN pip install --no-cache notebook
ENV HOME=/tmp

### create user with a home directory
ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}
WORKDIR ${HOME}

# Make sure the contents of our repo are in ${HOME}
COPY . ${HOME}
USER root
RUN chown -R ${NB_UID} ${HOME}
USER ${NB_USER}

FROM nginx:1.17.5
RUN rm -rf /usr/share/nginx/html/*
COPY --from=builder /home/jovyan /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80 443

CMD ["/bin/sh",  "-c",  "exec nginx -g 'daemon off;'"]