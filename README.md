# Chronicle Bootstrap

This repo serves as a base for setting up your own Chronicle domain.

It contains the structure and Makefile which can be used to build docker
images and run a local instance of Chronicle.

It does not contain an example domain, however if you would like to test it,
you can use a domain from the
[Chronicle Examples](https://github.com/btpworks/chronicle-examples) repo.

For example, the [manufacturing domain](https://github.com/btpworks/chronicle-examples/blob/main/domains/manufacturing/domain.yaml).

## Chronicle Documentation

Documentation for Chronicle in general may be found [here](https://docs.btp.works/chronicle/).
Example domains may be found [here](https://examples.btp.works).

## Prerequisites

To get started, there are some basic prerequisites which must be installed:

* [Docker](https://docs.docker.com/install/)
* [Docker Compose](https://docs.docker.com/compose/install/)
* [GNU Make v4.0+](https://www.gnu.org/software/make/)

## Setting up your own domain

This repository follow the same structure as the [Chronicle Examples](https://github.com/btpworks/chronicle-examples)
repository which you can use for reference.

1. Clone this repo, or download it as a zip file from GitHub
   [here](https://github.com/btpworks/chronicle-bootstrap/archive/refs/heads/main.zip).
   *Please note, if you download or copy the repo rather than cloning it,
   you will need to make sure you keep it up to date with the latest Chronicle
   releases in the future.*
1. Add your `domain.yaml` file in its own directory inside the `domains`
   directory. The name of its directory should be the name of your domain. For
   example, if your domain is called `manufacturing`, you would create
   `domains/manufacturing/domain.yaml`.

## Running your domain

You can run your domain locally using the Makefile.
This will use a standalone version of Chronicle which is a single node with a
local database rather than backed by a blockchain. Replace `manufacturing` with
the name of your domain.

```bash
gmake run-manufacturing
```

## Building the docker images

To build the docker images for your domain, use the `stl-release` command.
Again replace `manufacturing` with the name of your domain in this example.

This command uses the env var ISOLATION_ID to set the image tag.
This defaults to `local` if not set. In our example we will set it to `1.0.0`.

```bash
export ISOLATION_ID=1.0.0

gmake manufacturing-stl-release
```

This command will produce a `chronicle-manufacturing-stl-release:1.0.0`
docker image.

You will need to push this image to a docker registry, and specify it in
your Chronicle deployment.

See the following Docker documentation for more details:

* [Docker registry docs](https://docs.docker.com/registry/)
* [Docker tag docs](https://docs.docker.com/engine/reference/commandline/tag/)
* [Docker push docs](https://docs.docker.com/engine/reference/commandline/push/).
