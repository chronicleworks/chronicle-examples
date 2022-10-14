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

## Clone The Repository

```bash
git clone https://github.com/blockchaintp/chronicle-examples.git
```

This contains several example domain yaml files and docker and uses
`blockchaintp/chronicle-builder:BTP2.1.0` as the builder image by default.

## Build A Domain

Chose from one of the following examples.

* [Artworld](./domains/artworld/guide.md)
* [Evidence](./domains/evidence/guide.md)
* [Manufacturing](./domains/manufacturing/guide.md)

For the purposes of these instructions we will use the `manufacturing` domain,
but any domain will work.  Simply substitute the name of the domain's directory
for `manufacturing` in the following instructions.

### Building the container images

```bash
make clean manufacturing
```

### Run a standalone node

Now you can run up a standalone version of chronicle which is a single node with
a local database rather than backed by a blockchain.

```bash
make run-manufacturing
```

Now that you have built and have run your chronicle example. The terminal will
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

## Generating the GraphQL Schemas

Integration with chronicle is done primarily via GraphQL. The GraphQL schema is
particular to the domain and is generated from the `domain.yaml` file. To
generate your domain's GraphQL schema simply run
`make <domain>-sdl`.  For example for the manufacturing domain:

```bash
make manufacturing-sdl
```

## Adding a domain

Adding a domain to the examples is as simple as adding a new `domain.yaml` file
to a directory under `domains`.  The directory name will be used as the name of
the docker image.  For example, if you add a `domains/mydomain/domain.yaml`
file, the debug and inmem docker image will be `chronicle-mydomain-inmem:local`.

## GraphQL playground

This is built into chronicle, and served on the same port as the api. So you
should be able to start a browser on <http://127.0.0.1:9982> and see it.

The GraphQL playground is persistent via cookies etc, so running the same
browser on the same machine will remember all your queries and tab positions.

To add a new query tab, there's + on the right hand side of the tab bar.

The tab bar itself can be scrolled left and right with gestures on Mac, I am
unsure how this works on other OS', may be wise to check before swearing in
front of customers. Zoom screen sharing also breaks it for some reason.

Schema / and documentation tabs can be a little clunky, but will pop out from
the right hand side. Clicking on the main body sometimes closes them, sometimes
not. Swapping to another tab or resizing them slightly with the left hand side
of their flyout window usually does the job however.

Once you get to this point, you are ready to explore the example. To do this,
consult the relevant guide.

### Notes

The schema / docs tab is good for showing the relationship between
your domain.yaml config and the resulting api.

Shift-refresh on the playground will remove previous result from query tabs,
good to do before rerunning your example.

### Subscribe to events

Finally, to see what is happening in the playground you can subscribe to events
in one of the tabs.

```graphql
subscription {
  commitNotifications {
    correlationId
  }
}
```
