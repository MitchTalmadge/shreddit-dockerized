FROM python:alpine

ENV UID=1000
ENV GID=1000
ENV APP_DIR="/app"
ENV APP_CONFIG_DIR="${APP_DIR}/config"

# Install dependencies
RUN apk update && \
  apk upgrade && \
  apk add \
    bash \
    sudo
RUN pip install -U shreddit
# Arrow needs to be downgraded
RUN pip uninstall --yes arrow
RUN pip install arrow==0.9.0

# Create working environment
RUN mkdir -p ${APP_CONFIG_DIR}
COPY . ${APP_DIR}
WORKDIR ${APP_DIR}

# Run shreddit
ENTRYPOINT [ "/bin/sh", "/app/entrypoint.sh" ]
