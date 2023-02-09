# Artworld Guide

## Modeling the Artworld

In the world of art, many different players come together to create a thriving
and dynamic industry. In order to keep track of all of these players and their
actions, a model of the artworld outlines the different entities and agents
involved in the world of art, as well as the different activities and roles that
they play.

### Modeling an `Artwork` and `ArtworkDetails` and the Output

At the center of this model are two key entities: `Artwork` and `ArtworkDetails`.
`Artwork` refers to the actual physical art piece, while `ArtworkDetails` provides
more information about the piece, such as its title and description.

In our Chronicle domain specification these entities are captured as:

```yaml
entities:
  Artwork:
    attributes:
      - Title
  ArtworkDetails:
    attributes:
      - Title
      - Description
```

These entities can be defined in Chronicle using GraphQL like so:

```graphql
mutation {
  defineArtworkEntity(
    externalId: "salvatormundi"
    attributes: { titleAttribute: "Salvator Mundi" }
  ) {
    context
    txId
  }
  defineArtworkDetailsEntity(
    externalId: "salvatormundidetails"
    attributes: {
      titleAttribute: "Salvator Mundi"
      descriptionAttribute: "Depiction of Christ holding a crystal orb in his left hand and making the sign of the blessing with his right hand."
    }
  ) {
    context
    txId
  }
}
```

```json
{
  "data": {
    "defineArtworkEntity": {
      "context": "chronicle:entity:salvatormundi",
      "txId": "9c9748a7217818b7c8ba5e6c8699a50545a0888ddbf299738c8cc539e29e808d7fdace9ea8a376a495d9718fdfca46e1849306588943b4bd29d33a67e324b0e2"
    },
    "defineArtworkDetailsEntity": {
      "context": "chronicle:entity:salvatormundidetails",
      "txId": "ebd9363f7efe3194e42d153e0c436e152e4c4ce3096117df47458c38683e5cb4707eeb28a2309a8a6f9cf025ef0d36e630a4acd0e2ab752cbadb7d951046d1d9"
    }
  }
}
```

### Modeling a `Collector` and an `Artist` and the Output

The agents in this model are `Collector` and `Artist`, both of whom play crucial
roles in the art world. Collectors purchase and amass collections of art, while
artists create new works of art. Both kinds of agent might well be involved in
exhibiting and selling works of art.

In our Chronicle domain specification these entities are captured as:

```yaml
agents:
  Collector:
    attributes:
      - Name
  Artist:
    attributes:
      - Name
```

Defining these agents in Chronicle using GraphQL looks like this:

```graphql
mutation {
  defineCollectorAgent(
    externalId: "collector471"
    attributes: { nameAttribute: "Dmitry Rybolovlev" }
  ) {
    context
    txId
  }

  defineArtistAgent(
    externalId: "artist001"
    attributes: { nameAttribute: "Leonardo da Vinci" }
  ) {
    context
    txId
  }
}
```

```json
{
  "data": {
    "defineCollectorAgent": {
      "context": "chronicle:agent:collector471",
      "txId": "22400f32dba9bd2735ff455440f9b136bab1d53720d1be7526d3730a7711ab5a1dfef8539f7edb9a9a94c4466c03746a5d7de00acc0196175596575095f5beb3"
    },
    "defineArtistAgent": {
      "context": "chronicle:agent:artist001",
      "txId": "98252f9cebe03bfe98a5f3a8bd45bf19dfe0dad00b2aeb7b5c93ff407a9b0c4f710f40f03114730affdfb0899c290c6d1115b010554953f96c51a04b84bf11c2"
    }
  }
}
```

Finally, the model also outlines the different activities that take place within
the artworld, including exhibiting, creating, and selling. `Created` refers to the
act of creating a new piece of art, while `Exhibited` refers to the display of an
artwork in a public space. `Sold` refers to the transaction between a collector
and an artist, in which the collector purchases the artwork for a certain amount
of money.

### Modeling `Created`, `Exhibited`, and `Sold` and the Output

In our Chronicle domain specification these activities are modeled like this:

```yaml
activities:
  Exhibited:
    attributes:
      - Location
  Created:
    attributes:
      - Title
  Sold:
    attributes:
      - PurchaseValue
      - PurchaseValueCurrency
```

Here is a mutation defining these activities in Chronicle using GraphQL:

```graphql
mutation {
  defineCreatedActivity(
    externalId: "salvatormundi"
    attributes: { titleAttribute: "Salvator Mundi" }
  ) {
    context
    txId
  }
  defineExhibitedActivity(
    externalId: "salvatormundiprado"
    attributes: {
      locationAttribute: "Prado Museum"
    }
  ) {
    context
    txId
  }
  defineSoldActivity(
    externalId: "saleofsalvatormundi"
    attributes: {
      purchaseValueAttribute: "450000000"
      purchaseValueCurrencyAttribute: "USD"
    }
  ) {
    context
    txId
  }
}
```

```json
{
  "data": {
    "defineCreatedActivity": {
      "context": "chronicle:activity:salvatormundi",
      "txId": "e867b19f5a6fb8b32c2f4467f46f63eadff505576fb85deed07698001ac7c8264b17ba46a2695c9514fb1cd0c480f19272f9325cc7231e75a99d9b9addacf7e6"
    },
    "defineExhibitedActivity": {
      "context": "chronicle:activity:salvatormundiprado",
      "txId": "a04a00d330a72e6b27c1da219441462312c8f02cd4f09cc14ed8fdd013b6aab6668488909f4d9dcb4b477b80c097df97f100118568033d9177ce4a47bcdbc550"
    },
    "defineSoldActivity": {
      "context": "chronicle:activity:saleofsalvatormundi",
      "txId": "07eb5003511a5c73cd658ce4b534c15aef296f289b0488e9e7ced1b4006b28982e49de346e845fc5d1c908d3af9595fd2bbfd64029f831594ca1302d3222770e"
    }
  }
}
```

![Modeling the Artworld](/docs/diagrams/out/modeling_the_artworld.svg)

## Recording the Artworld

With this model in place, it is possible to keep track of the different events and
transactions that occur within the artworld. For example, when a new artwork is
created, this event can be recorded as a `Created` activity, with the artist and
the title of the artwork both noted. Similarly, when an artwork is sold, this can
be recorded as a `Sold` activity, along with details of the buyer and the purchase
price.

### Recording Associations of Artworld Agents with Artworld Activities and the Output

```graphql
mutation {
  wasAssociatedWith(
    responsible: { externalId: "artist001" }
    activity: { externalId: "salvatormundi" }
    role: CREATOR
  ) {
    context
    txId
  }
}
```

```json
{
  "data": {
    "wasAssociatedWith": {
      "context": "chronicle:agent:artist001",
      "txId": "c79317a4e7d0c685c946f6b2bebed891b862cad0d0138edc92240560d60c1dec2d9a48e99027d633b5d5b2bb19cd39d5f4eab6c60c16ee88ef7706730177c4fe"
    }
  }
}
```

```graphql
mutation {
  wasAssociatedWith(
    responsible: { externalId: "collector471" }
    activity: { externalId: "saleofsalvatormundi" }
    role: SELLER
  ) {
    context
    txId
  }
}
```

```json
{
  "data": {
    "wasAssociatedWith": {
      "context": "chronicle:agent:collector471",
      "txId": "c15682f289153b1726b53be678081168dd6900051d8e32387633367403c512560ef4ace45f7c9991c83d8a27158b41d3f32d3ffd0cbbb84c60d10c49abbf9622"
    }
  }
}
```

### Recording Use of Artworld Entities in Artworld Activities and the Output

```graphql
mutation {
  wasGeneratedBy(
    activity: { externalId: "salvatormundi" }
    id: { externalId: "salvatormundi" }
  ) {
    context
    txId
  }
}
```

```json
{
  "data": {
    "wasGeneratedBy": {
      "context": "chronicle:entity:salvatormundi",
      "txId": "f5e858671e5d57b6a00b95e7014dccb6b6c7cf45dfe9b6acbfc62b137a7d3e1d1c1131e56a44a012b3802aebba91917c60c254568c95409cb8c1456204b4b9b1"
    }
  }
}
```

```graphql
mutation {
  used(
    activity: { externalId: "saleofsalvatormundi" }
    id: { externalId: "salvatormundi" }
  ) {
    context
    txId
  }
}
```

```json
{
  "data": {
    "used": {
      "context": "chronicle:entity:salvatormundi",
      "txId": "c591a30a412c53bfe86b0f146fba800ed00d79e9e9650821379a761019fa1236386a1ddb2b00a2fe23de099face3e72e7faad6f31bff719eaf4be2bbd0379db5"
    }
  }
}
```

This is only one example, but by writing provenance data to a blockchain, we can
establish a comprehensive and irrefutable record of all activities and movements
within the artworld. This not only provides valuable insights into the history of
the artworld, but also holds the power to revolutionize the industry by promoting
transparency. With this data easily accessible, collectors and artists alike will
be able to confidently verify the value and authenticity of individual pieces,
ultimately enhancing trust in the art market.

![Recording the Artworld](/docs/diagrams/out/recording_the_artworld.svg)

## Querying the Artworld

With a comprehensive record of the artworld in place, it is now possible to query
this record and gain insights into the industry. For example, one could query the
record to determine the average sale price of artworks created by a particular
artist, or to see which artists are exhibiting their works in a particular location.

### Querying the Associations of the Sale of an Artwork and the Output

```graphql
query {
  activityById(id: {externalId: "saleofsalvatormundi"}) {
    ...on SoldActivity {
      wasAssociatedWith {
        responsible {
          role
          agent {
            ...on CollectorAgent {
              nameAttribute
              externalId
            }
          }
        }
      }
    }
  }
}
```

```json
{
  "data": {
    "activityById": {
      "wasAssociatedWith": [
        {
          "responsible": {
            "role": "SELLER",
            "agent": {
              "nameAttribute": "Dmitry Rybolovlev",
              "externalId": "collector471"
            }
          }
        }
      ]
    }
  }
}
```

```graphql
query {
  activitiesByType(activityType: SoldActivity) {
    nodes {
      ... on SoldActivity {
        purchaseValueAttribute
        purchaseValueCurrencyAttribute
        wasAssociatedWith {
          responsible {
            role
            agent {
              ... on CollectorAgent {
                externalId
                nameAttribute
              }
            }
          }
        }
      }
    }
  }
}
```

```json
{
  "data": {
    "activitiesByType": {
      "nodes": [
        {
          "purchaseValueAttribute": "450000000",
          "purchaseValueCurrencyAttribute": "USD",
          "wasAssociatedWith": [
            {
              "responsible": {
                "role": "SELLER",
                "agent": {
                  "externalId": "collector471",
                  "nameAttribute": "Dmitry Rybolovlev"
                }
              }
            }
          ]
        }
      ]
    }
  }
}
```

These and many more queries are made possible by the rich data to be recorded
about the artworld, including the names and roles of the different agents and
entities, as well as the details of each activity that has taken place. The
ability to query this data in a multitude of ways opens up a whole new world
of understanding about the artworld and its inner workings. By being able to
easily see the names, roles, and associations of the different players in the
industry, decision making is made all the more informed. Just like the law of
the Medes and Persians, the data recorded on a blockchain is unchanging and
absolute, giving it a level of permanence and authority like never before.
