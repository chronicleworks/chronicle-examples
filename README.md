# Chronicle Examples

This project contains contributed examples for Chronicle.  The markdown
documents in this repository are published on
[their own site](https://examples.chronicle.works). Documentation for
Chronicle in general may be found [here](https://docs.chronicle.works/).

## Prerequisites

To get started, there are some basic prerequisites which must be installed:

* [Docker](https://docs.docker.com/install/)
* [Docker Compose](https://docs.docker.com/compose/install/)
* [GNU Make v4.0+](https://www.gnu.org/software/make/)

In addition, a working knowledge of GraphQL is assumed. If you are new to this,
a good starting point is [Introduction to GraphQL](https://graphql.org/learn/).

## Clone the Repository

```bash
git clone https://github.com/chronicleworks/chronicle-examples
```

This contains several example domain yaml files, and Docker uses
`blockchaintp/chronicle-builder:BTP2.1.0-0.7.4` as the builder image by default

## Build a Domain

Choose from one of the following examples:

* [Artworld](./domains/artworld/guide.md)
* [Corporate Actions](./domains/corporate-actions/guide.md)
* [Manufacturing](./domains/manufacturing/guide.md)
* [Science Project](./domains/science-project/guide.md)
* [Time Recording](./domains/time-recording/guide.md)

For the purposes of these instructions we will use the `manufacturing` domain,
but any domain will work. Simply substitute the name of the domain's directory
for `manufacturing` in the following instructions. For the other listed
domains, instead substitute `artworld`, `corporate-actions`,
`science-project`, or `time-recording`, as desired.

### Run a Standalone Node

#### In-Memory Ledger

You can run up a version of Chronicle which is a single node with a local
database, recording transactions on an in-memory ledger rather than a
blockchain.

```bash
gmake run-manufacturing
```

Now you are ready to connect to Chronicle and interact with this example, using
a GraphQL client as detailed [below](#graphql-client).

To stop this node, simply use control-C or otherwise terminate the process.

#### Backed by Sawtooth

You can also run up a standalone node that, while still a single node with a
local database, also includes a local Sawtooth node whose validator is used
by Chronicle's transaction processor for recording transactions on a
blockchain:

```bash
gmake run-stl-manufacturing
```

Now you are ready to connect to Chronicle and interact with this example, using
a GraphQL client as detailed [below](#graphql-client).

To stop this node, a further command shuts it down:

```bash
gmake stop-stl-manufacturing
```

### Deploy to a Chronicle-on-Sawtooth Environment

Rather than running a live Chronicle node locally, you may build a typed
Chronicle image that is ready for deployment into an environment with Sawtooth
nodes using the
[Chronicle Rancher by SUSE Cookbook](https://docs.chronicle.works/rancher).
Options to decide on include:

* Which domain example to build for Chronicle's typing.

* `debug` for a debug build or `release` for a release build. The release
  build includes less debug information and takes longer to build but is
  more performant.

For example, for a debug build of the manufacturing domain,

```bash
gmake manufacturing-stl-debug
```

or a release build for the same domain,

```bash
gmake manufacturing-stl-release
```

As above, the name of any of the other listed domains may be substituted for
`manufacturing`.

After the build, running `docker image ls` should show the built image that
can then be pushed to the appropriate registry for installation.

By default, the images are given tags like, say,
`chronicle-manufacturing-stl-release:local`. A value other than `local` can
be set in the `ISOLATION_ID` environment variable prior to build.

### Set Environment Variables

Additional environment variables can be set that are recogized by the running
Chronicle process. You may list these in the `docker/chronicle-environment`
file which is initially empty. To instead read them from a different file,
set its location in the `DOCKER_COMPOSE_ENV` environment variable.

For example, to have Chronicle require all API requests to be
authenticated, you could write your authentication provider's
[OIDC endpoints](https://docs.chronicle.works/auth/) into
`docker/chronicle-environment` thus,

```properties
REQUIRE_AUTH=1
JWKS_URI=https://id.example.com:80/.well-known/jwks.json
USERINFO_URI=https://id.example.com:80/userinfo
```

taking the variable names from `chronicle serve-api --help`. Then, after you
use `gmake run-my-domain` or similar, the running Chronicle will use the
specified authentication provider to verify incoming requests.

## Generate the GraphQL Schema

Integration with Chronicle is primarily done through GraphQL. The GraphQL schema
is specific to the domain and is generated from the domain.yaml file. To generate
the GraphQL schema for your domain, simply run `gmake <domain>-sdl`. For example,
for the manufacturing domain:

```bash
gmake manufacturing-sdl
```

## Understanding the Makefile targets and Docker images

As described above, Chronicle can be built either
[with an in-memory ledger or backed by Sawtooth](#run-a-standalone-node).
These have `inmem` or `stl` in their image name, respectively. Also, it can be
built  either as [a debug or a release
build](#deploy-to-a-chronicle-on-sawtooth-environment). The former suffixes
image names with `-debug`, the latter with `-release`.

The `gmake build` target builds the in-memory release images for every example
domain. For Sawtooth-backed release builds, use `gmake stl-release` instead.

The `run-*` targets build debug versions, other targets typically build
release builds. Debug builds the code much faster for incremental changes but
this advantage is irrelevant when each build is done in a fresh Docker
container. Therefore, the better-optimized release builds are typically
recommended.

To build any specific Docker image, use the form `gmake A-B-C` where,

A
: the name of the domain, e.g., `manufacturing`

B
: either `inmem` or `stl`

C
: either `release` or `debug`

which builds and tags an image named `chronicle-A-B-C`. The previous
`chronicle-A-B` tag names are deprecated.

## GraphQL Client

Chronicle Examples use Chronicle's `serve-graphql` function to provide the
Chronicle GraphQL API. By using a GraphQL client, you can interact with
Chronicle by running GraphQL queries, mutations, and subscriptions.

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

Once you get to this point, you are ready to explore the examples. To do this,
refer to the relevant guide.

### Notes

If you are using Chronicle with default settings, point your GraphQL client or
browser <http://127.0.0.1:9982>.

In the case of the GraphQL Playground, the *SCHEMA* and *DOCS* tabs make it
easy to explore the relationship between your `domain.yaml` configuration and
the resulting strongly-typed Chronicle GraphQL API.

__NOTE__ Use Shift-R to refresh the playground before rerunning your example.

### Subscribing to Events (1)

Finally, to see what is happening as you run GraphQL mutations and queries, you
can subscribe to async events in one of the tabs. The GraphQL Playround handles
this automatically but other GraphQL clients may ask you to explicitly provide
the websocket end point. The default is <ws://localhost:9982/ws>.

```graphql
subscription {
  commitNotifications {
    stage
    txId
    error
    delta
  }
}
```

### Subscribing to Events (2)

If you are using JWT authorization you will need to install a GraphQL client
that supports subscriptions correctly by passing the `Authorization` header.

Neither the Altair GraphQL Client or the GraphQL Playground support this.
However, we have verified that the CLI
[gql-cli](https://gql.readthedocs.io/en/latest/gql-cli/intro.html)
included in [GQL 3](https://gql.readthedocs.io/en/latest/intro.html) handles
this gracefully. To install this use `pip`:

```bash
pip install "gql[all]"
```

Once `gql-cli` is installed you can use it to run the same subscription. To
faciliate this we have provided a script [subscription.sh](./scripts/subscription.sh).

We recommend that you run this script first, then experiment with mutations and
queries using your preferred GraphQL client.

__NOTE__ If you haven't locked down your environment using JWT, the bearer token
will be ignored.

## Adding a Domain

### Chronicle Definition

Adding a domain to the examples is as simple as adding a new `domain.yaml` file
to a new folder under `domains`.  The folder name will be used as the name of
the docker image.  For example, if you add a `domains/mydomain/domain.yaml`
file, the debug and inmem docker image will be `chronicle-mydomain-inmem:local`.

### User's Guide

The `domain.yaml` definition is typically the smaller part of what there is to
say about the domain's usage. Users will appreciate an accompanying `guide.md`
markdown document structured like those for the other example domains. Take a
look through those domains' guides because they illustrate how to write the
principal sections:

1. Modeling
1. Recording
1. Querying

Briefly explain what your domain is. Then, for the first section, take each
of the domain's most important activities, describe the participating agents
and entities, provide a diagram of how they relate to the activity, then show
how each is modeled in the `domain.yaml`. In this way, you can step through
various aspects of your domain, allowing the reader to accumulate a full
picture gradually. Conclude these by bringing those descriptions together as
the full `domain.yaml`. Note that `yaml` can be specified for the highlighting
in domain definitions.

For producing those diagrams, use [PlantUML](https://plantuml.com/)'s [class
diagrams](https://plantuml.com/class-diagram) with *extension* `--|>` arrows
showing which are agents, entities, and activities, and *directed association*
`-->` arrows for how those relate to each other. Include typed attributes as
fields in the class boxes where appropriate. Notice that the `docs/diagrams/`
folder has two subdirectories; review their contents and follow the same
pattern. Each of your domain agents, entities, and activities gets a
corresponding `include/*.iuml` file and, from your diagrams in `src/*.puml`,
you can `!include` the provided `default.iuml`, `agent.iuml`, `entity.iuml`,
`activity.iuml`, and your extra `*.iuml` for consistency across your diagrams
and those of the other example domains.

Follow the above tour of your domain with the other two sections: provide
example mutations and queries expressed in GraphQL, and show how the responses
should look, to give users some simple stories to try out in the Apollo
Sandbox in their browser. These examples should lead them through the most
important and common uses of your domain, giving them enough starting points
to easily try it out in their own applications. Note that `graphql` for
requests and `json` for responses can be specified for highlighting those
interactions.

For rendering your new guide locally, `docs/` also includes a list of the
Python dependencies required for running `mkdocs serve`. In using it to review
your guide, check that you have explained every aspect of your domain clearly
so the community can draw the greatest benefit from your work.
