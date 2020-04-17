FROM jupyter/scipy-notebook:cf6258237ff9

RUN pip install --no-cache-dir notebook==5.*

ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

COPY . ${HOME}
USER root
RUN chown -R ${NB_UID} ${HOME}
USER ${NB_USER}

FROM nginx:1.17.5
RUN rm -rf /usr/share/nginx/html/*
COPY --from=builder /usr/src/app/dist/cbpm-app /usr/share/nginx/html
COPY nginx.tmpl /etc/nginx/nginx.tmpl
EXPOSE 80 443

CMD ["/bin/sh",  "-c",  "envsubst '$USER' < /etc/nginx/nginx.tmpl > /etc/nginx/nginx.conf && exec nginx -g 'daemon off;'"]
