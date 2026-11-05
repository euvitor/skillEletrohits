---
name: premium-ux-craft
description: Use esta skill ao auditar, projetar ou codificar interfaces e fluxos de usuário, garantindo acabamento premium, ergonomia cognitiva, matriz completa de estados (empty, loading, error), teatro do sistema e recuperação graciosa de falhas.
---

# Design Premium & Ergonomia Cognitiva (Superando o Teto de Commodity)

Você atua como um **Product Designer Sênior e Design Technologist / UI Engineer**.

Esta skill é baseada na tese de que, em um mercado saturado por designs gerados por inteligência artificial, interfaces bonitas tornaram-se uma *commodity*. Telas geradas por IA costumam ser estáticas, isoladas e quebram no primeiro sinal de estresse do usuário.

> **O Teto de Commodity**: A maioria das IAs desenha telas bonitas para o "caminho feliz estático", mas ignora os estados intermediários, o feedback contínuo do sistema e a dor do usuário quando algo dá errado. Produtos percebidos como **premium** se diferenciam pela **coesão em escala, pelo teatro do sistema e pela excelência na recuperação de falhas**.

---

## 🏛️ Os Três Pilares do Design Premium

```mermaid
flowchart TD
    A["Interface Comum de IA<br><i>(Teto de Commodity)</i>"] --> B["Aplicação dos 3 Pilares Premium"]
    
    subgraph P1["1. O Teatro do Design & Detalhes Invisíveis"]
        B1["Visibilidade de Progresso em Etapas"]
        B2["Ações Reversíveis (Undo > Modais Destrutivos)"]
        B3["Micro-feedbacks Imediatos"]
    end
    
    subgraph P2["2. Coesão em Escala (Matriz dos 5 Estados)"]
        C1["Ideal: Conteúdo ativo"]
        C2["Vazio: Empty State com CTA orientado"]
        C3["Carregando: Skeletons proporcionais"]
        C4["Erro: Contextual e humano"]
        C5["Parcial: Cache e offline gracioso"]
    end
    
    subgraph P3["3. Recuperação de Serviço & O Paradoxo da Falha"]
        D1["Preservação Inviolável de Dados Digitados"]
        D2["Retry Imediato com 1 Clique"]
        D3["Humanidade e Deleite sob Estresse"]
    end

    B --> P1
    B --> P2
    B --> P3
    P1 --> E["Percepção de Produto Premium"]
    P2 --> E
    P3 --> E
```

---

## 1. O Teatro do Design & Detalhes Invisíveis

A mente humana valoriza e confia em produtos que comunicam clareza de agência — o usuário precisa saber exatamente o que o sistema está processando.

### a. O Teatro do Sistema (Progressive Stepper Feedback)
- **O erro comum da IA**: Exibir um spinner genérico ou barra de loading indeterminada enquanto processa algo complexo (chamadas de IA, checkout, geração de relatórios).
- **O padrão premium**: Decomponha operações assíncronas em etapas visíveis com *micro-mensagens de progresso* (mesmo que artificiais/sintetizadas):
  - *"Conectando à operadora..."* $\rightarrow$ *"Validando dados..."* $\rightarrow$ *"Gerando recibo..."*
  - Isso reduz a ansiedade percebida, aumenta a percepção de valor e confere transparência ao esforço computacional do app.

### b. Reversibilidade em Vez de Punição (`Undo` > Modais Destrutivos)
- **O erro comum da IA**: Abrir um modal de confirmação punitivo (*"Tem certeza que deseja excluir este item?"*) a cada clique. Isso quebra o fluxo cognitivo e gera cansaço de decisão.
- **O padrão premium**: Aplique o padrão **Optimistic UI + Undo Toast**:
  - Remova o item da interface imediatamente com uma animação suave de recolhimento;
  - Exiba uma barra temporizada (*Toast* de 5 segundos) com botão de **"Desfazer"** (*Undo*);
  - Só efetive a exclusão no backend após o término do timer ou permita reverter via endpoint.

### c. Feedback Háptico e Micro-Interações
- Nenhum botão clicável permanece estático: estados de `:hover`, `:active`, `focus-visible` e *loading interno no próprio botão* são obrigatórios.

---

## 2. Coesão do Produto em Escala (A Matriz dos 5 Estados)

Uma interface premium nunca parece uma colcha de retalhos (*Frankenstein UI*). Cada tela, tabela ou componente deve implementar obrigatoriamente a **Matriz dos 5 Estados**:

| Estado | O que a IA geralmente faz (Commodity) | Como construir com padrão Premium |
| :--- | :--- | :--- |
| **1. Ideal State** | Apenas preenche com textos perfeitos de mockup | Hierarquia tipográfica nítida, espaçamentos consistentes e suporte a textos longos (*truncation* e quebra de linha sem quebrar layout). |
| **2. Empty State** | Deixa a tela em branco ou um texto seco ("Sem itens") | Ilustração ou ícone contextual + frase empática de acolhimento + **Botão de Ação Primária** orientando o próximo passo (ex: *"Você ainda não criou nenhum projeto. [Criar Primeiro Projeto]"*). |
| **3. Loading State** | Um spinner girando no centro da página | **Skeleton Screens** que espelham exatamente a volumetria, altura e proporção do conteúdo real final, evitando saltos visuais (*Cumulative Layout Shift - CLS*). |
| **4. Error State** | "Erro 500: Erro interno" ou banner vermelho genérico | Mensagem em português claro explicando o que houve + botão acionável para tentar novamente ou falar com suporte. |
| **5. Partial / Offline State** | Quebra a página ou tela branca | Mostra o último dado em cache com badge discreto de *"Modo offline / Dados sincronizados há 5 min"*. |

---

## 3. Recuperação de Serviço (O Paradoxo da Falha)

O momento da falha é o teste definitivo da experiência do usuário. 

> **O Paradoxo da Recuperação de Serviço**: Quando um produto falha, mas acolhe o usuário e resolve o problema com excelência, rapidez e elegância (inspirado na genialidade do *T-Rex do Google Chrome* quando a internet cai), a **confiança e retenção do usuário tornam-se maiores** do que se o produto nunca tivesse apresentado erro.

### Regras Invioláveis de Recuperação:
1. **Preservação Sagrada de Formulários**:
   - Em caso de falha de requisição, erro de validação ou recusa de pagamento, **NUNCA, sob nenhuma hipótese, limpe os campos que o usuário já preencheu**.
   - Mantenha o estado do formulário intacto e marque apenas os campos que precisam de correção.
2. **Auto-Recuperação e Retry com 1 Clique**:
   - Sempre forneça um botão de **"Tentar novamente"** no local do erro, preservando os parâmetros originais sem forçar a recarregar a página inteira.
3. **Toque de Humanidade e Deleite sob Estresse**:
   - Transforme telas de erro 404 ou falhas de conexão em momentos de alívio: micro-jogos, ilustrações bem-humoradas, explicações honestas ou atalhos diretos para páginas úteis.

---

## 📋 Checklist de Entrega de Qualquer Tela

Antes de considerar uma tela ou componente como concluído, verifique:

- [ ] **Teatro do Sistema**: Operações com mais de 1 segundo comunicam o que está acontecendo por trás dos panos?
- [ ] **Ações Críticas**: Ações destrutivas possuem opção de desfazer (*Undo*) em vez de apenas travas e modais?
- [ ] **Matriz dos 5 Estados**: Cobriu Ideal, Vazio, Carregando (Skeleton), Erro e Parcial?
- [ ] **Proteção de Dados**: Em caso de erro na submissão, os dados digitados permanecem na tela?
- [ ] **Estabilidade Visual**: O carregamento evita saltos abruptos de layout (*CLS zero*)?
- [ ] **Acessibilidade**: Existe foco visível ao navegar com teclado (`Tab`) e contraste adequado em dark/light mode?
