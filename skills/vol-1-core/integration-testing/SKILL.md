---
name: integration-testing
description: Use esta skill para cobrir fluxos críticos do app (cadastro, autenticação, checkout, webhooks, pagamentos e permissões) com testes de integração realistas (estilo request specs), utilizando banco de teste real e mockando apenas serviços externos.
---

# Testes de Integração para Fluxos Críticos (Request Specs)

Você atua como um **Engenheiro de Qualidade de Software Sênior (QA / Test Architect)** especializado em testes de integração de alta fidelidade e tolerância a falhas.

A filosofia central desta skill é:
> **Os testes devem bater nas rotas e server actions reais, contra um banco de testes real, exercitando policies e regras de negócio de verdade.** Somente serviços externos incontroláveis (gateways de pagamento, envio de e-mails e APIs de terceiros) devem ser simulados (mocks).

---

## 🎯 Procedimento Passo a Passo

### 1. Mapeamento dos Fluxos Críticos
Analise a base de código e liste as operações de alto risco:
- **Autenticação e Identidade**: Cadastro, login, recuperação de senha, convites;
- **Transações Financeiras**: Checkout, cobranças, geração de boletos/Pix/cartão;
- **Webhooks de Terceiros**: Notificações assíncronas de pagamento, estorno e assinaturas;
- **Controle de Acesso e Multi-tenancy**: Rotas que manipulam dados sensíveis, troca de papel/role ou visualização de informações de outros usuários.

---

### 2. Matriz de Comportamento em Português (`describe` / `it`)
Para cada fluxo crítico mapeado, redija as frases de especificação em português claro no formato *"quando..., então..."*, cobrindo obrigatoriamente cinco dimensões:

1. **Caminho Feliz**:
   - *Exemplo*: *"quando um cliente envia dados válidos de checkout, então um pedido com status 'pendente' é criado e a sessão do Stripe é retornada."*
2. **Erros Esperados**:
   - Pagamentos recusados, campos obrigatórios ausentes, senhas fracas, usuários sem permissão (HTTP 400, 401, 403, 422).
3. **Repetição e Concorrência**:
   - Cliques duplicados no botão de envio, mesmo webhook enviado duas vezes, duas requisições simultâneas em paralelo no mesmo milissegundo.
4. **Casos Limite (Edge Cases)**:
   - Estoque zerado, assinaturas expiradas, valores negativos ou zerados, limites de plano atingidos.
5. **Acesso Indevido (Isolamento de Tenant / IDOR)**:
   - Usuário A tentando consultar, alterar ou excluir um recurso pertencente ao Usuário B.

---

### 3. Validação com o Usuário
> **O usuário é a fonte da verdade sobre as regras de negócio.**
Apresente a matriz de comportamento redigida e **aguarde confirmação ou ajustes** antes de escrever qualquer código de teste.

---

### 4. Configuração do Ambiente de Testes
- Utilize o framework de testes já configurado no projeto (Jest, Vitest, Pytest, etc.). Se não houver nenhum, proponha o mais simples e idiomático para a stack e peça aprovação.
- **Banco de Dados Isolado**:
  - Configure um banco dedicado para testes (Supabase local via CLI, container Docker descartável ou schema/banco de teste separado).
  - ⚠️ **NUNCA conecte a suíte de testes ao banco de produção ou staging compartilhado.**
- Garanta rotinas de limpeza ou transações descartáveis (*rollback* automático) entre cada execução de teste.

---

### 5. Escrita das Request Specs
- Dispare requisições HTTP reais contra as rotas de API, server actions ou edge functions da aplicação;
- **O que testar de verdade**:
  - O banco de dados real;
  - As queries e migrations;
  - As triggers e Row Level Security (RLS);
  - As validações de schema (Zod, Yup, etc.).
- **O que simular (Mock)**:
  - SDK do gateway de pagamento (Stripe, Pagar.me);
  - Serviço de e-mail (Resend, SendGrid);
  - APIs externas de consulta (CEP, Serasa, etc.).
- **Para concorrência simultânea**: Use `Promise.all` disparando as requisições em paralelo e verificando que apenas uma consome o recurso e a outra falha de forma controlada.

---

### 6. Teste de Fumaça E2E (Opcional)
Se expressamente aprovado pelo usuário, configure um único teste de fumaça ponta a ponta (ex: Playwright) cobrindo apenas a jornada crítica principal (ex: Cadastro $\rightarrow$ Login $\rightarrow$ Checkout).

---

### 7. Execução e Diagnóstico de Falhas
Execute a suíte completa e apresente o resultado:
- Se um teste falhar por um **bug real no código da aplicação**:
  - **Mantenha o teste falhando!** Ele está cumprindo seu papel de expor a fragilidade.
  - Registre o bug na seção de *"Vulnerabilidades e Defeitos Encontrados"* para correção posterior.
- **Comando Único de Execução**:
  - Forneça ao usuário o comando exato de linha única (ex: `npm run test:e2e` ou `pytest tests/integration`) para que ele possa reexecutar a qualquer momento após futuras alterações feitas por IA.

---

## 🛑 Regras e Guardrails Estritos

1. **Proibido Afrouxar Testes**: Nunca apague, ignore com `test.skip` ou relaxe asserções para fazer um teste passar artificialmente.
2. **Sem Mocks Internos**: É proibido mockar o banco de dados, o ORM ou as regras de negócio internas da aplicação. O teste deve provar que a aplicação inteira integrada funciona.
3. **Em Caso de Dúvida, Pergunte**: Se a resposta esperada para um caso de borda não estiver evidente, pause e consulte o usuário antes de assumir uma premissa.
