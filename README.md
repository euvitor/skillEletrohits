<img width="2048" height="768" alt="image" src="https://github.com/user-attachments/assets/1aa16e57-7003-4204-ae93-9a0d914c210e" />

# 🪩 skillEletrohits

Biblioteca compartilhada de **Skills**, **Diretrizes** e **Procedimentos** para assistentes e agentes de IA, compatível com:
- **Google Antigravity**
- **IntelliJ IDEA / JetBrains** (Junie / AI Assistant)
- **Claude Code**
- **Cursor**
- **Windsurf** / outros editores com suporte a regras em Markdown

---

## 📚 Catálogo de Skills

<!-- AUTO_SKILLS_TABLE:START -->
| Skill | Descrição | Arquivo |
| :--- | :--- | :--- |
| 🪩 `ai-app-audit` | Use esta skill para realizar uma auditoria completa e 100% somente-leitura (read-only) em aplicações web construídas com IA, gerando o relatório AUDITORIA.md com diagnóstico de testes, segurança no cliente, race conditions, idempotência e arquitetura. | [`SKILL.md`](skills/ai-app-audit/SKILL.md) |
| `github-project-planner` | Atua como Tech Lead e Project Manager lean. Estrutura projetos no GitHub analisando issues e milestones existentes, organizando entregas em fatias verticais de alta densidade em português (prontas para humanos ou agentes de IA) e automatizando a criação/edição via gh CLI ou GitHub API. | [`SKILL.md`](skills/github-project-planner/SKILL.md) |
| `integration-testing` | Use esta skill para cobrir fluxos críticos do app (cadastro, autenticação, checkout, webhooks, pagamentos e permissões) com testes de integração realistas (estilo request specs), utilizando banco de teste real e mockando apenas serviços externos. | [`SKILL.md`](skills/integration-testing/SKILL.md) |
| `payment-idempotency` | Use esta skill para auditar, implementar e garantir idempotência em webhooks e endpoints de pagamento, cobrança, liberação de planos, créditos ou reembolsos (Stripe, Pagar.me, Asaas, Mercado Pago, etc.). | [`SKILL.md`](skills/payment-idempotency/SKILL.md) |
| `premium-ux-craft` | Use esta skill ao auditar, projetar ou codificar interfaces e fluxos de usuário, garantindo acabamento premium, ergonomia cognitiva, matriz completa de estados (empty, loading, error), teatro do sistema e recuperação graciosa de falhas. | [`SKILL.md`](skills/premium-ux-craft/SKILL.md) |
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
- `~/.gemini/config/skills/` (Antigravity Global)
- `~/Library/Caches/JetBrains/*/aia/agents/` (IntelliJ IDEA / Extensão Oficial Antigravity & AI Assistant)
- `~/.junie/skills/` (JetBrains Junie)
- `~/.claude/skills/` (Claude Code)
- `~/.cursor/rules/` (Cursor)
- Além de regenerar automaticamente o catálogo deste `README.md`.

#### Opção B: Vincular a um Projeto Específico
Se quiser ativar essas skills apenas dentro de um projeto/repositório de trabalho:
```bash
./sync.sh --project /caminho/do/seu-projeto
```

### 3. Como Manter Atualizado
Sempre que novas skills forem adicionadas ao repositório:
```bash
cd ~/dev/skillEletrohits && git pull && ./sync.sh
```

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
    ├── premium-ux-craft/       # Design premium, teatro do sistema e recuperação de falhas
    ├── race-condition-audit/   # Auditoria de concorrência e race conditions
    ├── safe-refactoring/       # Separação de monolitos em camadas limpas
    └── security-audit/         # Auditoria de segurança e Zero-Client Trust
```

---

## 🤝 Como Contribuir

Quer sugerir uma nova skill ou melhorar uma existente? Contribuições da comunidade são muito bem-vindas!

1. Faça um **Fork** deste repositório;
2. Crie uma branch para a sua alteração (`git checkout -b feature/minha-nova-skill`);
3. Crie a pasta em `skills/<nome-da-skill>/SKILL.md` seguindo o padrão de frontmatter YAML (`name` e `description`);
4. Faça o commit das suas alterações (`git commit -m "feat(skills): add minha-nova-skill"`);
5. Envie para o seu fork (`git push origin feature/minha-nova-skill`);
6. Abra um **Pull Request**.

> 💡 **Dica**: Não se preocupe em atualizar a tabela do `README.md` manualmente. A nossa **GitHub Action** cuida disso automaticamente assim que o seu Pull Request for aprovado e mesclado!
