# Chronicle Examples

This is simplest done from source, currently these examples do not use the
builder image in CI, so this is a known working method

## Build Chronicle

Clone catenasys/chronicle and run

```bash
ISOLATION_ID=local make build
```

This should only require docker / make as a dependency

This builds the chronicle build image so it is available as builder:local

## Checkout Chronicle Examples

Clone catenasys/chronicle-examples

This contains several example domain yaml files and docker and uses
builder:local by default.

## Build Example

Chose from one of the following examples.

### Evidence Domain

This is the worked example in the Chronicle documentation.

```bash
export DOMAIN=evidence
make clean build
```

### Artworld Domain

This is another example from the world of art.

```bash
export DOMAIN=artworld
make clean build
```

## Run Example

Once you've built run this command.

```bash
make run-standalone-chronicle
```

This will build and run your chronicle example. The terminal will prompt you for
configuration settings. You can just press return to answer with defaults. You
should then see this in terminal:

```bash
docker run --env RUST_LOG=debug --publish 9982:9982 -it example-chronicle-inmem:local bash -c 'chronicle --console-logging pretty serve-graphql --interface 0.0.0.0:9982 --open'
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

!!!Note
    If you update the example domain, you currently need to stop this running
    image to re-run run-standalone-chronicle as it backgrounds on CTRL-C

## GraphQL playground

This is built into chronicle, and served on the same port as the api. So you
should be able to start a browser on <http://127.0.0.1:9982> and see it.

The graphql playground is persistent via cookies etc, so running the same
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

!!!Note
    The schema / docs tab is good for showing the relationship between
    domain.yaml config and the resulting api.

!!!Note
    Shift-refresh on the playground will remove previous result from query tabs,
    good to do before rerunning your example.
