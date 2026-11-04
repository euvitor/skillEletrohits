# 🪩⚡ skillEletrohits

Biblioteca compartilhada de **Skills**, **Diretrizes** e **Procedimentos** para assistentes e agentes de IA, compatível com:
- **Google Antigravity**
- **Claude Code**
- **Cursor**
- **Windsurf** / outros editores com suporte a regras em Markdown

---

## 📁 Estrutura do Repositório

```text
skillEletrohits/
├── plugin.json                 # Manifesto compatível com Antigravity
├── sync.sh                     # Script para conectar as skills às IAs instaladas
├── README.md                   # Documentação
└── skills/                     # Suas skills em Markdown universal
    ├── security-audit/
    │   └── SKILL.md            # Auditoria de segurança, confiança zero no client e RLS
    ├── payment-idempotency/
    │   └── SKILL.md            # Idempotência em webhooks e pagamentos (Stripe, etc.)
    ├── race-condition-audit/
    │   └── SKILL.md            # Auditoria e correção de concorrência e race conditions
    ├── code-review/
    │   └── SKILL.md            # Padrões e checklist de revisão de código
    ├── git-workflow/
    │   └── SKILL.md            # Padrões de commit e convenções Git
    └── architecture-decision/
        └── SKILL.md            # Guia de Architecture Decision Record (ADR)
```

---

## 🚀 Como Usar em Qualquer Computador

### 1. Clonar o Repositório
Em qualquer nova máquina:
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
4. Como as ferramentas usam links simbólicos para este repositório, **qualquer edição ou `git pull` é refletida imediatamente** em todos os assistentes!
