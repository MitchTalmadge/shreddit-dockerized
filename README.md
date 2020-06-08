# Shreddit Dockerized
A Docker wrapper for [Shreddit](https://github.com/x89/Shreddit), the Reddit auto-delete tool.
Can easily be automated on a cron schedule.

# Motivation
The idea behind this container is to allow you to automatically run shreddit once per day, hour, minute, whatever suits you -- or, you can do away with cron and have this container run shreddit only one time per invocation. 

If you don't already know what shreddit is, it is a python tool that can delete old posts and comments from your reddit account based on their age, score, subreddit, and much more. It's great for improving your privacy while using reddit so that people cannot snoop through your account and find out who you are or where you live.

I wanted a way to run this tool automatically so that every day, my history beyond one week would be completely wiped for me. I hate setting up python and cron, so I made a container to do it for me.

# Usage
I recommend using docker-compose to set up and run the container, but you can use what suits you.

This container does not need to be built from source; just use the pre-built image from Docker Hub, `mitchtalmadge/shreddit-dockerized:latest`.

## Shreddit Config
To configure shreddit, mount the docker volume `/app/mount`. 

The first time you run this container, template config files will be generated for you. Fill them out, and the next time you run the container, it will detect the config files and run shreddit as you specify (see later steps).

## Run Mode
There are two ways to run shreddit in this container: once-then-done, or periodically via cron.

### Once-then-done
This is the default behavior. No extra configuration needed.

When the container starts, it will immediately run shreddit and then exit. 

### Cron
To run shreddit on a cron schedule, just set the CRON env var with the schedule. For example:

```
CRON=* * * * *
```

That's it!

## UID & GID
The volume and configuration files will by default be owned by the user and group with UID and GID `1000`.

To choose your own UID/GID, just set the env vars:

```
UID=1001
GID=1001
```