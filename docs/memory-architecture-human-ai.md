# Архитектура памяти Kai: человеческая нейронная память → механическая нейронная память

**Дата:** 2026-06-18  
**Версия:** 1.0  
**Домен:** Memory & Cognition (MEM-WM-CTX) + Agentic Systems  
**Основание:** Research brief от 2026-06-18 (6 параллельных охотников, 93+ источников)

---

## Фундаментальная модель

Человеческий мозг — не одна память. Это **иерархия взаимодействующих систем**, каждая со своей структурой, временем жизни и механизмом консолидации. ИИ-агент, который не отражает эту архитектуру, будет иметь «плоскую» память — и это отличает игрушки от production-агентов в 2026.

```
ЧЕЛОВЕК                          ИИ-АГЕНТ (Kai)
─────────────────────────────────────────────────────────────
Сенсорная память (<1s)           Input buffer / токенизация
    ↓                                ↓
Кратковременная / Working           Контекстное окно Qwen3.6
(7±2 items, ~20s)                   (~260K токенов, YaRN RoPE)
    ↓                                ↓
Гиппокамп — индексация             Neo4j — entity graph
(что где когда)                     (эпизодические указатели)
    ↓                                ↓
Долговременная память:              Внешние store:
├── Эпизодическая (события)         Qdrant — векторы эпизодов
├── Семантическая (факты)           Neo4j — temporal KG фактов
├── Процедурная (навыки)            Model weights + MCP skills
└── Перцептивная (образы)           Embedding space
    ↓                                ↓
Консолидация во сне                 Sleep-time consolidation
(гиппокамп → неокортекс)            (Redis → Qdrant + Neo4j)
```

---

## Полушария мозга → два типа retrieval

| Полушарие | Человек | Аналог в Kai | Механизм |
|-----------|---------|--------------|----------|
| **Левое** | Последовательное, аналитическое, язык, детали, временная шкала, линейная причинность | **Qdrant** — vector search по chunk'ам, sequential retrieval, BM25 exact-match, хронология эпизодов | Hybrid search (dense BGE-M3 + sparse BM25 + ColBERT rerank) |
| **Правое** | Холистическое, пространственное, контекст, параллельные связи, большая картина, отношения | **Neo4j** — граф отношений, multi-hop reasoning, entity resolution, temporal graph, community detection | Graph traversal + Cypher + Graphiti temporal edges |
| **Мозолистое тело** | Связь между полушариями (~200M аксонов) | **Redis** + **Orchestrator** — bridging layer: hydration из Neo4j → Qdrant → Redis, fusion retrieval | MCP protocol + hydration pipeline |
| **Лобные доли** | Планирование, контроль, executive function | **LangGraph** / кастомный orchestrator | Hydration strategy, retrieval planning, confidence thresholds |
| **Гиппокамп** | Индексация, консолидация, spatial navigation | **Sleep-time worker** + **Graphiti episode ingestion** | Background consolidation |

**Ключевое открытие:** гибрид «Neo4j (graph query) → node IDs → Qdrant (text for nodes)» даёт **+23% multi-hop accuracy** против чистого vector search (NODES AI 2026, Neo4j). Разделение труда: Neo4j = гиппокампальные указатели, Qdrant = кора (содержание).

---

## Типы памяти: человек → конкретная реализация Kai

### 1. Сенсорная память (<1 сек)

| Человек | Kai |
|---------|-----|
| Иконическая (зрение), эхоическая (слух), тактильная | Input buffer / токенизация |

Не хранится. Проходит в рабочую память или отбрасывается.

### 2. Кратковременная / Рабочая память (~20 сек, 7±2 items)

| Аспект | Реализация |
|--------|-----------|
| **Хранилище** | Qwen3.6 context window (~260K токенов, YaRN RoPE scaling до 1M) |
| **Overflow** | Redis Agent Memory Server — автоматическая summarization старых turns |
| **Rehearsal** | Повторный вызов из Redis при каждом reasoning step |
| **TTL** | Redis EXPIRE на session hash |

**Алгоритм hydration:**
```
1. Redis HGETALL agent:session:{thread_id} → последние N turns
2. Neo4j MATCH (user)-[:CONTEXT]->(entities) → активные entity
3. Qdrant hybrid search с фильтром user_id → релевантные чанки
4. Сборка: system prompt + context + session history + retrieved entities
5. Qwen3.6 inference в рамках ~260K
6. Redis HSET нового turn + XADD event log
7. Если overflow → Redis summarization старых turns (background)
```

### 3. Гиппокампальная индексация

Человеческий гиппокамп не хранит воспоминания — он создаёт **указатели** на кортикальные паттерны. Во сне он проигрывает их для консолидации.

**Kai: Neo4j / Graphiti — система указателей.**

| Механизм | Описание |
|----------|----------|
| **Episode ingestion** | Каждая сессия → `graphiti.add_episode(name, episode_body)` |
| **Entity extraction** | LLM извлекает entities + relationships + temporal edges |
| **Conflict resolution** | Bi-temporal: `valid_from` / `valid_until`(superseded). Старые факты не удаляются |
| **Retrieval** | Cypher MATCH → node IDs → Qdrant fetch text for these nodes |

### 4. Долговременная эпизодическая память (что произошло)

Человек: автобиографические события, «я был в Париже в 2024».

**Kai: Qdrant — векторизованные чанки сессий.**

| Параметр | Значение |
|----------|----------|
| **Chunking** | Окна по 5 turns, stride 2 |
| **Embedding** | BGE-M3 multilingual (русский + английский) |
| **Retrieval** | Hybrid: dense (BGE-M3) + sparse (BM25/Qdrant) + RRF fusion |
| **Reranking** | Cross-encoder (ms-marco-MiniLM, CPU) |
| **Two-lane** | 45 окон + 15 extracted facts per query (RASPUTIN pattern) |
| **Multi-tenant** | Payload filter: `user_id`, `namespace` |

**Retrieval scoring formula (Stanford GenAgents, 4448 cit):**
```
score = recency_weight × importance_weight × relevance_similarity
```

### 5. Долговременная семантическая память (знание о мире)

Человек: факты без привязки к контексту — «Париж — столица Франции».

**Kai: Neo4j temporal knowledge graph (Graphiti / neo4j-agent-memory).**

| Компонент | Реализация |
|-----------|-----------|
| **Graph engine** | Graphiti (Zep, 24K★, Apache 2.0) |
| **Entity model** | POLE+O: Person, Organization, Location, Event, Object + preferences |
| **Temporal model** | Bi-temporal: `valid_from`/`valid_until` + `ingested_at` |
| **Relationship types** | `WORKS_AT`, `PREFERS`, `LOCATED_IN`, `MENTIONED`, `PURCHASED`, `TRAVELED_TO` |
| **Provenance** | Каждое ребро → source session_id + confidence score |
| **Extraction** | LLM после каждой сессии: subject-predicate-object + confidence |

**Пример:**
```
(User {name: "Алексей"})
  -[:PREFERS {value: "вегетарианец", valid_from: "2025-03-01", 
     superseded_at: "2026-01-15", source: "session_42", confidence: 0.95}]
  -[:PREFERS {value: "средиземноморская", valid_from: "2026-01-15", 
     source: "session_189", confidence: 0.88}]
  -[:TRAVELED_TO {city: "Париж", when: "2024-06", 
     purpose: "работа", source: "session_5"}]
```

### 6. Процедурная память (как делать)

Человек: навыки — ходьба, игра на пианино, не требуют сознательного recall.

| Аспект | Реализация |
|--------|-----------|
| **Базовые навыки** | В весах Qwen3.6 (родное обучение) |
| **Специфические навыки** | MCP tools (инструменты, API, функции) |
| **Долгосрочное обучение** | Token-space learning (Letta Context Constitution) — не weight-space |
| **Документация** | CLAUDE.md / agent instructions — редактируемый код, не weights |

Консенсус 2026: процедурную память выносят из weights в tools/skills/mcp. «Token-space learning вместо weight-space learning» (Letta).

---

## Sleep-time консолидация (ключевой механизм)

Человек: консолидация происходит во сне. Гиппокамп проигрывает дневные события, неокортекс интегрирует их в семантическую память.

**Kai: Sleep-time Consolidation Worker** — запускается в простое.

```
Фаза сна Kai (background worker):
│
├── 1. SELECT неконсолидированные сессии из Redis (старше N часов)
│
├── 2. LLM summarization каждой сессии:
│     ├── Ключевые события (эпизодические)
│     ├── Извлечение фактов (семантические)
│     └── Обновление user preferences
│
├── 3. Graphiti.add_episode(summary) → Neo4j:
│     ├── Entity resolution (MERGE, не CREATE)
│     ├── Temporal edge update
│     └── Conflict detection → supersede старые факты
│
├── 4. Qdrant реиндексация:
│     ├── Embed summary
│     ├── Semantic dedup (cosine >0.92 → merge)
│     └── Archive stale entries (trust score < N)
│
├── 5. Pruning:
│     ├── Belief drift check (Nexus: scored 0–10)
│     ├── Temporal invalidation: valid_until < now → superseded
│     └── Redis: EXPIRE старых session hash
│
└── 6. User profile composite update в Neo4j:
      └── Композитная суммаризация всех фактов о пользователе
```

Этот паттерн подтверждён тремя источниками 2026:
- **OpenAI Dreaming V3** (июнь 2026) — background synthesis, temporal awareness. Factual recall: 82.8%
- **Anthropic Dreams** (май 2026) — scheduled process reviewing agent sessions + memory stores
- **Letta Sleep-time Compute** (апрель 2025) — primary agent + sleep-time agent

---

## Сравнение подходов: US Labs vs Chinese Labs

| Аспект | US Labs | Chinese Labs |
|--------|---------|--------------|
| **Философия** | External memory + dreaming | Long context как память |
| **External memory** | Да (MCP, Memory Tool, Graphiti) | Нет (DeepSeek issue #1106 не реализовано) |
| **Consolidation** | Background dreaming | Не реализовано |
| **Temporal awareness** | Да (Dreaming V3) | Нет |
| **Safety** | User-facing controls, versioning, audit | Не документировано |
| **Для Kai** | **Брать паттерны управления** | **Брать base model (Qwen3.6)** |

Kai берёт лучшее из обоих: Qwen3.6 (260K native context, MoE 35B/3B) как база + US memory architecture (tiered + dreaming + temporal KG) сверху.

---

## Возможные проблемы и anti-patterns

1. **Контекст — не память.** 260K Qwen3.6 = human working memory, не жёсткий диск.

2. **Qwen3.6 RNN-state.** Гибридная архитектура Qwen3.5+ имеет persistent hidden states вне KV cache. `llama_memory_seq_rm` может не очищать их. Тестировать.

3. **Latency compounding.** Каждый шаг агента: Redis read + Neo4j query + Qdrant search. При 5 шагах: 5× latency. Кешировать.

4. **Self-reported бенчмарки.** OMEGA 95.4%, Mem0 managed 94.4% — но Mem0 OSS только 32.4%. Проверять независимо.

5. **Нет русского языка.** LongMemEval, MemoryAgentBench — только английский. Адаптировать.

6. **Graphiti на русском.** Entity extraction через LLM может быть хуже на русском. Нужен тест.

7. **Prompt injection через память.** Anthropic: read-only доступ для untrusted inputs, memory versioning, immutable snapshots. Kai: bounded auditable memory.

---

## Architecture Blueprint

```
                    User Query
                         │
                         ▼
┌────────────────────────────────────────┐
│         MCP Protocol Bridge             │
│  (97M+ downloads, стандарт 2026)        │
└────────────────┬───────────────────────┘
                 │
                 ▼
┌────────────────────────────────────────┐
│  Executive (Лобные доли)                │
│  LangGraph / orchestrator:              │
│  → hydration strategy                   │
│  → retrieval planning + квоты           │
│  → tool calling via MCP                 │
│  → confidence thresholds                │
└──────┬─────────────────────┬───────────┘
       │                     │
       ▼                     ▼
┌──────────────┐    ┌──────────────────────────────┐
│  Рабочая     │    │  Долговременная память        │
│  память      │    │                                │
│  (Левая      │    │  Qdrant (Левое — эпизоды):     │
│  лобная)     │    │  • Hybrid search BM25+vector   │
│              │    │  • Two-lane retrieval           │
│  Redis:      │    │  • Cross-encoder rerank        │
│  • Session   │    │  • Multi-tenant isolation      │
│  • Stream    │◄───│                                │
│  • Cache     │    │  Neo4j (Правое — связи):       │
│  • TTL       │    │  • Temporal KG (Graphiti)      │
│              │    │  • POLE+O entities             │
│              │    │  • Reasoning traces            │
│              │    │  • Shared multi-agent          │
└──────────────┘    └──────────────┬───────────────┘
                                   │
                                   ▼
┌──────────────────────────────────────────────┐
│  Консолидация (Сон / Гиппокамп)               │
│  Background Worker (sleep-time):              │
│  1. Summarization сессий                      │
│  2. Entity extraction → Neo4j                 │
│  3. Re-index → Qdrant + dedup                │
│  4. Temporal invalidation                     │
│  5. Belief drift check                        │
│  6. User profile update                       │
└──────────────────────────────────────────────┘
```

---

## Метрики и OKR

| Метрика | Таргет | Бенчмарк | Источник |
|---------|--------|-----------|----------|
| Factual recall | >85% | OpenAI: 82.8% | OpenAI Dreaming V3 |
| Cross-session reasoning | >70% | SOTA: 95.4% (self-reported) | LongMemEval |
| Preference adherence | >70% | OpenAI: 71.3% | OpenAI Dreaming V3 |
| Temporal awareness | Факты обновляются | OpenAI Dreaming V3 | Temporal invalidation test |
| Retrieval latency | <200ms p95 | Zep: 300ms, Qdrant: <10ms | Graphiti docs |
| Belief drift | <5% stale | Nexus: 0–10 scale | Nexus belief drift |
| Long-term accuracy | >75% | OpenAI: 75.1% | OpenAI Dreaming V3 |

---

## Стек технологий

| Компонент | Технология | Лицензия | Статус |
|-----------|-----------|----------|--------|
| Base model | Qwen3.6-35B-A3B (GGUF Q4_K_M) | Apache 2.0 | Production |
| Working memory | Redis Agent Memory Server | OSS | Official (май 2026) |
| Semantic/vector | Qdrant + Qdrant Alloy | OSS | v1.16+ |
| Temporal KG | Graphiti (Zep) | Apache 2.0 | 24K★ |
| Entity model | neo4j-agent-memory (POLE+O) | OSS | Neo4j Labs (фев 2026) |
| GraphRAG | neo4j-graphrag-python | OSS | v1.17.0 (май 2026) |
| Embedding | BGE-M3 multilingual | MIT | SOTA multilingual |
| Protocol | MCP (Model Context Protocol) | Linux Foundation | 97M+ downloads |
| Hybrid search | Qdrant Alloy (dense + sparse + ColBERT) | OSS | Qdrant Labs (янв 2026) |

---

## Источники

1. MemGPT: Towards LLMs as Operating Systems — arXiv 2310.08560 — Berkeley BAIR — 806+ cit
2. Generative Agents: Interactive Simulacra of Human Behavior — arXiv 2304.03442 — Stanford — 4448+ cit
3. Sleep-time Compute — Letta Blog — 2025-04-21
4. Context Constitution — Letta Blog — 2026-04-02
5. OpenAI Dreaming — openai.com/index/chatgpt-memory-dreaming/ — 2026-06-04
6. Anthropic Memory Tool — platform.claude.com/docs — 2026
7. Anthropic Dreams — platform.claude.com/docs/en/managed-agents/dreams — 2026
8. Memory for Autonomous LLM Agents — arXiv 2603.07670 — Multi — 2026-03
9. Memory in the Age of AI Agents — arXiv 2512.13564 — NUS — 2025-12
10. Externalization in LLM Agents — arXiv 2604.08224 — CMU et al. — 2026-04
11. LongMemEval — arXiv 2410.10813 — Multi-CN — ICLR 2025 — 173+ cit
12. Zep: A Temporal Knowledge Graph Architecture — arXiv 2501.13956 — Zep — 2025
13. Graphiti — github.com/getzep/graphiti — 24K★ — Apache 2.0
14. Redis Agent Memory Server — github.com/redis/agent-memory-server — 2025-2026
15. Qdrant Alloy — github.com/qdrant-labs/qdrant-alloy — 2026-01
16. Neo4j Agent Memory — neo4j.com/blog/developer/when-your-agents-share-a-brain/ — 2026-04
17. NODES AI 2026: Multi-Agent Shared Graph Memory — Neo4j — 2026-04
18. Redis Agent Memory Guide — redis.io/docs/latest/develop/use-cases/agent-memory/ — 2026-06
19. Infini-Attention — arXiv 2404.07143 — Google DeepMind — 2024 — 212+ cit
20. Building Effective AI Agents — anthropic.com/research — 2024-12
21. RASPUTIN Memory — github.com/shade-familiar/rasputin-memory — 2026-04
22. Nexus Memory — github.com/Neboy72/hermes-nexus-memory — 2026-05
23. Mnemostack — github.com/udjin-labs/mnemostack — 2026-04
24. Hystersis — github.com/Himan-D/agent-memory — 2026-04
25. Papr-ai/memory-opensource — github.com/Papr-ai/memory-opensource — 2025-12
26. Qwen3 Technical Report — arXiv 2505.09388 — Alibaba/Qwen — 2025-05
27. DeepSeek V4 Release — api-docs.deepseek.com/news/news260424 — 2026-04
