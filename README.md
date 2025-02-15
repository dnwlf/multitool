# multitool

A container-based set of devops tools, persistant gcloud auth, and volume-mounted .kube contexts, and a nice terminal

## Prerequisites
1. Docker Desktop or similar (e.g. [colima](https://github.com/abiosoft/colima) or [Rancher Desktop](https://rancherdesktop.io))
1. If you do not already have a global `.gitconfig`, create one:
    ```bash
    touch $HOME/.gitconfig
    ```
1. If you do not already have a `.kube` directory in your home, create one:
    ```bash
    mkdir -p $HOME/.kube
    ```
1. If you plan to work on any git projects within multitool, you'll need to add the `/multitool` directory to your git config's safe directories
   ```bash
   git config --global --add safe.directory /multitool
   ```

## Initialize
The first time you use this tool, you need to complete a few initializtion steps to set up the volumes that will contain your persistent configs.

1. Change directory to this project's root
1. Run the following command to build the tools
    ```bash
    docker-compose run --build tools
    ```
    1. You will need to re-run this command when you make changes to the `Dockerfile`, or want to update your local container to the latest tools versions.
1. You will need to run `gcloud auth login`, and any other commands to set up default projects and/or cluster contexts.
    1. NOTE: Your gcloud login info will persist in a local volume and will automatically be available each time you start this tool up

## Running the container

### Using multitool as a standalone container

1. Run the following command to start the tools:
    ```bash
    docker-compose run --rm tools
    ```

### Optionally, use multitool like a devcontainer

If you have not yet set up a [devcontainer](https://containers.dev) for a project, you can use multitool as a quick and dirty solution to having a common set of tools for working in a project.

1. Change directory to the project you want to mount to multitool
    ```bash
    cd /your/project/path
    ```

1. Run the `docker-compose` command, specifying the path to multitool's `compose.yaml` file.
    ```bash
    docker-compose -f /path/to/multitool/compose.yaml run --rm tools
    ```

## Finally
1. Have fun 🎉