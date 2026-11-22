# Dev.-DBs-Skills

Catálogo unificado de **65 Agent Skills** (Claude Code, Antigravity IDE, Codex, Cursor) cobrindo **Arquitetura & Design de Software (27 skills)**, **Cloud-Native, Resiliência, Evolução & IA (7 skills)**, **Documentação, Diagramas & Contratos (5 skills)**, **Workflow de Engenharia & Construção — Matt Pocock Pack (8 skills)**, **Fundamentos de Engenharia & Segurança (7 skills)**, **Fundamentos & Governança de Bancos de Dados (8 skills)** e **Diagnósticos de Motores SQL em Produção (3 skills)**.

Todas as skills são autocontidas, sem dependências externas, testadas por `check_skills.py` e verificadas contra `MANIFEST.sha256`.

---

## Catálogo Completo (65 Skills)

| # | Categoria | Skill | Descrição (1 linha) |
|---|---|---|---|
| 1 | Arquitetura & Design de Software | [`actor-model-space-based-architecture`](skills/actor-model-space-based-architecture/SKILL.md) | Sistemas concorrentes/distribuídos stateful com Actor Model (Akka, Orleans, Erlang/OTP) e Space-Based Architecture (In-Memory Data Grids). |
| 2 | Arquitetura & Design de Software | [`architecture-decision-trees-tradeoffs`](skills/architecture-decision-trees-tradeoffs/SKILL.md) | Árvores de decisão e trade-offs entre estilos arquiteturais (`-ilities`, Architecture Quantum, Katas) e modelos cloud IaaS/PaaS/FaaS. |
| 3 | Arquitetura & Design de Software | [`bff-pattern`](skills/bff-pattern/SKILL.md) | Edge Backend dedicado por experiência de cliente (Web, Mobile, IoT) alinhado à equipa de frontend e agregando chamadas downstream. |
| 4 | Arquitetura & Design de Software | [`clean-architecture`](skills/clean-architecture/SKILL.md) | Quatro círculos concêntricos (*Entities*, *Use Cases*, *Interface Adapters*, *Frameworks*) sob a *Dependency Rule* apontando para dentro. |
| 5 | Arquitetura & Design de Software | [`codebase-design`](skills/codebase-design/SKILL.md) | Vocabulário partilhado de módulos profundos (*Deep Modules*, *Seam*, *Leverage*, *Deletion Test*) e padrão *Design It Twice* para desenho de interfaces. |
| 6 | Arquitetura & Design de Software | [`cqrs-pattern`](skills/cqrs-pattern/SKILL.md) | Separação entre modelos de escrita (*Commands*) e leitura (*Queries*) com projeções síncronas ou eventuais num *Bounded Context*. |
| 7 | Arquitetura & Design de Software | [`ddd-domain-heuristics-debiasing`](skills/ddd-domain-heuristics-debiasing/SKILL.md) | Separação entre DDD estratégico e padrões táticos (Khononov), *Core Domain Charts* e checklist de 5 passos contra vieses cognitivos. |
| 8 | Arquitetura & Design de Software | [`defensive-domain-modeling`](skills/defensive-domain-modeling/SKILL.md) | *Parse Don't Validate*, estados ilegais irrepresentáveis, *Value Objects*, *Tell Don't Ask*, Lei de Demeter, CQS, *Guard Clauses* e *Railway-Oriented Programming*. |
| 9 | Arquitetura & Design de Software | [`event-driven-architecture`](skills/event-driven-architecture/SKILL.md) | Produtores, brokers e consumidores via *Pub/Sub* ou *Event Streaming*, distinguindo *Event Notification*, *ECST*, *Event Sourcing* e *CQRS*. |
| 10 | Arquitetura & Design de Software | [`event-sourcing-pattern`](skills/event-sourcing-pattern/SKILL.md) | Persistência *append-only* de eventos de domínio, *fold* (`decide`/`apply`), concorrência otimista, *snapshots*, *upcasting* e GDPR. |
| 11 | Arquitetura & Design de Software | [`hexagonal-architecture`](skills/hexagonal-architecture/SKILL.md) | *Ports & Adapters* isolando domínio e casos de uso com *driver/driven ports*, adaptadores substituíveis e *composition root* único. |
| 12 | Arquitetura & Design de Software | [`layered-n-tier-architecture`](skills/layered-n-tier-architecture/SKILL.md) | Separação de camadas lógicas (*Layers*) e físicas (*Tiers*), comunicação estrita vs. relaxada e prevenção de *layer sinkholes*. |
| 13 | Arquitetura & Design de Software | [`micro-frontends-architecture`](skills/micro-frontends-architecture/SKILL.md) | Fatias verticais de UI com deploy independente em *runtime* (Module Federation, Web Components, SSI) e isolamento de CSS/estado. |
| 14 | Arquitetura & Design de Software | [`microkernel-plugin-architecture`](skills/microkernel-plugin-architecture/SKILL.md) | Núcleo mínimo (*Core System*) extensível por plug-ins independentes via contratos versionados, registro e isolamento/sandbox. |
| 15 | Arquitetura & Design de Software | [`microservices-architecture`](skills/microservices-architecture/SKILL.md) | Serviços com deploy independente por subdomínio de negócio, BD privada por serviço, *Sagas*, *Outbox* e testes de contrato. |
| 16 | Arquitetura & Design de Software | [`modular-monolith-architecture`](skills/modular-monolith-architecture/SKILL.md) | Deploy único particionado em *Bounded Contexts* encapsulados, *schemas* de BD isolados e eventos *in-process* via *Outbox*. |
| 17 | Arquitetura & Design de Software | [`monolithic-architecture`](skills/monolithic-architecture/SKILL.md) | Estratégia *Monolith First* com deploy único, transações ACID locais e escala horizontal *stateless* antes do *Microservice Premium*. |
| 18 | Arquitetura & Design de Software | [`mvc-architecture`](skills/mvc-architecture/SKILL.md) | *Separated Presentation* e *Humble View*, mantendo regras no *Model*, coordenação fina no *Controller* e projeção passiva na *View*. |
| 19 | Arquitetura & Design de Software | [`package-by-feature-component`](skills/package-by-feature-component/SKILL.md) | Organização de módulos por funcionalidade ou componente (*Common Closure Principle*) com encapsulamento *package-private*. |
| 20 | Arquitetura & Design de Software | [`pipes-and-filters-pattern`](skills/pipes-and-filters-pattern/SKILL.md) | Workflows sequenciais em filtros *stateless* reutilizáveis ligados por *pipes*, com *backpressure*, idempotência e *poison-message routing*. |
| 21 | Arquitetura & Design de Software | [`pragmatic-solid-and-ssot`](skills/pragmatic-solid-and-ssot/SKILL.md) | DRY como SSOT de conhecimento, limites em *Bounded Context*, SOLID pragmático sem cerimónia de interfaces, *Rule of Three*, *Wrong Abstraction*, AHA e KISS. |
| 22 | Arquitetura & Design de Software | [`repository-root-monorepo-architecture`](skills/repository-root-monorepo-architecture/SKILL.md) | Layout raiz de repositórios, escolha *Monorepo vs. Polyrepo*, convenções Go/TS (`cmd/`, `internal/`, `apps/`, `packages/`) e `CODEOWNERS`. |
| 23 | Arquitetura & Design de Software | [`saga-transactional-outbox-pattern`](skills/saga-transactional-outbox-pattern/SKILL.md) | Transações distribuídas via *Sagas* (Coreografia vs. Orquestração, *Pivot*, compensação) e *Transactional Outbox* + *Inbox* idempotente. |
| 24 | Arquitetura & Design de Software | [`screaming-architecture`](skills/screaming-architecture/SKILL.md) | Diretórios de topo e pacotes que revelam o domínio de negócio e casos de uso em vez do framework ou ORM utilizado. |
| 25 | Arquitetura & Design de Software | [`serverless-architecture`](skills/serverless-architecture/SKILL.md) | Funções *stateless* (*FaaS*) + serviços geridos (*BaaS*) controlando *cold starts*, *pooling*, idempotência, DLQs e IAM mínimo. |
| 26 | Arquitetura & Design de Software | [`soa-vs-microservices-architecture`](skills/soa-vs-microservices-architecture/SKILL.md) | Comparação estrutural e regras de migração entre SOA corporativo (ESB, dados partilhados) e Microsserviços (*smart endpoints, dumb pipes*). |
| 27 | Arquitetura & Design de Software | [`vertical-slice-architecture`](skills/vertical-slice-architecture/SKILL.md) | Código organizado por fatia de requisição/funcionalidade (*REPR*/MediatR), eliminando camadas pass-through e respeitando o eixo de acoplamento. |
| 28 | Cloud-Native, Resiliência & IA | [`agent-skills-context-engineering`](skills/agent-skills-context-engineering/SKILL.md) | Especificação aberta `agentskills.io`, *progressive disclosure* em runtime, *Context Engineering* e controles *Feedforward/Feedback* de *Harness*. |
| 29 | Cloud-Native, Resiliência & IA | [`agentic-rag-architecture`](skills/agentic-rag-architecture/SKILL.md) | Escolha do nível mínimo de complexidade em sistemas de IA (Direct Call, Workflow, Single/Multi-Agent), *tool contracts* (ACI), RAG híbrido e avaliação. |
| 30 | Cloud-Native, Resiliência & IA | [`circuit-breaker-retry-telemetry`](skills/circuit-breaker-retry-telemetry/SKILL.md) | *Circuit Breaker* (*Closed/Open/Half-Open*), *exponential backoff* com *jitter*, *Bulkhead*, *Fallback* e observabilidade unificada OpenTelemetry. |
| 31 | Cloud-Native, Resiliência & IA | [`parallel-change-expand-contract`](skills/parallel-change-expand-contract/SKILL.md) | Migrações de esquema e contratos sem *downtime* em produção através das três fases discretas: *Expand*, *Transition* e *Contract*. |
| 32 | Cloud-Native, Resiliência & IA | [`testing-pyramid-and-shapes`](skills/testing-pyramid-and-shapes/SKILL.md) | Estratégia de testes automatizados comparando *Test Pyramid*, *Testing Trophy* e *Testing Honeycomb* com rácios, contratos e anti-padrões. |
| 33 | Cloud-Native, Resiliência & IA | [`twelve-factor-cloud-native`](skills/twelve-factor-cloud-native/SKILL.md) | Metodologia 12-Factor e extensões modernas 15-Factor (API-first, telemetria, zero-trust) para cargas portáteis e *stateless* em nuvem/containers. |
| 34 | Cloud-Native, Resiliência & IA | [`yagni-evolutionary-architecture`](skills/yagni-evolutionary-architecture/SKILL.md) | Prevenção de *overengineering*: modelo dos 4 custos do YAGNI, *Is Design Dead?*, *Design Stamina Hypothesis* e *Sacrificial Architecture*. |
| 35 | Documentação, Diagramas & Contratos | [`adr-architecture`](skills/adr-architecture/SKILL.md) | Registo imutável de decisões arquiteturais significativas (Nygard, MADR, Y-Statements) com alternativas, trade-offs e *superseding* em Git. |
| 36 | Documentação, Diagramas & Contratos | [`arc42-api-contracts-architecture`](skills/arc42-api-contracts-architecture/SKILL.md) | Documentação arquitetural nas 12 secções do template *arc42* integrada com contratos *contract-first* em OpenAPI 3.x e AsyncAPI 3.x. |
| 37 | Documentação, Diagramas & Contratos | [`c4-model-architecture`](skills/c4-model-architecture/SKILL.md) | Diagramação hierárquica C4 (*System Context*, *Container*, *Component*, *Code* + *Deployment/Dynamic*) com checklist de notação e Mermaid/Structurizr. |
| 38 | Documentação, Diagramas & Contratos | [`diataxis-documentation-architecture`](skills/diataxis-documentation-architecture/SKILL.md) | Organização de documentação técnica nos 4 quadrantes *Diátaxis* (*Tutorials*, *How-to Guides*, *Reference*, *Explanation*) sem contaminação cruzada. |
| 39 | Documentação, Diagramas & Contratos | [`mermaid`](skills/mermaid/SKILL.md) | Engenharia de diagramas Mermaid como código (*flowchart*, *sequence*, *ER*, *state*, *class*, C4, `architecture-beta`), portabilidade GitHub/ELK e validação via `mmdc`. |
| 40 | Workflow de Engenharia (Matt Pocock) | [`code-review`](skills/code-review/SKILL.md) | Revisão em sub-agentes frescos em paralelo por dois eixos separados (*Standards* + 12 smells de Fowler + guardrails do pack vs. *Spec*). |
| 41 | Workflow de Engenharia (Matt Pocock) | [`grill-me`](skills/grill-me/SKILL.md) | Ponto de entrada explícito do utilizador para iniciar uma entrevista exaustiva de árvore de decisão via `grilling`. |
| 42 | Workflow de Engenharia (Matt Pocock) | [`grilling`](skills/grilling/SKILL.md) | Entrevista implacável por rondas na fronteira da árvore de decisão (factos investigados pelo agente em contexto fresco; decisões do utilizador). |
| 43 | Workflow de Engenharia (Matt Pocock) | [`implement`](skills/implement/SKILL.md) | Execução guiada de *spec* ou *tickets* aplicando `tdd` em *seams* acordados, modelagem defensiva/segurança e `code-review` antes do commit. |
| 44 | Workflow de Engenharia (Matt Pocock) | [`setup-matt-pocock-skills`](skills/setup-matt-pocock-skills/SKILL.md) | Configuração inicial por repositório de *issue tracker* (GitHub, GitLab, `.scratch/`), vocabulário de triagem e layout `GLOSSARY.md` / `docs/adr/`. |
| 45 | Workflow de Engenharia (Matt Pocock) | [`tdd`](skills/tdd/SKILL.md) | Ciclo *Red → Green* por fatias verticais em *seams* pré-acordados, anti-padrões (*mocking* interno, testes tautológicos) e vocabulário de `codebase-design`. |
| 46 | Workflow de Engenharia (Matt Pocock) | [`to-spec`](skills/to-spec/SKILL.md) | Síntese da conversa atual em especificação estruturada (*Problem*, *Stories*, *Implementation Decisions*, *Testing Seams*, *Out of Scope*) sem re-entrevistar. |
| 47 | Workflow de Engenharia (Matt Pocock) | [`to-tickets`](skills/to-tickets/SKILL.md) | Decomposição em *tracer-bullet* slices verticais com arestas `Blocked by` explícitas e exceção *expand–contract* para refactors transversais. |
| 48 | Fundamentos de Engenharia & Segurança | [`fundamentals-audit`](skills/fundamentals-audit/SKILL.md) | Auditoria só de leitura dos 5 fundamentos (testes de integração, confiança no cliente, race conditions, idempotência, separação), gerando `AUDIT.md`. |
| 49 | Fundamentos de Engenharia & Segurança | [`idempotency-fix`](skills/idempotency-fix/SKILL.md) | Webhooks e pagamentos com efeito único por evento via verificação de assinatura, tabela de eventos processados e chave de idempotência. |
| 50 | Fundamentos de Engenharia & Segurança | [`integration-tests`](skills/integration-tests/SKILL.md) | Testes de integração de rota contra banco real a partir de frases de comportamento aprovadas e regra de ouro de nunca enfraquecer testes. |
| 51 | Fundamentos de Engenharia & Segurança | [`layered-refactor`](skills/layered-refactor/SKILL.md) | Decomposição incremental de ficheiros monolíticos (UI + regras + dados) em camadas separadas com testes de caracterização a cada passo. |
| 52 | Fundamentos de Engenharia & Segurança | [`never-trust-the-client`](skills/never-trust-the-client/SKILL.md) | Migração de regras de negócio, preços, permissões e segredos do cliente para o servidor e revisão de políticas de acesso (RLS). |
| 53 | Fundamentos de Engenharia & Segurança | [`race-condition-fix`](skills/race-condition-fix/SKILL.md) | Correção de *read-decide-write* no banco (`UNIQUE`, update atómico, row lock) comprovada por testes de requisições simultâneas. |
| 54 | Fundamentos de Engenharia & Segurança | [`security-audit`](skills/security-audit/SKILL.md) | Auditoria de segurança só de leitura: isolamento de tenant, autorização client-side, IDOR, segredos no histórico git e XSS. |
| 55 | Bancos de Dados & Governança | [`backup-restore-drill`](skills/backup-restore-drill/SKILL.md) | Rotina de backup diário off-server com retenção, teste real de restauração comparando contagens de linhas e runbook de desastre. |
| 56 | Bancos de Dados & Governança | [`database-audit`](skills/database-audit/SKILL.md) | Auditoria só de leitura em 7 frentes de banco de dados (exposição, backups, custo, transações, esquema, migrations, performance) em `DB-AUDIT.md`. |
| 57 | Bancos de Dados & Governança | [`database-cost-guard`](skills/database-cost-guard/SKILL.md) | Contenção de custos em bancos cobrados por leitura/escrita: detecção de `N+1`, listeners, paginação por offset, projeção 10x e limites de gasto. |
| 58 | Bancos de Dados & Governança | [`database-exposure`](skills/database-exposure/SKILL.md) | Verificação de portas abertas, credenciais vazadas (incluindo git), exposição de API pública e políticas permissivas (RLS/Firebase/grants). |
| 59 | Bancos de Dados & Governança | [`migrations-and-environments`](skills/migrations-and-environments/SKILL.md) | Migrations numeradas em controlo de versão com *baseline*, checagem de *drift*, isolamento dev/prod e utilizador de privilégio mínimo. |
| 60 | Bancos de Dados & Governança | [`query-performance`](skills/query-performance/SKILL.md) | Otimização de queries lentas com `EXPLAIN ANALYZE`, índices em FKs, remoção de `N+1` e paginação por cursor com medição antes/depois. |
| 61 | Bancos de Dados & Governança | [`schema-and-constraints`](skills/schema-and-constraints/SKILL.md) | Integridade no próprio esquema: dinheiro exato, `timestamptz`, FKs, `NOT NULL`, `UNIQUE`, `CHECK` e contagem de violações prévias à migração. |
| 62 | Bancos de Dados & Governança | [`transaction-fix`](skills/transaction-fix/SKILL.md) | Envolvimento de escritas multi-tabela em transações ACID tudo-ou-nada, mantendo chamadas externas fora da transação e testando falhas forçadas. |
| 63 | Diagnósticos de Motores SQL | [`postgres-diagnostics`](skills/postgres-diagnostics/SKILL.md) | 31 scripts só de leitura para PostgreSQL 16, 17 e 18 (bloat, wraparound, locks, `pg_stat_statements`, WAL, replicação, índices). |
| 64 | Diagnósticos de Motores SQL | [`sql-server-diagnostics`](skills/sql-server-diagnostics/SKILL.md) | 30 scripts só de leitura para SQL Server 2019, 2022 e 2025 (DMVs, wait stats, índices, deadlocks, backups, HA, segurança). |
| 65 | Diagnósticos de Motores SQL | [`sqlite-diagnostics`](skills/sqlite-diagnostics/SKILL.md) | 19 scripts só de leitura para SQLite 3.49 e 3.53 (`integrity_check`, `foreign_key_check`, tamanho, FKs sem índice, `AUTOINCREMENT`). |

---

## Instalação e Validação

### Opção A — Script Python incluído (Windows, macOS ou Linux, biblioteca padrão Python 3.9+)

```bash
# Instalar no projeto atual (./.claude/skills)
python install_skills.py --project .

# Instalar globalmente no utilizador (~/.claude/skills)
python install_skills.py --user

# Instalar em qualquer diretório de skills (ex.: ~/.gemini/config/skills ou .agents/skills)
python install_skills.py --target ~/.gemini/config/skills

# Opções: --dry-run (apenas mostra), --force (atualiza skills existentes que diferem)
```

### Opção B — CLI `npx skills` (seguindo o protocolo de agentes específicos)

```bash
# Global (apenas para Claude Code e Antigravity IDE — nunca usar -a '*')
npx skills add Kitsune-27295/Dev.-DBs-Skills -g -a claude,antigravity --copy -y

# Apenas uma skill específica
npx skills add Kitsune-27295/Dev.-DBs-Skills -g -a claude,antigravity -s 'hexagonal-architecture' --copy -y
```

### Validação de integridade do pacote

```bash
python check_skills.py skills
```

O script `check_skills.py` valida que todas as 65 pastas possuem frontmatter YAML válido (`name` igual à pasta, `description` <= 1024 caracteres), que todos os links Markdown relativos (incluindo `references/sources.md` e scripts `.sql`) existem no disco e que todas as referências cruzadas entre skills estão íntegras.

---

## Estrutura do Repositório

```text
Dev.-DBs-Skills/
├── README.md               # Catálogo completo das 65 skills e guia de instalação
├── NOTICE.md               # Créditos, origens e notas sobre fontes
├── MANIFEST.sha256         # Hashes SHA-256 de todos os ficheiros em skills/
├── install_skills.py       # Instalador idempotente com verificação SHA-256
├── check_skills.py         # Validador estático de frontmatter, links e referências
└── skills/                 # As 65 skills autocontidas
    ├── actor-model-space-based-architecture/
    ├── adr-architecture/
    ├── agent-skills-context-engineering/
    ├── agentic-rag-architecture/
    ├── arc42-api-contracts-architecture/
    ├── architecture-decision-trees-tradeoffs/
    ├── backup-restore-drill/
    ├── bff-pattern/
    ├── c4-model-architecture/
    ├── circuit-breaker-retry-telemetry/
    ├── clean-architecture/
    ├── code-review/
    ├── codebase-design/
    ├── cqrs-pattern/
    ├── database-audit/
    ├── database-cost-guard/
    ├── database-exposure/
    ├── ddd-domain-heuristics-debiasing/
    ├── defensive-domain-modeling/
    ├── diataxis-documentation-architecture/
    ├── event-driven-architecture/
    ├── event-sourcing-pattern/
    ├── fundamentals-audit/
    ├── grill-me/
    ├── grilling/
    ├── hexagonal-architecture/
    ├── idempotency-fix/
    ├── implement/
    ├── integration-tests/
    ├── layered-n-tier-architecture/
    ├── layered-refactor/
    ├── mermaid/
    ├── micro-frontends-architecture/
    ├── microkernel-plugin-architecture/
    ├── microservices-architecture/
    ├── migrations-and-environments/
    ├── modular-monolith-architecture/
    ├── monolithic-architecture/
    ├── mvc-architecture/
    ├── never-trust-the-client/
    ├── package-by-feature-component/
    ├── parallel-change-expand-contract/
    ├── pipes-and-filters-pattern/
    ├── postgres-diagnostics/
    ├── pragmatic-solid-and-ssot/
    ├── query-performance/
    ├── race-condition-fix/
    ├── repository-root-monorepo-architecture/
    ├── saga-transactional-outbox-pattern/
    ├── schema-and-constraints/
    ├── screaming-architecture/
    ├── security-audit/
    ├── serverless-architecture/
    ├── setup-matt-pocock-skills/
    ├── soa-vs-microservices-architecture/
    ├── sql-server-diagnostics/
    ├── sqlite-diagnostics/
    ├── tdd/
    ├── testing-pyramid-and-shapes/
    ├── to-spec/
    ├── to-tickets/
    ├── transaction-fix/
    ├── twelve-factor-cloud-native/
    ├── vertical-slice-architecture/
    └── yagni-evolutionary-architecture/
```
