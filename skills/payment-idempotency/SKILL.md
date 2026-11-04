---
name: payment-idempotency
description: Use esta skill para auditar, implementar e garantir idempotência em webhooks e endpoints de pagamento, cobrança, liberação de planos, créditos ou reembolsos (Stripe, Pagar.me, Asaas, Mercado Pago, etc.).
---

# Idempotência em Pagamentos e Webhooks

Você atua como um **Engenheiro de Software Sênior especialista em gateways de pagamento, tolerância a falhas e consistência em sistemas financeiros distribuídos**.

O objetivo primordial desta skill é garantir que **nenhuma cobrança, liberação de plano, crédito de saldo ou disparo de e-mail seja processado mais de uma vez**, mesmo sob reenvios do gateway, falhas de rede ou requisições concorrentes idênticas.

---

## 🎯 Procedimento de Implementação Passo a Passo

### 1. Mapeamento da Superfície de Pagamentos
Varra o código e documente todos os pontos de contato financeiro:
- **Webhooks Recebidos (Inbound Webhooks)**: Endpoints que recebem notificações de gateways (Stripe, Pagar.me, Asaas, Mercado Pago, etc.).
- **Endpoints de Pagamento da Aplicação**: Endpoints expostos aos clientes que criam checkout, cobranças ou processam assinaturas.
- **Operações Críticas Derivadas**: Funções e services que:
  - Liberam ou fazem upgrade de planos de usuários;
  - Adicionam créditos/saldo à carteira;
  - Despacham e-mails transacionais (recibos, confirmações de compra).

---

### 2. Arquitetura Defensiva para Webhooks

#### a. Validação Estrita de Assinatura com Raw Body
- A assinatura do webhook (ex: `stripe-signature`) **deve** ser validada usando o corpo bruto (*raw buffer/string*) da requisição HTTP.
- **Atenção**: Nunca faça parse de JSON no body antes de validar a assinatura criptográfica, pois transformações de whitespace invalidam o HMAC.

#### b. Registro de Eventos com Chave Única no Banco
Crie ou verifique a existência de uma tabela dedicada a eventos de webhook (ex: `processed_webhook_events`):
```sql
CREATE TABLE processed_webhook_events (
    id VARCHAR(255) PRIMARY KEY, -- ID único do evento gerado pelo gateway (ex: evt_1N...)
    gateway VARCHAR(50) NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    status VARCHAR(50) NOT NULL,
    processed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

#### c. Padrão "Insert First" (Reserva Atômica do Evento)
Ao receber a notificação:
1. Tente registrar imediatamente o `event_id` na tabela de eventos antes de disparar qualquer lógica de negócio;
2. Se a inserção falhar por violação de chave primária/única (`Unique Violation / 23505`):
   - **Retorne HTTP 200 OK imediatamente** e interrompa o processamento. O gateway considerará o evento entregue e não fará novos retries.

#### d. Tolerância a Chegada Fora de Ordem (Out-of-Order Delivery)
- Webhooks chegam pela internet e não há garantia de entrega ordenada (um evento `invoice.paid` pode chegar antes de `customer.subscription.created`).
- **Diretriz**: Nunca confie cegamente apenas no payload do webhook para transições de estado críticas. Quando precisar do estado mais atual do recurso, consulte diretamente o objeto na API oficial do gateway (`stripe.subscriptions.retrieve(...)`).

#### e. Fast ACK (Resposta Imediata)
- O handler do webhook deve responder com status HTTP 2xx em menos de 2 a 3 segundos para evitar timeouts do gateway.
- Se o processamento pós-confirmação for pesado (geração de PDF, sincronização com CRM, envio de e-mails), delegue para uma fila ou tarefa em background (se o projeto já tiver essa infraestrutura).

---

### 3. Chamadas de Saída para o Gateway (Outbound Idempotency)
Ao realizar chamadas que criam ou cobram recursos no gateway (ex: cobranças, novas assinaturas, emissão de reembolsos):
- Gere e envie uma **Idempotency Key (UUID v4)** gerada no início da intenção de negócio;
- **Reaproveitamento em Retries**: Se a chamada falhar por timeout de rede ou erro 5xx do gateway, reenvie a requisição utilizando a **mesma Idempotency Key** original. Isso impede cobranças duplicadas no cartão do cliente.

Exemplo (Stripe):
```typescript
await stripe.paymentIntents.create(
  {
    amount: pedido.totalEmCentavos,
    currency: 'brl',
    customer: cliente.stripeCustomerId,
  },
  {
    idempotencyKey: `order_${pedido.id}_intent`, // Chave estável por pedido
  }
);
```

---

### 4. Endpoints Inbound de Checkout / Pedido no App
Para endpoints do seu app onde o usuário clica em "Finalizar Compra" ou "Pagar":
- Aceite o cabeçalho HTTP `Idempotency-Key` enviado pelo cliente/frontend;
- Armazene o resultado da primeira resposta com a chave e status de processamento;
- Se uma segunda requisição chegar com a mesma chave:
  - Se ainda estiver em processamento: retorne HTTP 409 Conflict ou 425 Too Early;
  - Se já concluída: retorne a resposta salva em cache/banco com o mesmo status original sem reprocessar a cobrança.

---

### 5. Testes Automatizados de Idempotência
Para cada webhook ou endpoint protegido, escreva testes automatizados cobrindo dois cenários:

#### Cenário A: Repetição Sequencial (Retries do Gateway)
Envie o mesmo payload de evento duas vezes sequencialmente e verifique que:
- Ambas as respostas retornam HTTP 200;
- A regra de negócio (liberar plano, adicionar saldo, enviar e-mail) foi executada **apenas 1 vez**.

#### Cenário B: Concorrência Simultânea Extrema (Race Conditions)
Dispare o mesmo evento simultaneamente em paralelo:
```typescript
test('deve processar o webhook apenas uma vez sob concorrência paralela', async () => {
  const eventoMock = gerarEventoStripe('evt_teste_123');

  const [res1, res2] = await Promise.all([
    enviarWebhook(eventoMock),
    enviarWebhook(eventoMock),
  ]);

  // Ambos devem receber 200 (ACK)
  expect(res1.status).toBe(200);
  expect(res2.status).toBe(200);

  // Mas o efeito colateral só pode ter acontecido UMA vez
  const registros = await buscarPlanosLiberados('usuario_123');
  expect(registros).toHaveLength(1);
});
```

---

## 🛑 Regras e Guardrails Estritos

1. **Apresentar Plano Prévio**: Apresente a lista completa de webhooks/endpoints e a estratégia de idempotência antes de alterar qualquer código.
2. **Intocabilidade Financeira**: Nunca altere valores, regras de cálculo, preços ou parâmetros de faturamento do projeto.
3. **Privacidade e LGPD**: Nunca utilize dados pessoais identificáveis (e-mail, CPF, telefone, nome) como chave de idempotência. Use sempre identificadores opacos (IDs internos de pedidos, IDs do gateway ou UUIDs v4).
