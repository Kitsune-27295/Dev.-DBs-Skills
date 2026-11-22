# Dev.-DBs-Skills

Catálogo unificado de **31 Agent Skills** (Claude Code, Antigravity IDE, Codex, Cursor) cobrindo **Arquitetura de Software & Padrões Arquiteturais (13 skills)**, **Fundamentos de Engenharia & Segurança (7 skills)**, **Fundamentos & Governança de Bancos de Dados (8 skills)** e **Diagnósticos de Motores SQL em Produção (3 skills)**.

Todas as skills são autocontidas, sem dependências externas, testadas por `check_skills.py` e verificadas contra `MANIFEST.sha256`.

---

## 1. Arquitetura de Software & Padrões Arquiteturais (13 Skills)

Cada skill arquitetural documenta o vocabulário canónico, invariantes e regras de direção de dependências, ordem de construção (*test-first*), estratégia de testes por camada/componente, quando compensa (*vs.* quando é sobre-engenharia), erros comuns a intercetar em code review e `references/sources.md` com as fontes primárias (Martin Fowler, Robert C. Martin, Sam Newman, Alistair Cockburn, Chris Richardson, Kamil Grzybek, Oskar Dudycz, Cam Jackson, Michael Geers, Microsoft Azure Architecture Center, AWS Architecture, Marco Tulio Valente).

| Skill | Estilo / Padrão | Para quê | Fontes Canónicas (`references/sources.md`) |
|---|---|---|---|
| [`hexagonal-architecture`](skills/hexagonal-architecture/SKILL.md) | Hexagonal (Ports & Adapters) | Isolar o domínio e casos de uso de qualquer tecnologia externa através de *driver ports* (inbound), *driven ports* (outbound), adaptadores intercambiáveis e *composition root* único | Cockburn / Garrido de Paz, Valente, AWS Prescriptive Guidance, Netflix Tech Blog, Hombergs, Baeldung |
| [`layered-n-tier-architecture`](skills/layered-n-tier-architecture/SKILL.md) | Arquitetura em Camadas (Layered / N-Tier) | Separar camadas lógicas (*Presentation*, *Business*, *Data Access*) de camadas físicas (*Tiers*), escolher comunicação estrita vs. relaxada e evitar *layer sinkholes* | Microsoft Azure Architecture Center (N-tier EN/PT), Valente (*Eng. Soft. Moderna* Cap. 7), .NET Web Architectures |
| [`mvc-architecture`](skills/mvc-architecture/SKILL.md) | MVC (Model-View-Controller) | Aplicar *Separated Presentation* e *Humble View*, mantendo regras de negócio no *Model*, coordenação fina no *Controller* e projeção sem lógica na *View* / *ViewModel* | Martin Fowler (*GUI Architectures*, *PoEAA MVC*), MDN Web Docs, Valente |
| [`clean-architecture`](skills/clean-architecture/SKILL.md) | Clean Architecture (Arquitetura Limpa) | Organizar o sistema nos 4 círculos concêntricos (*Entities*, *Use Cases*, *Interface Adapters*, *Frameworks & Drivers*) sob a *Dependency Rule* (dependências só apontam para dentro) | Robert C. Martin (*The Clean Architecture*), Valente (*SoftEngBook*), Jason Taylor (`CleanArchitecture`), Microsoft .NET |
| [`monolithic-architecture`](skills/monolithic-architecture/SKILL.md) | Monolítica Tradicional | Aplicar a estratégia *Monolith First*, organizar um único artefacto de deploy com transações ACID locais e escalar horizontalmente com processos *stateless* antes de pagar o *Microservice Premium* | Martin Fowler (*Monolith First*), Microsoft .NET Architecture Guide, AWS Monolithic vs. Microservices |
| [`modular-monolith-architecture`](skills/modular-monolith-architecture/SKILL.md) | Monólito Modular (DDD) | Particionar um único deploy em módulos verticais autónomos (*Bounded Contexts*) com tipos internos encapsulados, *schemas* de BD isolados (zero `JOIN`s entre módulos) e eventos *in-process* via *Outbox* | Kamil Grzybek (`modular-monolith-with-ddd`), Spring Modulith Reference Docs, Fowler |
| [`microservices-architecture`](skills/microservices-architecture/SKILL.md) | Microsserviços | Desenhar serviços com deploy independente organizados por capacidade de negócio (*Subdomains*), BD privada por serviço, *Sagas*, *Transactional Outbox* e testes de contrato (*Consumer-Driven Contracts*) | James Lewis & Martin Fowler (*Microservices*), Chris Richardson (`microservices.io` pattern language) |
| [`serverless-architecture`](skills/serverless-architecture/SKILL.md) | Serverless (FaaS & BaaS) | Construir funções *stateless* orientadas a eventos (*FaaS*) + serviços geridos (*BaaS*), gerindo *cold starts*, limites de execução, *connection pooling*, idempotência, DLQs e permissões IAM mínimas | Mike Roberts (*Serverless Architectures*), Badri Janakiraman, AWS Well-Architected Serverless Applications Lens |
| [`event-driven-architecture`](skills/event-driven-architecture/SKILL.md) | Event-Driven (Orientada a Eventos) | Desacoplar produtores e consumidores via *Pub/Sub* ou *Event Streaming*, distinguindo *Event Notification*, *Event-Carried State Transfer*, *Event Sourcing* e *CQRS* sem cair em comandos passivo-agressivos | Martin Fowler (*What do you mean by "Event-Driven"?*), Microsoft Azure Architecture Center (EN/PT), Valente |
| [`cqrs-pattern`](skills/cqrs-pattern/SKILL.md) | CQRS & CQS | Segregar o modelo de escrita (*Commands* orientados a tarefas) do modelo de leitura (*Queries* projetadas direto para DTOs) dentro de um *Bounded Context* (em BD única ou BDs separadas) | Martin Fowler (*CQRS*, *Command Query Separation*), Microsoft Azure Architecture Center (EN/PT) |
| [`event-sourcing-pattern`](skills/event-sourcing-pattern/SKILL.md) | Event Sourcing | Persistir cada mudança de estado como sequência imutável (*append-only*) de eventos de domínio, reconstituir agregados (`decide` vs. `apply` puro), controlo de concorrência otimista, *upcasting*, *snapshots* e GDPR | Martin Fowler (*Event Sourcing*), Microsoft Azure Architecture Center, Chris Richardson, Oskar Dudycz (`EventSourcing.NetCore`) |
| [`bff-pattern`](skills/bff-pattern/SKILL.md) | BFF (Backend for Frontend) | Criar um *Edge Backend* dedicado por experiência de utilizador (Web, Mobile, Voz/IoT) gerido pela própria equipa de frontend (Lei de Conway), agregando chamadas em paralelo com degradação graciosa | Sam Newman (*Backends For Frontends*), Microsoft Azure Architecture Center, Chris Richardson (*API Gateway / BFF*) |
| [`micro-frontends-architecture`](skills/micro-frontends-architecture/SKILL.md) | Micro-frontends | Decompor um *Frontend Monolith* em fatias verticais de negócio com deploy independente em *runtime* (JS / Module Federation, Web Components, Server-Side Includes), isolamento de CSS/estado e comunicação via URL/DOM | Cam Jackson (*Micro Frontends* / Fowler), Michael Geers (`micro-frontends.org`), Microsoft .NET Composite UI |

---

## 2. Fundamentos de Engenharia de Software & Segurança (7 Skills)

Auditorias só de leitura e procedimentos cirúrgicos de correção test-first:

| Skill | Para quê | Modelo / esforço recomendado |
|---|---|---|
| [`fundamentals-audit`](skills/fundamentals-audit/SKILL.md) | Audita os cinco fundamentos de uma vez (só leitura), escreve `AUDIT.md` e indica qual correção rodar primeiro; guarda a ordem e as regras de segurança que as outras citam | opus / high |
| [`security-audit`](skills/security-audit/SKILL.md) | Auditoria de segurança só de leitura: isolamento de tenant, permissão só no navegador, IDOR, chaves expostas (inclui histórico do git), XSS; relatório com `arquivo:linha` e rascunhos de issues | opus / high |
| [`integration-tests`](skills/integration-tests/SKILL.md) | Cobre os fluxos críticos com testes de rota contra banco de teste real, a partir de frases de comportamento aprovadas; regra de ouro: nunca apagar, pular ou afrouxar teste | sonnet / high |
| [`never-trust-the-client`](skills/never-trust-the-client/SKILL.md) | Retira regras, segredos e políticas de acesso do cliente e coloca no servidor (relatório primeiro, uma correção por vez) | sonnet / high |
| [`race-condition-fix`](skills/race-condition-fix/SKILL.md) | Corrige leia-decida-grave no banco (`UNIQUE`, atualização atómica, trava de linha) e prova com teste de requisições simultâneas | sonnet / high |
| [`idempotency-fix`](skills/idempotency-fix/SKILL.md) | Webhook e pagamento com um só efeito por evento: verificação de assinatura, tabela de eventos processados e chave de idempotência | sonnet / high |
| [`layered-refactor`](skills/layered-refactor/SKILL.md) | Divide um arquivo gigante que mistura UI, regras e dados em camadas separadas sem mudar comportamento, com testes de caracterização | sonnet / high |

---

## 3. Fundamentos, Custo & Governança de Bancos de Dados (8 Skills)

| Skill | Para quê | Modelo / esforço recomendado |
|---|---|---|
| [`database-audit`](skills/database-audit/SKILL.md) | Audita o banco em sete frentes de uma vez (só leitura), escreve `DB-AUDIT.md`, dá a ordem de execução e orienta qual banco usar | opus / high |
| [`database-exposure`](skills/database-exposure/SKILL.md) | Verifica porta do banco aberta, chaves e senhas (inclui histórico do git), quem lê e escreve tabela por tabela e políticas frouxas (RLS/Firebase); relatório primeiro | opus / high |
| [`backup-restore-drill`](skills/backup-restore-drill/SKILL.md) | Backup diário fora do servidor com retenção, teste real de restauração em outro banco comparando contagens e roteiro de recuperação | sonnet / high |
| [`database-cost-guard`](skills/database-cost-guard/SKILL.md) | Banco cobrado por uso: encontra consultas em laço (`N+1`), listeners e paginação por offset, estima o custo com 10x mais utilizadores e define limite de gastos | sonnet / high |
| [`transaction-fix`](skills/transaction-fix/SKILL.md) | Operação que grava em várias tabelas vira tudo-ou-nada (transação ACID), mantendo chamadas externas fora da transação e provando com teste de falha forçada | sonnet / high |
| [`schema-and-constraints`](skills/schema-and-constraints/SKILL.md) | O banco recusa dado ruim: dinheiro exato, `timestamptz`, chaves estrangeiras, `NOT NULL`, `UNIQUE`, `CHECK`; conta as linhas que já violam antes de migrar | sonnet / high |
| [`migrations-and-environments`](skills/migrations-and-environments/SKILL.md) | Migrations numeradas sob controlo de versão com baseline e checagem de drift, desenvolvimento separado de produção e utilizador da app com privilégio mínimo | sonnet / high |
| [`query-performance`](skills/query-performance/SKILL.md) | Consultas lentas: `EXPLAIN ANALYZE`, índices em falta (inclusive em chaves estrangeiras), eliminação de `N+1` e paginação por cursor medindo antes e depois | sonnet / high |

---

## 4. Diagnósticos de Motores de Banco de Dados (3 Skills)

Coleções de consultas SQL só de leitura, organizadas por versão do motor:

| Skill | Para quê | Modelo / esforço recomendado |
|---|---|---|
| [`sql-server-diagnostics`](skills/sql-server-diagnostics/SKILL.md) | 30 consultas só de leitura para SQL Server por versão (2019, 2022, 2025; 31 na 2025), com guias do que muda em cada versão e script de verificação `check_versions.py` | sonnet / high |
| [`postgres-diagnostics`](skills/postgres-diagnostics/SKILL.md) | 31 consultas só de leitura para PostgreSQL 16, 17 e 18 (bloat, wraparound, conexões, locks, `pg_stat_statements`, WAL, replicação, índices) com tabela das diferenças entre versões | sonnet / high |
| [`sqlite-diagnostics`](skills/sqlite-diagnostics/SKILL.md) | 19 consultas só de leitura para SQLite (`integrity_check`, `foreign_key_check`, esquema, tamanho por tabela/índice, chaves estrangeiras sem índice, `AUTOINCREMENT`), testadas em 3.49 e 3.53 | sonnet / high |

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

O script `check_skills.py` valida que todas as 31 pastas possuem frontmatter YAML válido (`name` igual à pasta, `description` <= 1024 caracteres), que todos os links Markdown relativos (incluindo `references/sources.md` e scripts `.sql`) existem no disco e que todas as referências cruzadas entre skills estão íntegras.

---

## Estrutura do Repositório

```text
Dev.-DBs-Skills/
├── README.md               # Catálogo completo e guia de instalação
├── NOTICE.md               # Créditos, origens e notas sobre fontes
├── MANIFEST.sha256         # Hashes SHA-256 de todos os ficheiros em skills/
├── install_skills.py       # Instalador idempotente com verificação SHA-256
├── check_skills.py         # Validador estático de frontmatter, links e referências
└── skills/                 # As 31 skills autocontidas
    ├── backup-restore-drill/
    ├── bff-pattern/
    ├── clean-architecture/
    ├── cqrs-pattern/
    ├── database-audit/
    ├── database-cost-guard/
    ├── database-exposure/
    ├── event-driven-architecture/
    ├── event-sourcing-pattern/
    ├── fundamentals-audit/
    ├── hexagonal-architecture/
    ├── idempotency-fix/
    ├── integration-tests/
    ├── layered-n-tier-architecture/
    ├── layered-refactor/
    ├── micro-frontends-architecture/
    ├── microservices-architecture/
    ├── migrations-and-environments/
    ├── modular-monolith-architecture/
    ├── monolithic-architecture/
    ├── mvc-architecture/
    ├── never-trust-the-client/
    ├── postgres-diagnostics/
    ├── query-performance/
    ├── race-condition-fix/
    ├── schema-and-constraints/
    ├── security-audit/
    ├── serverless-architecture/
    ├── sql-server-diagnostics/
    ├── sqlite-diagnostics/
    └── transaction-fix/
```
