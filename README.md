# Dev.-DBs-Skills

Catálogo unificado de **127 Agent Skills** portáteis ([`agentskills.io`](https://agentskills.io)) para **Claude Code**, **Antigravity IDE**, **Codex CLI**, **Cursor**, **VS Code** e **Windsurf**, utilizáveis e instaláveis via **servidor MCP (*stdio*)** ou **CLI Python / `npx skills`**.

---

## O que este projeto faz

Reúne num único pacote verificável **127 skills autocontidas** cobrindo todo o ciclo de engenharia de software e dados:

- **Skills pilares (2):** `skill-orchestrator` + `model-effort-routing` formam o protocolo de início de tarefa: a primeira decide quais instruções e skills se aplicam e em que ordem (incluindo regras comportamentais estilo Karpathy para `CLAUDE.md`/`AGENTS.md`), a segunda decide modelo, esforço e delegação, sempre pela solução mais econômica e eficaz.
- **Arquitetura & Design de Software (27 skills):** estilos arquiteturais (Hexagonal, Clean, Layered, Modular Monolith, Microservices, EDA, CQRS, Event Sourcing, Vertical Slice, BFF, Micro-Frontends, Microkernel, Actor Model/Space-Based), DDD estratégico, SSOT/SOLID pragmático, modelagem defensiva e módulos profundos.
- **Componentes de Software (12 skills):** Router/Front Controller, API Gateway/Reverse Proxy, Middleware, Cache, Background Worker, Rate Limiter, AuthN/AuthZ, Repository/Unit of Work, DTO/Mapper/ACL, Validator, Feature Flags, State Machine.
- **Princípios & Conceitos Fundamentais (7 skills):** aprofundamentos de SSOT/DRY, OCP, SRP, DIP/Composition Root, KISS/YAGNI/AHA, Value Objects e Problem Details/Result.
- **Cloud-Native, Resiliência, Evolução & IA (18 skills):** coordenação multiagente, MCP Apps, memória de sessão e higiene de memória, portão de qualidade de texto, relatório de custo de agentes, migração de configuração e diagnóstico Zabbix, orquestração de instruções e skills (CLAUDE.md/AGENTS.md, roteamento), roteamento de modelo e esforço (a opção mais econômica e eficaz), pesquisa profunda na web com citações verificadas, 12/15-Factor, Circuit Breaker/Retry/OpenTelemetry, Expand–Contract zero-downtime, YAGNI evolutivo, pirâmides/troféus de testes, Agentic RAG e Context/Harness Engineering.
- **Documentação, Diagramas & Contratos (5 skills):** ADRs, arc42 + OpenAPI/AsyncAPI, C4 Model, Diátaxis e Mermaid.
- **Workflow de Engenharia — Matt Pocock Pack (20 skills):** triagem, *wayfinder*, retrospectiva, *handoff*, protótipo, modelagem de domínio, guardrails de git, *wizard*, módulos profundos em TS, pre-commit e questionários (12 skills adicionadas do upstream MIT), fluxo ponta a ponta (`setup-matt-pocock-skills` → `grill-me` / `grilling` → `to-spec` → `to-tickets` → `implement` + `tdd` → `code-review`), com invocação autônoma pelo modelo liberada para execuções completas de ponta a ponta.
- **Fundamentos de Engenharia & Segurança (26 skills):** revisão e descrição de PRs, desempenho de aplicações, auditorias de simplificação, acessibilidade (WCAG), testes confiáveis no CI, ameaças e triagem de vulnerabilidades, verificação em ciclo fechado, segurança operacional e pós-mortem sem culpa, auditoria geral, diagnóstico de bugs por loop de feedback (`diagnosing-bugs`), automação de QA com Playwright (ciclo completo com guardrails anti-batota), padrões de escrita de código limpo para agentes, auditoria somente leitura de repositórios open-source externos, commits atômicos e higiene Git, proteção anti-client-trust, *race conditions*, idempotência, refatoração incremental em camadas, testes de integração com DB real e auditoria de segurança.
- **Bancos de Dados & Governança (9 skills):** auditoria de SQL Server, auditoria em 7 frentes, exposição e RLS, *backup & restore drill*, controle de custos, transações ACID, *constraints* de esquema, *migrations* e performance (`EXPLAIN ANALYZE`).
- **Diagnósticos de Motores SQL em Produção (3 skills):** 80 scripts só de leitura para PostgreSQL (16–18), SQL Server (2019–2025) e SQLite (3.49–3.53).

## Por que usar este repositório

- **Zero dependências externas em runtime:** tanto o servidor MCP em Node.js ESM ([bin/mcp-server.mjs](bin/mcp-server.mjs)) como os scripts CLI ([install_skills.py](install_skills.py) e [check_skills.py](check_skills.py)) usam exclusivamente bibliotecas padrão.
- **Dupla via de consumo (MCP + instalação local):** carregue instruções sob demanda via *progressive disclosure* (`skill://index.json`, `get_skill`) sem poluir o contexto com as 127 skills de uma vez, ou instale uma seleção exata no workspace/máquina.
- **Integridade verificada por SHA-256 e validação estática:** cada arquivo em `skills/` possui hash registrado em [MANIFEST.sha256](MANIFEST.sha256) e passa por validação de frontmatter, links relativos e referências cruzadas.
- **Portabilidade multi-agente:** funciona com `.claude/skills`, `.agents/skills` (Antigravity), `.codex/skills`, `.cursor/skills` e diretórios globais (`~/.claude/skills`, `~/.gemini/config/skills`).

---

## Início Rápido (Getting Started)

> **Pré-requisitos:** **Node.js >= 18** para o servidor MCP (ou `npx skills`), e/ou **Python 3.9+** para os scripts locais.

### 1. Conectar via MCP direto do GitHub (sem clonar)

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

Depois de conectado, basta pedir ao agente no chat:
- *"Lista ou pesquisa skills de arquitetura/SQL neste MCP e aplica `hexagonal-architecture`."*
- *"Usa `install_skills` para instalar `grill-me`, `to-spec` e `tdd` neste projeto para o Antigravity/Claude."*

### 2. Instalar via CLI sem servidor MCP

**Script Python incluído ([install_skills.py](install_skills.py)):**

```bash
# Instalar todas as 127 skills no projeto atual (./.claude/skills)
python install_skills.py --project .

# Instalar globalmente no usuário (~/.claude/skills)
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
| **Tools — Descoberta & Uso** | `list_skills`, `search_skills`, `get_skill`, `read_skill_file` | Lista/pesquisa as 127 skills, lê `SKILL.md` sob demanda (com `include_references` opcional) e acede a `references/sources.md`, templates e scripts `.sql` com proteção contra *path traversal*. |
| **Tools — Instalação & Auditoria** | `install_skills`, `check_installed_skills` | Copia 1, várias ou todas (`["*"]`) as skills para `claude`, `antigravity`, `agents`, `codex`, `cursor` ou `target_dir`, verifica hashes SHA-256 em [MANIFEST.sha256](MANIFEST.sha256) e valida links/frontmatter. |
| **Resources** | `skill://index.json`, `skill://{name}/{+path}` | Expõe o catálogo JSON completo e qualquer arquivo interno via URI `skill://`. |
| **Prompts** | Todas as 127 skills em `prompts/list` / `prompts/get` | Permite invocar qualquer skill como *prompt*/*slash* do cliente MCP com argumento opcional `context`. |

---

## Catálogo Completo (127 Skills)

Use o menu **Outline** do GitHub para pular diretamente entre seções, ou pesquise pelo nome exato abaixo.

| # | Categoria | Skill | Descrição (1 linha) |
|---|---|---|---|
| 1 | Arquitetura & Design de Software | [`actor-model-space-based-architecture`](skills/actor-model-space-based-architecture/SKILL.md) | Sistemas concorrentes/distribuídos stateful com Actor Model (Akka, Orleans, Erlang/OTP) e Space-Based Architecture (In-Memory Data Grids). |
| 2 | Arquitetura & Design de Software | [`architecture-decision-trees-tradeoffs`](skills/architecture-decision-trees-tradeoffs/SKILL.md) | Árvores de decisão e trade-offs entre estilos arquiteturais (`-ilities`, Architecture Quantum, Katas) e modelos cloud IaaS/PaaS/FaaS. |
| 3 | Arquitetura & Design de Software | [`bff-pattern`](skills/bff-pattern/SKILL.md) | Edge Backend dedicado por experiência de cliente (Web, Mobile, IoT) alinhado à equipe de frontend e agregando chamadas downstream. |
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
| 20 | Arquitetura & Design de Software | [`pipes-and-filters-pattern`](skills/pipes-and-filters-pattern/SKILL.md) | Workflows sequenciais em filtros *stateless* reutilizáveis conectados por *pipes*, com *backpressure*, idempotência e *poison-message routing*. |
| 21 | Arquitetura & Design de Software | [`pragmatic-solid-and-ssot`](skills/pragmatic-solid-and-ssot/SKILL.md) | DRY como SSOT de conhecimento, limites em *Bounded Context*, SOLID pragmático sem cerimónia de interfaces, *Rule of Three*, *Wrong Abstraction*, AHA e KISS. |
| 22 | Arquitetura & Design de Software | [`repository-root-monorepo-architecture`](skills/repository-root-monorepo-architecture/SKILL.md) | Layout raiz de repositórios, escolha *Monorepo vs. Polyrepo*, convenções Go/TS (`cmd/`, `internal/`, `apps/`, `packages/`) e `CODEOWNERS`. |
| 23 | Arquitetura & Design de Software | [`saga-transactional-outbox-pattern`](skills/saga-transactional-outbox-pattern/SKILL.md) | Transações distribuídas via *Sagas* (Coreografia vs. Orquestração, *Pivot*, compensação) e *Transactional Outbox* + *Inbox* idempotente. |
| 24 | Arquitetura & Design de Software | [`screaming-architecture`](skills/screaming-architecture/SKILL.md) | Diretórios de topo e pacotes que revelam o domínio de negócio e casos de uso em vez do framework ou ORM usado. |
| 25 | Arquitetura & Design de Software | [`serverless-architecture`](skills/serverless-architecture/SKILL.md) | Funções *stateless* (*FaaS*) + serviços geridos (*BaaS*) controlando *cold starts*, *pooling*, idempotência, DLQs e IAM mínimo. |
| 26 | Arquitetura & Design de Software | [`soa-vs-microservices-architecture`](skills/soa-vs-microservices-architecture/SKILL.md) | Comparação estrutural e regras de migração entre SOA corporativo (ESB, dados partilhados) e Microsserviços (*smart endpoints, dumb pipes*). |
| 27 | Arquitetura & Design de Software | [`vertical-slice-architecture`](skills/vertical-slice-architecture/SKILL.md) | Código organizado por fatia de requisição/funcionalidade (*REPR*/MediatR), eliminando camadas pass-through e respeitando o eixo de acoplamento. |
| 28 | Cloud-Native, Resiliência & IA | [`agent-skills-context-engineering`](skills/agent-skills-context-engineering/SKILL.md) | Especificação aberta `agentskills.io`, *progressive disclosure* em runtime, *Context Engineering* e controles *Feedforward/Feedback* de *Harness*. |
| 29 | Cloud-Native, Resiliência & IA | [`agentic-rag-architecture`](skills/agentic-rag-architecture/SKILL.md) | Escolha do nível mínimo de complexidade em sistemas de IA (Direct Call, Workflow, Single/Multi-Agent), *tool contracts* (ACI), RAG híbrido e avaliação. |
| 30 | Cloud-Native, Resiliência & IA | [`circuit-breaker-retry-telemetry`](skills/circuit-breaker-retry-telemetry/SKILL.md) | *Circuit Breaker* (*Closed/Open/Half-Open*), *exponential backoff* com *jitter*, *Bulkhead*, *Fallback* e observabilidade unificada OpenTelemetry. |
| 31 | Cloud-Native, Resiliência & IA | [`parallel-change-expand-contract`](skills/parallel-change-expand-contract/SKILL.md) | Migrações de esquema e contratos sem *downtime* em produção por meio das três fases discretas: *Expand*, *Transition* e *Contract*. |
| 32 | Cloud-Native, Resiliência & IA | [`testing-pyramid-and-shapes`](skills/testing-pyramid-and-shapes/SKILL.md) | Estratégia de testes automatizados comparando *Test Pyramid*, *Testing Trophy* e *Testing Honeycomb* com rácios, contratos e anti-padrões. |
| 33 | Cloud-Native, Resiliência & IA | [`twelve-factor-cloud-native`](skills/twelve-factor-cloud-native/SKILL.md) | Metodologia 12-Factor e extensões modernas 15-Factor (API-first, telemetria, zero-trust) para cargas portáteis e *stateless* em nuvem/containers. |
| 34 | Cloud-Native, Resiliência & IA | [`yagni-evolutionary-architecture`](skills/yagni-evolutionary-architecture/SKILL.md) | Prevenção de *overengineering*: modelo dos 4 custos do YAGNI, *Is Design Dead?*, *Design Stamina Hypothesis* e *Sacrificial Architecture*. |
| 35 | Documentação, Diagramas & Contratos | [`adr-architecture`](skills/adr-architecture/SKILL.md) | Registro imutável de decisões arquiteturais significativas (Nygard, MADR, Y-Statements) com alternativas, trade-offs e *superseding* em Git. |
| 36 | Documentação, Diagramas & Contratos | [`arc42-api-contracts-architecture`](skills/arc42-api-contracts-architecture/SKILL.md) | Documentação arquitetural nas 12 seções do template *arc42* integrada com contratos *contract-first* em OpenAPI 3.x e AsyncAPI 3.x. |
| 37 | Documentação, Diagramas & Contratos | [`c4-model-architecture`](skills/c4-model-architecture/SKILL.md) | Diagramação hierárquica C4 (*System Context*, *Container*, *Component*, *Code* + *Deployment/Dynamic*) com checklist de notação e Mermaid/Structurizr. |
| 38 | Documentação, Diagramas & Contratos | [`diataxis-documentation-architecture`](skills/diataxis-documentation-architecture/SKILL.md) | Organização de documentação técnica nos 4 quadrantes *Diátaxis* (*Tutorials*, *How-to Guides*, *Reference*, *Explanation*) sem contaminação cruzada. |
| 39 | Documentação, Diagramas & Contratos | [`mermaid`](skills/mermaid/SKILL.md) | Engenharia de diagramas Mermaid como código (*flowchart*, *sequence*, *ER*, *state*, *class*, C4, `architecture-beta`), portabilidade GitHub/ELK e validação via `mmdc`. |
| 40 | Workflow de Engenharia (Matt Pocock) | [`code-review`](skills/code-review/SKILL.md) | Revisão em sub-agentes frescos em paralelo por dois eixos separados (*Standards* + 12 smells de Fowler + guardrails do pack vs. *Spec*). |
| 41 | Workflow de Engenharia (Matt Pocock) | [`grill-me`](skills/grill-me/SKILL.md) | Ponto de entrada (usuário ou agente) para iniciar uma entrevista exaustiva de árvore de decisão via `grilling`. |
| 42 | Workflow de Engenharia (Matt Pocock) | [`grilling`](skills/grilling/SKILL.md) | Entrevista implacável por rodadas na fronteira da árvore de decisão (fatos investigados pelo agente em contexto fresco; decisões do usuário). |
| 43 | Workflow de Engenharia (Matt Pocock) | [`implement`](skills/implement/SKILL.md) | Execução guiada de *spec* ou *tickets* aplicando `tdd` em *seams* acordados, modelagem defensiva/segurança e `code-review` antes do commit. |
| 44 | Workflow de Engenharia (Matt Pocock) | [`setup-matt-pocock-skills`](skills/setup-matt-pocock-skills/SKILL.md) | Configuração inicial por repositório de *issue tracker* (GitHub, GitLab, `.scratch/`), vocabulário de triagem e layout `GLOSSARY.md` / `docs/adr/`. |
| 45 | Workflow de Engenharia (Matt Pocock) | [`tdd`](skills/tdd/SKILL.md) | Ciclo *Red → Green* por fatias verticais em *seams* pré-acordados, anti-padrões (*mocking* interno, testes tautológicos) e vocabulário de `codebase-design`. |
| 46 | Workflow de Engenharia (Matt Pocock) | [`to-spec`](skills/to-spec/SKILL.md) | Síntese da conversa atual em especificação estruturada (*Problem*, *Stories*, *Implementation Decisions*, *Testing Seams*, *Out of Scope*) sem re-entrevistar. |
| 47 | Workflow de Engenharia (Matt Pocock) | [`to-tickets`](skills/to-tickets/SKILL.md) | Decomposição em *tracer-bullet* slices verticais com arestas `Blocked by` explícitas e exceção *expand–contract* para refactors transversais. |
| 48 | Fundamentos de Engenharia & Segurança | [`fundamentals-audit`](skills/fundamentals-audit/SKILL.md) | Auditoria só de leitura dos 5 fundamentos (testes de integração, confiança no cliente, race conditions, idempotência, separação), gerando `AUDIT.md`. |
| 49 | Fundamentos de Engenharia & Segurança | [`idempotency-fix`](skills/idempotency-fix/SKILL.md) | Webhooks e pagamentos com efeito único por evento via verificação de assinatura, tabela de eventos processados e chave de idempotência. |
| 50 | Fundamentos de Engenharia & Segurança | [`integration-tests`](skills/integration-tests/SKILL.md) | Testes de integração de rota contra banco real a partir de frases de comportamento aprovadas e regra de ouro de nunca enfraquecer testes. |
| 51 | Fundamentos de Engenharia & Segurança | [`layered-refactor`](skills/layered-refactor/SKILL.md) | Decomposição incremental de arquivos monolíticos (UI + regras + dados) em camadas separadas com testes de caracterização a cada passo. |
| 52 | Fundamentos de Engenharia & Segurança | [`never-trust-the-client`](skills/never-trust-the-client/SKILL.md) | Migração de regras de negócio, preços, permissões e segredos do cliente para o servidor e revisão de políticas de acesso (RLS). |
| 53 | Fundamentos de Engenharia & Segurança | [`race-condition-fix`](skills/race-condition-fix/SKILL.md) | Correção de *read-decide-write* no banco (`UNIQUE`, update atômico, row lock) comprovada por testes de requisições simultâneas. |
| 54 | Fundamentos de Engenharia & Segurança | [`security-audit`](skills/security-audit/SKILL.md) | Auditoria de segurança só de leitura: isolamento de tenant, autorização client-side, IDOR, segredos no histórico git e XSS. |
| 55 | Bancos de Dados & Governança | [`backup-restore-drill`](skills/backup-restore-drill/SKILL.md) | Rotina de backup diário off-server com retenção, teste real de restauração comparando contagens de linhas e runbook de desastre. |
| 56 | Bancos de Dados & Governança | [`database-audit`](skills/database-audit/SKILL.md) | Auditoria só de leitura em 7 frentes de banco de dados (exposição, backups, custo, transações, esquema, migrations, performance) em `DB-AUDIT.md`. |
| 57 | Bancos de Dados & Governança | [`database-cost-guard`](skills/database-cost-guard/SKILL.md) | Contenção de custos em bancos cobrados por leitura/escrita: detecção de `N+1`, listeners, paginação por offset, projeção 10x e limites de gasto. |
| 58 | Bancos de Dados & Governança | [`database-exposure`](skills/database-exposure/SKILL.md) | Verificação de portas abertas, credenciais vazadas (incluindo git), exposição de API pública e políticas permissivas (RLS/Firebase/grants). |
| 59 | Bancos de Dados & Governança | [`migrations-and-environments`](skills/migrations-and-environments/SKILL.md) | Migrations numeradas em controle de versão com *baseline*, checagem de *drift*, isolamento dev/prod e usuário de privilégio mínimo. |
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
| 85 | Fundamentos de Engenharia & Segurança | [`git-atomic-commits`](skills/git-atomic-commits/SKILL.md) | Commits atômicos, Conventional Commits/SemVer, mensagens, `git add -p`, reescrita segura de histórico, `--force-with-lease` e higiene de segredos. |
| 86 | Cloud-Native, Resiliência, Evolução & IA | [`model-effort-routing`](skills/model-effort-routing/SKILL.md) | **Skill-chave de custo/eficácia:** escolhe o tier de modelo e o esforço de raciocínio certos por tarefa (sem modelo caro para tarefa simples nem esforço curto para tarefa crítica), delega a subagentes, escala/faz *fallback* com verificação e busca a solução mais econômica em tokens que resolve o problema (Claude Code, Antigravity e outros). |
| 87 | Fundamentos de Engenharia & Segurança | [`oss-deep-audit`](skills/oss-deep-audit/SKILL.md) | Auditoria *read-only* de repositórios open-source externos antes de adotar/integrar: reconhecimento e saúde, arquitetura e fluxo, dependências e cadeia de suprimentos, separando Observações, Inferências e Lacunas (disciplina REA), com veredito baseado em evidência. |
| 88 | Cloud-Native, Resiliência, Evolução & IA | [`deep-web-research`](skills/deep-web-research/SKILL.md) | Pesquisa profunda na web em ondas, com orçamento por modo de profundidade, subagentes paralelos, registro de afirmações, validação de citações, níveis de confiança e contrato de ferramentas com *fallback* (Firecrawl → WebSearch/WebFetch → curl). |
| 89 | Fundamentos de Engenharia & Segurança | [`playwright-qa-orchestrator`](skills/playwright-qa-orchestrator/SKILL.md) | Ciclo contínuo de QA com Playwright (descoberta, plano, implementação, execução direcionada, análise de falhas e recuperação controlada), com modos Plan/Test/Test & Fix, guardrails anti-batota e adaptadores por stack. |
| 90 | Fundamentos de Engenharia & Segurança | [`clean-code-for-agents`](skills/clean-code-for-agents/SKILL.md) | Regras de escrita e autorrevisão de código para agentes (simplicidade, nomes, funções, comentários estritamente necessários, código morto), com registro canônico de regras e contramedidas aos vieses dos LLMs. |
| 91 | Cloud-Native, Resiliência, Evolução & IA | [`skill-orchestrator`](skills/skill-orchestrator/SKILL.md) | **Pilar (com `model-effort-routing`):** governa arquivos de instrução (`CLAUDE.md`/`AGENTS.md`, regras estilo Karpathy), decide quais skills se aplicam e em que ordem (descoberta barata, processo antes de implementação) e separa o que é conselho do que exige *hooks*/permissões. |
| 92 | Fundamentos de Engenharia & Segurança | [`diagnosing-bugs`](skills/diagnosing-bugs/SKILL.md) | Diagnóstico de bugs difíceis e regressões de desempenho: loop de feedback vermelho primeiro, reprodução mínima, hipóteses falsificáveis, instrumentação marcada e teste de regressão no *seam* correto (MIT, Matt Pocock). |
| 93 | Fundamentos de Engenharia & Segurança | [`verification-loop`](skills/verification-loop/SKILL.md) | Verificação em ciclo fechado: critérios `AC-n` falsificáveis, registro de evidência por comando, verificador independente, vias por risco, tetos de tentativas e estados finais (Implemented, Validated, Partially validated, Blocked). |
| 94 | Fundamentos de Engenharia & Segurança | [`a11y-audit`](skills/a11y-audit/SKILL.md) | Audita acessibilidade de página ou app web com evidências, mapeada para WCAG 2.2 A/AA: árvore de acessibilidade, teclado e foco, contraste, alvos, zoom, formulários, axe-core e Lighthouse, declarando o que a automação não cobre. |
| 95 | Fundamentos de Engenharia & Segurança | [`ci-test-reliability`](skills/ci-test-reliability/SKILL.md) | Testes confiáveis no CI: topologia de execução, alocação atômica de portas e diretórios, estado global, tempo e rede, esperas por estado, teardown, diferenças Windows/POSIX, retries como diagnóstico, quarentena e correções que só mascaram flakiness. |
| 96 | Fundamentos de Engenharia & Segurança | [`cross-layer-value-trace`](skills/cross-layer-value-trace/SKILL.md) | Rastreia um valor errado, ausente ou desatualizado da fonte de verdade até a tela, salto a salto, com quatro perguntas por salto (valor, ausência, frescor, falha), e entrega o conserto à skill certa. |
| 97 | Fundamentos de Engenharia & Segurança | [`threat-modeling`](skills/threat-modeling/SKILL.md) | Modelo de ameaças leve: DFD, fronteiras de confiança, STRIDE/LINDDUN, mitigação, validação e manutenção contínua. |
| 98 | Fundamentos de Engenharia & Segurança | [`vulnerability-triage`](skills/vulnerability-triage/SKILL.md) | Triagem de achados de segurança: reproduzir ou rejeitar, alcançabilidade, CVSS × SSVC × matriz de risco, veredito, roteamento e noções de divulgação. |
| 99 | Bancos de Dados & Governança | [`sql-server-audit`](skills/sql-server-audit/SKILL.md) | Método para auditar instância ou banco SQL Server: evidência antes de opinião, somente leitura, severidade e confiança por achado, mitos desmentidos e relatório priorizado com correções apenas propostas. |
| 100 | Cloud-Native, Resiliência, Evolução & IA | [`agent-session-memory`](skills/agent-session-memory/SKILL.md) | Memória durável entre sessões para agentes de código: quatro canais curtos e limitados, balanço final em 3 linhas e *handoff* de uso único com registro *append-only*. |
| 101 | Cloud-Native, Resiliência, Evolução & IA | [`memory-hygiene`](skills/memory-hygiene/SKILL.md) | Varredura de confiança da memória do agente: classifica afirmações, verifica contra o ambiente real, carimba `last_verified` e `confidence` e propõe arquivar ou substituir, nunca apagar. |
| 102 | Workflow de Engenharia (Matt Pocock) | [`triage`](skills/triage/SKILL.md) | Move issues e PRs por uma máquina de estados de triagem, verifica, questiona e escreve briefs prontos para agentes (MIT, Matt Pocock). |
| 103 | Workflow de Engenharia (Matt Pocock) | [`wayfinder`](skills/wayfinder/SKILL.md) | Planeja trabalho grande como mapa de tickets de decisão no tracker e os resolve um a um (MIT, Matt Pocock). |
| 104 | Workflow de Engenharia (Matt Pocock) | [`retro`](skills/retro/SKILL.md) | Retrospectiva de uma sessão de código com propostas de melhoria do ambiente do agente (MIT, Matt Pocock). |
| 105 | Workflow de Engenharia (Matt Pocock) | [`handoff`](skills/handoff/SKILL.md) | Compacta a conversa num documento de passagem para outro agente, com variante opcional para a CLI do Claude Code (MIT, Matt Pocock). |
| 106 | Workflow de Engenharia (Matt Pocock) | [`prototype`](skills/prototype/SKILL.md) | Cria um protótipo descartável para responder a uma dúvida de lógica ou de UI (MIT, Matt Pocock). |
| 107 | Workflow de Engenharia (Matt Pocock) | [`domain-modeling`](skills/domain-modeling/SKILL.md) | Constrói o modelo de domínio: glossário, terminologia e ADRs no momento da discussão (MIT, Matt Pocock). |
| 108 | Workflow de Engenharia (Matt Pocock) | [`git-guardrails-claude-code`](skills/git-guardrails-claude-code/SKILL.md) | Hook do Claude Code que bloqueia comandos git perigosos (push, reset --hard, clean), endurecido e com falha fechada (MIT, Matt Pocock). |
| 109 | Workflow de Engenharia (Matt Pocock) | [`wizard`](skills/wizard/SKILL.md) | Gera um script bash interativo que guia o humano por passos manuais (credenciais, segredos de CI), com confirmações e sem expor valores (MIT, Matt Pocock). |
| 110 | Workflow de Engenharia (Matt Pocock) | [`setup-ts-deep-modules`](skills/setup-ts-deep-modules/SKILL.md) | Impõe pacotes TypeScript como módulos profundos via dependency-cruiser (MIT, Matt Pocock). |
| 111 | Workflow de Engenharia (Matt Pocock) | [`setup-pre-commit`](skills/setup-pre-commit/SKILL.md) | Configura Husky, lint-staged e Prettier com typecheck e testes no pre-commit (MIT, Matt Pocock). |
| 112 | Workflow de Engenharia (Matt Pocock) | [`to-questionnaire`](skills/to-questionnaire/SKILL.md) | Transforma uma decisão que você não resolve sozinho num questionário em Markdown para outra pessoa (MIT, Matt Pocock). |
| 113 | Workflow de Engenharia (Matt Pocock) | [`wait-what`](skills/wait-what/SKILL.md) | Pede a re-explicação da última mensagem em linguagem simples e com o glossário do projeto (MIT, Matt Pocock). |
| 114 | Fundamentos de Engenharia & Segurança | [`receiving-code-review`](skills/receiving-code-review/SKILL.md) | Receber code review como autor: verificar cada comentário no código, sem concordância performática, separar bloqueante de opcional, recusar com evidência, agrupar correções e responder a todas as threads. |
| 115 | Fundamentos de Engenharia & Segurança | [`pr-description`](skills/pr-description/SKILL.md) | Escrever a descrição de um pull request: título Conventional Commits, motivação, mudanças de interface × comportamento, evidência de testes, risco e rollback, tamanho e divisão, e linha de divulgação de IA quando exigida. |
| 116 | Fundamentos de Engenharia & Segurança | [`application-performance`](skills/application-performance/SKILL.md) | Torna uma aplicação mais rápida com evidência: define a jornada, mede antes, acha o custo dominante, corrige em passos pequenos e mede de novo (backend, navegador e CI). |
| 117 | Fundamentos de Engenharia & Segurança | [`simplification-audit`](skills/simplification-audit/SKILL.md) | Audita o que pode ser removido ou colapsado (APIs, flags, estados, configuração e testes mortos), exigindo prova de que não há consumidores. |
| 118 | Fundamentos de Engenharia & Segurança | [`ops-safety`](skills/ops-safety/SKILL.md) | Portão antes de ações destrutivas (cartão de recuperabilidade e "sim" explícito, lembrando que convenção não é *enforcement*) e "meça antes de corrigir" para alertas de lentidão ou travamento. |
| 119 | Fundamentos de Engenharia & Segurança | [`incident-analyst-brief`](skills/incident-analyst-brief/SKILL.md) | Como briefar um agente analista em segundo plano durante uma falha inesperada: brief estruturado, busca de lição prévia e regra de que o analista propõe e o líder aplica. |
| 120 | Fundamentos de Engenharia & Segurança | [`blameless-postmortem`](skills/blameless-postmortem/SKILL.md) | Pós-mortem sem culpa: linha do tempo sempre com fonte, causa conhecida × assumida, itens de ação com dono e data, marcadores `[PENDING VALIDATION]` e nenhum segredo copiado de logs. |
| 121 | Fundamentos de Engenharia & Segurança | [`worst-case-data-ui-check`](skills/worst-case-data-ui-check/SKILL.md) | Testa uma tela com dados realistas de pior caso (textos longos, vazio, RTL, 320 px, zoom) via rotas mockadas do Playwright e apenas reporta o que quebra. |
| 122 | Cloud-Native, Resiliência, Evolução & IA | [`multi-agent-coordination`](skills/multi-agent-coordination/SKILL.md) | Coordena vários agentes numa tarefa paralelizável: coordenador que só delega e julga, quadro compartilhado, propriedade de arquivos, monitor de travamento, revisão cruzada, regras de merge e limites de custo. |
| 123 | Cloud-Native, Resiliência, Evolução & IA | [`mcp-apps`](skills/mcp-apps/SKILL.md) | Constrói MCP Apps (UI interativa para ferramentas MCP) só pela especificação pública: recurso `ui://`, iframe com sandbox e CSP, ponte postMessage, segurança, empacotamento, fallback e status do spec. |
| 124 | Cloud-Native, Resiliência, Evolução & IA | [`text-quality-gate`](skills/text-quality-gate/SKILL.md) | Desenha um gate determinístico de qualidade para texto gerado (sinais inequívocos × sinais contados, código de saída, hooks). |
| 125 | Cloud-Native, Resiliência, Evolução & IA | [`agent-cost-report`](skills/agent-cost-report/SKILL.md) | Método mínimo para estimar o custo de sessões de agentes a partir de transcrições, com deduplicação, contabilidade de cache e rótulo ESTIMATED. |
| 126 | Cloud-Native, Resiliência, Evolução & IA | [`agent-config-migration`](skills/agent-config-migration/SKILL.md) | Migra configuração entre agentes de código com plano confirmado, pacote reversível, fontes intocadas e verificação. |
| 127 | Cloud-Native, Resiliência, Evolução & IA | [`zabbix-diagnostics`](skills/zabbix-diagnostics/SKILL.md) | Diagnóstico somente leitura de um Zabbix pela API JSON-RPC, agrupado por causa, com catálogo de métodos e regras de uso seguro. |

---

> **Referências aprofundadas:** cada skill traz, além de `references/sources.md`, arquivos `references/*.md` com análise detalhada das fontes (lidas em 2026-11-23); páginas não lidas estão sinalizadas nos próprios arquivos.

## Validação e Testes

Execute antes de abrir *pull requests* ou após sincronizar atualizações:

```bash
# 1. Validar frontmatter YAML, links relativos e referências cruzadas das 127 skills
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
├── MANIFEST.sha256         # Hashes SHA-256 de todos os arquivos em skills/
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
└── skills/                 # As 127 skills autocontidas
    ├── a11y-audit/
    ├── actor-model-space-based-architecture/
    ├── adr-architecture/
    ├── agent-config-migration/
    ├── agent-cost-report/
    ├── agent-session-memory/
    ├── agent-skills-context-engineering/
    ├── agentic-rag-architecture/
    ├── api-gateway-reverse-proxy/
    ├── application-performance/
    ├── arc42-api-contracts-architecture/
    ├── architecture-decision-trees-tradeoffs/
    ├── authn-authz-guard/
    ├── background-worker-job-scheduler/
    ├── backup-restore-drill/
    ├── bff-pattern/
    ├── blameless-postmortem/
    ├── c4-model-architecture/
    ├── caching-strategies/
    ├── ci-test-reliability/
    ├── circuit-breaker-retry-telemetry/
    ├── clean-architecture/
    ├── clean-code-for-agents/
    ├── code-review/
    ├── codebase-design/
    ├── cqrs-pattern/
    ├── cross-layer-value-trace/
    ├── database-audit/
    ├── database-cost-guard/
    ├── database-exposure/
    ├── ddd-domain-heuristics-debiasing/
    ├── deep-web-research/
    ├── defensive-domain-modeling/
    ├── dependency-inversion-composition-root/
    ├── diagnosing-bugs/
    ├── diataxis-documentation-architecture/
    ├── domain-modeling/
    ├── dto-mapper-anti-corruption-layer/
    ├── error-handling-problem-details/
    ├── event-driven-architecture/
    ├── event-sourcing-pattern/
    ├── feature-flag-toggle-engine/
    ├── fundamentals-audit/
    ├── git-atomic-commits/
    ├── git-guardrails-claude-code/
    ├── grill-me/
    ├── grilling/
    ├── handoff/
    ├── hexagonal-architecture/
    ├── idempotency-fix/
    ├── implement/
    ├── incident-analyst-brief/
    ├── integration-tests/
    ├── kiss-yagni-aha/
    ├── layered-n-tier-architecture/
    ├── layered-refactor/
    ├── mcp-apps/
    ├── memory-hygiene/
    ├── mermaid/
    ├── micro-frontends-architecture/
    ├── microkernel-plugin-architecture/
    ├── microservices-architecture/
    ├── middleware-interceptor-chain/
    ├── migrations-and-environments/
    ├── model-effort-routing/
    ├── modular-monolith-architecture/
    ├── monolithic-architecture/
    ├── multi-agent-coordination/
    ├── mvc-architecture/
    ├── never-trust-the-client/
    ├── open-closed-principle/
    ├── ops-safety/
    ├── oss-deep-audit/
    ├── package-by-feature-component/
    ├── parallel-change-expand-contract/
    ├── pipes-and-filters-pattern/
    ├── playwright-qa-orchestrator/
    ├── postgres-diagnostics/
    ├── pr-description/
    ├── pragmatic-solid-and-ssot/
    ├── prototype/
    ├── query-performance/
    ├── race-condition-fix/
    ├── rate-limiter-throttler/
    ├── receiving-code-review/
    ├── repository-root-monorepo-architecture/
    ├── repository-unit-of-work/
    ├── retro/
    ├── router-front-controller-routing/
    ├── saga-transactional-outbox-pattern/
    ├── schema-and-constraints/
    ├── screaming-architecture/
    ├── security-audit/
    ├── serverless-architecture/
    ├── setup-matt-pocock-skills/
    ├── setup-pre-commit/
    ├── setup-ts-deep-modules/
    ├── simplification-audit/
    ├── single-responsibility-cohesion/
    ├── skill-orchestrator/
    ├── soa-vs-microservices-architecture/
    ├── sql-server-audit/
    ├── sql-server-diagnostics/
    ├── sqlite-diagnostics/
    ├── ssot-and-dry/
    ├── state-machine-workflow-engine/
    ├── tdd/
    ├── testing-pyramid-and-shapes/
    ├── text-quality-gate/
    ├── threat-modeling/
    ├── to-questionnaire/
    ├── to-spec/
    ├── to-tickets/
    ├── transaction-fix/
    ├── triage/
    ├── twelve-factor-cloud-native/
    ├── validator-input-parser/
    ├── value-objects-type-invariants/
    ├── verification-loop/
    ├── vertical-slice-architecture/
    ├── vulnerability-triage/
    ├── wait-what/
    ├── wayfinder/
    ├── wizard/
    ├── worst-case-data-ui-check/
    ├── yagni-evolutionary-architecture/
    └── zabbix-diagnostics/
```

---

## Ajuda, Manutenção e Contribuição

- **Ajuda e problemas:** consulte [NOTICE.md](NOTICE.md) e o arquivo `references/sources.md` dentro de cada skill para fontes primárias, ou abra um registro em [GitHub Issues](https://github.com/Kitsune-27295/Dev.-DBs-Skills/issues).
- **Manutenção e licença:** mantido por [@Kitsune-27295](https://github.com/Kitsune-27295), distribuído sob licença MIT ([package.json](package.json)) e com atribuições detalhadas em [NOTICE.md](NOTICE.md).
- **Como contribuir:** ao adicionar ou alterar qualquer arquivo em `skills/`, atualize [MANIFEST.sha256](MANIFEST.sha256), o catálogo acima e a lista `PACK` em [check_skills.py](check_skills.py), validando tudo com `python check_skills.py skills` e `node --test test/mcp-server.test.mjs`.
