# Enforcement and Wrong-Target Guards

Sources: https://about.gitlab.com/blog/postmortem-of-database-outage-of-january-31/ · https://sre.google/sre-book/emergency-response/ · https://docs.aws.amazon.com/wellarchitected/latest/framework/ops_mit_deploy_risks_plan_for_unsuccessful_changes.html (page body not readable; see Reading limits) · Last verified 2026-11-24

## Convention is not enforcement

An instruction to an agent works only while it is loaded and followed. A skill is routed in by matching the situation to its description; a long session, a compacted context or a misread request can leave it out. Nothing in the text of a skill can stop a shell command. That does not make the convention useless (most operations go right because the careful path is the default), but it caps what it can promise. State the cap whenever a mistake would be severe.

What actually enforces:

| Control | Strength | Weakness |
|---|---|---|
| Harness permission rules (deny or ask for a command pattern) | Runs before the command, independent of the model's judgment | Pattern based; a different spelling of the same command can slip through |
| Hooks that inspect the command and return a refusal with a reason | Can look at arguments, current directory, environment | You must write, test and maintain them; a broken hook fails open or closed depending on how it is written |
| Credentials with least privilege (read-only role for diagnostics, no drop rights for the application user) | The command fails whatever the agent believes | Needs setup per system |
| Platform safety nets: delete protection, versioning, snapshots, retention locks | Makes the loss small | Easy to assume they are on; verify |
| Environment separation (clearly different prompts, hostnames, colors, credentials for production) | Makes wrong-target mistakes visible | Humans and agents still can skip the look |

For git, `git-guardrails-claude-code` installs the hook layer. For database privileges and environment separation use `migrations-and-environments` and `database-exposure`. This skill's job is the decision around them, and the honesty about which layer is carrying the risk.

## What the 2017 postmortem teaches about wrong-target damage

The postmortem describes a destructive command run on the primary instead of the replica during a late-night attempt to rebuild replication. Points that generalize, in the postmortem's own framing and my reading of it:

- The first defense it argues for is not blocking one command (an alias for the remove command guards one kind of slip and not the others) but making the target unmistakable, for example by showing the environment and host in the shell prompt, and making mistakes recoverable.
- The damage was multiplied by the recovery story, not the command: the daily dump was empty, disk snapshots were not enabled for the database servers, replication had just been wiped, and the one usable snapshot lived on slow staging storage that took many hours to copy back. The lost window was the time since that snapshot was taken.
- Nobody owned "backups restore". The follow-ups included automated restore tests and a named owner for data durability. This is `backup-restore-drill` territory; the gate card makes the same gap visible earlier by forcing "last verified restore" onto the page.
- A silent tool (a rebuild command that waited without output) and an unreviewed setting (a very high connection limit) set the scene. Treat silence as "unknown", not "fine", and write down what you saw.
- Stress and time are part of the system. A rule that must be remembered under stress is weaker than a check built into the path.

## What the SRE emergency chapter adds

The Google SRE chapter on emergency response gives three cases where well-intended actions caused incidents. Three transferable guards:

1. **Rollback before action.** A planned test to block one database failed to bring access back quickly because the rollback had never been rehearsed. Before any production change that blocks, removes or rewrites, state the rollback and have exercised it somewhere safe.
2. **Canary every change, however low the risk.** A change judged low risk got a lighter canary and a rare input combination crashed a fleet. The gate asks "what is the smallest first step?" for this reason.
3. **Sanity checks in automation.** A decommission automation took an empty lookup result as "no filter" and queued machines across many sites for disk erasure. Guards that would have caught it: refuse an empty or unexpectedly large target set; require the count to match an expectation; cap how many items one run can touch; make a retry of a partly failed operation idempotent. If an agent writes or runs a loop over query results, add these checks before the destructive step.

The chapter also stresses calm and escalation: bring more people in, resolve the immediate issue first, and afterwards write it up. That is the hand-off from this skill to `blameless-postmortem`.

## A note on rollback planning guidance from cloud providers

Cloud well-architected guides list "plan for unsuccessful changes" as a standard practice: every production change has a defined way back, rollback is automated and tested, and schema changes are made backward compatible so that application rollback does not require undoing data changes. The page body could not be read in this authoring pass (see Reading limits), so treat that as general practice and not as a quotation. The schema-compatibility technique is covered in `parallel-change-expand-contract`.

## How an agent should apply this

- In a high-stakes message, say plainly: "this is a convention; nothing stops the command if I get it wrong". Then name the enforcement that exists or the one that should.
- Propose the cheapest enforcement that fits: a deny or ask rule, a hook, a read-only credential for the task at hand.
- Before an automated destructive step, add three guards: nonempty target, count within an expected range, hard cap per run.
- Make the target visible in your own output: print host, environment and path before the command and after.
- Treat silent tools and green dashboards as unverified until you have read the actual result.

## Reading limits

The AWS page is a script-rendered shell: both a summarizing fetch and a direct request returned only a generic title, so no text from it was read. The paragraph above is labeled general practice, not read from source.
