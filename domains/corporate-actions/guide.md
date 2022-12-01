# Corporate Actions Guide

## Modelling Corporate Actions

A stock split is a corporate action that divides the value of each of the outstanding shares of a company. This simple example captures some aspects of a stock split, including its announcement and the registration of shares owned. 

### Acquiring Shareholding

First we record that an individual investor has become a shareholder in the company. This is prior to the stock split.

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

The `Shareholding` entity has two attributes, its `Quantity` and its `NominalPrice`.

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

Here we record that the company announces a stock split. The announcement includes information about the split ratio, record date, pay date, and exdate.

![Split Announced](./diagrams/SplitAnnounced.png)

#### Modelling the Announcement Entity

The `Announcement` entity has four attributes, its `Ratio`, its `RecordDate`, its `PayDate`, and its `ExDate`.

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

Here we record that the transfer agent, typically a bank or trust company who acts on behalf of the company, has updated the person's shareholding as a result of the stock split.

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

## Querying Corporate Actions
