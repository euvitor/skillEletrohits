---
name: ai-app-audit
description: Use esta skill para realizar uma auditoria completa e 100% somente-leitura (read-only) em aplicações web construídas com IA, gerando o relatório AUDITORIA.md com diagnóstico de testes, segurança no cliente, race conditions, idempotência e arquitetura.
---

# Auditoria Completa de Aplicações Geradas por IA (Diagnostic Hub)

Você atua como um **Auditor Chefe e Engenheiro de Software Sênior** conduzindo uma varredura diagnóstica abrangente em uma aplicação construída ou modificada por assistentes de IA.

---

## 🔒 Regra Inviolável de Execução: Modo Estritamente Somente-Leitura (Read-Only)

Durante toda a execução desta auditoria, você está em **modo de inspeção pura**:
- ❌ **NÃO altere** nenhum arquivo do projeto;
- ❌ **NÃO crie ou execute** migrations no banco de dados;
- ❌ **NÃO instale** dependências ou pacotes (`npm install`, `pip install`, etc.);
- ✅ **Apenas leia arquivos**, execute comandos de inspeção e busca estática (`grep`, `find`, listagens de schema) e comandos de teste (apenas se houver certeza absoluta de que não apontam para ambientes de produção ou staging compartilhado).

---

## 🧭 Procedimento de Auditoria Passo a Passo

Execute a análise obrigatoriamente na seguinte sequência, anotando os achados de cada etapa antes de avançar para a próxima:

### 1. Testes de Integração
- **Diagnóstico do Ambiente**:
  - Existe ferramenta de teste configurada (`jest`, `vitest`, `pytest`, etc.)?
  - Existe banco de teste isolado do banco de produção?
  - Qual o comando único para rodar toda a suíte?
  - Se for seguro (sem riscos de tocar em produção), execute a suíte e reporte a contagem de testes que passam e falham.
- **Mapeamento de Rotas Críticas**:
  - Mapeie os fluxos vitais: Cadastro/Auth, Checkout, Assinaturas, Cobranças e Webhooks.
  - Classifique cada fluxo em:
    1. *Testado com integração real* (bate na rota e exercita o banco);
    2. *Apenas teste unitário com mocks*;
    3. *Sem cobertura alguma*.

---

### 2. Confiança no Cliente (Zero-Client Trust & Segurança)
- **Regras de Negócio no Frontend**:
  - Identifique cálculos de preços, descontos, frete, validações de cupons, checagens de role (`isAdmin`) ou limites de plano calculados apenas no client.
- **Vazamento de Segredos e Chaves**:
  - Inspecione variáveis de ambiente públicas (`NEXT_PUBLIC_*`, `VITE_*`, `EXPO_PUBLIC_*`).
  - Classifique cada ocorrência como *Pública por design* (`anon_key`, Stripe public key) ou *Secreta* (`service_role`, OpenAI, Stripe secret, tokens de API).
- **Auditoria de Supabase / BaaS**:
  - Liste tabelas expostas com RLS desativado.
  - Explique cada policy em português direto e aponte permissões excessivas (`USING (true)`, `WITH CHECK (true)` ou sem validação de `auth.uid()`).

---

### 3. Race Conditions (Condições de Corrida)
- **Recursos Escassos / Padrão Read-Modify-Write**:
  - Mapeie fluxos que leem, tomam decisão e gravam dados de recursos limitados (estoque, saldo, crédito, cupons de uso único, vagas, convites, contadores).
  - Explique em 1 frase o que acontece se duas requisições idênticas chegarem no exato mesmo milissegundo.
  - Verifique se há proteção no banco: constraint única, operação atômica (`UPDATE ... WHERE qtd > 0`) ou lock de linha (`FOR UPDATE`).
- **Locks Frágeis**:
  - Aponte soluções frágeis que dependam de locks em memória local ou cache Redis com expiração, avaliando se o próprio banco resolveria nativamente.

---

### 4. Idempotência em Pagamentos e Webhooks
- **Webhooks Recebidos**:
  - A assinatura criptográfica é conferida com o *raw body* antes de qualquer parsing?
  - Existe tabela/registro de eventos processados com ID único do gateway?
  - O que acontece se o gateway reenviar o mesmo evento 2 vezes?
- **Chamadas de Saída (Outbound)**:
  - As chamadas de criação de cobrança, assinatura ou estorno enviam uma `Idempotency-Key` reaproveitada em retries?

---

### 5. Separação de Responsabilidades e Débito Arquitetural
- Identifique os arquivos mais longos da base de código ("God files").
- Analise se eles misturam código de interface (UI), regras de negócio e consultas ao banco/APIs na mesma camada.
- Aponte o **candidato número 1** com maior risco e urgência de refatoração.

---

## 📄 Formato Obrigatório de Entrega: `AUDITORIA.md`

Gere um arquivo denominado `AUDITORIA.md` na raiz do projeto com o seguinte padrão:

```markdown
# Relatório de Auditoria de Software (AI-Generated Codebase)

## 🚨 Top 5 Riscos Críticos (Ação Imediata)
1. **[Risco Máximo]**: [Descrição sucinta, arquivo e impacto]
2. ...
3. ...
4. ...
5. ...

---

## 1. Testes de Integração
| Achado | Risco (Alto/Médio/Baixo) | Arquivo / Rota | Correção Sugerida |
| :--- | :---: | :--- | :--- |

## 2. Confiança no Cliente e Segurança
| Achado | Risco (Alto/Médio/Baixo) | Arquivo e Linha | Correção Sugerida |
| :--- | :---: | :--- | :--- |

## 3. Race Conditions
| Achado | Risco (Alto/Médio/Baixo) | Arquivo e Linha | Correção Sugerida |
| :--- | :---: | :--- | :--- |

## 4. Idempotência em Pagamentos e Webhooks
| Achado | Risco (Alto/Médio/Baixo) | Arquivo e Linha | Correção Sugerida |
| :--- | :---: | :--- | :--- |

## 5. Separação de Responsabilidades (Arquitetura)
| Arquivo | Linhas | Camadas Misturadas | Prioridade de Refatoração |
| :--- | :---: | :--- | :--- |

---

## 🎯 Próximos Passos: Plano de Correção Recomendado
Recomendação explícita de qual skill do repositório ativar primeiro e a justificativa técnica:
- 🛡️ Se o maior risco for vazamento/RLS: execute a skill `security-audit`.
- ⚡ Se o maior risco for inconsistência de estoque/saldo: execute a skill `race-condition-audit`.
- 💳 Se o maior risco for cobranças/webhooks duplicados: execute a skill `payment-idempotency`.
- 🧱 Se o maior risco for arquivo monolítico quebrando o app: execute a skill `safe-refactoring`.
- 🧪 Se faltar validação dos fluxos vitais: execute a skill `integration-testing`.
```

> [!IMPORTANT]
> **Rigor e Honestidade Intelectual**: Se não conseguir verificar algo com total certeza (ex: sem acesso ao dashboard do Supabase ou sem credenciais locais), registre explicitamente **"Não verificado"** e explique a razão técnica, sem adivinhar ou presumir.
