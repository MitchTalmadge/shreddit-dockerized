#!/bin/bash -e
set +o xtrace # To debug, change + to -

APP_DIR="/app"
APP_MOUNT_DIR="${APP_DIR}/mount"

APP_USER="appuser"
APP_GROUP="appgroup"

# Create user and group that will own the config files.
if [ ! "$(getent group ${APP_GROUP})" ]
then
  # Create group
	addgroup \
		--gid "${GID}" \
		${APP_GROUP}

  # Create user
  adduser \
		--uid "${UID}" \
		--shell /bin/bash \
		--no-create-home \
    --ingroup ${APP_GROUP} \
    --system \
		${APP_USER}
fi
chown -R ${APP_USER}:${APP_GROUP} /app/mount

# Check for existence of config files and generate if missing
PRAW_FILE="${APP_MOUNT_DIR}/praw.ini"
CONFIG_FILE="${APP_MOUNT_DIR}/shreddit.yml"
if [[ ! -f "${PRAW_FILE}" || ! -f "${CONFIG_FILE}" ]]; then
	echo "One or more config files are missing. Generating config files..."
	su ${APP_USER} -c "shreddit -g" && \
	echo "Config files generated. Please fill them in and then restart the container."
	exit 0
fi

# Use cron if schedule specified
if [[ ! -z "${CRON}" ]]; then 
	echo "Shreddit will run on the following cron schedule: ${CRON}"

	# Append cron job if not already appended
	if ! crontab -l | cat | grep -qe "shreddit"; then
		crontab -l | { cat; echo "${CRON} su ${APP_USER} -c \"(cd ${APP_MOUNT_DIR}; shreddit)\" > /proc/1/fd/1 2>/proc/1/fd/2"; } | crontab -
	fi

	# Start cron in foreground
	crond -f
else
	su ${APP_USER} -c "shreddit"
fi