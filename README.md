# Chronicle Examples

This project contains contributed examples for Chronicle.  The markdown
documents in this repository are published on
[their own site](https://examples.btp.works). Documentation for
Chronicle in general may be found [here](https://docs.btp.works/chronicle/).

## Prerequisites

To get started, there are some basic prerequisites which must be installed:

* [Docker](https://docs.docker.com/install/)
* [Docker Compose](https://docs.docker.com/compose/install/)
* [GNU Make v4.0+](https://www.gnu.org/software/make/)

In addition, a working knowledge of GraphQL is assumed. If you are new to this,
a good starting point is [Introduction to GraphQL](https://graphql.org/learn/).

## Clone the Repository

```bash
git clone https://github.com/btpworks/chronicle-examples.git
```

This contains several example domain yaml files, and Docker uses
`blockchaintp/chronicle-builder:BTP2.1.0-0.6.0` as the builder image by default

## Build a Domain

Choose from one of the following examples:

* [Artworld](./domains/artworld/guide)
* [Corporate Actions](./domains/corporate-actions/guide)
* [Manufacturing](./domains/manufacturing/guide)
* [Time Recording](./domains/time-recording/guide)

For the purposes of these instructions we will use the `manufacturing` domain,
but any domain will work.  Simply substitute the name of the domain's directory
for `manufacturing` in the following instructions.

### Run a Standalone Node

You can run up a standalone version of Chronicle which is a single node with a
local database rather than backed by a blockchain.

```bash
gmake run-manufacturing
```

Now you are ready to connect to a GraphQL client, such as the
[Altair GraphQL Client](#graphql-client).

## Generate the GraphQL Schema

Integration with Chronicle is primarily done through GraphQL. The GraphQL schema
is specific to the domain and is generated from the domain.yaml file. To generate
the GraphQL schema for your domain, simply run `gmake <domain>-sdl`. For example,
for the manufacturing domain:

```bash
gmake manufacturing-sdl
```

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
    delta
  }
}
```

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
