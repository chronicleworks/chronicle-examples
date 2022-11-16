# Time Recording

## Motivation

This Chronicle domain allows the capture of work done by employees of
organizations whose work on cost-plus contracts may be audited by external
agencies, as is typical for large research and development contracts awarded
by the US Government. Federal regulations require that time recording software
maintains a trustworthy audit trail that includes history of changes made to
the time records. This assists the auditors in determining the true cost to
the employer of performing the work on each project.

## Recording

An employee's work on a task is literally a `Work` activity in this Chronicle
domain, with start and end times matching their work under role `WORKER`. A
`Task` attribute notes what the employee actually did. The activity "uses" the
`Project` entity corresponding to which project the employee worked on.

Employers may use `started` and `ended` to note the day of work rather than
the exact times, in which case only the `Work` activity's `Duration` attribute
records the effort expended.

### Work (the activity)

- `wasAssociatedWith` a `WORKER`
- `used` a `Project`
- `started` and `ended`

## Reporting

An employee's `Timesheet` entity is attributed to them. They generate it in a
`Report` activity that is informed by their `Work` activities over that
reporting period. Their `SUPERVISOR` may `Approve` or `Reject` the timesheet.

### Report (the activity, for workers creating timesheets)

- `generated` a `Timesheet`
- `wasAssociatedWith` a `WORKER`
- `wasInformedBy` their `Work`

## Project Tracking

Projects require a report about the effort spent on a project rather than
effort spent by an employee. Each project's lead has responsibility to the
organization funding the project. In their role as `PROJECT_LEAD`, a manager
can cause a generation of a `Summary` report attributed to them, that `Report`
being informed by the `Work` activities for their project by many employees.

### Report (the activity, for project leads creating summaries)

- `generated` a `Summary`
- `wasAssociatedWith` a `PROJECT_LEAD`
- `wasInformedBy` employees' `Work` on the `Project`
- `used` a `Project`

## Viewing

It is valuable to record who viewed which reports when, so one may determine
the basis of their judgments, so a `View` activity is also captured.

### View (the activity)

- `used` a `Timesheet` or `Summary`
- `wasAssociatedWith` whoever viewed it

## Revision

The `Revise` activity is the means by which an worker may generate a corrected
version of a previously submitted timesheet for a new submission. The new
timesheet is derived from the previous and is informed by different `Work`.
The `Reject` and `Revise` activities have a `Reason` attribute to assist
subsequent audits.

### Revise (the activity)

- `generated` a `Timesheet` which `wasDerivedFrom` another
- `wasAssociatedWith` a `WORKER`
- `wasInformedBy` their `Work`

## Proxies

Typically only in exceptional circumstances, a person may record or report
time on behalf of another. `actedOnBehalfOf` records this, and the person acts
in the role of `ADMINISTRATOR`. This is most typically in the context of a
revision.
