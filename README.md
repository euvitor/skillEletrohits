<img width="2048" height="768" alt="image" src="https://github.com/user-attachments/assets/1aa16e57-7003-4204-ae93-9a0d914c210e" />

# 🪩 skillEletrohits

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Skills](https://img.shields.io/badge/Skills-9%20Faixas%20%7C%202%20Álbuns-blueviolet.svg)](#-catálogo-por-álbum)
[![Multi-IDE](https://img.shields.io/badge/Compatível-Antigravity%20%7C%20Android%20Studio%20%7C%20IntelliJ%20%7C%20Claude%20%7C%20Cursor-00ADD8.svg)](#-como-instalar-e-usar)

Coletânea aberta de **Skills** organizada em **Álbuns temáticos** (inspirada nos clássicos *Summer Eletrohits*) para transformar seu assistente de IA em um time de *Staff Engineers*, *AppSec* e *Product Designers*.

**Compatível com:** Google Antigravity · Android Studio · IntelliJ IDEA · Claude Code · Cursor · Windsurf

---

## 📚 Catálogo por Álbum

<!-- AUTO_SKILLS_TABLE:START -->
### 💿 Vol. 1 — Técnico, Segurança & Performance

| Skill | Descrição | Arquivo |
| :--- | :--- | :--- |
| 🪩 `ai-app-audit` | Use esta skill para realizar uma auditoria geral panorâmica e 100% somente-leitura (read-only) de toda a aplicação web construída com IA, gerando o relatório AUDITORIA.md com diagnóstico de testes, segurança no cliente, race conditions, idempotência e arquitetura. | [`SKILL.md`](skills/vol-1-core/ai-app-audit/SKILL.md) |
| `github-project-planner` | Atua como Tech Lead e Project Manager lean. Estrutura projetos no GitHub analisando issues e milestones existentes, organizando entregas em fatias verticais de alta densidade em português (prontas para humanos ou agentes de IA) e automatizando a criação/edição via gh CLI ou GitHub API. | [`SKILL.md`](skills/vol-1-core/github-project-planner/SKILL.md) |
| `input-validation-guard` | Use esta skill para blindar fronteiras de dados e contratos em runtime (Zod, Pydantic, DTOs) tanto no Backend/APIs (prevenindo mass assignment e payloads inválidos) quanto no Frontend/Mobile/Backend ao consumir APIs de terceiros sem type casting cego. | [`SKILL.md`](skills/vol-1-core/input-validation-guard/SKILL.md) |
| `integration-testing` | Use esta skill para cobrir fluxos críticos do app (cadastro, autenticação, checkout, webhooks, pagamentos e permissões) com testes de integração realistas (estilo request specs), utilizando banco de teste real e mockando apenas serviços externos. | [`SKILL.md`](skills/vol-1-core/integration-testing/SKILL.md) |
| `payment-idempotency` | Use esta skill para auditar, implementar e garantir idempotência em webhooks e endpoints de pagamento, cobrança, liberação de planos, créditos ou reembolsos (Stripe, Pagar.me, Asaas, Mercado Pago, etc.). | [`SKILL.md`](skills/vol-1-core/payment-idempotency/SKILL.md) |
| `race-condition-audit` | Use esta skill para identificar, auditar, prevenir e corrigir race conditions (condições de corrida) em operações críticas como criação de pedidos, baixa de estoque, cupons, saldos, vagas, convites ou contadores. | [`SKILL.md`](skills/vol-1-core/race-condition-audit/SKILL.md) |
| `safe-refactoring` | Use esta skill quando o usuário pedir para refatorar, modularizar ou dividir arquivos grandes ou monolíticos ("God files", telas ou rotas gigantes) em camadas limpas, sem alterar o comportamento existente e com testes de caracterização. | [`SKILL.md`](skills/vol-1-core/safe-refactoring/SKILL.md) |
| `security-audit` | Use esta skill para realizar auditorias de segurança fullstack, identificando regras de negócio expostas no frontend (preço, descontos, permissões), vazamento de chaves e segredos em variáveis públicas (NEXT_PUBLIC_, VITE_), e brechas de Row Level Security (RLS) no Supabase ou bancos expostos por API. | [`SKILL.md`](skills/vol-1-core/security-audit/SKILL.md) |

### ✨ Vol. 2 — Estética, UI/UX & Acabamento

| Skill | Descrição | Arquivo |
| :--- | :--- | :--- |
| `premium-ux-craft` | Use esta skill ao auditar, projetar ou codificar interfaces e fluxos de usuário, garantindo acabamento premium, ergonomia cognitiva, matriz completa de estados (empty, loading, error), teatro do sistema e recuperação graciosa de falhas. | [`SKILL.md`](skills/vol-2-estetica/premium-ux-craft/SKILL.md) |

<!-- AUTO_SKILLS_TABLE:END -->

> 💡 **Escopo:** As faixas de auditoria, testes e pagamentos do **Vol. 1** são otimizadas para apps **Web / Fullstack / SaaS**; `premium-ux-craft`, `safe-refactoring` e `github-project-planner` são **agnósticas de stack** (Web, Mobile, Backend).

---

## 🚀 Como Instalar e Usar

**1. Clone e sincronize:**
```bash
git clone https://github.com/euvitor/skillEletrohits.git ~/dev/skillEletrohits
cd ~/dev/skillEletrohits

# macOS / Linux (sincroniza todos os álbuns)
./sync.sh

# Windows (PowerShell)
.\sync.ps1
```

**2. Chame qualquer skill no chat da sua IDE:**
- *"Use a skill `ai-app-audit` para fazer uma auditoria read-only deste projeto e gerar o `AUDITORIA.md`."*
- *"Aplique a skill `premium-ux-craft` nesta tela para cobrir os 5 estados e melhorar a recuperação de erro."*

<details>
<summary>⚙️ Filtrar por álbum (--album), opções por projeto, symlinks e estrutura</summary>

### Instalar apenas um álbum específico
```bash
# macOS / Linux
./sync.sh --album vol-1   # Apenas Técnico, Segurança & Performance
./sync.sh --album vol-2   # Apenas Estética, UI/UX & Acabamento

# Windows (PowerShell)
.\sync.ps1 -Album vol-1
```

### Vincular apenas a um projeto específico
```bash
# macOS / Linux
./sync.sh --project /caminho/do/seu-projeto

# Windows (PowerShell)
.\sync.ps1 -Project "C:\caminho\do\seu-projeto"
```

### Atualizar skills existentes
```bash
cd ~/dev/skillEletrohits && git pull && ./sync.sh
```

### Destinos sincronizados no modo global (links planos)
- `~/.gemini/config/skills/` (Antigravity Global)
- `~/.android-studio/skills/` (Android Studio Global)
- `~/Library/Caches/JetBrains/*/aia/agents/` (IntelliJ IDEA / Extensão Oficial Antigravity & AI Assistant)
- `~/.agents/skills/` (Padrão Global Multi-IDE)
- `~/.junie/skills/` (JetBrains Junie)
- `~/.claude/skills/` (Claude Code)
- `~/.cursor/rules/` (Cursor)

### Estrutura do repositório
```text
skillEletrohits/
├── LICENSE                       # Licença MIT
├── plugin.json                   # Manifesto compatível com Antigravity
├── sync.sh                       # Sincronizador automático (macOS / Linux)
├── sync.ps1                      # Sincronizador automático (Windows PowerShell)
├── scripts/
│   ├── update-catalog.py         # Gerador automático do catálogo por álbum
│   └── validate-skills.py        # Validador de PRs (estrutura, frontmatter e unicidade)
├── .github/workflows/
│   ├── update-skills-catalog.yml # Atualiza README após merge na main
│   └── validate-skills.yml       # Valida PRs automaticamente
├── README.md
└── skills/
    ├── vol-1-core/               # Vol. 1 — Técnico, Segurança & Performance
    │   ├── ai-app-audit/
    │   ├── github-project-planner/
    │   ├── input-validation-guard/
    │   ├── integration-testing/
    │   ├── payment-idempotency/
    │   ├── race-condition-audit/
    │   ├── safe-refactoring/
    │   └── security-audit/
    └── vol-2-estetica/           # Vol. 2 — Estética, UI/UX & Acabamento
        └── premium-ux-craft/
```

</details>

---

## 🤝 Como Contribuir

1. Faça um **Fork** e crie sua branch (`git checkout -b feature/minha-skill`);
2. Adicione `skills/<album>/<nome-da-skill>/SKILL.md` (ex: `vol-1-core` ou `vol-2-estetica`) com frontmatter YAML (`name` e `description`);
3. Envie um **Pull Request** — nosso CI valida o formato e a GitHub Action atualiza o catálogo deste README automaticamente após o merge.
