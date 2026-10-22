# Lifecycle Overview

Identity and access management governs who has access to what, from first day to last. The lifecycle has three stages, all driven by HR events.

## End-to-end flow

```mermaid
flowchart TD
    A[HR event recorded] --> B{Event type}
    B -->|New hire| J1[Create identity]
    B -->|Role / dept change| M1[Recalculate entitlements]
    B -->|Termination| L1[Disable account]

    J1 --> J2[Assign birthright access]
    J2 --> J3[Enroll MFA]
    J3 --> J4[Manager approves extras]
    J4 --> J5[Day-1 verification]

    M1 --> M2[Remove old-role access]
    M2 --> M3[Add new-role access]
    M3 --> M4[Manager attests]
    M4 --> M5[Verify no residual access]

    L1 --> L2[Revoke sessions and tokens]
    L2 --> L3[Remove groups, licenses, roles]
    L3 --> L4[Recover devices, handle mailbox/data]
    L4 --> L5[Verify and archive evidence]
```

## Principles

1. **HR is the source of truth.** Identity actions follow HR records, never ad-hoc tickets.
2. **Least privilege by default.** Birthright access is the minimum for the role; everything else is requested and approved.
3. **Remove before add.** In a mover event, strip old access first.
4. **Time-bound.** Leaver disable happens on the termination effective time, not days later.
5. **Verify.** Every stage ends with a check that proves the intended state.
6. **Log everything.** Every action produces an audit record that detections can use.

## Roles and responsibilities

| Role | Responsibility |
|------|----------------|
| HR | Accurate, timely lifecycle events |
| Hiring manager | Approves non-birthright access, attests in reviews |
| IAM / IT | Executes and verifies provisioning |
| Security / SOC | Monitors for lifecycle anomalies |
| Application owners | Approve and certify app-specific access |
