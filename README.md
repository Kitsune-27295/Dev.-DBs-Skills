# Dev.-DBs-Skills

Catálogo unificado de **84 Agent Skills** portáteis ([`agentskills.io`](https://agentskills.io)) para **Claude Code**, **Antigravity IDE**, **Codex CLI**, **Cursor**, **VS Code** e **Windsurf**, utilizáveis e instaláveis via **servidor MCP (*stdio*)** ou **CLI Python / `npx skills`**.

---

## O que este projeto faz

Reúne num único pacote verificável **84 skills autocontidas** cobrindo todo o ciclo de engenharia de software e dados:

- **Arquitetura & Design de Software (27 skills):** estilos arquiteturais (Hexagonal, Clean, Layered, Modular Monolith, Microservices, EDA, CQRS, Event Sourcing, Vertical Slice, BFF, Micro-Frontends, Microkernel, Actor Model/Space-Based), DDD estratégico, SSOT/SOLID pragmático, modelagem defensiva e módulos profundos.
- **Componentes de Software (12 skills):** Router/Front Controller, API Gateway/Reverse Proxy, Middleware, Cache, Background Worker, Rate Limiter, AuthN/AuthZ, Repository/Unit of Work, DTO/Mapper/ACL, Validator, Feature Flags, State Machine.
- **Princípios & Conceitos Fundamentais (7 skills):** aprofundamentos de SSOT/DRY, OCP, SRP, DIP/Composition Root, KISS/YAGNI/AHA, Value Objects e Problem Details/Result.
- **Cloud-Native, Resiliência, Evolução & IA (7 skills):** 12/15-Factor, Circuit Breaker/Retry/OpenTelemetry, Expand–Contract zero-downtime, YAGNI evolutivo, pirâmides/troféus de testes, Agentic RAG e Context/Harness Engineering.
- **Documentação, Diagramas & Contratos (5 skills):** ADRs, arc42 + OpenAPI/AsyncAPI, C4 Model, Diátaxis e Mermaid.
- **Workflow de Engenharia — Matt Pocock Pack (8 skills):** fluxo ponta a ponta (`setup-matt-pocock-skills` → `grill-me` / `grilling` → `to-spec` → `to-tickets` → `implement` + `tdd` → `code-review`), com invocação autónoma pelo modelo liberada para execuções completas de ponta a ponta.
- **Fundamentos de Engenharia & Segurança (7 skills):** auditoria geral, proteção anti-client-trust, *race conditions*, idempotência, refatoração incremental em camadas, testes de integração com DB real e auditoria de segurança.
- **Bancos de Dados & Governança (8 skills):** auditoria em 7 frentes, exposição e RLS, *backup & restore drill*, controlo de custos, transações ACID, *constraints* de esquema, *migrations* e performance (`EXPLAIN ANALYZE`).
- **Diagnósticos de Motores SQL em Produção (3 skills):** 80 scripts só de leitura para PostgreSQL (16–18), SQL Server (2019–2025) e SQLite (3.49–3.53).

## Por que usar este repositório

- **Zero dependências externas em runtime:** tanto o servidor MCP em Node.js ESM ([bin/mcp-server.mjs](bin/mcp-server.mjs)) como os scripts CLI ([install_skills.py](install_skills.py) e [check_skills.py](check_skills.py)) usam exclusivamente bibliotecas padrão.
- **Dupla via de consumo (MCP + instalação local):** carregue instruções sob demanda via *progressive disclosure* (`skill://index.json`, `get_skill`) sem poluir o contexto com as 84 skills de uma vez, ou instale uma seleção exata no workspace/máquina.
- **Integridade verificada por SHA-256 e validação estática:** cada ficheiro em `skills/` possui hash registado em [MANIFEST.sha256](MANIFEST.sha256) e passa por validação de frontmatter, links relativos e referências cruzadas.
- **Portabilidade multi-agente:** funciona com `.claude/skills`, `.agents/skills` (Antigravity), `.codex/skills`, `.cursor/skills` e diretórios globais (`~/.claude/skills`, `~/.gemini/config/skills`).

---

## Início Rápido (Getting Started)

> **Pré-requisitos:** **Node.js >= 18** para o servidor MCP (ou `npx skills`), e/ou **Python 3.9+** para os scripts locais.

### 1. Ligar via MCP direto do GitHub (sem clonar)

**Claude Code:**

```bash
claude mcp add dev-dbs-skills -- npx -y github:Kitsune-27295/Dev.-DBs-Skills
```

**Codex CLI:**

```bash
codex mcp add dev-dbs-skills -- npx -y github:Kitsune-27295/Dev.-DBs-Skills
```

**Antigravity IDE (`mcp_config.json`), Cursor, Windsurf ou Claude Desktop:**

```json
{
  "mcpServers": {
    "dev-dbs-skills": {
      "command": "npx",
      "args": ["-y", "github:Kitsune-27295/Dev.-DBs-Skills"]
    }
  }
}
```

**VS Code (`.vscode/mcp.json`):**

```json
{
  "servers": {
    "dev-dbs-skills": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "github:Kitsune-27295/Dev.-DBs-Skills"]
    }
  }
}
```

**Execução MCP a partir de um clone local:**

```json
{
  "mcpServers": {
    "dev-dbs-skills": {
      "command": "node",
      "args": ["/caminho/para/Dev.-DBs-Skills/bin/mcp-server.mjs"]
    }
  }
}
```

Depois de ligado, basta pedir ao agente no chat:
- *"Lista ou pesquisa skills de arquitetura/SQL neste MCP e aplica `hexagonal-architecture`."*
- *"Usa `install_skills` para instalar `grill-me`, `to-spec` e `tdd` neste projeto para o Antigravity/Claude."*

### 2. Instalar via CLI sem servidor MCP

**Script Python incluído ([install_skills.py](install_skills.py)):**

```bash
# Instalar todas as 84 skills no projeto atual (./.claude/skills)
python install_skills.py --project .

# Instalar globalmente no utilizador (~/.claude/skills)
python install_skills.py --user

# Instalar num diretório específico (ex.: Antigravity global ou .agents/skills do projeto)
python install_skills.py --target ~/.gemini/config/skills

# Pré-visualizar ou sobrescrever skills modificadas
python install_skills.py --target ~/.gemini/config/skills --dry-run
python install_skills.py --target ~/.gemini/config/skills --force
```

**CLI `npx skills` (alvo explícito de agentes):**

```bash
# Global apenas para Claude Code e Antigravity IDE (evite -a '*')
npx skills add Kitsune-27295/Dev.-DBs-Skills -g -a claude,antigravity --copy -y

# Apenas uma skill específica
npx skills add Kitsune-27295/Dev.-DBs-Skills -g -a claude,antigravity -s 'hexagonal-architecture' --copy -y
```

---

## Como o Servidor MCP Funciona

Implementado em [src/mcp-core.mjs](src/mcp-core.mjs) e exposto em [bin/mcp-server.mjs](bin/mcp-server.mjs) (compatível com MCP `2024-11-05`, `2025-03-26` e `2025-06-18`):

| Superfície MCP | Identificadores | O que faz |
|---|---|---|
| **Tools — Descoberta & Uso** | `list_skills`, `search_skills`, `get_skill`, `read_skill_file` | Lista/pesquisa as 84 skills, lê `SKILL.md` sob demanda (com `include_references` opcional) e acede a `references/sources.md`, templates e scripts `.sql` com proteção contra *path traversal*. |
| **Tools — Instalação & Auditoria** | `install_skills`, `check_installed_skills` | Copia 1, várias ou todas (`["*"]`) as skills para `claude`, `antigravity`, `agents`, `codex`, `cursor` ou `target_dir`, verifica hashes SHA-256 em [MANIFEST.sha256](MANIFEST.sha256) e valida links/frontmatter. |
| **Resources** | `skill://index.json`, `skill://{name}/{+path}` | Expõe o catálogo JSON completo e qualquer ficheiro interno via URI `skill://`. |
| **Prompts** | Todas as 84 skills em `prompts/list` / `prompts/get` | Permite invocar qualquer skill como *prompt*/*slash* do cliente MCP com argumento opcional `context`. |

---

## Catálogo Completo (84 Skills)

Use o menu **Outline** do GitHub para saltar diretamente entre secções, ou pesquise pelo nome exato abaixo.

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
| 41 | Workflow de Engenharia (Matt Pocock) | [`grill-me`](skills/grill-me/SKILL.md) | Ponto de entrada (utilizador ou agente) para iniciar uma entrevista exaustiva de árvore de decisão via `grilling`. |
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
| 66 | Componentes de Software | [`router-front-controller-routing`](skills/router-front-controller-routing/SKILL.md) | Roteamento HTTP, de mensagens e de UI: *Front Controller*, *Content-Based Router*, *Gateway Routing* e History API, separando decisão de destino de preocupações transversais. |
| 67 | Componentes de Software | [`api-gateway-reverse-proxy`](skills/api-gateway-reverse-proxy/SKILL.md) | Ponto de entrada de borda com semântica de intermediários HTTP (RFC 9110), *offloading* e *aggregation*, e fronteira com o BFF. |
| 68 | Componentes de Software | [`middleware-interceptor-chain`](skills/middleware-interceptor-chain/SKILL.md) | *Chain of Responsibility*, filtros de mensagem e ordem do *pipeline* de middleware para preocupações transversais. |
| 69 | Componentes de Software | [`caching-strategies`](skills/caching-strategies/SKILL.md) | *Cache-Aside*, *write-through/behind*, invalidação, TTL, *cache stampede* e semântica de cache HTTP (RFC 9111/5861). |
| 70 | Componentes de Software | [`background-worker-job-scheduler`](skills/background-worker-job-scheduler/SKILL.md) | Jobs em segundo plano, *Competing Consumers*, *Leader Election*, agendamento e execução idempotente. |
| 71 | Componentes de Software | [`rate-limiter-throttler`](skills/rate-limiter-throttler/SKILL.md) | *Throttling* e *rate limiting* (token bucket, janelas, *load shedding*) segundo Azure e Stripe. |
| 72 | Componentes de Software | [`authn-authz-guard`](skills/authn-authz-guard/SKILL.md) | Autenticação, sessões, OAuth 2.0 (RFC 6749) e Security BCP (RFC 9700), RBAC/ABAC e decisões de autorização (OWASP). |
| 73 | Componentes de Software | [`repository-unit-of-work`](skills/repository-unit-of-work/SKILL.md) | *Repository* e *Unit of Work*: abstração de persistência, agregados e escopo transacional. |
| 74 | Componentes de Software | [`dto-mapper-anti-corruption-layer`](skills/dto-mapper-anti-corruption-layer/SKILL.md) | *DTO*, *Mapper* e *Anti-Corruption Layer* para formas de dados em fronteiras e tradução entre modelos/contextos. |
| 75 | Componentes de Software | [`validator-input-parser`](skills/validator-input-parser/SKILL.md) | Validação/*parsing* de entrada em fronteiras de confiança (OWASP), *allowlist* e *Notification Pattern* para coletar erros. |
| 76 | Componentes de Software | [`feature-flag-toggle-engine`](skills/feature-flag-toggle-engine/SKILL.md) | Taxonomia de *feature toggles*, ciclo de vida e dívida, pontos de decisão e API OpenFeature. |
| 77 | Componentes de Software | [`state-machine-workflow-engine`](skills/state-machine-workflow-engine/SKILL.md) | Padrão *State*, máquinas de estados finitos e *statecharts* (hierarquia, guardas, ações) com modelagem Stately/XState. |
| 78 | Princípios & Conceitos Fundamentais | [`ssot-and-dry`](skills/ssot-and-dry/SKILL.md) | Aprofundamento: DRY como conhecimento único (SSOT), duplicação inadvertida/imposta e limites por *Bounded Context*. |
| 79 | Princípios & Conceitos Fundamentais | [`open-closed-principle`](skills/open-closed-principle/SKILL.md) | Aprofundamento: OCP e *Strategy* como mecanismo de extensão sem modificar política estável. |
| 80 | Princípios & Conceitos Fundamentais | [`single-responsibility-cohesion`](skills/single-responsibility-cohesion/SKILL.md) | Aprofundamento: SRP como coesão por ator/eixo de mudança e *Common Closure Principle*. |
| 81 | Princípios & Conceitos Fundamentais | [`dependency-inversion-composition-root`](skills/dependency-inversion-composition-root/SKILL.md) | Aprofundamento: DIP, formas de injeção de dependência, *Composition Root* e *Service Locator* como anti-padrão. |
| 82 | Princípios & Conceitos Fundamentais | [`kiss-yagni-aha`](skills/kiss-yagni-aha/SKILL.md) | Aprofundamento: KISS, YAGNI, *Rule of Three*, *Wrong Abstraction* e AHA como procedimento de decisão no código. |
| 83 | Princípios & Conceitos Fundamentais | [`value-objects-type-invariants`](skills/value-objects-type-invariants/SKILL.md) | Aprofundamento: *Value Objects*, *Money*/alocação e arredondamento, e estados modelados como tipos. |
| 84 | Princípios & Conceitos Fundamentais | [`error-handling-problem-details`](skills/error-handling-problem-details/SKILL.md) | Taxonomia de erros, contrato HTTP RFC 9457 (*Problem Details*), *Result*/ROP e tratamento seguro de erros (OWASP). |

---

> **Referências aprofundadas:** cada skill traz, além de `references/sources.md`, ficheiros `references/*.md` com análise detalhada das fontes (lidas em 2026-11-23); páginas não lidas estão assinaladas nos próprios ficheiros.

## Validação e Testes

Execute antes de abrir *pull requests* ou após sincronizar atualizações:

```bash
# 1. Validar frontmatter YAML, links relativos e referências cruzadas das 84 skills
python check_skills.py skills

# 2. Executar a suíte de testes do servidor MCP (handshake, tools, resources, prompts, SHA-256, stdio)
node --test test/mcp-server.test.mjs
```

> Em Windows PowerShell com política restrita para scripts `.ps1`, use `node --test test/mcp-server.test.mjs`, `npm.cmd test` ou `npx.cmd -y github:Kitsune-27295/Dev.-DBs-Skills`.

---

## Estrutura do Repositório

```text
Dev.-DBs-Skills/
├── README.md               # Documentação principal, catálogo e guia MCP/CLI
├── NOTICE.md               # Créditos, licenças upstream e notas sobre fontes
├── MANIFEST.sha256         # Hashes SHA-256 de todos os ficheiros em skills/
├── package.json            # Empacotamento Node ESM (npx -y github:Kitsune-27295/Dev.-DBs-Skills)
├── .gitattributes          # Finais LF garantidos para binários e scripts
├── bin/
│   └── mcp-server.mjs      # Entrada stdio JSON-RPC 2.0 do servidor MCP
├── src/
│   └── mcp-core.mjs        # Catálogo, pesquisa, instalação SHA-256, validação e handlers MCP
├── test/
│   └── mcp-server.test.mjs # Testes automatizados do servidor MCP (node --test)
├── install_skills.py       # Instalador idempotente Python com verificação SHA-256
├── check_skills.py         # Validador estático de frontmatter, links e referências
└── skills/                 # As 84 skills autocontidas
    ├── actor-model-space-based-architecture/
    ├── adr-architecture/
    ├── agent-skills-context-engineering/
    ├── agentic-rag-architecture/
    ├── api-gateway-reverse-proxy/
    ├── arc42-api-contracts-architecture/
    ├── architecture-decision-trees-tradeoffs/
    ├── authn-authz-guard/
    ├── background-worker-job-scheduler/
    ├── backup-restore-drill/
    ├── bff-pattern/
    ├── c4-model-architecture/
    ├── caching-strategies/
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
    ├── dependency-inversion-composition-root/
    ├── diataxis-documentation-architecture/
    ├── dto-mapper-anti-corruption-layer/
    ├── error-handling-problem-details/
    ├── event-driven-architecture/
    ├── event-sourcing-pattern/
    ├── feature-flag-toggle-engine/
    ├── fundamentals-audit/
    ├── grill-me/
    ├── grilling/
    ├── hexagonal-architecture/
    ├── idempotency-fix/
    ├── implement/
    ├── integration-tests/
    ├── kiss-yagni-aha/
    ├── layered-n-tier-architecture/
    ├── layered-refactor/
    ├── mermaid/
    ├── micro-frontends-architecture/
    ├── microkernel-plugin-architecture/
    ├── microservices-architecture/
    ├── middleware-interceptor-chain/
    ├── migrations-and-environments/
    ├── modular-monolith-architecture/
    ├── monolithic-architecture/
    ├── mvc-architecture/
    ├── never-trust-the-client/
    ├── open-closed-principle/
    ├── package-by-feature-component/
    ├── parallel-change-expand-contract/
    ├── pipes-and-filters-pattern/
    ├── postgres-diagnostics/
    ├── pragmatic-solid-and-ssot/
    ├── query-performance/
    ├── race-condition-fix/
    ├── rate-limiter-throttler/
    ├── repository-root-monorepo-architecture/
    ├── repository-unit-of-work/
    ├── router-front-controller-routing/
    ├── saga-transactional-outbox-pattern/
    ├── schema-and-constraints/
    ├── screaming-architecture/
    ├── security-audit/
    ├── serverless-architecture/
    ├── setup-matt-pocock-skills/
    ├── single-responsibility-cohesion/
    ├── soa-vs-microservices-architecture/
    ├── sql-server-diagnostics/
    ├── sqlite-diagnostics/
    ├── ssot-and-dry/
    ├── state-machine-workflow-engine/
    ├── tdd/
    ├── testing-pyramid-and-shapes/
    ├── to-spec/
    ├── to-tickets/
    ├── transaction-fix/
    ├── twelve-factor-cloud-native/
    ├── validator-input-parser/
    ├── value-objects-type-invariants/
    ├── vertical-slice-architecture/
    └── yagni-evolutionary-architecture/
```

---

## Ajuda, Manutenção e Contribuição

- **Ajuda e problemas:** consulte [NOTICE.md](NOTICE.md) e o ficheiro `references/sources.md` dentro de cada skill para fontes primárias, ou abra um registo em [GitHub Issues](https://github.com/Kitsune-27295/Dev.-DBs-Skills/issues).
- **Manutenção e licença:** mantido por [@Kitsune-27295](https://github.com/Kitsune-27295), distribuído sob licença MIT ([package.json](package.json)) e com atribuições detalhadas em [NOTICE.md](NOTICE.md).
- **Como contribuir:** ao adicionar ou alterar qualquer ficheiro em `skills/`, atualize [MANIFEST.sha256](MANIFEST.sha256), o catálogo acima e a lista `PACK` em [check_skills.py](check_skills.py), validando tudo com `python check_skills.py skills` e `node --test test/mcp-server.test.mjs`.
