# Chronicle Examples

This project contains contributed examples for Chronicle.  Documentation for
Chronicle can be found at
[https://docs.blockchaintp.com/en/stable/chronicle/](https://docs.blockchaintp.com/en/stable/chronicle/).

## Prerequisites

To get started, there are some basic prerequisites which must be installed:

* [Docker](https://docs.docker.com/install/)
* [GNU Make v4.0+](https://www.gnu.org/software/make/)
* As of now, an `x86_64` based host is required. We are working on `arm`
  support for this repository.

In addition, a working knowledge of GraphQL is assumed. If you are new to this,
a good starting point is [Introduction to GraphQL](https://graphql.org/learn/).

## Clone the Repository

```bash
git clone https://github.com/blockchaintp/chronicle-examples.git
```

This contains several example domain yaml files and docker and uses
`blockchaintp/chronicle-builder:BTP2.1.0` as the builder image by default.

## Build a Domain

Chose from one of the following examples.

* [Artworld](./domains/artworld/guide.md)
* [Evidence](./domains/evidence/guide.md)
* [Manufacturing](./domains/manufacturing/guide.md)

For the purposes of these instructions we will use the `manufacturing` domain,
but any domain will work.  Simply substitute the name of the domain's directory
for `manufacturing` in the following instructions.

### Build the Container Images

```bash
make clean manufacturing
```

### Run a Standalone Node

Now you can run up a standalone version of Chronicle which is a single node with
a local database rather than backed by a blockchain.

```bash
make run-manufacturing
```

Now that you have built and have run your Chronicle example. The terminal will
prompt you for configuration settings. You can just press return to answer with
defaults. You should then see something like this in your terminal:

```bash
$ make run-manufacturing
docker run --env RUST_LOG=debug --publish 9982:9982 -it chronicle-manufacturing-inmem:local --console-logging pretty serve-graphql --interface 0.0.0.0:9982 --open
No configuration found at /root/.chronicle/config.toml, create? (Y/n)
Where should chronicle store state? (/root/.chronicle/store)
Where should chronicle store secrets? (/root/.chronicle/secrets)
What is the address of the sawtooth validator zeromq service? (tcp://localhost:4004)
Generate a new default key in the secret store? (Y/n)
Creating config dir /root/.chronicle/config.toml if needed
Creating db dir /root/.chronicle/store if needed
Creating secret dir /root/.chronicle/secrets if needed
Writing config to /root/.chronicle/config.toml

[secrets]
path = "/root/.chronicle/secrets"
[store]
path = "/root/.chronicle/store"
[validator]
address = "tcp://localhost:4004"
[namespace_bindings]
```

## Generate the GraphQL Schema

Integration with Chronicle is done primarily via GraphQL. The GraphQL schema is
particular to the domain and is generated from the `domain.yaml` file. To
generate your domain's GraphQL schema simply run
`make <domain>-sdl`.  For example for the manufacturing domain:

```bash
make manufacturing-sdl
```

## GraphQL Playground

The [GraphQL playground](https://github.com/graphql/graphql-playground) is built
into Chronicle, and served on the same port as the Chronicle API. Therefore you
should be able to connect to it on <http://127.0.0.1:9982>, assuming that you
are running locally.

The GraphQL playground is persistent via cookies etc, so running the same
browser on the same machine will remember all your queries and tab positions.

To add a new mutation or query tab, there is a `+` on the right hand side of the
tab bar.

Once you get to this point, you are ready to explore the example. To do this,
consult the relevant guide.

### Notes

The *SCHEMA* and *DOCS* tabs are good for showing the relationship between
your `domain.yaml` config and the resulting Chronicle API.

Shift-refresh on the playground will remove previous result from query tabs,
good to do before rerunning your example.

### Subscribe to Events

Finally, to see what is happening in the playground you can subscribe to events
in one of the tabs.

```graphql
subscription {
  commitNotifications {
    correlationId
  }
}
```

## Adding a Domain

Adding a domain to the examples is as simple as adding a new `domain.yaml` file
to a directory under `domains`.  The directory name will be used as the name of
the docker image.  For example, if you add a `domains/mydomain/domain.yaml`
file, the debug and inmem docker image will be `chronicle-mydomain-inmem:local`.
