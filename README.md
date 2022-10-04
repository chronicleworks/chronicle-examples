# Chronicle Examples

## Clone The Repository

```bash
git clone https://github.com/blockchaintp/chronicle-examples.git
```

This contains several example domain yaml files and docker and uses
`blockchaintp/chronicle-builder:BTP2.1.0` as the builder image by default.

## Build Example

Chose from one of the following examples.

### `evidence` Domain

This is the worked example in the Chronicle documentation.

```bash
make clean evidence
```

To run this example you may run the following:

```bash
make run-evidence
```

To continue proceed to [Run Example](#run-example)

### `artworld` Domain

This is another example from the world of art.

```bash
make clean artworld
```

To run this example you may run the following:

```bash
make run-artworld
```

To continue proceed to [Run Example](#run-example)

## Run Example

Now that you have built and have run your chronicle example. The terminal will
prompt you for configuration settings. You can just press return to answer with
defaults. You should then see something like this in your terminal:

```bash
$ make run-artworld
docker run --env RUST_LOG=debug --publish 9982:9982 -it chronicle-artworld-inmem:local --console-logging pretty serve-graphql --interface 0.0.0.0:9982 --open
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

### Note

If you update an example domain, you currently need to stop this running
image to re-run `run-<domain>` as it backgrounds on CTRL-C

## Generating the Grapql Schemas

Integration with chronicle is done primarily via graphql. The graphql schema is
particular to the domain and is generated from the `domain.yaml` file. To
generate your domain's graphql schema simply run
`make <domain>-sdl`.  For example for the artworld domain:

```bash
make artworld-sdl
```

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

### Notes

The schema / docs tab is good for showing the relationship between
your domain.yaml config and the resulting api.

Shift-refresh on the playground will remove previous result from query tabs,
good to do before rerunning your example.
