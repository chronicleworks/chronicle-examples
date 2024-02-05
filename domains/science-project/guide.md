# Science Project Guide

## Modeling a University Science Project

Academic dishonesty is unfortunately rife in universities. Here we show a
Chronicle domain that can be used to track the activities of a student and the
subsequent marking by the university professor

### Modeling Labwork

#### Modeling the Student Agent

The `Student` agent has two attributes, its `StudentID` and its `Grade`.
In our Chronicle domain specification this is captured as follows -

```yaml
agents:
  Student:
    attributes:
      - StudentID
      - Grade
attributes:
  StudentID:
    type: "String"
  Grade:
    type: "String"
```

#### Modeling the Experiment Entity

The `Experiment` entity has three attributes, its `Reaction`, the `Reagents`
used in the reaction, and the `Approval` status of the reaction.

```yaml
  Experiment:
    attributes:
      - Reaction
      - Reagents
      - Approval
attributes:
  Reaction:
    type: String
  Reagents:
    type: String
  Approval:
    type: String
```

### Modeling the Labwork Activity

The `Labwork` activity has three attributes, the `StudentID` doing the labwork,
the `Workplan` of the labwork, and the `Approval` status of the labwork.

```yaml
  Labwork:
    attributes:
      - StudentID
      - Workplan
      - Approval
attributes:
    StudentID:
        type: String
    Workplan:
        type: String
    Approval:
        type: String

```

### Modeling the results of Labwork

the student's lab-work generates the `Results` entity that has 4 attributes. The
`RawData`, the `ReportURL`, the `Purity` of the chemistry produced, and the
`Yield`.

```yaml
Results:
  attributes:
    - RawData
    - ReportURL
    - Purity
    - Yield
```

### Assessment of Labwork

In this Model the Labwork is being assessed by a Professor

#### Modeling the Marks Entity

The `Marks` entity has three attributes, its `Grade`, the total `Marks` awarded,
and a `FeedbackURL`.

```yaml
entities:
  Marks:
    attributes:
      - Grade
      - Marks
      - FeedbackURL
```

#### Modeling the Assessment Activity

The `Assessment` activity has two attributes the `StaffID` of the assessor and
the `ReportURL` being assessed.

```yaml
activities:
  Assessment:
    attributes:
      - StaffID
      - ReportURL
```

### Chronicle Domain

Combining these fragments gives us our Chronicle `scienceproject` domain.

```yaml
name: "scienceproject"
agents:
  Student:
    attributes:
      - StudentID
      - Grade
  Professor:
    attributes:
      - StaffID
      - Department
entities:
  Experiment:
    attributes:
      - Reaction
      - Reagents
      - Approval
  Results:
    attributes:
      - RawData
      - ReportURL
      - Purity
      - Yield
  Marks:
    attributes:
      - Grade
      - Marks
      - FeedbackURL
activities:
  Labwork:
    attributes:
      - StudentID
      - Workplan
      - Approval
  Assessment:
    attributes:
      - StaffID
      - ReportURL
roles:
  - student
  - professor
attributes:
  StudentID:
    type: String
  Grade:
    type: String
  StaffID:
    type: String
  Department:
    type: String
  Reaction:
    type: String
  Reagents:
    type: String
  Approval:
    type: String
  RawData:
    type: String
  ReportURL:
    type: String
  Purity:
    type: String
  Yield:
    type: String
  Marks:
    type: String
  FeedbackURL:
    type: String
  Workplan:
    type: String
```

## Recording the Science Project

In this example we will create a `Student` and `Professor` agent. These agents
will complete the following activities:

1. `Labwork` activity to record when a student has completed some labwork to be
   graded.
1. `Assessment` an activity to record when a professor has assessed a students
   labwork.

### Defining Agents

Here is where we define who is involved in this example. In a real world example
there would likely be many more students and a few more professor agents.

```graphql
mutation defineAgents {
  defineStudentAgent(
    externalId: "Joe Bloggs"
    attributes: { studentIDAttribute: "Joe Blogs", gradeAttribute: "A" }
  ) {
    context
    txId
  }
  defineProfessorAgent(
    externalId: "Prof Plum"
    attributes: {
      staffIDAttribute: "Prof Plum"
      departmentAttribute: "Chemistry"
    }
  ) {
    context
    txId
  }
}
```

Which will output something similar to

```json
{
  "data": {
    "defineStudentAgent": {
      "context": "chronicle:agent:Joe%20BLoggs",
      "txId": "fe6ef365-1ec6-4f2c-960c-e2137c920d31"
    },
    "defineProfessorAgent": {
      "context": "chronicle:agent:Prof%20Plum",
      "txId": "ee61a7b1-853c-44fd-a871-27168100bfc5"
    }
  }
}
```

### Recording the start of Labwork

the `Labwork` activity is started simply with the following mutation

```graphql
mutation {
  startActivity(id: { externalId: "Labwork" }) {
    context
    txId
  }
}
```

Before any real world work is done an experiment is planned as part of labwork
therefore the experiment entity is generated at the start of the labwork
activity

```graphql
mutation {
  defineExperimentEntity(
    externalId: "Chemistry labwork"
    attributes: {
      reactionAttribute: "Suzuki reaction R^1-x + R^2-BY -> R^1-R-2"
      reagentsAttribute: "Halide, OrganoBoron species, Pd catalyst, base"
      approvalAttribute: "Approved with safety sheet"
    }
  ) {
    context
    txId
  }
}
```

OUTPUT

```json
{
  "data": {
    "defineExperimentEntity": {
      "context": "chronicle:entity:Chemistry%20labwork",
      "txId": "0b441d99-4a83-439b-bb84-73c029a00bbd"
    }
  }
}
```

this entity is then generated and associated with the Labwork activity

```graphql
mutation {
  wasGeneratedBy(
    activity: { externalId: "Labwork" }
    id: { externalId: "Chemistry experiment" }
  ) {
    context
    txId
  }
  wasAssociatedWith(
    activity: { externalId: "Labwork" }
    responsible: { externalId: "Joe Bloggs" }
    role: STUDENT
  ) {
    context
    txId
  }
}
```

OUTPUT

```json
{
  "data": {
    "wasGeneratedBy": {
      "context": "chronicle:entity:Chemistry%20experiment",
      "txId": "567ab0b3-8336-4234-b1c0-a28467489b0b"
    },
    "wasAssociatedWith": {
      "context": "chronicle:agent:Joe%20Bloggs",
      "txId": "f10fdc58-9d74-40ff-8cad-fb0a3cacc202"
    }
  }
}
```

Now that there is an experimental plan the student completes the experiment and
generates the results and subsequent report to produce the results entity

```graphql
mutation {
  defineResultsEntity(
    externalId: "Chemistry experiment results"
    attributes: {
      rawDataAttribute: "rawdata"
      reportURLAttribute: "reportURL"
      purityAttribute: "98.6"
      yieldAttribute: "5mg"
    }
  ) {
    context
    txId
  }
}
```

OUTPUT

```json
{
  "data": {
    "defineResultsEntity": {
      "context": "chronicle:entity:Chemistry%20experiment%20results",
      "txId": "ff46cac8-1d26-42e1-9722-87d9536cf70f"
    }
  }
}
```

This is then tied to the activity

```graphql
mutation {
  wasGeneratedBy(
    id: { externalId: "Chemistry experiment results" }
    activity: { externalId: "Labwork" }
  ) {
    context
    txId
  }
  wasAssociatedWith(
    activity: { externalId: "Labwork" }
    responsible: { externalId: "Joe Bloggs" }
    role: STUDENT
  ) {
    context
    txId
  }
}
```

OUTPUT

```json
{
  "data": {
    "wasGeneratedBy": {
      "context": "chronicle:entity:Chemistry%20experiment%20results",
      "txId": "842f8f60-d54f-4772-8e37-bb8ac14e609f"
    },
    "wasAssociatedWith": {
      "context": "chronicle:agent:Joe%20Bloggs",
      "txId": "7a8e5f36-791e-49a5-a7d8-65990e2aa074"
    }
  }
}
```

With the Labwork done the activity is brought to an end

```graphql
mutation {
  endActivity(id: { externalId: "Labwork" }) {
    context
    txId
  }
}
```

OUTPUT

```json
{
  "data": {
    "wasGeneratedBy": {
      "context": "chronicle:entity:Chemistry%20experiment%20results",
      "txId": "842f8f60-d54f-4772-8e37-bb8ac14e609f"
    },
    "wasAssociatedWith": {
      "context": "chronicle:agent:Joe%20Bloggs",
      "txId": "7a8e5f36-791e-49a5-a7d8-65990e2aa074"
    }
  }
}
```

### Recording the Assessment of LabWork

With the labwork complete and submitted the Professor then begins the marking

```graphql
mutation {
  startActivity(id: { externalId: "Assessment" }) {
    context
    txId
  }
}
```

OUTPUT

```json
{
  "data": {
    "startActivity": {
      "context": "chronicle:activity:Assessment",
      "txId": "89943f70-8fa7-4f90-bd58-4b10c1a13a3b"
    }
  }
}
```

this generates marks

```graphql
mutation {
  defineMarksEntity(
    externalId: "Chemistry experiment marks"
    attributes: {
      gradeAttribute: "A"
      marksAttribute: "95"
      feedbackURLAttribute: "feedbackURL"
    }
  ) {
    context
    txId
  }
}
```

OUTPUT

```json
{
  "data": {
    "defineMarksEntity": {
      "context": "chronicle:entity:Chemistry%20experiment%20marks",
      "txId": "a5f403f4-ec99-40b7-8a85-960a0127f042"
    }
  }
}
```

The associations are made in the following mutation

```graphql
mutation {
  wasGeneratedBy(
    id: { externalId: "Chemistry experiment marks" }
    activity: { externalId: "Assesment" }
  ) {
    context
    txId
  }
  wasAssociatedWith(
    activity: { externalId: "Assesment" }
    responsible: { externalId: "Prof Plum" }
    role: PROFESSOR
  ) {
    context
    txId
  }
  used(
    id: { externalId: "Chemistry experiment" }
    activity: { externalId: "Labwork" }
  ) {
    context
    txId
  }
}
```

OUTPUT

```json
{
  "data": {
    "wasGeneratedBy": {
      "context": "chronicle:entity:Chemistry%20experiment%20marks",
      "txId": "d8bb0110-4b5f-4f8e-b334-202979aa78b7"
    },
    "wasAssociatedWith": {
      "context": "chronicle:agent:Prof%20Plum",
      "txId": "28f40a32-df56-4605-9ad4-47ec9f355ce2"
    },
    "used": {
      "context": "chronicle:entity:Chemistry%20experiment",
      "txId": "2057d83b-d4e6-416b-9efe-c27db0f73087"
    }
  }
}
```

Then the activity is over and ended with the following mutation

```graphql
mutation {
  endActivity(id: { externalId: "Assesment" }) {
    context
    txId
  }
}
```

OUTPUT

```json
{
  "data": {
    "endActivity": {
      "context": "chronicle:activity:Assesment",
      "txId": "785ed7f1-17dd-42e7-8b9e-f9fb97a9dd6b"
    }
  }
}
```

This concludes a cycle tracking what output a student made and who marked it

## Querying the science Project

In this query we are asking in q1 what was the reaction that was the
reactionAttribute of the "Chemistry experiment" experiment entity in q2 we ask
what the attributes are of the results of that experiment and in q3 what grade
the work received.

```graphql
query {
  q1: entityById(id: { externalId: "Chemistry experiment" }) {
    ... on ExperimentEntity {
      reactionAttribute
      wasGeneratedBy {
        ... on LabworkActivity {
          id
        }
      }
    }
  }
  q2: entityById(id: { externalId: "Chemistry experiment results" }) {
    ... on ResultsEntity {
      yieldAttribute
      purityAttribute
      reportURLAttribute
      wasGeneratedBy {
        ... on LabworkActivity {
          id
        }
      }
    }
  }
  q3: entityById(id: { externalId: "Chemistry experiment marks" }) {
    ... on MarksEntity {
      gradeAttribute
      wasGeneratedBy {
        ... on AssessmentActivity {
          id
        }
      }
    }
  }
}
```

OUTPUT

```json
{
  "data": {
    "q1": {
      "reactionAttribute": "suzuki reaction",
      "wasGeneratedBy": [
        {
          "id": "chronicle:activity:Labwork"
        }
      ]
    },
    "q2": {
      "yieldAttribute": "5mg",
      "purityAttribute": "98.6",
      "reportURLAttribute": "reportURL",
      "wasGeneratedBy": [
        {
          "id": "chronicle:activity:Labwork"
        }
      ]
    },
    "q3": {
      "gradeAttribute": "A",
      "wasGeneratedBy": [
        {
          "id": "chronicle:activity:Assessment"
        }
      ]
    }
  }
}
```

### Query 2

In this query we are querying the timeline of activities that generated a marks
marks entity

```graphql
query {
  activityTimeline(
    forEntity: [{ externalId: "Chemistry experiment marks" }]
    activityTypes: []
    forAgent: []
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
        ... on AssessmentActivity {
          started
          ended
          wasAssociatedWith {
            responsible {
              role
              agent {
                __typename
                ... on ProfessorAgent {
                  staffIDAttribute
                  departmentAttribute
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

OUTPUT

```json
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
            "**typename": "AssessmentActivity",
            "started": "2023-02-20T15:22:02.661197305+00:00",
            "ended": "2023-02-20T15:26:20.493090216+00:00",
            "wasAssociatedWith": [
              {
                "responsible": {
                  "role": "PROFESSOR",
                  "agent": {
                    "**typename": "ProfessorAgent",
                    "staffIDAttribute": "Prof Plum",
                    "departmentAttribute": "Chemistry"
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

## Query 3

In this query we are querying the activity timeline of a student and what
entities they generated

```graphql
query {
  activityTimeline(
    forAgent: [{ externalId: "Joe Bloggs" }]
    activityTypes: []
    forEntity: []
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
        ... on LabworkActivity {
          started
          ended
          wasAssociatedWith {
            responsible {
              role
              agent {
                ... on StudentAgent {
                  studentIDAttribute
                  gradeAttribute
                }
              }
            }
          }
          generated {
            __typename
          }
        }
      }
      cursor
    }
  }
}
```

OUTPUT

```json
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
            "**typename": "LabworkActivity",
            "started": "2023-02-20T15:11:12.060207254+00:00",
            "ended": "2023-02-20T15:20:37.756462960+00:00",
            "wasAssociatedWith": [
              {
                "responsible": {
                  "role": "STUDENT",
                  "agent": {
                    "**typename": "ProvAgent"
                  }
                }
              }
            ],
            "generated": [
              {
                "__typename": "ExperimentEntity"
              },
              {
                "__typename": "ResultsEntity"
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
