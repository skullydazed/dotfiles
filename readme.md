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

You can use [`docker_deploy`](home/bin/docker_deploy) to deploy the docker service in the current directory to your local machine. It will build the service, tag it after the directory name, and launch it. You can create a `DOCKER_RUN` file to control the behavior of your service.

The following `docker run` arguments will always be passed by `docker_deploy`:

    -it --name $container_name --restart=unless-stopped

You can specify more arguments for both `docker run` and the container's entrypoint in the `DOCKER_RUN` file. `DOCKER_RUN` will be sourced by [`docker_deploy`](home/bin/docker_deploy) to specify these arguments.

| Variable | Description |
|----------|-------------|
| `DOCKER_RUN_ARGS` | Arguments to pass to `docker run`, such as `--port` |
| `DOCKER_ENTRYPOINT_ARGS` | Arguments to pass to the container |
