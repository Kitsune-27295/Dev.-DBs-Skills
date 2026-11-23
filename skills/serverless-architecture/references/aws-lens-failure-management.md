# AWS Serverless Lens: Failure Management and Pillar Structure

Sources: https://docs.aws.amazon.com/wellarchitected/latest/serverless-applications-lens/welcome.html (intro only), plus sub-pages reliability-pillar.html, failure-management.html, security-pillar.html (extra pages) · Last verified 2026-11-23

Read status: the welcome page yielded only its introduction (lens dated 2022-07-14, scoped to serverless-specific guidance on top of the main Framework). The design-principles page returned no body text, so nothing is claimed from it. Detailed content below comes from the failure-management page.

## Structure facts that were read

- The reliability pillar has three areas: foundations, change management, failure management.
- The security pillar lists five areas: identity and access management, detective controls, infrastructure protection, data protection, incident response. It notes serverless removes OS patching but OWASP and application-security practice still apply.

## Failure management: asynchronous calls must be captured and retried

Otherwise data is lost. Concrete mechanisms described:

| Source | Behavior | Control |
|---|---|---|
| Lambda async invocation | Failed events can go to a per-function SQS dead-letter queue | DLQ per function |
| Kinesis / DynamoDB Streams | Whole batch retried; repeated errors block the shard until fixed or items expire | Maximum retry attempts, maximum record age, destination on failure, bisect batch on function error (removes poison pills) |
| AWS SDK calls | Default back-off and retry usually adequate | Review keepalive, connection and socket timeouts |
| Non-atomic batch APIs (`PutRecords`, `BatchWriteItem`) | Report success if at least one record landed | Inspect the response and handle partial failures in code |
| Multi-step transactions | Roll back through the Saga pattern | Step Functions state machines |

Step Functions guidance: use them to cut custom try/catch, back-off and retry code, and to save failed runs to a DLQ. Choose Express (short, high-volume, sync or async) vs Standard (long-running, more durability and audit).

## Example: poison pill handling (pseudo-config)

```
event_source: stream
  max_retry_attempts: 3
  max_record_age: 1h
  bisect_batch_on_error: true
  on_failure: dlq-orders        # metadata of the bad batch for analysis
```

## Items not read from source

Least-privilege IAM per function, throttling, and idempotency are standard serverless practice and appear in the existing skill; the pages above did not expand them in the portions read.

## How an agent should apply this

- Attach a DLQ or on-failure destination to every asynchronous function and stream mapping, and state who inspects it.
- For streams, set retry limits and maximum record age so one poison record cannot block a shard.
- Check partial-failure fields in batch API responses, never only the HTTP status.
- Prefer Step Functions for multi-step flows and sagas over hand-rolled retry code in handlers.
- Make handlers idempotent because retries and redelivery are by design.
