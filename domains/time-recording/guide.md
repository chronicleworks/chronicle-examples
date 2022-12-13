# Time Recording

## Overview

This Chronicle domain captures how employees, who may be working on multiple
projects, record their work time and submit their timesheets periodically. It
includes provision for approval and revision.

## Motivation

Organizations that bill on cost-plus contracts may be audited by external
agencies, as is typical for large research and development contracts awarded
by the US Government. For those contracts, the relevant Federal regulations
require that time recording software maintains a trustworthy audit trail that
includes history of changes made to the time records. This assists the
auditors in determining the true cost to the employer of performing the work
on each project.

## Modeling the Domain

### Recording

An employee's work on a task is literally a `Work` activity in this Chronicle
domain, with start and end times matching their work under role `WORKER`. A
`Task` attribute notes what the employee actually did. The activity "uses" the
`Project` entity corresponding to the project that the employee worked on.

#### Work (the activity)

- `wasAssociatedWith` a `WORKER`
- `used` a `Project`
- `started` and `ended`

![Record Time Worked](./diagrams/RecordTime.svg)

*Note:* In this first diagram, much is depicted explicitly. For clarity,
subsequent diagrams may omit relations shown previously, e.g., `Person` will
not again depict that they are an `Agent`.

#### Domain Representation

```yaml
attributes:
  Name:
    type: String
  Task:
    type: String
agents:
  Person:
    attributes:
      - Name
entities:
  Project:
    attributes:
      - Name
activities:
  Work:
    attributes:
      - Task
      - Duration
roles:
  - WORKER
```

*Note:* Subsequent extracts from the domain definition may assume elements
from previous, e.g., that `Person` is defined as an agent with a `Name`
attribute.

## Recording

An employee's `Timesheet` activity is their collation of work tasks for review
and submission. It is informed by their `Work` activities over the reporting
period identified by the start and end times of the `Timesheet`.

#### Timesheet (the activity)

- `wasAssociatedWith` a `WORKER`
- `wasInformedBy` their `Work`
- `started` and `ended`

![Report Time Worked](./diagrams/ReportTime.svg)

#### Domain Representation

```yaml
activities:
  Timesheet:
    attributes: []
```

### Submitting

An employee submits their timesheet for review by their supervisor. This is an
aspect of the workflows that the following definitions allow, capturing how a
`SUPERVISOR` may `Approve` or `Reject` the timesheet. `Approve` and `Reject`
are informed by `Submit` which is informed by the `Timesheet` (or, as
described below, a `Revision` thereof).

![Submit Timesheet](./diagrams/SubmitTimesheet.svg)

#### Domain Representation

```yaml
attributes:
  Reason:
    type: String
activities:
  Submit:
    attributes: []
  Approve:
    attributes: []
  Reject:
    attributes:
      - Reason
roles:
  - SUPERVISOR
```

### Project Tracking

Projects require a report detailing the effort spent on a project rather than
effort spent by an employee. Each project's lead has responsibility to the
organization funding the project. In their role as `PROJECT_LEAD`, a manager
can create a `Summary`, which is analogous to a `Timesheet` except for that
the `Work` informing it is all related to the same `Project` rather than the
same `Person`, collating the contribution of possibly many employees.

#### Summary (the activity)

- `wasAssociatedWith` a `PROJECT_LEAD`
- `wasInformedBy` employees' `Work` on the `Project`
- `started` and `ended`
- `used` a `Project`

![Project Summary](./diagrams/ProjectSummary.svg)

#### Domain Representation

```yaml
entities:
  Summary:
    attributes: []
roles:
  - PROJECT_LEAD
```

### Viewing

It is valuable to record who viewed which reports when, that one may determine
the basis of their judgments, so a `View` activity is also captured.

#### View (the activity)

- `used` a `Timesheet` or `Summary`
- `wasAssociatedWith` whoever viewed it

![View Timesheet](./diagrams/ViewTimesheet.svg)

#### Domain Representation

```yaml
activities:
  View:
    attributes: []
```

### Revision and Proxies

The `Revision` activity is the corrected version of a previously submitted
`Timesheet` for a resubmission. It is informed by the timesheet it revises,
and differs from that timesheet in the work informing it. The `Reject` and
`Revision` activities have a `Reason` attribute to assist subsequent audits.

Typically only in exceptional circumstances, a person may record or report
time on behalf of another. `actedOnBehalfOf` records this, and the person acts
in the role of `ADMINISTRATOR`. This is most typically in the context of a
revision.

For example, if an employee's final timesheet were rejected by their
supervisor, that employee may have now left the organization and it may fall
to an administrator to correct any issues so that the remaining work can be
billed. So, they issue the correction,

![ReviseOnBehalf](./diagrams/ReviseOnBehalf.svg)

then submit it for the supervisor's review,

![SubmitOnBehalf](./diagrams/SubmitOnBehalf.svg)

#### Revision (the activity)

- `wasAssociatedWith` a `WORKER` or an `ADMINISTRATOR`
- `wasInformedBy` the new `Work` and the previous `Timesheet`

#### Domain Representation

```yaml
activities:
  Revision:
    attributes:
      - Reason
roles:
  - ADMINISTRATOR
```

### Combining the Domain Representation

Combining and naming the above domain representation fragments gives,

```yaml
name: Time Recording
attributes:
  Name:
    type: String
  Task:
    type: String
  Reason:
    type: String
agents:
  Person:
    attributes:
      - Name
entities:
  Project:
    attributes:
      - Name
activities:
  Work:
    attributes:
      - Task
  Timesheet:
    attributes: []
  Revision:
    attributes:
      - Reason
  Summary:
    attributes: []
  Submit:
    attributes: []
  View:
    attributes: []
  Approve:
    attributes: []
  Reject:
    attributes:
      - Reason
roles:
  - WORKER
  - SUPERVISOR
  - PROJECT_LEAD
  - ADMINISTRATOR
```

## Interacting with Chronicle

### Recording

#### Define a Worker and a Project

First, we need a worker defined,

```graphql
mutation {
  definePersonAgent(
    externalId: "staff-4366"
    attributes: { nameAttribute: "Duane Barry" }
  ) {
    context
    txId
  }
}
```

with a response like,

```json
{
  "definePersonAgent": {
    "context": "chronicle:agent:staff%2D4366",
    "txId": "0d10c872-931c-409a-ab12-17f6a88bebd3"
  }
}
```

Also, projects for them to work on,

```graphql
mutation {
  pets: defineProjectEntity(
    externalId: "proj-533"
    attributes: { nameAttribute: "dog grooming" }
  ) {
    context
    txId
  }

  parties: defineProjectEntity(
    externalId: "proj-576B"
    attributes: { nameAttribute: "make party hats" }
  ) {
    context
    txId
  }
}
```

with response like,

```json
{
  "pets": {
    "context": "chronicle:entity:proj%2D533",
    "txId": "0edf0a56-0b35-48bf-a4e4-d5e9cd47d446"
  },
  "parties": {
    "context": "chronicle:entity:proj%2D576B",
    "txId": "e6a545bb-739a-4fe7-af58-79770404d4d6"
  }
}
```

Observed responses will vary a little as Chronicle generates IDs as
necesssary.

#### Define the Performed Task

In tracking that the worker performed a task, first we define the task,

```graphql
mutation {
  defineWorkActivity(
    externalId: "entry-3555103"
    attributes: { taskAttribute: "washing dog" }
  ) {
    context
    txId
  }
}
```

which gives us something like,

```json
{
  "defineWorkActivity": {
    "context": "chronicle:activity:entry%2D3555103",
    "txId": "a13a284b-d100-4d03-985e-228fc5f74116"
  }
}
```

then we define when it happened. It starts,

```graphql
mutation {
  startActivity(
    id: { externalId: "entry-3555103" }
    time: "2022-12-07T10:08:00-05:00"
  ) {
    context
    txId
  }
}
```

with Chronicle responding,

```json
{
  "startActivity": {
    "context": "chronicle:activity:entry%2D3555103",
    "txId": "96b53211-6d6c-4cb1-86df-eea24639bce7"
  }
}
```

then ends,

```graphql
mutation {
  endActivity(
    id: { externalId: "entry-3555103" }
    time: "2022-12-07T10:28:00-05:00"
  ) {
    context
    txId
  }
}
```

Henceforth, we shall miss out many of the responses, unless they contain
anything interesting, because the above provide a good idea of what to expect.

#### Define the Performed Task's Relationships

We associate the task performance with a project,

```graphql
mutation {
  used(
    activity: { externalId: "entry-3555103" }
    id: { externalId: "proj-533" }
  ) {
    context
    txId
  }
}
```

and with a worker,

```graphql
mutation {
  wasAssociatedWith(
    activity: { externalId: "entry-3555103" }
    responsible: { externalId: "staff-4366" }
    role: WORKER
  ) {
    context
    txId
  }
}
```

### Reporting

Create a timesheet to submit for the work,

```graphql
mutation {
  defineTimesheetActivity(
    externalId: "ts-32205"
  ) {
    context
    txId
  }
}
```

specify that it covers the full week,


```graphql
mutation {
  startActivity(
    id: { externalId: "ts-32205" }
    time: "2022-12-04T00:00:00-05:00"
  ) {
    context
    txId
  }

  endActivity(
    id: { externalId: "ts-32205" }
    time: "2022-12-11T00:00:00-05:00"
  ) {
    context
    txId
  }
}
```
then note that it is the worker's timesheet,

```graphql
mutation {
  wasAssociatedWith(
    activity: { externalId: "ts-32205" }
    responsible: { externalId: "staff-4366" }
    role: WORKER
  ) {
    context
    txId
  }
}
```

and add the work to the timesheet,

```graphql
mutation {
  wasInformedBy(
    activity: { externalId: "ts-32205" }
    informingActivity: { externalId: "entry-3555103" }
  ) {
    context
    txId
  }
}
```

### Submitting

First, define a supervisor for the worker,

```graphql
mutation {
  definePersonAgent(
    externalId: "staff-3621"
    attributes: { nameAttribute: "Roland Fuller" }
  ) {
    context
    txId
  }
}
```

have the worker submit their timesheet at the start of the following week,

```graphql
mutation {
  defineSubmitActivity(
    externalId: "submit-32439"
  ) {
    context
    txId
  }

  instantActivity(
    id: { externalId: "submit-32439" }
    time: "2022-12-12T09:40:30-05:00"
  ) {
    context
    txId
  }

  wasAssociatedWith(
    activity: { externalId: "submit-32439" }
    responsible: { externalId: "staff-4366" }
    role: WORKER
  ) {
    context
    txId
  }

  wasInformedBy(
    activity: { externalId: "submit-32439" }
    informingActivity: { externalId: "ts-32205" }
  ) {
    context
    txId
  }
}
```

and the supervisor approve it,

```graphql
mutation {
  defineApproveActivity(
    externalId: "approve-31280"
  ) {
    context
    txId
  }

  instantActivity(
    id: { externalId: "approve-31280" }
    time: "2022-12-12T11:16:06-05:00"
  ) {
    context
    txId
  }

  wasAssociatedWith(
    activity: { externalId: "approve-31280" }
    responsible: { externalId: "staff-3621" }
    role: SUPERVISOR
  ) {
    context
    txId
  }

  wasInformedBy(
    activity: { externalId: "approve-31280" }
    informingActivity: { externalId: "submit-32439" }
  ) {
    context
    txId
  }
}
```

In these, we define the activity, when it happened, who did it, then what
informed it.

### Revision

Let us imagine that the supervisor instead rejected the timesheet so it needs
revising. For example, perhaps the previous work was billed for the wrong day.
Note that one *cannot* change the existing data in Chronicle once it has been
set. Instead, following patterns shown above, we create a corrected task,

```graphql
mutation {
  defineWorkActivity(
    externalId: "entry-3556230"
    attributes: { taskAttribute: "washing dog" }
  ) {
    context
    txId
  }

  used(
    activity: { externalId: "entry-3556230" }
    id: { externalId: "proj-533" }
  ) {
    context
    txId
  }

  wasAssociatedWith(
    activity: { externalId: "entry-3556230" }
    responsible: { externalId: "staff-4366" }
    role: WORKER
  ) {
    context
    txId
  }

  startActivity(
    id: { externalId: "entry-3556230" }
    time: "2022-12-08T10:08:00-05:00"
  ) {
    context
    txId
  }

  endActivity(
    id: { externalId: "entry-3556230" }
    time: "2022-12-08T10:28:00-05:00"
  ) {
    context
    txId
  }
}
```

a revised timesheet,

```graphql
mutation {
  defineRevisionActivity(
    externalId: "rts-2130"
    attributes: { reasonAttribute: "misremembered which day" }
  ) {
    context
    txId
  }

  startActivity(
    id: { externalId: "rts-2130" }
    time: "2022-12-04T00:00:00-05:00"
  ) {
    context
    txId
  }

  endActivity(
    id: { externalId: "rts-2130" }
    time: "2022-12-11T00:00:00-05:00"
  ) {
    context
    txId
  }

  wasAssociatedWith(
    activity: { externalId: "rts-2130" }
    responsible: { externalId: "staff-4366" }
    role: WORKER
  ) {
    context
    txId
  }
}
```

and add the corrected work to the timesheet,

```graphql
mutation {
  wasInformedBy(
    activity: { externalId: "rts-2130" }
    informingActivity: { externalId: "entry-3556230" }
  ) {
    context
    txId
  }
}
```

note that it revises the original,


```graphql
mutation {
  wasInformedBy(
    activity: { externalId: "rts-2130" }
    informingActivity: { externalId: "ts-32205" }
  ) {
    context
    txId
  }
}
```

and submit that one instead,

```graphql
mutation {
  defineSubmitActivity(
    externalId: "submit-32470"
  ) {
    context
    txId
  }

  instantActivity(
    id: { externalId: "submit-32470" }
    time: "2022-12-12T12:11:52-05:00"
  ) {
    context
    txId
  }

  wasAssociatedWith(
    activity: { externalId: "submit-32470" }
    responsible: { externalId: "staff-4366" }
    role: WORKER
  ) {
    context
    txId
  }

  wasInformedBy(
    activity: { externalId: "submit-32470" }
    informingActivity: { externalId: "rts-2130" }
  ) {
    context
    txId
  }
}
```

### Delegation

Perhaps the worker's revised timesheet should be approved but their supervisor
is unavailable. An administrator may approve the timesheet on their behalf.
First, let us define them in Chronicle,

```graphql
mutation {
  definePersonAgent(
    externalId: "staff-3150"
    attributes: { nameAttribute: "Suzanne Modeski" }
  ) {
    context
    txId
  }
}
```

have them approve the revision on the supervisor's behalf,

```graphql
mutation {
  defineApproveActivity(
    externalId: "approve-31305"
  ) {
    context
    txId
  }

  instantActivity(
    id: { externalId: "approve-31305" }
    time: "2022-12-12T14:40:10-05:00"
  ) {
    context
    txId
  }

  wasAssociatedWith(
    activity: { externalId: "approve-31305" }
    responsible: { externalId: "staff-3621" }
    role: SUPERVISOR
  ) {
    context
    txId
  }

  wasInformedBy(
    activity: { externalId: "approve-31305" }
    informingActivity: { externalId: "submit-32470" }
  ) {
    context
    txId
  }
}
```

and note that they did so

```graphql
mutation {
  actedOnBehalfOf(
    responsible: { externalId: "staff-3621" }
    delegate: { externalId: "staff-3150" }
    activity: { externalId: "approve-31305" }
    role: ADMINISTRATOR
  ) {
    context
    txId
  }
}
```

![Delegation Example](./diagrams/DelegationExample.svg)

## Querying

### Exploring Approvals

Assume that all the above `mutation`s have been performed, the combined effect
is to have the worker revising an approved timesheet.

First, we check which submissions have been approved, and by who,

```graphql
{
  activitiesByType(activityType: ApproveActivity) {
    nodes {
      ... on ApproveActivity {
        externalId
        wasAssociatedWith {
          responsible {
            role
            agent {
              ... on PersonAgent {
                externalId
                nameAttribute
              }
            }
          }
        }
        wasInformedBy {
          ... on SubmitActivity {
            externalId
            wasAssociatedWith {
              responsible {
                role
                agent {
                  ... on PersonAgent {
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
  }
}
```

The search results come back as,

```json
{
  "activitiesByType": {
    "nodes": [
      {
        "externalId": "approve-31280",
        "wasAssociatedWith": [
          {
            "responsible": {
              "role": "SUPERVISOR",
              "agent": {
                "externalId": "staff-3621",
                "nameAttribute": "Roland Fuller"
              }
            }
          }
        ],
        "wasInformedBy": [
          {
            "externalId": "submit-32439",
            "wasAssociatedWith": [
              {
                "responsible": {
                  "role": "WORKER",
                  "agent": {
                    "externalId": "staff-4366",
                    "nameAttribute": "Duane Barry"
                  }
                }
              }
            ]
          }
        ]
      },
      {
        "externalId": "approve-31305",
        "wasAssociatedWith": [
          {
            "responsible": {
              "role": "ADMINISTRATOR",
              "agent": {
                "externalId": "staff-3150",
                "nameAttribute": "Suzanne Modeski"
              }
            }
          }
        ],
        "wasInformedBy": [
          {
            "externalId": "submit-32470",
            "wasAssociatedWith": [
              {
                "responsible": {
                  "role": "WORKER",
                  "agent": {
                    "externalId": "staff-4366",
                    "nameAttribute": "Duane Barry"
                  }
                }
              }
            ]
          }
        ]
      }
    ]
  }
}
```

where Duane's initial timesheet was approved by Roland, their supervisor.
Subsequently, their revised timesheet was approved by Suzanne in their role as
administrator. Let us check that Suzanne was acting on Roland's behalf in
that,

```graphql
{
  activityById(id: { externalId: "approve-31305" }) {
    ... on ApproveActivity {
      wasAssociatedWith {
        responsible {
          agent {
            ... on PersonAgent {
              externalId
              nameAttribute
            }
          }
          role
        }
        delegate {
          agent {
            ... on PersonAgent {
              externalId
              nameAttribute
            }
          }
          role
        }
      }
    }
  }
}
```

confirms that,

```json
{
  "activityById": {
    "wasAssociatedWith": [
      {
        "responsible": {
          "agent": {
            "externalId": "staff-3621",
            "nameAttribute": "Roland Fuller",
          },
          "role": "SUPERVISOR"
        },
        "delegate": {
          "agent": {
            "externalId": "staff-3150",
            "nameAttribute": "Suzanne Modeski",
          },
          "role": "ADMINISTRATOR"
        }
      }
    ]
  }
}
```

### Work and Timesheets

We can also query to find out about the timesheet that was approved above,

```graphql
fragment AssociationDetails on Association {
  responsible {
    agent {
      ... on PersonAgent {
        externalId
        nameAttribute
      }
    }
    role
  }
}

fragment WorkDetails on WorkActivity {
  externalId
  started
  ended
  taskAttribute
  used {
    ... on ProjectEntity {
      externalId
      nameAttribute
    }
  }
}

{
  activityById(id: { externalId: "submit-32470" }) {
    ... on SubmitActivity {
      wasInformedBy {
        ... on TimesheetActivity {
          externalId
          wasAssociatedWith {
            ...AssociationDetails
          }
          wasInformedBy {
            ...WorkDetails
          }
        }
        ... on RevisionActivity {
          externalId
          wasAssociatedWith {
            ...AssociationDetails
          }
          reasonAttribute
          wasInformedBy {
            ...WorkDetails
          }
        }
      }
    }
  }
}
```

Note the use of named fragments to avoid repetition in the query. The result
reflects the mutations with which we started this guide,

```json
{
  "activityById": {
    "wasInformedBy": [
      {
        "externalId": "rts-2130",
        "wasAssociatedWith": [
          {
            "responsible": {
              "agent": {
                "externalId": "staff-4366",
                "nameAttribute": "Duane Barry"
              },
              "role": "WORKER"
            }
          }
        ],
        "reasonAttribute": "misremembered which day",
        "wasInformedBy": [
          {
            "externalId": "entry-3556230",
            "started": "2022-12-08T15:08:00+00:00",
            "ended": "2022-12-08T15:28:00+00:00",
            "taskAttribute": "washing dog",
            "used": [
              {
                "externalId": "proj-533",
                "nameAttribute": "dog grooming"
              }
            ]
          },
          {}
        ]
      }
    ]
  }
}
```

### Activity Timeline

The previous query retrieved any work entries for Duane's revised timesheet.
Alternatively, we can see all of what they have been chronicling on their
projects,

```graphql
{
  activityTimeline(
    activityTypes: [WorkActivity]
    forAgent: { externalId: "staff-4366" }
    forEntity: [{ externalId: "proj-533" }, { externalId: "proj-576B" }]
    order: OLDEST_FIRST
  ) {
    nodes {
      ... on WorkActivity {
        externalId
        started
        ended
        taskAttribute
      }
    }
  }
}
```

This shows both the original and the corrected tasks,

```json
{
  "activityTimeline": {
    "nodes": [
      {
        "externalId": "entry-3555103",
        "started": "2022-12-07T15:08:00+00:00",
        "ended": "2022-12-07T15:28:00+00:00",
        "taskAttribute": "washing dog"
      },
      {
        "externalId": "entry-3556230",
        "started": "2022-12-08T15:08:00+00:00",
        "ended": "2022-12-08T15:28:00+00:00",
        "taskAttribute": "washing dog"
      }
    ]
  }
}
```

To understand what happened, we can connect the tasks with timesheets,

```graphql
{
  activityTimeline(
    activityTypes: [TimesheetActivity, RevisionActivity]
    forAgent: { externalId: "staff-4366" }
    forEntity: []
  ) {
    nodes {
      ... on TimesheetActivity {
        externalId
        wasInformedBy {
          ... on WorkActivity {
            externalId
          }
        }
      }
      ... on RevisionActivity {
        externalId
        reasonAttribute
        wasInformedBy {
          ... on WorkActivity {
            externalId
          }
        }
      }
    }
  }
}
```

to see this timeline,

```json
{
  "activityTimeline": {
    "nodes": [
      {
        "externalId": "rts-2130",
        "reasonAttribute": "misremembered which day",
        "wasInformedBy": [
          {
            "externalId": "entry-3556230"
          },
          {}
        ]
      },
      {
        "externalId": "ts-32205",
        "wasInformedBy": [
          {
            "externalId": "entry-3555103"
          }
        ]
      }
    ]
  }
}
```

showing both the original and the revised timesheets, with one task each.
