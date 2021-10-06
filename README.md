# Lab Agora Proxy

Dockerized domain binfing proxy for Lab Agora server.

- [How it works](#how-it-works)
  - [Remote server](#remote-server)
- [Server Deployment](#server-deployment)
  - [Automated Git Deployment Setup](#automated-git-deployment-setup)

## How it works

### Remote server

`~/repositories` is where bare Git repositories "listening" to Git pushes (via a `post-receive` hook) live.
`~/deployments` is where Git repositories data is deployed.

Each repository, representing each dockerized web-service, has a corresponding directory in both above directories.

All the dockerized web-services will use the same Dcoker network, which must be created once and for all while deploying
this proxy container.

Each dockerized web-service will then declare its [FQDN](https://en.wikipedia.org/wiki/Fully_qualified_domain_name) via
a `VIRTUAL_HOST` environment variable under its public entry-point service (within its `docker-compose.yml` config).

The current dockerized proxy will then listen on the port declared and automatically bind the declared domain name to
the matching web-service.

## Server Deployment

### Automated Git Deployment Setup

Prepare remote server directories structure:

```sh
ssh <USERNAME>@<SERVER_IP>
mkdir ~/deployments
mkdir ~/repositories
```

Add the current proxy Git repository workflow:

```sh
git init --bare ~/repositories/inca-proxy.git
vim ~/repositories/inca-proxy.git/hooks/post-receive
```

with could look like this:

```sh
#!/bin/sh

# Exit when any command fails:
set -e

TARGET="/home/<USERNAME>/deployments/vps"
GIT_DIR="/home/<USERNAME>/repositories/vps.git"
BRANCH="main"

while read oldrev newrev ref
do
  # Only checking out the specified branch:
  if [[ $ref = "refs/heads/${BRANCH}" ]]
  then
    echo "Git reference $ref received. Deploying ${BRANCH} branch to production..."
    git --work-tree="$TARGET" --git-dir="$GIT_DIR" checkout -f "$BRANCH"
    cd $TARGET
    sudo make start
  else
    echo "Git reference $ref received. Doing nothing: only the ${BRANCH} branch may be deployed on this server."
  fi
done
```

Give the execution rights:

```sh
chmod +x post-receive
```

Create the shared Docker network:

```sh
docker network create proxy
```

You can now exit and go into you your local proxy directory to add your server repository reference:

```
git remote add live ssh://<USERNAME>@<SERVER_IP>/home/<USERNAME>/repositories/vps.git
```

Everything i snow setup for the proxy part and you can simply push any new commit via:

```sh
git push live main
```
