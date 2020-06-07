FROM python:alpine

ENV UID=1001
ENV GID=1001

# Install dependencies
RUN apk update && \
  apk upgrade && \
  apk add \
    bash \
    sudo
RUN pip install -U shreddit

# Create working environment
RUN mkdir -p /app/mount
COPY . /app
WORKDIR /app/mount

# Run shreddit
ENTRYPOINT [ "/bin/sh", "/app/entrypoint.sh" ]