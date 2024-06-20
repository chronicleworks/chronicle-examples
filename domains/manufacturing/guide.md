# Manufacturing Guide

## Modeling Manufacturing

We want to record the batch manufacture of high specification items such as
rotor blades by a contractor, which then inspects these individually and issues
a certificate.

### Manufacturing Items

Although various agents could be involved in the manufacturing activity, in this
example, the contractor is the only agent responsible for the manufacturing of
high specification rotor blades, which it does so in batches.

![Item Manufactured](/docs/diagrams/out/manufacturing_ItemManufactured.svg)

#### Modeling the Contractor Agent

The `Contractor` agent has two attributes, its `CompanyName` and its `Location`.
In our Chronicle domain specification this is captured as follows -

```yaml
attributes:
  CompanyName:
    type: String
  Location:
    type: String
agents:
  Contractor:
    attributes:
      - CompanyName
      - Location
```

#### Modeling the Item Entity

The `Item` entity has one attribute, its `PartID`.

```yaml
attributes:
  PartID:
    type: String
entities:
  Item:
    attributes:
      - PartID
```

#### Modeling the ItemManufactured Activity

The `ItemManufactured` activity has one attribute, its `BatchID`. It also has a
`Manufacturer` role.

```yaml
attributes:
  BatchID:
    type: String
activities:
  ItemManufactured:
    attributes:
      - BatchID
roles:
  - Manufacturer
```

### Certifying Items

Although various agents could be involved in the certification activity, in this
example, the contractor is the only agent responsible for the certification of
high specification rotor blades, which it does so individually.
Therefore this activity uses the item and issues a certificate for it.

![Item Manufactured](/docs/diagrams/out/manufacturing_ItemCertified.svg)

#### Modeling the Certificate Entity

The `Certificate` entity has one attribute, its `CertID`.

```yaml
attributes:
  CertID:
    type: String
entities:
  Certificate:
    attributes:
      - CertID
```

#### Modeling the ItemCertified Activity

The `ItemCertified` activity has no attributes but it has a role `Certifier`.

```yaml
activities:
  ItemCertified:
    attributes: []
roles:
  - Certifier
```

### Chronicle Domain

Combining these fragments gives us our Chronicle `manufacturing` domain.

```yaml
name: "manufacturing"
attributes:
  BatchID:
    type: String
  CertID:
    type: String
  CompanyName:
    type: String
  PartID:
    type: String
  Location:
    type: String
agents:
  Contractor:
    attributes:
      - Location
entities:
  Certificate:
    attributes:
      - CertID
  Item:
    attributes:
      - PartID
activities:
  ItemCertified:
    attributes: []
  ItemManufactured:
    attributes:
      - BatchID
roles:
  - Certifier
  - Manufacturer
```

## Recording Manufacturing

In this example we will create a `Contractor` agent which will then embark on
the following activities:

1. An `ItemManufactured` activity to manufacture a batch of rotor blades
1. A series of `ItemCertified` activities to certify each rotor blade in turn

### Record Contractor

The first record is that there is a contractor called Helicopters PLC based in
Bristol.

```graphql
mutation {
  defineContractorAgent(externalId: "helicoptersplc", attributes:{
    companyNameAttribute: "Helicopters PLC",
    locationAttribute:"Bristol"}) {
    context
    txId
  }
}
```

The output should look something like this -

```json
{
  "data": {
    "defineContractorAgent": {
      "context": "chronicle:agent:helicoptersplc",
      "txId": "492c4827-d3c5-4427-8b43-d35f9ad58687"
    }
  }
}
```

#### Obtaining the list of Contractors

Note that you can always obtain the list of contractors known to Chronicle
using this query -

```graphql
query {
  agentsByType(agentType: ContractorAgent) {
    nodes {
      __typename
      ... on ContractorAgent {
        externalId
        companyNameAttribute
        locationAttribute
      }
    }
  }
}
```

The output should look something like this -

```json
{
  "data": {
    "agentsByType": {
      "nodes": [
        {
          "__typename": "ContractorAgent",
          "externalId": "acmecorp",
          "companyNameAttribute": "ACME Corp",
          "locationAttribute": "Burbank, California"
        },
        {
          "__typename": "ContractorAgent",
          "externalId": "helicoptersplc",
          "companyNameAttribute": "Helicopters PLC",
          "locationAttribute": "Bristol"
        }
      ]
    }
  }
}
```

### Manufacturing Rotor Blades

#### Record Manufacturing Activity Instance

```graphql
mutation {
  defineItemManufacturedActivity(externalId: "rotorblade-manufacture-run-001", attributes:{ batchIDAttribute: "run-001" }) {
    context
    txId
  }
}
```

The output should look something like this -

```json
{
  "data": {
    "defineItemManufacturedActivity": {
      "context": "chronicle:activity:rotorblade%2Dmanufacture%2Drun%2D001",
      "txId": "93ad8dd6-4e97-45e0-9c60-ddb079863830"
    }
  }
}
```

#### Record Contractor's Role in the Manufacturing Activity

We assert that contractor was responsible for this activity in its role
as a `Manufacturer` using the `wasAssociatedWith` relationship -

```graphql
mutation {
    wasAssociatedWith(
    activity: { externalId: "rotorblade-manufacture-run-001" },
    responsible: { externalId: "helicoptersplc" },
    role: MANUFACTURER) {
    context
    txId
  }
}
```

The output should look something like this -

```json
{
  "data": {
    "wasAssociatedWith": {
      "context": "chronicle:agent:helicoptersplc",
      "txId": "59b26631-db0f-4c5d-a79d-9ff8d85564d4"
    }
  }
}
```

#### Record Start of Manufacturing Activity

```graphql
mutation {
  startActivity(
    id: { externalId: "rotorblade-manufacture-run-001" }) {
    context
    txId
  }
}
```

The output should look something like this -

```json
{
  "data": {
    "startActivity": {
      "context": "chronicle:activity:rotorblade%2Dmanufacture%2Drun%2D001",
      "txId": "36d58122-35ec-4e66-a31b-1534710e310b"
    }
  }
}
```

#### Record the Manufacturing of Batch of Rotor Blades

For each rotor blade produced by this activity, we first record its creation.

**NOTE** that here we are focusing on a single rotor blade. However, in a real
world example, this process would be repeated and we would need to make sure
that the `externalId` and `PartID` were incremented.

```graphql
mutation {
  defineItemEntity(externalId:"rotorblade-run-001-001",attributes:{partIDAttribute:"run-001-001"}) {
    context
    txId
  }
}
```

The output should look something like this -

```json
{
  "data": {
    "defineItemEntity": {
      "context": "chronicle:entity:rotorblade%2Drun%2D001%2D001",
      "txId": "630356af-01e1-42cd-9513-f52b59c70d53"
    }
  }
}
```

Then we assert that it `wasGeneratedBy` by the relevant manufacturing activity.

```graphql
mutation {
  wasGeneratedBy(id: { externalId: "rotorblade-run-001-001" },
    activity: { externalId: "rotorblade-manufacture-run-001" }) {
    context
    txId
  }
}
```

The output should look something like this -

```json
{
  "data": {
    "wasGeneratedBy": {
      "context": "chronicle:entity:rotorblade%2Drun%2D001%2D001",
      "txId": "edde4708-e451-4bb6-b548-0cf818db5b3b"
    }
  }
}
```

**NOTE** that this is a bidirectional relationship and the fact that the manufacturing
activity `generated` this rotor blade is inferred.

In this guide, we are only showing the recording of a single rotor blade, however,
in practice, a batch will be associated with this activity, before the activity comes
to an end.

#### Record End of Manufacturing Activity

```graphql
mutation {
  endActivity(
    id:{ externalId: "rotorblade-manufacture-run-001" }) {
    context
    txId
  }
}
```

The output should look something like this -

```json
{
  "data": {
    "endActivity": {
      "context": "chronicle:activity:rotorblade%2Dmanufacture%2Drun%2D001",
      "txId": "51839346-b068-4946-9491-334d465faa56"
    }
  }
}
```

### Certifying Rotor Blades

In this example, each rotor blade is certified, using a distinct activity.

#### Record Certification Activity Instance

Here, the identity of the activity can incorporate the PartID.

```graphql
mutation {
  defineItemCertifiedActivity(externalId: "rotorblade-certify-run-001-001") {
    context
    txId
  }
}
```

The output should look something like this -

```json
{
  "data": {
    "defineItemCertifiedActivity": {
      "context": "chronicle:activity:rotorblade%2Dcertify%2Drun%2D001%2D001",
      "txId": "e2ca580a-f0dd-4ea5-8bce-297a4f6800b7"
    }
  }
}
```

#### Record Contractor's Role in the Certification Activity

We assert that contractor was responsible for this activity in its role
as a `CERTIFIER` using the `wasAssociatedWith` relationship -

```graphql
mutation {
    wasAssociatedWith(
    activity: { externalId: "rotorblade-certify-run-001-001" },
    responsible: { externalId: "helicoptersplc" },
    role: CERTIFIER) {
    context
    txId
  }
}
```

The output should look something like this -

```json
{
  "data": {
    "wasAssociatedWith": {
      "context": "chronicle:agent:helicoptersplc",
      "txId": "e2998de6-1629-4924-aa90-b93b8ddd1c85"
    }
  }
}
```

#### Record Start of Certification Activity

```graphql
mutation {
  startActivity(
    id: { externalId: "rotorblade-certify-run-001-001" }) {
    context
    txId
  }
}
```

The output should look something like this -

```json
{
  "data": {
    "startActivity": {
      "context": "chronicle:activity:rotorblade%2Dcertify%2Drun%2D001%2D001",
      "txId": "fc1570a7-1077-4839-9277-c906c834a8b4"
    }
  }
}
```

#### Record the Certification of a Rotor Blade

For each rotor blade certified by this activity, we first record its
corresponding certificate generation along with its CertID. In this simplified
example, the CertID of the rotor blade is the same as its PartID.

```graphql
mutation {
  defineCertificateEntity(externalId: "rotorblade-certificate-run-001-001", attributes:{ certIDAttribute: "run-001-001" }) {
    context
    txId
  }
}
```

The output should look something like this -

```json
{
  "data": {
    "defineCertificateEntity": {
      "context": "chronicle:entity:rotorblade%2Dcertificate%2Drun%2D001%2D001",
      "txId": "2db682a4-c1cf-4ebd-8f07-8f81d6c9da2f"
    }
  }
}
```

Then, we assert that it `wasGeneratedBy` by the certification activity.

```graphql
mutation {
  wasGeneratedBy(id: { externalId: "rotorblade-certificate-run-001-001" },
    activity: { externalId: "rotorblade-certify-run-001-001" }) {
    context
    txId
  }
}
```

The output should look something like this -

```json
{
  "data": {
    "wasGeneratedBy": {
      "context": "chronicle:entity:rotorblade%2Dcertificate%2Drun%2D001%2D001",
      "txId": "83acf7e3-afcc-4685-8f76-b34a91acff7f"
    }
  }
}
```

**NOTE** that this is a bidirectional relationship and the fact that the certification
activity `generated` this certificate is inferred.

However, this time we also record the fact that the activity `used` the rotor blade.

```graphql
mutation {
  used(id: { externalId: "rotorblade-run-001-001" },
    activity: { externalId: "rotorblade-certify-run-001-001" }) {
    context
    txId
  }
}
```

The output should look something like this -

```json
{
  "data": {
    "used": {
      "context": "chronicle:entity:rotorblade%2Drun%2D001%2D001",
      "txId": "d0eb8691-29e0-4264-aebb-31733f4ffb21"
    }
  }
}
```

Given the scope of this activity is limited to a single rotor blade, we now end
the activity.

#### Record End of Certifying Activity

```graphql
mutation {
  endActivity(
    id: { externalId: "rotorblade-certify-run-001-001" }) {
    context
    txId
  }
}
```

The output should look something like this -

```json
{
  "data": {
    "endActivity": {
      "context": "chronicle:activity:rotorblade%2Dcertify%2Drun%2D001%2D001",
      "txId": "ae86576a-9e1f-4bef-9b74-c5c45c8b6ff7"
    }
  }
}
```

## Querying Manufacturing

There are many queries that can be run. Here are a couple of examples.

### Example 1

```graphql
query {
  q1: entityById(id: { externalId: "rotorblade-run-001-001" }) {
    ... on ItemEntity {
      partIDAttribute
      wasGeneratedBy { ... on ItemManufacturedActivity { id } }
    }
  }
  q2: entityById(id: {externalId: "rotorblade-certificate-run-001-001"}) {
    ... on CertificateEntity {
      certIDAttribute
      wasGeneratedBy { ... on ItemCertifiedActivity { id } }
    }
  }
}
```

The output should look something like this -

```json
{
  "data": {
    "q1": {
      "partIDAttribute": "run-001-001",
      "wasGeneratedBy": [
        {
          "id": "chronicle:activity:rotorblade%2Dmanufacture%2Drun%2D001"
        }
      ]
    },
    "q2": {
      "certIDAttribute": "run-001-001",
      "wasGeneratedBy": [
        {
          "id": "chronicle:activity:rotorblade%2Dcertify%2Drun%2D001%2D001"
        }
      ]
    }
  }
}
```

### Example 2

```graphql
query {
  activityTimeline(forEntity: [{ externalId: "rotorblade-run-001-001" }],
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
             ... on ItemCertifiedActivity {
                started
                ended
                wasAssociatedWith {
                  responsible {
                    role
                    agent {
                      __typename
                      ... on ContractorAgent {
                        companyNameAttribute
                      }
                    }
                  }
                }
              }
              ... on ItemManufacturedActivity {
                started
                ended
                wasAssociatedWith {
                  responsible {
                    role
                    agent {
                      __typename
                      ... on ContractorAgent {
                        companyNameAttribute
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

The output should look something like this -

```json
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
            "__typename": "ItemCertifiedActivity",
            "started": "2022-11-10T11:25:27.525043763+00:00",
            "ended": "2022-11-10T11:30:46.038513324+00:00",
            "wasAssociatedWith": [
              {
                "responsible": {
                  "role": "CERTIFIER",
                  "agent": {
                    "__typename": "ContractorAgent",
                    "companyNameAttribute": "Helicopters PLC"
                  }
                }
              }
            ]
          },
          "cursor": "0"
        },
        {
          "node": {
            "__typename": "ItemManufacturedActivity",
            "started": "2022-11-10T11:11:22.766341245+00:00",
            "ended": "2022-11-10T11:20:37.201544076+00:00",
            "wasAssociatedWith": [
              {
                "responsible": {
                  "role": "MANUFACTURER",
                  "agent": {
                    "__typename": "ContractorAgent",
                    "companyNameAttribute": "Helicopters PLC"
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
  activityTimeline(forEntity: [{ externalId: "rotorblade-run-001-001" }],
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
             ... on ItemCertifiedActivity {
                started
                ended
                wasAssociatedWith {
                  responsible {
                    role
                    agent {
                      __typename
                      ... on ContractorAgent {
                        companyNameAttribute
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

The output should look something like this -

```json
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
            "__typename": "ItemCertifiedActivity",
            "started": "2022-11-10T11:25:27.525043763+00:00",
            "ended": "2022-11-10T11:30:46.038513324+00:00",
            "wasAssociatedWith": [
              {
                "responsible": {
                  "role": "CERTIFIER",
                  "agent": {
                    "__typename": "ContractorAgent",
                    "companyNameAttribute": "Helicopters PLC"
                  }
                }
              }
            ]
          },
          "cursor": "0"
        },
        {
          "node": {
            "__typename": "ItemManufacturedActivity"
          },
          "cursor": "1"
        }
      ]
    }
  }
}
```
