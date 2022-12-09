# Corporate Actions Guide

## Modelling Corporate Actions

A stock split is a corporate action that divides the value of each of the outstanding
shares of a company. This simple example captures some aspects of a stock split,
including its announcement and the registration of shares owned.

### Acquiring Shareholding

First we record that an individual investor has become a shareholder in the company.
This is prior to the stock split.

![Shareholding Acquired](./diagrams/ShareholdingAcquired.png)

#### Modelling the Company Agent

The `Company` agent has two attributes, its `Name` and its `Location`.
In our Chronicle domain specification this is captured as follows -

```yaml
attributes:
  Name:
    type: String
  Location:
    type: String
agents:
  Company:
    attributes:
      - Name
      - Location
```

#### Modelling the Person Agent

The `Person` agent has two attributes, its `Name` and its `Location`.
In our Chronicle domain specification this is captured as follows -

```yaml
attributes:
  Name:
    type: String
  Location:
    type: String
agents:
  Person:
    attributes:
      - Name
      - Location
```

#### Modelling the Shareholding Entity

The `Shareholding` entity has two attributes, its `Quantity` and the `NominalPrice`
per share.

```yaml
attributes:
  Quantity:
    type: Int
  NominalPrice:
    type: String
entities:
  Shareholding:
    attributes:
      - Quantity
      - NominalPrice
```

#### Modelling the ShareholdingAcquired Activity

The `ShareholdingAcquired` activity has no attributes, but it has an
`Issuer` and a `Shareholder`role.

```yaml
attributes: []
activities:
  ShareholdingAcquired:
    attributes: []
roles:
  - Issuer
  - Shareholder
```

### Announcing Stock Split

Here we record that the company announces a stock split. The announcement includes
information about the split ratio, record date, pay date, and exdate.

![Split Announced](./diagrams/SplitAnnounced.png)

#### Modelling the Announcement Entity

The `Announcement` entity has four attributes, its `Ratio`, its `RecordDate`, its
`PayDate`, and its `ExDate`.

```yaml
attributes:
  Ratio:
    type: String
  RecordDate:
    type: String
  PayDate:
    type: String
  ExDate:
    type: String
entities:
  Announcement:
    attributes:
      - Ratio
      - RecordDate
      - PayDate
      - ExDate
```

#### Modelling the SplitAnnounced Activity

The `SplitAnnounced` activity has one attribute `PressDate`, and it also has a role
`Issuer`.

```yaml
attributes:
  PressDate:
    type: String
activities:
  SplitAnnounced:
    attributes:
  - PressDate
roles:
  - Issuer
```

### Updating Shareholding

Here we record that the transfer agent, typically a bank or trust company who acts
on behalf of the company, has updated the person's shareholding as a result of the
stock split.

![Shareholding Updated](./diagrams/ShareholdingUpdated.png)

#### Modelling the TransferAgent Agent

The `TransferAgent` agent has two attributes, its `Name` and its `Location`.
In our Chronicle domain specification this is captured as follows -

```yaml
attributes:
  Name:
    type: String
  Location:
    type: String
agents:
  TransferAgent:
    attributes:
      - Name
      - Location
```

#### Modelling the ShareholdingUpdated Activity

The `ShareholdingUpdated` activity has no attributes, but it has two roles
`Issuer` and `Registrar`.

```yaml
attributes: []
activities:
  ShareholdingUpdated:
    attributes: []
roles:
  - Issuer
  - Registrar
```

### Chronicle Domain

Combining these fragments gives us our Chronicle `corpactions` domain.

```yaml
name: "corpactions"
attributes:
  ExDate:
    type: String
  Name:
    type: String
  Location:
    type: String
  NominalPrice:
    type: String
  PayDate:
    type: String
  PressDate:
    type: String
  Quantity:
    type: Int
  Ratio:
    type: String
  RecordDate:
    type: String
entities:
  Announcement:
    attributes:
      - Ratio
      - RecordDate
      - PayDate
      - ExDate
  ShareHolding:
    attributes:
      - Quantity
      - NominalPrice
activities:
  ShareholdingAcquired:
    attributes: []
  ShareholdingUpdated:
    attributes: []
  SplitAnnounced:
    attributes:
      - PressDate
agents:
  Company:
    attributes:
      - Name
      - Location
  Person:
    attributes:
      - Name
      - Location
  TransferAgent:
    attributes:
      - Name
      - Location
roles:
  - ISSUER
  - REGISTRAR
  - SHAREHOLDER
```

## Recording Corporate Actions

In this example we will create a `Company`, a `Person`, and a `TransferAgent` agent,
which will then embark on the following activities:

1. A `ShareholdingAcquired` activity to record that an individual investor has become
   a shareholder in the company.

1. A `SplitAnnounced` activity to record that the company announces a stock split.

1. A `ShareholdingUpdated` activity to record that the `TransferAgent`, acting on behalf
   of the company, updated the investor's `Shareholding`.

### Record Agents

```graphql
mutation defineAgents {
  defineCompanyAgent(
    externalId: "FTXCorp"
    attributes: { nameAttribute: "FTXCorp", locationAttribute: "Bahamas" }
  ) {
    context
    txId
  }
  definePersonAgent(
    externalId: "NinjaCsilla"
    attributes: { nameAttribute: "NinjaCsilla", locationAttribute: "Barcelona" }
  ) {
    context
    txId
  }
  defineTransferAgentAgent(
    externalId: "Bank"
    attributes: { nameAttribute: "Bank", locationAttribute: "London" }
  ) {
    context
    txId
  }
}
```

The output should look something like this -

```json
{
  "data": {
    "defineCompanyAgent": {
      "context": "chronicle:agent:FTXCorp",
      "txId": "412701fd-9b4c-480b-a264-f6b05027704f"
    },
    "definePersonAgent": {
      "context": "chronicle:agent:NinjaCsilla",
      "txId": "12b258ab-6fb1-4477-868a-e76b5094af73"
    },
    "defineTransferAgentAgent": {
      "context": "chronicle:agent:Bank",
      "txId": "adb3adca-3cc9-445b-8fba-c9c1651640be"
    }
  }
}
```

### Record a ShareholdingAcquiredActivity

Here we define the activity and the roles of the company as the `ISSUER` and the individual
investor as the `SHAREHOLDER`.

```graphql
mutation defineShareholdingAcquisition {
  defineShareholdingAcquiredActivity(externalId: "ShareholdingAcquired") {
    context
    txId
  }
  company: wasAssociatedWith(
    activity: { externalId: "ShareholdingAcquired" }
    responsible: { externalId: "FTXCorp" }
    role: ISSUER
  ) {
    context
    txId
  }
  shareholder: wasAssociatedWith(
    activity: { externalId: "ShareholdingAcquired" }
    responsible: { externalId: "NinjaCsilla" }
    role: SHAREHOLDER
  ) {
    context
    txId
  }
}
```

The output should look something like this -

```json
{
  "data": {
    "defineShareholdingAcquiredActivity": {
      "context": "chronicle:activity:ShareholdingAcquired",
      "txId": "0e4070cd-a096-4e60-93ec-3b4434999a9c"
    },
    "company": {
      "context": "chronicle:agent:FTXCorp",
      "txId": "f885d54a-b74f-41ce-a6ae-6907f0008c2a"
    },
    "shareholder": {
      "context": "chronicle:agent:NinjaCsilla",
      "txId": "b54054c4-98ef-4126-aa17-d339db31fde5"
    }
  }
}
```

### Record the Execution of the ShareholdingAcquiredActivity

Here we record the instantaneous execution of a shareholding acquisition along with the
details of the shareholding, in this case 100 shares each with a nominal value of $1.00.

```graphql
mutation recordShareholdingAcquisition {
  instantActivity(id: { externalId: "ShareholdingAcquired" }) {
    context
    txId
  }
  defineShareHoldingEntity(
    externalId: "Shareholding"
    attributes: { quantityAttribute: 100, nominalPriceAttribute: "$1.00" }
  ) {
    context
  }
  wasGeneratedBy(
    id: { externalId: "Shareholding" }
    activity: { externalId: "ShareholdingAcquired" }
  ) {
    context
    txId
  }
}
```

The output should look something like this -

```json
{
  "data": {
    "instantActivity": {
      "context": "chronicle:activity:ShareholdingAcquired",
      "txId": "4ac7acad-d92e-41dc-9afc-9b0a10263fc8"
    },
    "defineShareHoldingEntity": {
      "context": "chronicle:entity:Shareholding"
    },
    "wasGeneratedBy": {
      "context": "chronicle:entity:Shareholding",
      "txId": "0533c114-9c29-4c5d-ae44-345eae5d2d03"
    }
  }
}
```

### Record the SplitAnnouncedActivity

Here we define the activity and the role of the company as the `ISSUER`.

```graphql
mutation defineSplitAnnouncement {
  defineSplitAnnouncedActivity(
    externalId: "SplitAnnounced"
    attributes: { pressDateAttribute: "Yesterday" }
  ) {
    context
    txId
  }
  wasAssociatedWith(
    activity: { externalId: "SplitAnnounced" }
    responsible: { externalId: "FTXCorp" }
    role: ISSUER
  ) {
    context
    txId
  }
}
```

The output should look something like this -

```json
{
  "data": {
    "defineSplitAnnouncedActivity": {
      "context": "chronicle:activity:SplitAnnounced",
      "txId": "7df145b2-1ae9-4fc3-94fd-350c0cc6c91f"
    },
    "wasAssociatedWith": {
      "context": "chronicle:agent:FTXCorp",
      "txId": "8f26649f-292c-4470-a8c7-aa1224579564"
    }
  }
}
```

### Record the Execution of the SplitAnnouncedActivity

Here we record the instantaneous execution of a stock split announcement along with the
details of the stock split, in this case 2:1.

```graphql
mutation recordSplitAnnouncement {
  instantActivity(
    id: { externalId: "SplitAnnounced" }
  ) {
    context
    txId
  }
  defineAnnouncementEntity(
    externalId: "Announcement"
    attributes: {
      ratioAttribute: "2:1"
      recordDateAttribute: "Today"
      payDateAttribute: "Tomorrow"
      exDateAttribute: "Day After Tomorrow"
    }
  ) {
    context
    txId
  }
  wasGeneratedBy(
    activity: { externalId: "SplitAnnounced" }
    id: { externalId: "Announcement" }
  ) {
    context
    txId
  }
}
```

The output should look something like this -

```json
{
  "data": {
    "instantActivity": {
      "context": "chronicle:activity:SplitAnnounced",
      "txId": "e02a9a52-9b38-4aff-ae7f-1c609a2c661b"
    },
    "defineAnnouncementEntity": {
      "context": "chronicle:entity:Announcement",
      "txId": "d379ab66-9502-4d8a-8a99-ee776de98742"
    },
    "wasGeneratedBy": {
      "context": "chronicle:entity:Announcement",
      "txId": "1253bc46-3d1c-41a4-99c2-a0a145957f3a"
    }
  }
}
```

### Record the ShareholdingUpdatedActivity

Here we define the activity, the role of the transfer agent as the `REGISTRAR`, the
fact that it is acting on behalf of the company as its `REGISTRAR`, and the fact that
it uses both the original shareholding and the announcement.


```graphql
mutation defineShareholdingUpdate {
  defineShareholdingUpdatedActivity(externalId: "ShareholdingUpdated") {
    context
    txId
  }
  wasAssociatedWith(
    activity: { externalId: "ShareholdingUpdated" }
    responsible: { externalId: "Bank" }
    role: REGISTRAR
  ) {
    context
    txId
  }
  announcement: used(
    activity: { externalId: "ShareholdingUpdated" }
    id: { externalId: "Announcement" }
  ) {
    context
  }
  shareholding: used(
    activity: { externalId: "ShareholdingUpdated" }
    id: { externalId: "Shareholding" }
  ) {
    context
  }
  actedOnBehalfOf(
    responsible: { externalId: "FTXCorp" }
    activity: { externalId: "ShareholdingUpdated" }
    delegate: { externalId: "Bank" }
    role: REGISTRAR
  ) {
    context
    txId
  }
}
```

The output should look something like this -

```json
{
  "data": {
    "defineShareholdingUpdatedActivity": {
      "context": "chronicle:activity:ShareholdingUpdated",
      "txId": "2612cc21-4bc6-4fe2-b60f-e847f2ec145b"
    },
    "wasAssociatedWith": {
      "context": "chronicle:agent:Bank",
      "txId": "2c3e0855-0bf4-4d87-9667-5ad3964f6289"
    },
    "announcement": {
      "context": "chronicle:entity:Announcement"
    },
    "shareholding": {
      "context": "chronicle:entity:Shareholding"
    },
    "actedOnBehalfOf": {
      "context": "chronicle:agent:FTXCorp",
      "txId": "45d4187c-f19c-4daf-b7a8-7dc8976d8590"
    }
  }
}
```

### Record the revision of the ShareholdingEntity

Here we create a revised version of the shareholding, in this case 200 shares
each with a nominal value of $0.50, as a consequence of the split.

```graphql
mutation recordShareholdingUpdate {
  defineShareHoldingEntity(
    externalId: "RevisedShareholding"
    attributes: { quantityAttribute: 200, nominalPriceAttribute: "$0.50" }
  ) {
    context
    txId
  }
  wasRevisionOf(
    generatedEntity: { externalId: "RevisedShareholding" }
    usedEntity: { externalId: "Shareholding" }
  ) {
    context
    txId
  }
}
```

The output should look something like this -

```json
{
  "data": {
    "defineShareHoldingEntity": {
      "context": "chronicle:entity:RevisedShareholding",
      "txId": "2a880631-112f-40b8-b331-cf757a7cbd01"
    },
    "wasRevisionOf": {
      "context": "chronicle:entity:RevisedShareholding",
      "txId": "0ade083b-8fba-4bef-81b1-cd28c171466e"
    }
  }
}
```

## Querying Corporate Actions

Here is an example of how you can query the timeline of the activities that
have been created:

```graphql
query timeline {
  activityTimeline(
    activityTypes: [
      ShareholdingAcquiredActivity
      SplitAnnouncedActivity
      ShareholdingUpdatedActivity
    ]
    forAgent: []
    forEntity: []
  ) {
    nodes {
      __typename
      ... on ShareholdingAcquiredActivity {
        id
        wasAssociatedWith {
          responsible {
            agent {
              __typename
            }
            role
          }
        }
      }
      ... on SplitAnnouncedActivity {
        id
        wasAssociatedWith {
          responsible {
            agent {
              __typename
            }
            role
          }
        }
      }
      ... on ShareholdingUpdatedActivity {
        id
        wasAssociatedWith {
          responsible {
            agent {
              __typename
            }
            role
          }
          delegate {
            agent {
              __typename
            }
          }
        }
      }
    }
  }
}
```

Here are the results of the timeline query:

```json
{
  "data": {
    "activityTimeline": {
      "nodes": [
        {
          "__typename": "SplitAnnouncedActivity",
          "id": "chronicle:activity:SplitAnnounced",
          "wasAssociatedWith": [
            {
              "responsible": {
                "agent": {
                  "__typename": "CompanyAgent"
                },
                "role": "ISSUER"
              }
            }
          ]
        },
        {
          "__typename": "ShareholdingAcquiredActivity",
          "id": "chronicle:activity:ShareholdingAcquired",
          "wasAssociatedWith": [
            {
              "responsible": {
                "agent": {
                  "__typename": "CompanyAgent"
                },
                "role": "ISSUER"
              }
            },
            {
              "responsible": {
                "agent": {
                  "__typename": "PersonAgent"
                },
                "role": "SHAREHOLDER"
              }
            }
          ]
        }
      ]
    }
  }
}
```
