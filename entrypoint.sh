#!/bin/bash -e
set +o xtrace

# Create user and group that will own the config files.
if [ ! "$(getent group appgroup)" ]
then
  # Create group
	addgroup \
		--gid "${GID}" \
		appgroup

  # Create user
  adduser \
		--uid "${UID}" \
		--shell /bin/bash \
		--no-create-home \
    --ingroup appgroup \
    --system \
		appuser
fi
chown -R appuser:appgroup /app/mount

# Check for existence of config files and generate if missing
PRAW_FILE=/app/mount/praw.ini
CONFIG_FILE=/app/mount/shreddit.yml
if [[ ! -f "$PRAW_FILE" || ! -f "$CONFIG_FILE" ]]; then
	echo "One or more config files are missing. Generating config files..."
	su appuser -c "shreddit -g" && \
	echo "Config files generated. Please fill them in and then restart the container."
	exit 0
fi

su appuser -c "shreddit"