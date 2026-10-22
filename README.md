## About This Repo

Identity is often where security incidents begin, and the employee lifecycle is where identity controls most often break down. This repo documents how to manage that lifecycle end to end across three stages:

- **Joiner (onboarding):** create identities, assign least-privilege birthright access, and enforce MFA from day one.
- **Mover (role changes):** recalculate access when someone changes roles, so old permissions don't pile up as privilege creep.
- **Leaver (offboarding):** disable accounts, revoke sessions, strip access, and verify nothing is left behind.

Each stage includes a step-by-step runbook with diagrams, Microsoft Graph PowerShell automation, and KQL detections for Microsoft Sentinel that catch lifecycle failures, such as a disabled account still signing in. The controls are mapped to NIST CSF, ISO 27001, and CIS Controls.

**Who it's for:** IAM and IT teams building a lifecycle process, SOC analysts and detection engineers monitoring identity risk, and anyone learning how process and detection fit together.

**Tech:** Entra ID, Microsoft Graph, PowerShell, KQL, Microsoft Sentinel, Mermaid diagrams.
