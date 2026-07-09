---
title: "AWS AI Partner Builder Day 2026 — Day 1"
date: 2026-07-09
categories: ["Programming"]
tags: ["aws", "bedrock", "agents"]
series: ["aws-training"]
draft: true
---

## Summary
<!-- One paragraph: what is this and why does it matter? -->
Notes from day 1 of AWS AI Partner Builder Day 2026 (July 9–10). The sessions covered what's new across three products — Amazon Bedrock, Amazon Bedrock AgentCore, and Strands Agents — followed by a workshop on AI agent patterns, agentic workflow patterns, and multi-tenant architectures.

## Notes
<!-- Your detailed notes -->

Three stops:

1. Amazon Bedrock
2. Amazon Bedrock AgentCore
3. Strands Agents

### I. What's new in Amazon Bedrock

**New inference endpoint: bedrock-mantle** — `bedrock-mantle.{region}.api.aws`

Advantages over `bedrock-runtime`:

- Easy migration
- Asynchronous inference
- Stateful conversations
- Higher throughput by design

**Three APIs, one endpoint:**

- **OpenAI Responses API** — `/v1/responses`: stateful, async; built for agentic workflows
- **OpenAI Chat Completions API** — `/v1/chat/completions`
- **Anthropic Messages API** — `/anthropic/v1/messages`: native Claude requests

**Projects — OpenAI-compatible workload isolation.** A logical boundary for isolating apps and environments. Created via API in seconds; up to 1,000 projects.

**Workspaces — Anthropic-compatible isolation.** Same idea, same isolation — differs only in the reference mechanism. Use when migrating Claude-native apps.

**Decision framework:**

- Brand-new build → bedrock-mantle + Responses API
- Migrating an existing app → bedrock-mantle

> **Open question:** if the client is already on OpenAI, why would they want to migrate to AWS?
> *My take (not from the speaker): enterprise reasons — data stays inside your AWS account/VPC, unified billing against existing AWS commitments, compliance posture, and access to multiple model families behind one endpoint.*

### II. What's new in Amazon Bedrock AgentCore

**AgentCore Policy — deterministic tool guardrails.** Policies compile to Cedar, AWS's authorization language. Every tool call is intercepted by a policy engine. Default-deny, forbid-overrides-permit evaluation; every decision is logged to CloudWatch for full audit traceability.

**AgentCore Registry — discover & govern agents.** A single catalog that complements AgentCore Gateway's data plane. Hybrid search combines keyword and semantic matching. Built around three personas: Admin, Publisher, Consumer. Indexes resources wherever they run — queryable as an MCP server.

**AgentCore Evaluations — quality monitoring.** Continuously assesses agent quality against real-world behavior. 13 built-in evaluators covering the necessary topics. Ground-truth support for measuring agents against reference answers. Custom evaluators can be LLM-based or fully deterministic. All metrics land in one CloudWatch dashboard, and it works with any framework (Strands, LangGraph, CrewAI).

### III. What's new in Strands Agents

Core concepts: agent loop, state, snapshots, prompt hooks, tools.

**Context management** — two modes: Auto and Agentic. Agentic-mode use cases:

- Long-running coding or research agents
- High-stakes workflows
- Cost-sensitive production agents

**Memory** — three jobs: recall, injection, extraction. Use cases:

- Personalized support agents
- Multi-tenant SaaS agents
- Compliance-aware agents

**Sandbox** — a pluggable execution backend for complex calculations.

#### Strands orchestration: four multi-agent patterns

**1. Agents as Tools** — clear routing, escalation paths, specialist focus.

One supervisor agent orchestrates multiple specialist agents by calling them as tools — a classic hierarchy.

Example use case: customer support (card lost, fraud dispute, billing). A supervisor triage agent receives the customer request and calls the right specialist — Card Agent, Fraud Agent, or Billing Agent — as a tool, then composes the final answer.

The problem it solves: support requests span many domains, but the customer should talk to one interface. A supervisor gives clear routing and escalation paths while each specialist stays focused on its own tools and instructions.

**2. Swarm** — complex multi-angle analysis, parallel peer expertise.

Multiple peer agents (no hierarchy) autonomously decide who works next via handoffs, sharing the same memory — a self-organizing team.

Example use case: fraud investigation & risk scoring. Multiple fraud analysts work simultaneously, each examining a different angle; when one discovers something, they hand off to the peer with more expertise on that angle.

The problem it solves: fraud is multifaceted — one agent can't see everything, so peers must collaborate and hand off dynamically.

**3. Graph** — clear decision tree, risk-based routing, conditional branching.

A directed graph where nodes = agents and edges = data flow, with conditional branching and looping revision until a quality gate approves.

Example use case: loan underwriting & credit decisioning — a clear decision tree where each node is an agent and routes branch on risk level.

The problem it solves: loan decisions have fixed stages (income verification → credit score → fraud check → final decision), but the path depends on risk signals (low risk = fast track; high risk = full, careful review).

**4. Workflow** — fixed legal sequence, parallel stages, error recovery.

Example use case: KYC onboarding pipeline — a linear, multi-stage compliance process where each stage must complete before the next. High stakes means strict ordering, parallel efficiency, and error recovery.

The problem it solves: KYC onboarding has legal stages (identity verification → document validation → risk scoring → sanctions check → final approval), each depending on the previous — but many stages can run in parallel (documents can be analyzed while the ID is being verified).

---

### AI agent patterns (workshop)

Development workflow tip from the session: go in the reverse direction.

#### 1. Tool-based agent

A single agent that answers requests by calling external tools (APIs, databases, calculators) instead of relying only on model knowledge.

Capabilities:

- Function/tool calling with structured inputs and outputs
- Grounds answers in live data instead of parametric memory
- Simplest agent shape — one model, one loop, a set of tools

Common use cases:

- Account balance and transaction lookups
- FX rates, market data, or product info retrieval
- Form filling and simple task automation

#### 2. Basic ReAct agent

An agent that runs a reason–act loop: think about the problem, act (call a tool), observe the result, and repeat until it can answer.

Capabilities:

- Interleaved reasoning and tool use (Thought → Action → Observation)
- Multi-step problem solving without a predefined plan
- Self-correction — a failed tool call feeds back into the next reasoning step

Common use cases:

- Research or investigation tasks over several data sources
- Troubleshooting flows where the next step depends on what was just found
- Ad-hoc analysis questions that need several dependent lookups

#### 3. Speech & voice agent

Capabilities:

- Multi-turn session awareness
- Integration with streaming APIs
- Multilingual STT and TTS

Common use cases:

- AI helpdesk
- Conversational IVR systems
- Voice interfaces for next-gen smart devices

#### 4. Workflow orchestration agent

An agent that coordinates a multi-step process end to end — sequencing sub-agents and tools, tracking state, and handling branches and failures.

Capabilities:

- Deterministic control flow with agent steps inside (order, branching, retries)
- State passed and accumulated across steps
- Error recovery and human-in-the-loop escalation points

Common use cases:

- Document processing pipelines (intake → extract → validate → approve)
- Compliance processes like KYC/onboarding with fixed stages
- Report generation that combines several analysis steps

### Agentic workflow patterns

#### 1. Prompt Chaining

TL;DR: sequential reasoning with a handoff at each step.

Each step takes the previous output as input. The model reasons through one stage, generates output, and passes it to the next stage.

How it works:

1. Extract key facts from the input
2. Use those facts to generate analysis
3. Use the analysis to produce recommendations
4. Use the recommendations to draft a response

Advantages:

- **Explainability:** each step is visible and auditable; regulators can trace the reasoning
- **Error isolation:** if step 3 fails, you know exactly where the breakdown occurred
- **Reduced hallucination:** breaking complex problems into steps improves accuracy vs. single-shot reasoning
- **Easy to debug:** test each step independently; inject test data at any stage
- **Deterministic:** same input → same sequence of steps → reproducible output
- **Regulatory compliance:** full chain of custody for decisions (critical in banking, healthcare, finance)
- **Cost control on high-stakes decisions:** invest tokens upfront for accuracy; worth it for $500K+ loans

When to use:

- Complex reasoning that needs scaffolding
- Later steps depend on earlier conclusions
- Reducing hallucination by breaking the problem down
- Audit trails (each step is logged and reviewable)

#### 2. Routing

TL;DR: classifies inputs and directs each to a specialized handler.

A classifier agent (or a simple decision tree) examines the request and directs it to the best-fit handler. No branching logic inside a single agent — route to the right agent instead.

How it works:

1. Classifier reads the input
2. Outputs `{category: "X", confidence: 0.95}`
3. Router dispatches to Agent-X (specialized for category X)
4. Agent-X processes with its tuned instructions, tools, and context

When to use:

- Multiple distinct problem types (support tickets, transactions, inquiries)
- You want specialized agents optimized per category
- Reducing cognitive load (each agent focuses on one domain)
- Scaling (add new agents without rewriting the router)

Banking example — customer inquiry routing:

- Input: "I want to close my account"
- Classifier → `{category: "Account Management", confidence: 0.98}`
- Router → Account Closure Agent
- Account Closure Agent verifies ID, checks for pending transactions, processes the closure, sends confirmation
- Other routes: Loan Inquiry Agent, Fraud Report Agent, Investment Advisor Agent, Card Services Agent

Advantages:

- **Specialization:** each agent is tuned for one problem type (better prompts, fewer tokens wasted on irrelevant context)
- **Scalability:** add new agents without rewriting the router; scales to dozens of categories
- **Faster response:** focused agent = fewer reasoning steps = lower latency
- **Lower cost per request:** specialized agents use fewer tokens than a generalist
- **Better performance:** domain-specific training/fine-tuning is possible per agent
- **Isolation:** if one agent degrades, the others still work; easier to A/B test variants
- **Team ownership:** each team can own and optimize its specialist agent
- **Reduced cognitive load:** an agent isn't juggling 10 different problems; it stays focused

#### 3. Parallelization

TL;DR: splits a task into simultaneous subtasks and merges the results.

Split the task into independent subtasks → execute simultaneously → merge results. The agent (or orchestrator) decomposes the work into parallel branches, fires them concurrently, and synthesizes the results.

How it works:

1. **Decompose:** "I need X, Y, Z — all independent"
2. **Execute:** fire all branches in parallel
3. **Merge:** combine outputs into a unified response

When to use:

- Subtasks are independent (no inter-dependencies)
- Wall-clock speed is critical
- You can tolerate some redundancy (multiple agents may call overlapping tools)
- Aggregating multiple perspectives or data sources

Banking example — comprehensive customer financial health check:

- Track 1: fetch account balances, transaction history, spending trends
- Track 2: query credit score, loan history, payment records
- Track 3: analyze investment portfolio, asset allocation, performance
- Track 4: check insurance policies, coverage gaps, claims history
- Merge: synthesize into a single "financial dashboard" and risk profile

All four run at once; the final synthesis takes <2 seconds instead of 8 seconds sequentially.

Advantages:

- **Speed:** wall-clock time drops dramatically (parallel execution vs. sequential queuing)
- **Responsiveness:** customer-facing apps get <2s responses; better UX
- **Redundancy:** if one data source times out, the others still complete; graceful degradation
- **Resource utilization:** fully uses multi-core systems and concurrent API calls
- **Throughput:** more requests per second when I/O-bound
- **Reduced latency for large requests:** fetching 4 data sources in parallel = 1/4 the time
- **Independent reasoning:** each parallel agent reasons in isolation; less context pollution
- **Natural for aggregation:** gathering insights from multiple sources (credit bureaus, transaction DB, investment platform)

#### 4. Orchestration

TL;DR: breaks a complex agent into sub-agents with state/context passing.

A coordinator agent manages a sequence of specialized sub-agents, passing state between them and deciding which sub-agent to invoke next.

How it works:

1. Coordinator parses the request and initializes shared state
2. Invokes Sub-Agent 1 (e.g., data gatherer) with context
3. Sub-Agent 1 returns results and updates the shared state
4. Coordinator decides: call Sub-Agent 2 or Sub-Agent 3?
5. Continue until done, accumulating state
6. Coordinator synthesizes the final response

When to use:

- Sequential flow with conditional branching (not purely linear)
- Sub-agents need to share mutable state
- Complex business logic (approval workflows, escalations)
- Debugging/audit (each sub-agent decision is logged)

Banking example — mortgage underwriting orchestration:

1. **Data Ingestion Agent:** collects application, documents, credit report → state = `{applicant_data, doc_status}`
2. Coordinator checks: all docs present? If not → invoke Doc Request Agent (sends email, waits) → loop back to step 1
3. **Risk Assessment Agent:** analyzes financials → state = `{risk_score, flags}`
4. Coordinator checks: risk score under threshold? If yes → proceed; if no → escalate to Manual Review Agent
5. **Compliance Agent:** checks regulatory constraints → state = `{compliant: yes/no, notes}`
6. **Pricing Agent:** determines the rate → state = `{rate, terms}`
7. Coordinator synthesizes: final approval or rejection with a full audit trail

Advantages:

- **Conditional logic:** easy to express "if risk_score > X, escalate" without rewriting agents
- **State management:** each step builds on prior state; no information loss between steps
- **Flexibility:** the coordinator routes to different sub-agents based on runtime conditions
- **Visibility:** full audit trail of decisions and state changes at each step
- **Reusability:** sub-agents can be swapped or reused in different workflows
- **Testability:** test coordinator logic independently from sub-agents
- **Maintainability:** clear separation of concerns (coordinator = logic, sub-agents = specialists)
- **Exception handling:** the coordinator can catch failures and invoke recovery agents
- **Scalability:** add new conditional branches without rewriting the core flow

### Multi-tenant patterns

#### 1. Silo

Separate, isolated infrastructure per tenant (1:1 mapping).

Architecture:

- Each tenant gets a dedicated stack: agent, compute, storage, knowledge bases
- No shared components — often a separate AWS account or VPC per tenant
- Tenant onboarding = provisioning a full new stack (typically via IaC templates)

Key features:

- Complete resource and data isolation per tenant
- Per-tenant configuration, model choice, and scaling
- Blast radius limited to a single tenant

Advantages:

- Maximum isolation (data, performance, and security boundaries)
- Simplest compliance story (per-tenant audit, data residency)
- No noisy-neighbor effects; per-tenant cost attribution is trivial
- Per-tenant customization without affecting others

Disadvantages:

- Highest cost (duplicated infrastructure sits idle for small tenants)
- Operational overhead scales linearly with tenant count
- Slow onboarding (a full stack must be provisioned per tenant)
- Fleet-wide updates must be rolled out N times

Best for:

- Regulated industries (banking, healthcare) with strict data-isolation requirements
- A small number of large, high-value enterprise tenants
- Contracts that mandate dedicated infrastructure or data residency

#### 2. Pool

Shared infrastructure for all tenants (N:1 mapping).

Architecture:

- One shared agent and backend serves every tenant
- Tenant identity travels with each request (e.g., JWT claims / session context)
- Data partitioned logically — tenant-ID keys in DynamoDB, metadata filters on knowledge bases

Key features:

- Single deployment to operate, monitor, and update
- Tenant context enforced at the application layer, not the infrastructure layer
- Resources scale with aggregate load, not tenant count

Advantages:

- Lowest cost (shared compute and storage, high utilization)
- Simplest operations (one deployment, one dashboard, one update path)
- Instant tenant onboarding (a new tenant is just a new row/config)
- Economies of scale improve as tenants grow

Disadvantages:

- Weakest isolation — a partitioning bug can leak data across tenants
- Noisy neighbors (one heavy tenant degrades everyone's latency)
- Hard to customize per tenant (one agent must serve all)
- Per-tenant cost attribution and throttling require extra work

Best for:

- B2C or SMB SaaS with many small, homogeneous tenants
- Cost-sensitive products where isolation requirements are modest
- Early-stage products that need fast tenant onboarding over customization

#### 3. Bridge

Tenant-isolated agents that bridge to shared infrastructure.

Architecture:

- Each tenant has a dedicated Bedrock agent (isolated)
- Agents share common infrastructure (Lambda, DynamoDB, APIs)
- Agents communicate through a shared message bus / event layer
- Tenant data flows through shared services but remains partitioned

Key features:

- Agent isolation (each tenant's agent is separate)
- Shared backend (DynamoDB, Knowledge Bases, and tools are pooled)
- Event-driven communication (async message passing)
- Tenant context preserved across shared services

Advantages:

- Medium cost (N agents, but shared compute)
- Strong isolation (agents can't interfere with each other)
- Flexibility (each agent is customizable, with a unified backend)
- Scalability (add an agent per tenant; infrastructure scales horizontally)

Disadvantages:

- Moderate complexity (manage N agents plus the shared layer)
- Message-bus overhead (latency from async communication)
- Coordination complexity (ensuring tenant context is preserved)

Best for:

- Mid-market SaaS with 20–100+ tenants
- Per-tenant customization with cost efficiency
- A hybrid approach between Silo and Pool
- Integration-heavy platforms (each tenant's agent integrates differently)

## Takeaways
<!-- What you'll actually remember -->
1. Default new Bedrock builds to bedrock-mantle — one endpoint, three APIs (OpenAI Responses, OpenAI Chat Completions, Anthropic Messages), with Projects/Workspaces for isolation.
2. Treat AgentCore Policy + Evaluations as non-negotiable for production: default-deny Cedar guardrails on every tool call, plus continuous quality monitoring in CloudWatch.
3. Pick a multi-agent pattern by how fixed the process is: Workflow/Graph for regulated, staged flows (KYC, underwriting); Agents-as-Tools/Swarm when routing or investigation is open-ended.
4. Start with the simplest agent shape that works and escalate only when needed: tool-based → ReAct → workflow orchestration. Don't reach for multi-agent until a single agent with tools demonstrably falls short.
5. The agentic workflow patterns are composable, not competing: route first (Routing), fan out independent work (Parallelization), chain dependent reasoning (Prompt Chaining), and add a coordinator (Orchestration) only when you need conditional branching over shared state.
6. Multi-tenancy is a cost-vs-isolation dial: Silo for a few regulated enterprise tenants, Pool for many small homogeneous ones, Bridge as the mid-market compromise — isolated agents on a shared backend.

## References

<!-- Papers, articles, books, links -->
- [Amazon Bedrock documentation](https://docs.aws.amazon.com/bedrock/)
- [Amazon Bedrock AgentCore](https://aws.amazon.com/bedrock/agentcore/)
- [Strands Agents](https://strandsagents.com/)
