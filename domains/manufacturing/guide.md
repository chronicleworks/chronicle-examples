# Manufacturing Guide

## Modelling Manufacturing

We want to be able to manufacture high specification items such as rotorblades
in batches but then certify them individually.

### Manufacturing Items

// TODO

### Certifying Items

// TODO

## Recording Manufacturing

In this example we will create a `Contractor` agent which will then embark on
the following activities:

1. An `ItemManufactured` activity to manufacture a batch of rotor blades
1. A series of `ItemCertified` activities to certify each rotor blade in turn

### Record Contractor Creation

```graphql
mutation {
  contractor(name:"helicoptersplc",attributes:{locationAttribute:"Bristol"}) {
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
      "context": "http://blockchaintp.com/chronicle/ns#agent:helicoptersplc",
      "correlationId": "21a78773-67ff-4ca5-9887-a376086a5e7a"
    }
  }
}
```

### Manufacturing Rotor Blades

#### Record Manufacturing Activity Creation

```graphql
mutation {
  itemManufactured(name:"rotorbladefab-20221014-001",attributes:{batchIdAttribute:"20221014-001"}) {
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
      "correlationId": "6e847156-3692-465a-85a7-c34357df5670",
      "context": "http://blockchaintp.com/chronicle/ns#activity:rotorbladefab%2D20221014%2D001"
    }
  }
}
```

#### Record Start of Manufacturing Activity

```graphql
mutation {
  startActivity(
    id:"http://blockchaintp.com/chronicle/ns#activity:rotorbladefab%2D20221014%2D001")    {
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
      "correlationId": "951d545c-7f3e-447e-89d5-f3edcaec47c4",
      "context": "http://blockchaintp.com/chronicle/ns#activity:rotorbladefab%2D20221014%2D001"
    }
  }
}
```

#### Record Manufacture of Batch of Rotor Blades

For each rotor blade produced by this activity we first record its creation.

**NOTE** that here we are focusing on a single rotor blade. However, in a real
world example this process would be repeated and we would need to make sure that
the identity and partID were incremented.

```graphql
mutation {
  item(name:"rotorblade-20221014-0001",attributes:{partIdAttribute:"20221014-0001"}) {
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
      "context": "http://blockchaintp.com/chronicle/ns#entity:rotorblade%2D20221014%2D0001",
      "correlationId": "e11aae24-d683-4a0a-81c2-3da3b5739b2b"
    }
  }
}
```

Then we assert that it `wasGeneratedBy` by the relevant manufacturing activity.

```graphql
mutation {
  wasGeneratedBy(id:"http://blockchaintp.com/chronicle/ns#entity:rotorblade%2D20221014%2D0001",
    activity:"http://blockchaintp.com/chronicle/ns#activity:rotorbladefab%2D20221014%2D001") {
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
      "correlationId": "2878bea4-4ed1-42ca-bc54-c2e647571738",
      "context": "http://blockchaintp.com/chronicle/ns#entity:rotorblade%2D20221014%2D0001"
    }
  }
}
```

For completeness we record that the activity `used` it. (In a future release
this will be replaced by `Generated`.)

```graphql
mutation {
  used(id:"http://blockchaintp.com/chronicle/ns#entity:rotorblade%2D20221014%2D0001",
    activity:"http://blockchaintp.com/chronicle/ns#activity:rotorbladefab%2D20221014%2D001") {
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
      "correlationId": "787e5d34-328b-4844-807e-9804a7c593f3",
      "context": "http://blockchaintp.com/chronicle/ns#entity:rotorblade%2D20221014%2D0001"
    }
  }
}
```

In this guide we are only showing the recording of a single rotor blade but in
practice a batch will be associated with this activity before it comes to an
end.

#### Record End of Manufacturing Activity

First we assert that contractor was responsible for this activity in its role
as a `Manufacturer` using the `wasAssociatedWith` relationship -

```graphql
mutation {
    wasAssociatedWith(
    activity: "http://blockchaintp.com/chronicle/ns#activity:rotorbladefab%2D20221014%2D001",
    responsible:"http://blockchaintp.com/chronicle/ns#agent:helicoptersplc",
    role:MANUFACTURER) {
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
      "correlationId": "9846db0a-be54-43b8-9466-313f715cf613",
      "context": "http://blockchaintp.com/chronicle/ns#agent:helicoptersplc"
    }
  }
}
```

Then we end the activity.

```graphql
mutation {
  endActivity(
    id:"http://blockchaintp.com/chronicle/ns#activity:rotorbladefab%2D20221014%2D001") {
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
      "correlationId": "938dda55-f91b-44c2-9aa4-62b97ddba2ee",
      "context": "http://blockchaintp.com/chronicle/ns#activity:rotorbladefab%2D20221014%2D001"
    }
  }
}
```

### Certifying Rotor Blades

In this example each a rotor blade is certified using a distinct activity.

#### Record Certification Activity Creation

Here the identity of the activity can incorporate (if we chose) the partID.

```graphql
mutation {
  itemCertified(name:"rotorbladecert-20221014-0001") {
    correlationId,
    context
  }
}
```

Output should look something like this -

```graphql
{
  "data": {
    "itemCertified": {
      "correlationId": "9555462c-87c9-42bb-b3ed-485880a50734",
      "context": "http://blockchaintp.com/chronicle/ns#activity:rotorbladecert%2D20221014%2D0001"
    }
  }
}
```

#### Record Start of Certification Activity

```graphql
mutation {
  startActivity(
    id:"http://blockchaintp.com/chronicle/ns#activity:rotorbladecert%2D20221014%2D0001") {
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
      "correlationId": "951d545c-7f3e-447e-89d5-f3edcaec47c4",
      "context": "http://blockchaintp.com/chronicle/ns#activity:rotorbladefab%2D20221014%2D001"
    }
  }
}
```

#### Record the Certification of a Rotor Blade

For each rotor blade certified by this activity we first record its
corresponding certificate creation along with its certID. In this simple
example the certID is the same as the partID of the rotor blade.

```graphql
mutation {
  certificate(name:"rotorbladecert-20221014-0001",attributes:{certIdAttribute:"20221014-0001"}) {
    context,
    correlationId
  }
}
```

Output should look something like this -

```graphql
{
  "data": {
    "certificate": {
      "context": "http://blockchaintp.com/chronicle/ns#entity:rotorbladecert%2D20221014%2D0001",
      "correlationId": "6d6bb3cd-95f1-469e-981e-640d22ad194c"
    }
  }
}
```

Then we assert that it `wasGeneratedBy` by the certification activity.

```graphql
mutation {
  wasGeneratedBy(id:"http://blockchaintp.com/chronicle/ns#entity:rotorbladecert%2D20221014%2D0001",
    activity:"http://blockchaintp.com/chronicle/ns#activity:rotorbladecert%2D20221014%2D0001") {
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
      "correlationId": "a09642f2-2b88-4ccd-868d-f3e990ec5e04",
      "context": "http://blockchaintp.com/chronicle/ns#entity:rotorbladecert%2D20221014%2D0001"
    }
  }
}
```

For completeness we record that the activity `used` the certificate. (In a
future release this will be replaced by `Generated`.) However, this time we also
record the fact that the activity `used` the rotor blade.

```graphql
mutation {
  cert: used(id:"http://blockchaintp.com/chronicle/ns#entity:rotorbladecert%2D20221014%2D0001",
    activity:"http://blockchaintp.com/chronicle/ns#activity:rotorbladecert%2D20221014%2D0001") {
    correlationId,
    context
  }
  blade: used(id:"http://blockchaintp.com/chronicle/ns#entity:rotorblade%2D20221014%2D0001",
    activity:"http://blockchaintp.com/chronicle/ns#activity:rotorbladecert%2D20221014%2D0001") {
    correlationId,
    context
  }
}
```

Output should look something like this -

```graphql
{
  "data": {
    "cert": {
      "correlationId": "4d2323e7-49ad-4031-89fb-20cf7eceedc9",
      "context": "http://blockchaintp.com/chronicle/ns#entity:rotorbladecert%2D20221014%2D0001"
    },
    "blade": {
      "correlationId": "adba37c9-8d37-4a54-bb02-f28a7ba1f342",
      "context": "http://blockchaintp.com/chronicle/ns#entity:rotorblade%2D20221014%2D0001"
    }
  }
}
```

Given the scope of this activity is limited to a single rotor blade we now end
it.

#### Record End of Certifying Activity

First we assert that contractor was responsible for this activity in its role
as a `CERTIFIER` using the `wasAssociatedWith` relationship -

```graphql
mutation {
    wasAssociatedWith(
    activity: "http://blockchaintp.com/chronicle/ns#activity:rotorbladecert%2D20221014%2D0001",
    responsible:"http://blockchaintp.com/chronicle/ns#agent:helicoptersplc",
    role:CERTIFIER) {
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
      "correlationId": "3a8a66df-ea08-46ed-a67f-50f0c7fcaf7b",
      "context": "http://blockchaintp.com/chronicle/ns#agent:helicoptersplc"
    }
  }
}
```

Then we end the activity.

```graphql
mutation {
  endActivity(
    id:"http://blockchaintp.com/chronicle/ns#activity:rotorbladecert%2D20221014%2D0001") {
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
      "correlationId": "75874c77-e50a-4b4b-87f7-0e00ade3e2a0",
      "context": "http://blockchaintp.com/chronicle/ns#activity:rotorbladecert%2D20221014%2D0001"
    }
  }
}
```

## Querying Manufacturing

There are many queries that can be run. Here are a couple of examples.

### Example 1

```graphql
query {
  q1: entityById(id:"http://blockchaintp.com/chronicle/ns#entity:rotorblade%2D20221014%2D0001") {
    ... on Item {
      partIdAttribute
      wasGeneratedBy { ... on ItemManufactured { id } }
    }
  }
  q2: entityById(id:"http://blockchaintp.com/chronicle/ns#entity:rotorbladecert%2D20221014%2D0001") {
    ... on Certificate {
      certIdAttribute
      wasGeneratedBy { ... on ItemCertified { id } }
    }
  }
}
```

Output should look something like this -

```graphql
{
  "data": {
    "q1": {
      "partIdAttribute": "20221014-0001",
      "wasGeneratedBy": [
        {
          "id": "http://blockchaintp.com/chronicle/ns#activity:rotorbladefab%2D20221014%2D001"
        }
      ]
    },
    "q2": {
      "certIdAttribute": "20221014-0001",
      "wasGeneratedBy": [
        {
          "id": "http://blockchaintp.com/chronicle/ns#activity:rotorbladecert%2D20221014%2D0001"
        }
      ]
    }
  }
}
```

### Example 2

```graphql
query {
  activityTimeline(forEntity: ["http://blockchaintp.com/chronicle/ns#entity:rotorblade%2D20221014%2D0001"],
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
             ... on ItemCertified {
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
        "endCursor": "1"
      },
      "edges": [
        {
          "node": {
            "__typename": "ItemCertified",
            "started": "2022-10-14T20:12:37.865949122+00:00",
            "ended": "2022-10-14T20:12:37.865949122+00:00",
            "wasAssociatedWith": [
              {
                "responsible": {
                  "role": "CERTIFIER",
                  "agent": {
                    "__typename": "Contractor",
                    "name": "helicoptersplc"
                  }
                }
              }
            ]
          },
          "cursor": "0"
        },
        {
          "node": {
            "__typename": "ItemManufactured",
            "started": "2022-10-14T18:36:28.955763872+00:00",
            "ended": "2022-10-14T19:23:53.589009662+00:00",
            "wasAssociatedWith": [
              {
                "responsible": {
                  "role": "MANUFACTURER",
                  "agent": {
                    "__typename": "Contractor",
                    "name": "helicoptersplc"
                  }
                }
              }
            ]
          },
          "cursor": "1"
        }
      ]
    }
  }
}
```

### Example 3

```graphql
query {
  activityTimeline(forEntity: ["http://blockchaintp.com/chronicle/ns#entity:rotorbladecert%2D20221014%2D0001"],
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
             ... on ItemCertified {
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
        "endCursor": "1"
      },
      "edges": [
        {
          "node": {
            "__typename": "ItemCertified",
            "started": "2022-10-14T20:12:37.865949122+00:00",
            "ended": "2022-10-14T20:12:37.865949122+00:00",
            "wasAssociatedWith": [
              {
                "responsible": {
                  "role": "CERTIFIER",
                  "agent": {
                    "__typename": "Contractor",
                    "name": "helicoptersplc"
                  }
                }
              }
            ]
          },
          "cursor": "0"
        },
        {
          "node": {
            "__typename": "ItemCertified",
            "started": "2022-10-14T20:12:37.865949122+00:00",
            "ended": "2022-10-14T20:12:37.865949122+00:00",
            "wasAssociatedWith": [
              {
                "responsible": {
                  "role": "CERTIFIER",
                  "agent": {
                    "__typename": "Contractor",
                    "name": "helicoptersplc"
                  }
                }
              }
            ]
          },
          "cursor": "1"
        }
      ]
    }
  }
}
```
