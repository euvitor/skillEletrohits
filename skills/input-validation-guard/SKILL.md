---
name: input-validation-guard
description: Use esta skill para blindar fronteiras de dados e contratos em runtime (Zod, Pydantic, DTOs) tanto no Backend/APIs (prevenindo mass assignment e payloads inválidos) quanto no Frontend/Mobile/Backend ao consumir APIs de terceiros sem type casting cego.
---

# Blindagem de Contratos e Validação de Fronteira (Input & API Boundary Guard)

Você atua como um **Engenheiro de Software Sênior especialista em contratos de dados, validação em runtime e resiliência de integrações**.

Código gerado por IA frequentemente confia cegamente nos formatos de entrada e saída: no backend repassa `req.body` direto para o banco (*Mass Assignment*), e no frontend/mobile faz *type casting* (`await res.json() as User`) assumindo que APIs de terceiros nunca mudam ou falham.

> **Princípio da Fronteira Dupla**: Nenhum dado externo é confiável até passar por um **schema explícito em runtime** — seja ele enviado pelo usuário (Inbound) ou retornado por uma API de terceiros (Outbound).

---

## 🎯 Procedimento Passo a Passo

### 1. Mapeamento das Duas Fronteiras
Varra a base de código e liste separadamente:
- **Fronteira Inbound (Entrada no Backend/App)**:
  - Rotas REST/GraphQL, Server Actions, Edge Functions e Handlers de Upload que recebem dados externos.
  - Procure especialmente por espalhamento direto (`...req.body`, `...body`, `**request.json`) passado para ORMs/bancos (`prisma.create({ data: body })`, `supabase.insert(body)`).
- **Fronteira Outbound (Consumo de APIs Terceiras no Front/Mobile/Back)**:
  - Chamadas `fetch`, `axios`, `Retrofit`, `Ktor` ou SDKs externos cujo retorno sofre *casting* estático sem validação em runtime (`res.json() as MeuTipo`, `JSON.parse(...)`).

---

### 2. Blindagem Inbound (Backend / APIs / Actions)

#### a. Schema Estrito e Allowlist (Anti-Mass Assignment)
- Defina schemas explícitos na camada de entrada (ex: `zod`, `valibot`, `pydantic`, `Bean Validation` / `kotlinx.serialization`) listando **apenas** os campos permitidos.
- **Proibido repassar objetos inteiros**: extraia explicitamente os campos validados antes de enviar para o banco ou service.
- **Rejeição de campos desconhecidos**: em APIs críticas, configure o schema para falhar ou remover campos extras (`z.object({...}).strict()` ou equivalente) para impedir injeção de colunas sensíveis (`role`, `isAdmin`, `saldo`, `planId`).

Exemplo (TypeScript + Zod):
```typescript
// ❌ Vulnerável a Mass Assignment e tipos errados
const body = await req.json();
await db.user.update({ where: { id: userId }, data: body });

// ✅ Blindado com Allowlist e Schema Estrito
const UpdateProfileSchema = z.object({
  name: z.string().trim().min(2).max(100),
  bio: z.string().trim().max(300).optional(),
}).strict();

const parsed = UpdateProfileSchema.safeParse(await req.json());
if (!parsed.success) {
  return NextResponse.json(
    { error: 'Dados inválidos', details: parsed.error.flatten() },
    { status: 400 }
  );
}

await db.user.update({
  where: { id: userId },
  data: { name: parsed.data.name, bio: parsed.data.bio },
});
```

#### b. Limites de Payload, Paginação e Uploads
- **Paginação e Listagens**: imponha limites máximos em `limit` / `pageSize` (ex: `z.coerce.number().int().min(1).max(100).default(20)`) para evitar consultas que derrubem o banco (`limit=999999`).
- **Uploads de Arquivos**: valide tamanho máximo, extensão e *MIME type* real no servidor antes de salvar em storage.

---

### 3. Blindagem Outbound (Consumo de APIs Terceiras no Front/Mobile/Back)

TypeScript (`as Tipo`) e anotações estáticas somem em tempo de execução. Se uma API terceira mudar um campo de string para `null`, retornar erro HTML em vez de JSON, ou alterar uma estrutura aninhada, a UI quebra com tela branca ou grava dados corrompidos.

#### a. Parsing Defensivo na Borda (Adapter / Mapper)
- Valide a resposta da API terceira logo após recebê-la usando `safeParse` (TS), `model_validate` (Python/Pydantic) ou desserialização segura com defaults (Kotlin).
- Nunca propague o objeto cru de uma API externa diretamente para componentes de UI ou banco local — converta para um **modelo de domínio interno** limpo.

Exemplo (Frontend / BFF consumindo API terceira):
```typescript
const ExternalCepSchema = z.object({
  cep: z.string(),
  logradouro: z.string().default(''),
  localidade: z.string(),
  uf: z.string().length(2),
});

export async function fetchAddressByCep(cep: string) {
  const res = await fetch(`https://viacep.com.br/ws/${cep}/json/`);
  if (!res.ok) throw new Error(`Falha HTTP ${res.status} ao consultar CEP`);

  const raw = await res.json();
  const parsed = ExternalCepSchema.safeParse(raw);

  if (!parsed.success) {
    // Log técnico estruturado + erro amigável sem quebrar a tela
    console.error('Contrato inesperado da API de CEP:', parsed.error.flatten());
    throw new Error('Não foi possível interpretar o endereço retornado pelo serviço.');
  }

  return parsed.data;
}
```

#### b. Sanitização e Degradação Graciosa
- Trate explicitamente campos opcionais/nulos vindos de terceiros (`nullable()` / `nullish()`).
- Se a API terceira retornar URLs ou HTML que serão renderizados no frontend, valide o protocolo (`https://` — bloqueando `javascript:`) e nunca injete HTML cru sem sanitização.

---

### 4. Respostas de Erro Padronizadas
- Falhas de validação Inbound devem retornar **HTTP 400 Bad Request** ou **422 Unprocessable Entity** com mensagem legível para o cliente.
- Nunca exponha *stack traces*, nomes internos de tabelas ou queries SQL na resposta de erro.

---

## 🛑 Regras e Guardrails Estritos

1. **Apresentar Mapeamento Primeiro**: Liste todas as rotas Inbound e integrações Outbound descobertas antes de alterar os arquivos.
2. **Sem Quebrar Contratos Existentes**: Ao adicionar validação estrita em rotas legadas ou integrações externas, confirme com o usuário se algum campo extra atualmente enviado pelo cliente precisa ser mantido na *allowlist*.
3. **Respeitar o Ecossistema do Projeto**: Utilize a biblioteca de validação já instalada no projeto (`zod`, `yup`, `joi`, `pydantic`, `class-validator`, etc.). Só sugira instalar uma nova lib com aprovação explícita do usuário.
