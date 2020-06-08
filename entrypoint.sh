#!/bin/bash -e
set +o xtrace # To debug, change + to -

# Create user and group that will own the config files (if they don't exist already).
if [ ! "$(getent group ${GID})" ]; then
  # Create group
	addgroup \
		--gid ${GID} \
		appgroup
fi
APP_GROUP=`getent group ${GID} | awk -F ":" '{ print $1 }'`
if [ ! "$(getent passwd ${UID})" ]; then
  # Create user
  adduser \
		--uid ${UID} \
		--shell /bin/bash \
		--no-create-home \
		--ingroup ${APP_GROUP} \
    --system \
		appuser
fi
APP_USER=`getent passwd ${UID} | awk -F ":" '{ print $1 }'`
chown -R ${APP_USER}:${APP_GROUP} ${APP_CONFIG_DIR}

# Check for existence of config files and generate if missing
PRAW_FILE="${APP_CONFIG_DIR}/praw.ini"
CONFIG_FILE="${APP_CONFIG_DIR}/shreddit.yml"
if [[ ! -f "${PRAW_FILE}" || ! -f "${CONFIG_FILE}" ]]; then
	echo "One or more config files are missing. Generating config files..."
	su ${APP_USER} -c "(cd ${APP_CONFIG_DIR}; shreddit -g)" && \
	echo "Config files generated. Please fill them in and then restart the container."
	exit 0
fi

# Use cron if schedule specified
if [[ ! -z "${CRON}" ]]; then 
	echo "Shreddit will run on the following cron schedule: ${CRON}"

	# Append cron job if not already appended
	if ! crontab -l | cat | grep -qe "shreddit"; then
		crontab -l | { cat; echo "${CRON} su ${APP_USER} -c \"(cd ${APP_CONFIG_DIR}; shreddit)\" > /proc/1/fd/1 2>/proc/1/fd/2"; } | crontab -
	fi

	# Start cron in foreground
	crond -f
else
	su ${APP_USER} -c "(cd ${APP_CONFIG_DIR}; shreddit)"
fi