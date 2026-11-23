# Orchestration Control Plane

Sources: https://www.kosmoy.com/resources/blog/what-is-ai-orchestration/ · https://github.com/machinedge/building-effective-agents/blob/main/building-effective-agents.md · https://thinking.inc/en/blue-ocean/agentic/agent-orchestration-patterns/ · https://www.anthropic.com/research/building-effective-agents · Last verified 2026-11-23

The Kosmoy article is vendor marketing ("What Is AI Orchestration? The 2026 Enterprise Playbook", updated 2026-08-15); it contains no benchmarks. Its architecture argument is useful, its product claims are not evidence.

## What the control plane is
Orchestration = coordinating models, agents, tools and data into one system, covering routing, context, permissions, policy enforcement and observability. It is a systems problem (reliability, governance, cost attribution), distinct from single-model quality.
Differs from: workflow automation (fixed task sequences, no LLM concerns), ML-lifecycle tools, plain API gateways (no token tracking or prompt policy), agent frameworks (govern one agent, not a fleet).
Stages (Kosmoy): trigger, planning, execution, governance, observability; governance applies at each step.

## Components (Kosmoy)
- **Central LLM gateway**: single entry/exit for model traffic; routing, policy, cost attribution, audit logs.
- **Agent registry**: inventory of agents with system access, models, owners, risk class.
- **Sandboxing**: containment enforced by infrastructure. Guardrails ask the agent to restrain itself; a sandbox enforces it regardless.
- **Observability**: live cost, usage, quality, behaviour.
- **Agent controls**: kill switches, action logging, scope enforcement, human escalation.
- Routing criteria: cost, capability, latency, compliance (data residency). Multi-provider routing so apps do not hard-code a vendor.

## Tool and agent protocols
- MCP: open agent-to-tool standard (machinedge guide says it moved to a Linux Foundation foundation in Dec 2025; not verified against a primary source). Portability is real but auth and feature support vary per server.
- A2A, ACP, ANP: agent-to-agent protocols; the machinedge guide covers them in a chapter beyond the readable part, so no detail is recorded here.
- Kosmoy's point: agent activity increasingly flows through MCP tool calls and agent-to-agent messages, so a layer that sees only model completions is blind to it. Route, authorise and log tool/agent traffic like model calls.
- Anthropic's tool advice applies at the protocol edge: unambiguous names, examples, edge cases, argument shapes that make mistakes hard.

## Governance rules from the sources
- Centralise governance and audit in shared infrastructure; per-app controls are fragile (Kosmoy).
- Human approval gates at finalisation and high-stakes actions; too many bottleneck, too few lose oversight (machinedge).
- Hard stops: iteration cap (guide suggests 10-20 steps), ~2-3 retries per tool, stuck detection after ~3 failures, timeout returning best-so-far, explicit done criteria, a verification pass (all machinedge heuristics, not standards).
- Keep the validating "guardian" separate from the agent it monitors (machinedge).
- Audit trails favour pipelines and supervisors; fan-out is harder to govern (thinking.inc).
- Context: sub-agents return summaries, not transcripts; compact near capacity; context editing and external memory (Anthropic PDF).
- Observability must capture prompts, retrieval context, tokens and inter-agent delegation, not only stack traces (Anthropic PDF).
- Monitor three levels: agent, orchestration (routing accuracy, handoff failures, coordination overhead), workflow (completion, cost, human interventions). Alert thresholds in thinking.inc (95% routing, 5% handoff failure, 25% overhead) are that vendor's suggestions.

## Where sources disagree or overreach
- machinedge argues most production systems should be workflows; Anthropic's article is milder.
- Anthropic's PDF favours multi-agent for open-ended parallel work; the machinedge guide calls orchestrators often over-built.
- Compliance dates in Kosmoy (EU AI Act phase-in) are the author's account; verify against the regulation.

## Example: minimal control-plane wrapper
```
def call(agent, tool, args):
    policy.check(agent.risk_class, tool, args)    # scope enforcement
    if tool.high_stakes: approval.wait(agent, args)
    with budget(agent.run_id, max_calls=20, timeout=120):
        out = gateway.invoke(tool, args)           # logged, cost-attributed
    audit.write(agent.id, tool, args, out)
    return out
```

## How an agent should apply this
- Put limits (iteration, retries, timeout, budget) outside the model's control.
- Log every tool and agent-to-agent call with owner, scope and cost.
- Use infra-level containment for anything with production access; treat prompts as advisory only.
- Gate irreversible or costly actions with approval; keep the gate list short and risk-based.
- Keep the policy checker separate from the worker it checks.
- Treat vendor "playbook" figures as claims until measured.
