#!/bin/bash -e
set +o xtrace

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

su appuser -c "shreddit -g" && \
su appuser -c "shreddit"