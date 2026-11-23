# Azure Compute Decision Tree and Technology-Choice Guides

Sources: https://learn.microsoft.com/en-us/azure/architecture/guide/technology-choices/compute-decision-tree · https://learn.microsoft.com/en-us/azure/architecture/guide/technology-choices/technology-choices-overview · Last verified 2026-11-23

Figures below are as published on the pages at read time; re-check quotas before sizing.

## How the compute guide works

The flowchart branches first on **migrate** versus **build new**. Migrate: is the app already cloud-optimized, and can it be lifted and shifted (VMs, VMware Solution, or App Service)? Build new: do you need full control (VMs), HPC (Batch), event-driven (Functions), managed web hosting (App Service), or container orchestration (AKS, Container Apps, Container Instances, Red Hat OpenShift)? The output is only a **candidate**; then validate against the tables. Different components of one workload may legitimately use different services.

- **Lift and shift (rehost)**: no redesign; the page recommends like-for-like and deferring optimization unless budget and timeline allow redesign.
- **Cloud optimized**: refactor for cloud-native features; also describes greenfield.

## Hosting-model spectrum

IaaS (most control, portability, most ops), PaaS (App Service, Container Apps), FaaS (Functions, nearly everything managed). Autoscaling is not exclusive to PaaS/FaaS (VM scale sets); capability varies by service, not by category.

## Evaluation dimensions (the table columns)

| Dimension | Notable facts |
|---|---|
| Composition, density, state | App Service stateless; Functions stateless or stateful with Durable Functions; Container Apps serverless density |
| Minimum nodes | AKS production 6 (3 system + 3 user); OpenShift 6; VMs 1 (higher SLA needs 2+) |
| Networking | VNet integration and hybrid connectivity per service; App Service needs Basic tier or above |
| DevOps | local/remote debugging, update model: slots (App Service, Functions), rolling (AKS), revisions (Container Apps) |
| **Team skills / ops overhead** | VMs high; AKS high (cluster management); App Service low; Functions very low; Container Apps low ("modern patterns without Kubernetes complexity") |
| Scale limits | e.g. AKS 5,000 nodes (Standard/Premium); Container Apps 1,000 replicas per revision; App Service Premium plans 30 instances |
| Multiregion | all listed platforms are single-region; an external router plus multiple deployments is required for active-active or active-passive |
| Other | TLS handling, GPU support, cost, suitable styles (Functions/AKS/Container Apps map to microservices and event-driven; App Service to web-queue-worker; VMs to n-tier and big compute) |
| Specialty | HPC scheduling (CycleCloud), SAP, Oracle, Service Fabric, mainframe, bare metal, etc. |

## The wider technology-choices index

Same taxonomy applies across: compute, containers, hybrid, identity, storage, data stores (OLTP, OLAP, data lakes, search, vector), analytics (batch vs stream), AI/ML, networking and load balancing, integration, messaging (Event Grid vs Event Hubs vs Service Bus), IoT, plus AWS/GCP-to-Azure service maps. Use it as a checklist of decision categories so none is skipped.

## Failure modes

- Treating the flowchart's first output as the answer.
- Ignoring team skills: choosing AKS without Kubernetes expertise.
- Assuming a PaaS is multi-region by itself.
- Forgetting limits and cost until after commitment.
- Using one compute service for components with different needs.

## Example decision record skeleton

```
Need: event-driven API, spiky load, small team, 1 region + DR region
Candidates: Functions, Container Apps, AKS
Rejected: AKS (ops overhead high, no K8s skills)
Chosen: Container Apps; external router for 2nd region
Revisit if: need K8s API access or >1,000 replicas
```

## How an agent should apply this

- Run the decision as two passes: flowchart for candidates, then tables for disqualifiers.
- Always include team skills and operational overhead as a first-class criterion.
- State multiregion strategy explicitly; platforms do not provide it.
- Cite the service limit that could bite and mark it as "verify against current quotas".
- Evaluate each distinct compute component separately.
