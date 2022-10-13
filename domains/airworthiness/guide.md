# Airworthiness Guide

## Modelling Provenance

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

Once you get to this point, you are ready to demo

The schema / docs tab is good for showing the relationship between domain.yaml
config and the resulting api

Shift-refresh on the playground will remove previous result from query tabs,
good to do before starting a demo

### Subscribing to events

```graphql
subscription {
  commitNotifications {
    correlationId
  }
}
```

## Recording Provenance

### Create `Contractor` Agent

```graphql
mutation {
  contractor(name:"baesystems",attributes:{locationAttribute:"Bristol"}) {
    context
    correlationId
  }
}
```

Output should look something like this -

```graphql
{
  "data": {
    "contractor": {
      "context": "http://blockchaintp.com/chronicle/ns#agent:baesystems",
      "correlationId": "1beca706-7a61-4506-8d79-89aa2a74db34"
    }
  }
}
```

### Create `ItemManufactured` Activity

```graphql
mutation {
  itemManufactured(name:"rotorbladefabrication",attributes:{batchIdAttribute:"BATCH1234567890"}) {
    correlationId,
    context
  }
}
```

Output should look something like this -

```graphql
{
  "data": {
    "itemManufactured": {
      "correlationId": "8c09ef66-236d-4f19-9d6c-be60c60a798b",
      "context": "http://blockchaintp.com/chronicle/ns#activity:rotorbladefabrication"
    }
  }
}
```

### Start Activity

```graphql
mutation {
  startActivity(
    id:"http://blockchaintp.com/chronicle/ns#activity:rotorbladefabrication")    {
    correlationId,
    context
  }
}
```

Output should look something like this -

```graphql
{
  "data": {
    "startActivity": {
      "correlationId": "3eae1872-b14c-45bc-a76d-6eadab1ca846",
      "context": "http://blockchaintp.com/chronicle/ns#activity:rotorbladefabrication"
    }
  }
}
```

### Create Item

```graphql
mutation {
  item(name:"rotorblade",attributes:{partIdAttribute:"NATO12344567890"}) {
    context,
    correlationId
  }
}
```

Output should look something like this -

```graphql
{
  "data": {
    "item": {
      "context": "http://blockchaintp.com/chronicle/ns#entity:rotorblade",
      "correlationId": "addd547c-ea06-4c6d-9e20-6af77efd6a25"
    }
  }
}
```

### Record `wasGeneratedBy` Relationship

Assert that our rotorblade was manufactured via this activity -

```graphql
mutation {
  wasGeneratedBy(id:"http://blockchaintp.com/chronicle/ns#entity:rotorblade",
    activity:"http://blockchaintp.com/chronicle/ns#activity:rotorbladefabrication") {
    correlationId,
    context
  }
}
```

Output should look something like this -

```graphql
{
  "data": {
    "wasGeneratedBy": {
      "correlationId": "721ced20-79ef-4b40-8fda-139770f6ed37",
      "context": "http://blockchaintp.com/chronicle/ns#entity:rotorblade"
    }
  }
}
```

### Record `used` relationship

```graphql
mutation {
  used(id:"http://blockchaintp.com/chronicle/ns#entity:rotorblade",
    activity:"http://blockchaintp.com/chronicle/ns#activity:rotorbladefabrication") {
    correlationId,
    context
  }
}
```

Output should look something like this -

```graphql
{
  "data": {
    "used": {
      "correlationId": "8f313fc8-47bb-44fb-bc9b-0e3892ef54e3",
      "context": "http://blockchaintp.com/chronicle/ns#entity:rotorblade"
    }
  }
}
```

### Record `wasAssociatedWith` Relationship

Assert that contractor was responsible for this activity in its role as a
Manufacturer -

```graphql
mutation {
    wasAssociatedWith(
    activity: "http://blockchaintp.com/chronicle/ns#activity:rotorbladefabrication",
    responsible:"http://blockchaintp.com/chronicle/ns#agent:baesystems",
    role:Manufacturer) {
    correlationId
    context
  }
}
```

Output should look something like this -

```graphql
{
  "data": {
    "wasAssociatedWith": {
      "correlationId": "3ddde8b0-2e4f-4a9c-89aa-6256e052d1cd",
      "context": "http://blockchaintp.com/chronicle/ns#agent:baesystems"
    }
  }
}
```

### End Activity

```graphql
mutation {
  endActivity(
    id:"http://blockchaintp.com/chronicle/ns#activity:rotorbladefabrication") {
    correlationId,
    context
  }
}
```

Output should look something like this -

```graphql
{
  "data": {
    "endActivity": {
      "correlationId": "52c38812-07dd-4793-b286-efb6f557fc55",
      "context": "http://blockchaintp.com/chronicle/ns#activity:rotorbladefabrication"
    }
  }
}
```

## Querying Provenance

### What activity was this item generated by

```graphql
query {
  entityById(id: "http://blockchaintp.com/chronicle/ns#entity:rotorblade") {
    ... on Item {
      partIdAttribute
      wasGeneratedBy { ... on ItemManufactured { id } }
    }
  }
}
```

Output should look something like this -

```graphql
{
  "data": {
    "entityById": {
      "partIdAttribute": "NATO12344567890",
      "wasGeneratedBy": [
        {
          "id": "http://blockchaintp.com/chronicle/ns#activity:rotorbladefabrication"
        }
      ]
    }
  }
}
```

### What is the activity timeline for this item

```graphql
query {
  activityTimeline(forEntity: ["http://blockchaintp.com/chronicle/ns#entity:rotorblade"],
                  activityTypes: [],
                  forAgent:[]
                  ) {
      pageInfo {
          hasPreviousPage
          hasNextPage
          startCursor
          endCursor
      }
      edges {
          node {
              __typename
              ... on ItemManufactured {
                started
                ended
                wasAssociatedWith {
                  responsible {
                    role
                    agent {
                      __typename
                      ... on Contractor {
                        name
                      }
                    }
                  }
                }
              }
          }
          cursor
      }
  }
}
```

Output should look something like this -

```graphql
{
  "data": {
    "activityTimeline": {
      "pageInfo": {
        "hasPreviousPage": false,
        "hasNextPage": false,
        "startCursor": "0",
        "endCursor": "0"
      },
      "edges": [
        {
          "node": {
            "__typename": "ItemManufactured",
            "started": "2022-10-13T16:05:07.900923563+00:00",
            "ended": "2022-10-13T16:09:09.876029683+00:00",
            "wasAssociatedWith": [
              {
                "responsible": {
                  "role": "Manufacturer",
                  "agent": {
                    "__typename": "Contractor",
                    "name": "baesystems"
                  }
                }
              }
            ]
          },
          "cursor": "0"
        }
      ]
    }
  }
}
```
