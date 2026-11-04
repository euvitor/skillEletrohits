<img width="1672" height="941" alt="image" src="https://github.com/user-attachments/assets/9d8ff847-a562-4e13-adc0-6124c1e5fac6" />

# 🪩⚡ skillEletrohits

Biblioteca compartilhada de **Skills**, **Diretrizes** e **Procedimentos** para assistentes e agentes de IA, compatível com:
- **Google Antigravity**
- **Claude Code**
- **Cursor**
- **Windsurf** / outros editores com suporte a regras em Markdown

---

## 📚 Catálogo de Skills

<!-- AUTO_SKILLS_TABLE:START -->
| Skill | Descrição | Arquivo |
| :--- | :--- | :--- |
| 🪩 `ai-app-audit` | Use esta skill para realizar uma auditoria completa e 100% somente-leitura (read-only) em aplicações web construídas com IA, gerando o relatório AUDITORIA.md com diagnóstico de testes, segurança no cliente, race conditions, idempotência e arquitetura. | [`SKILL.md`](skills/ai-app-audit/SKILL.md) |
| `integration-testing` | Use esta skill para cobrir fluxos críticos do app (cadastro, autenticação, checkout, webhooks, pagamentos e permissões) com testes de integração realistas (estilo request specs), utilizando banco de teste real e mockando apenas serviços externos. | [`SKILL.md`](skills/integration-testing/SKILL.md) |
| `payment-idempotency` | Use esta skill para auditar, implementar e garantir idempotência em webhooks e endpoints de pagamento, cobrança, liberação de planos, créditos ou reembolsos (Stripe, Pagar.me, Asaas, Mercado Pago, etc.). | [`SKILL.md`](skills/payment-idempotency/SKILL.md) |
| `race-condition-audit` | Use esta skill para identificar, auditar, prevenir e corrigir race conditions (condições de corrida) em operações críticas como criação de pedidos, baixa de estoque, cupons, saldos, vagas, convites ou contadores. | [`SKILL.md`](skills/race-condition-audit/SKILL.md) |
| `safe-refactoring` | Use esta skill quando o usuário pedir para refatorar, modularizar ou dividir arquivos grandes ou monolíticos ("God files", telas ou rotas gigantes) em camadas limpas, sem alterar o comportamento existente e com testes de caracterização. | [`SKILL.md`](skills/safe-refactoring/SKILL.md) |
| `security-audit` | Use esta skill para realizar auditorias de segurança fullstack, identificando regras de negócio expostas no frontend (preço, descontos, permissões), vazamento de chaves e segredos em variáveis públicas (NEXT_PUBLIC_, VITE_), e brechas de Row Level Security (RLS) no Supabase ou bancos expostos por API. | [`SKILL.md`](skills/security-audit/SKILL.md) |
<!-- AUTO_SKILLS_TABLE:END -->

---

## 🚀 Como Usar em Qualquer Computador

### 1. Clonar o Repositório
Em qualquer máquina nova:
```bash
git clone git@github.com:euvitor/skillEletrohits.git ~/dev/skillEletrohits
cd ~/dev/skillEletrohits
```

### 2. Sincronizar com as Ferramentas de IA

#### Opção A: Sincronização Global (Válido para toda a máquina)
Basta executar o script de sincronização:
```bash
./sync.sh
```
Isso criará links simbólicos (*symlinks*) apontando para este repositório em:
- `~/.gemini/config/skills/` (Antigravity)
- `~/.claude/skills/` (Claude Code)
- `~/.cursor/rules/` (Cursor)
- Além de regenerar automaticamente o catálogo deste `README.md`.

#### Opção B: Vincular a um Projeto Específico
Se quiser ativar essas skills apenas dentro de um projeto/repositório de trabalho:
```bash
./sync.sh --project /caminho/do/seu-projeto
```

---

## ✍️ Como Adicionar Novas Skills

1. Crie uma nova pasta dentro de `skills/` (ex: `skills/minha-nova-skill/`).
2. Crie um arquivo `SKILL.md` dentro dela com o cabeçalho YAML obrigatório:

```markdown
---
name: minha-nova-skill
description: Descreva quando a IA deve ativar esta skill (em terceira pessoa).
---

# Título da Skill

Instruções claras e estruturadas para o agente de IA...
```

3. Suba as alterações para o GitHub:
```bash
git add .
git commit -m "feat: adiciona nova skill"
git push
```
4. **Catálogo 100% Automático**: A GitHub Action do repositório (e o `./sync.sh` local) atualizará a tabela de skills do `README.md` automaticamente!

---

## 📁 Estrutura Técnica do Repositório

```text
skillEletrohits/
├── plugin.json                 # Manifesto compatível com Antigravity
├── sync.sh                     # Script para conectar as skills às IAs instaladas
├── scripts/
│   └── update-catalog.py       # Gerador automático do catálogo de skills
├── .github/workflows/
│   └── update-skills-catalog.yml # Automação do GitHub Actions
├── README.md                   # Documentação
└── skills/                     # Suas skills em Markdown universal
    ├── ai-app-audit/           # Diagnóstico 100% read-only do app (Hub)
    ├── integration-testing/    # Request specs com banco de teste real
    ├── payment-idempotency/    # Idempotência em webhooks e pagamentos
    ├── race-condition-audit/   # Auditoria de concorrência e race conditions
    ├── safe-refactoring/       # Separação de monolitos em camadas limpas
    └── security-audit/         # Auditoria de segurança e Zero-Client Trust
```
