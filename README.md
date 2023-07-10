# Chronicle Bootstrap

This repo serves as a base for setting up your own Chronicle domain.

It contains the structure and `Makefile` which can be used to build docker
images and run a local instance of Chronicle.

It does not contain an example domain, however if you would like to test it,
you can use a domain from the
[Chronicle Examples](https://github.com/btpworks/chronicle-examples) repo.

For example, the [manufacturing domain](https://github.com/btpworks/chronicle-examples/blob/main/domains/manufacturing/domain.yaml).

## Chronicle Documentation

Documentation for Chronicle in general may be found [here](https://docs.btp.works/chronicle/).
Example domains may be found [here](https://examples.btp.works).

## Setting up your own domain

This repository follows the same structure as the [Chronicle Examples](https://github.com/btpworks/chronicle-examples)
repository, which you can use for reference.

To get started with Chronicle Bootstrap:

1. Clone this repo, or download it as a zip file from GitHub
   [here](https://github.com/btpworks/chronicle-bootstrap/archive/refs/heads/main.zip).
   *Please note, if you download or copy the repo rather than cloning it,
   you will need to make sure you keep it up to date with the latest Chronicle
   releases in the future.*
1. Add your `domain.yaml` file in its own directory inside the `domains`
   directory. The name of its directory should be the name of your domain. For
   example, if your domain is called `manufacturing`, you would create
   `domains/manufacturing/domain.yaml`.

From there, we suggest using the following sections of the Chronicle Examples `README`
as a guide:

- [Prerequisites](https://github.com/btpworks/chronicle-examples/blob/main/README.md#prerequisites)
- [Building a Domain](https://github.com/btpworks/chronicle-examples/blob/main/README.md#build-a-domain)
- [Running a Standalone Node](https://github.com/btpworks/chronicle-examples/blob/main/README.md#run-a-standalone-node)
- [Deploying to a Chronicle-on-Sawtooth Environment](https://github.com/btpworks/chronicle-examples/blob/main/README.md#deploy-to-a-chronicle-on-sawtooth-environment)
- [Generating a GraphQL Schema](https://github.com/btpworks/chronicle-examples/blob/main/README.md#generate-the-graphql-schema)
