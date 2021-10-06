# Lab Agora Proxy

Dockerized domain binding proxy for Lab Agora server using [Traefik Proxy](https://traefik.io/traefik/).

- [How it works](#how-it-works)
  - [Remote server](#remote-server)
- [Server Deployment](#server-deployment)
  - [Git Deployment Setup](#git-deployment-setup)
  - [Proxy Setup](#proxy-setup)

## How it works

### Remote server

`~/repositories` is where bare Git repositories "listening" to Git pushes (via a `post-receive` hook) live.
`~/deployments` is where Git repositories data is deployed.

Each repository, representing each dockerized web-service, has a corresponding directory in both above directories.

All the dockerized web-services will use the same Docker network, and the domain binding is handled by Traefik Proxy
which is provided via the current repository.

## Server Deployment

### Git Deployment Setup

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

You can now exit and go into you your local proxy directory to add your server repository reference:

```
git remote add live ssh://<USERNAME>@<SERVER_IP>/home/<USERNAME>/repositories/vps.git
```

Everything is now ready for the proxy part and you will now be able to push any new commit via:

```sh
git push live main
```

### Proxy Setup

Connect to the remote server:

```sh
ssh <USERNAME>@<SERVER_IP>
```

Create the shared Docker network (you may need to run it via sudo):

```sh
docker network create proxy
```
