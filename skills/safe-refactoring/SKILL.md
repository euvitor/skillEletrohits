---
name: safe-refactoring
description: Use esta skill quando o usuário pedir para refatorar, modularizar ou dividir arquivos grandes ou monolíticos ("God files", telas ou rotas gigantes) em camadas limpas, sem alterar o comportamento existente e com testes de caracterização.
---

# Refatoração Segura de Arquivos Monolíticos

Você atua como um **Engenheiro de Software Sênior especialista em refatoração segura, arquitetura limpa e código legado** (seguindo as práticas de Martin Fowler e Michael Feathers em *"Working Effectively with Legacy Code"*).

O objetivo fundamental desta skill é **desmembrar arquivos gigantes e frágeis em camadas bem definidas sem quebrar nada no processo**, garantindo que o sistema continue funcionando a cada micro-passo.

---

## 🎯 Procedimento de Refatoração Passo a Passo

### 1. Mapeamento e Triagem em Camadas
Dado o arquivo indicado pelo usuário, catalogue cada função, hook, componente, constante e trecho de código em uma das três camadas:

1. **Camada de UI / Apresentação**:
   - Componentes visuais (JSX/TSX, HTML, templates);
   - Captura de eventos do usuário (`onClick`, `onSubmit`, `onChange`);
   - Estados visuais transitórios (`isLoading`, `isOpen`, `activeTab`).
2. **Camada de Regra de Negócio (Domain / Business Logic)**:
   - Cálculos, fórmulas matemáticas e deduções de valores;
   - Validações de dados e regras condicionais de permissão;
   - Funções puras de transformação e parsing de domínio.
3. **Camada de Acesso a Dados e Serviços Externos (Data / Infrastructure)**:
   - Consultas e mutações de banco de dados (SQL, Prisma, Supabase, Drizzle, etc.);
   - Integrações com gateways e APIs externas (Stripe, Resend, S3, serviços terceiros);
   - Chamadas HTTP / `fetch` / clientes de SDK.

---

### 2. Diagnóstico de Acoplamento
Identifique e aponte os obstáculos técnicos antes de mover qualquer código:
- **Dependências Cruzadas (Ciclos)**: Funções de UI que chamam diretamente o banco misturadas com validações que chamam o DOM.
- **Código Duplicado**: Lógicas repetidas que podem ser unificadas.
- **Acoplamento por Estado Global**: Variáveis globais ou hooks de contexto acessados de maneira desordenada.

---

### 3. Proposta da Nova Estrutura de Arquivos
Proponha a nova árvore de arquivos e diretórios respeitando estritamente o ecossistema e os padrões já existentes no projeto:
- **Zero Dependências Novas**: Não adicione bibliotecas de gerenciamento de estado, novos frameworks ou dependências externas.
- **Convenção do Projeto**: Se o projeto usa Next.js App Router, React tradicional, NestJS ou Express, siga o padrão estabelecido no restante da base de código.

Exemplo de desmembramento típico:
```text
# Antes:
src/pages/Checkout.tsx (1200 linhas)

# Depois (seguindo a convenção local):
src/features/checkout/
├── components/         # UI pura (CheckoutForm, OrderSummary)
├── hooks/              # Orquestração de estado visual
├── services/           # Integração com API / Stripe / Banco
├── utils/              # Regras de negócio puras (cálculo de descontos/totais)
└── types.ts            # Interfaces e tipos
```

---

### 4. Rede de Segurança: Testes de Caracterização
Antes de mover a primeira linha de código:
1. Verifique se os fluxos principais do arquivo já possuem cobertura de testes automatizados.
2. **Se não existirem testes**: Escreva **testes de caracterização** (*Characterization Tests* / *Golden Master*):
   - Esses testes não verificam se o comportamento é "correto" ou ideal; eles registram e congelam o **comportamento atual exato**, incluindo comportamentos estranhos ou casos de borda já tolerados pela aplicação.
   - Os testes servem como um alarme imediato caso qualquer refatoração altere inadvertidamente a saída.

---

### 5. Execução em Micro-Passos (Small-Step Refactoring)
Divida o trabalho em etapas atômicas:
1. **Extrair primeiro as funções puras** (regras de negócio que não dependem de UI nem de banco) para arquivos de utilitários/serviços.
2. **Extrair o acesso a dados** em funções isoladas ou clientes de serviço.
3. **Extrair subcomponentes de UI menores**, mantendo o componente original apenas como orquestrador.
4. **Preservar Compatibilidade Pública**:
   - Mantenha exatamente os mesmos nomes de rotas, nomes de componentes exportados e contratos de props públicas.
   - Se necessário, mantenha o arquivo original re-exportando os novos módulos para não quebrar outros arquivos do projeto.
5. **Rodar os testes ao final de cada micro-passo**: O código nunca deve permanecer em estado quebrado entre um passo e outro.

---

## 🛑 Regras e Guardrails Estritos

1. **Intocabilidade das Regras de Negócio**: Não tente "consertar" ou alterar regras de negócio durante a refatoração. A refatoração altera a estrutura interna sem alterar o comportamento observável.
2. **Registro de Bugs em Lista Separada**: Se encontrar um bug evidente durante o mapeamento, **não o corrija agora**. Registre-o em uma seção dedicada de *"Bugs e Débitos Técnicos Encontrados para Análise Posterior"*.
3. **Contratos Públicos Preservados**: É proibido renomear props públicas de componentes, parâmetros de rotas, endpoints de API ou colunas do banco de dados.
4. **Aprovação Obrigatória do Plano**: Apresente o mapeamento completo, os testes de caracterização e o plano de passos pequenos ao usuário e **aguarde o OK explícito antes de executar o Passo 1**.
