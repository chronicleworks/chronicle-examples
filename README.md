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

This contains several example domain yaml files, and Docker uses
`blockchaintp/chronicle-builder:BTP2.1.0-0.7.3` as the builder image by default

## Build a Domain

Choose from one of the following examples:

* [Artworld](./domains/artworld/guide)
* [Corporate Actions](./domains/corporate-actions/guide)
* [Manufacturing](./domains/manufacturing/guide)
* [Time Recording](./domains/time-recording/guide)

For the purposes of these instructions we will use the `manufacturing` domain,
but any domain will work. Simply substitute the name of the domain's directory
for `manufacturing` in the following instructions. For the other listed
domains, instead substitute `artworld`, `corporate-actions`, or
`time-recording`, as desired.

### Run a Standalone Node

#### In-Memory Ledger

You can run up a version of Chronicle which is a single node with a local
database, recording transactions on an in-memory ledger rather than a
blockchain.

```bash
gmake run-manufacturing
```

## Building the docker images

To stop this node, simply use control-C or otherwise terminate the process.

#### Backed by Sawtooth

You can also run up a standalone node that, while still a single node with a
local database, also includes a local Sawtooth node whose validator is used
by Chronicle's transaction processor for recording transactions on a
blockchain:

```bash
gmake run-stl-manufacturing
```

To stop this node, a further command shuts it down:

```bash
gmake stop-stl-manufacturing
```

### Deploy to a Chronicle-on-Sawtooth Environment

Rather than running a live Chronicle node locally, you may build a typed
Chronicle image that is ready for deployment into an environment with Sawtooth
nodes using the
[Chronicle cookbook](https://docs.btp.works/cookbooks/chronicle/rancher).
Options to decide on include:

- Which domain example to build for Chronicle's typing.

- `debug` for a debug build or `release` for a release build. The release
  build includes less debug information and takes longer to build but is
  more performant.

For example, for a debug build of the manufacturing domain,
```bash
gmake manufacturing-stl-debug
```
or a release build for the same domain,
```
gmake manufacturing-stl-release
```

As above, the name of any of the other listed domains may be substituted for
`manufacturing`.

After the build, running `docker image ls` should show the built image that
can then be pushed to the appropriate registry for installation.

By default, the images are given tags like, say,
`chronicle-manufacturing-stl-release:local`. A value other than `local` can
be set in the `ISOLATION_ID` environment variable prior to build.

## Generate the GraphQL Schema

This command uses the env var ISOLATION_ID to set the image tag.
This defaults to `local` if not set. In our example we will set it to `1.0.0`.

```bash
export ISOLATION_ID=1.0.0

## GraphQL Client

Chronicle Examples use Chronicle's `serve-graphql` function to provide the
Chronicle GraphQL API. By using a GraphQL client, you can interact with Chronicle
by running GraphQL queries, mutations, and subscriptions.

We recommend using the [Altair GraphQL Client](https://altairgraphql.dev/),
which is available as a free desktop GraphQL IDE or web browser extension.

If you have previously used Chronicle Examples, you can still access the
[GraphQL Playground](https://github.com/graphql/graphql-playground) through your
web browser at <http://127.0.0.1:9982>, however we will be deprecating support
for GraphQL Playground in future releases.

Both of these GraphQL clients are persistent via cookies, so running the same
browser on the same machine will remember all your queries and tab positions.

To add a new mutation or query tab, there is a `+` on the right-hand side of the
tab bar.

Once you get to this point, you are ready to explore the example. To do this,
refer to the relevant guide.

### Notes

If you are using Chronicle on default settings, point the GraphQL client to
<http://127.0.0.1:9982>.

The *SCHEMA* and *DOCS* tabs are useful for showing the relationship between
your `domain.yaml` configuration and the resulting Chronicle API.

Shift-refresh on the playground will remove previous results from query tabs,
which is recommended before rerunning your example.

### Subscribe to Events

Finally, to see what is happening as you run GraphQL mutations and queries, you
can subscribe to events in one of the tabs by using the subscription URL
<ws://localhost:9982/ws>.

```graphql
subscription {
  commitNotifications {
    stage
    error
    delta
  }
}
```

This command will produce a `chronicle-manufacturing-stl-release:1.0.0`
docker image.

You will need to push this image to a docker registry, and specify it in
your Chronicle deployment.

See the following Docker documentation for more details:

* [Docker registry docs](https://docs.docker.com/registry/)
* [Docker tag docs](https://docs.docker.com/engine/reference/commandline/tag/)
* [Docker push docs](https://docs.docker.com/engine/reference/commandline/push/).
