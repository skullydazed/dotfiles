# skullydazed's dotfiles

## Installation

You can install this with:

    curl https://raw.githubusercontent.com/skullydazed/dotfiles/main/install.sh | bash

It will update itself every time you login.

## Things to know about

### .note files

Put a file named .note into a directory and the contents will be displayed every time you enter that directory.

### Updating

When you login the dotfiles will be updated automatically in the background, and any missing symlinks will be added. If you change where a symlink points to the update system will not change it- this gives you a way to handle local overrides if needed.

Your .profile changes will not be picked up until the next time you login.

### Docker

You can use [`docker_deploy`](home/bin/docker_deploy) to deploy the docker service in the current directory to your local machine. It will build the service, tag it after the directory name, and launch it. You must create a `DOCKER_RUN` file to control the behavior of your service.

The following `docker run` arguments will always be passed by `docker_deploy`:

    -it --name $container_name --restart=unless-stopped

You can specify more arguments for both `docker run` and the container's entrypoint in the `DOCKER_RUN` file. `DOCKER_RUN` will be sourced by [`docker_deploy`](home/bin/docker_deploy) to specify these arguments.

| Variable | Description |
|----------|-------------|
| `DOCKER_RUN_ARGS` | Arguments to pass to `docker run`, such as `--port` |
| `DOCKER_ENTRYPOINT_ARGS` | Arguments to pass to the container |

#### Docker Deploy Example

You can run the following commands to create a minimal `docker_deploy` directory:

```bash
mkdir hello-world
cd hello-world
echo 'FROM hello-world' > Dockerfile
echo 'DOCKER_RUN_ARGS=""' > DOCKER_RUN 
docker_deploy
```

This will build and tag a `hello-world` container and launch it, leaving you connected to the console.

#### Why not use <docker-compose|swarm|k8s|rancher> instead?

For application development purposes docker-compose is great. When it comes to deploying in a production cluster you'll setup a lot of infrastructure around Rancher or Kubernetes. But if you have only one server that you want to deploy several docker containers to and manage them semi-independently you'll run into friction using docker-compose, which tries to treat all your containers as being part of larger service. The best way to go for a standalone production server is to setup Rancher or k8s, but they both consume a pretty heafty chunk of your time setting them up and can eat up 2-4gb of your available RAM.

The nice thing about `docker_deploy` is that all you need to use it is a `Dockerfile` and `DOCKER_RUN` in a directory dedicated to a specific container. You can manage each container much like you manage the services on a machine.
