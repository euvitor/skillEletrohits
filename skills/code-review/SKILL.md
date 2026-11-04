---
name: code-review
description: Use esta skill para realizar revisões de código (code reviews) detalhadas, focando em qualidade, boas práticas, segurança e legibilidade.
---

# Diretrizes de Code Review

Instruções para análise e revisão de código:

## 1. Critérios de Avaliação
- **Legibilidade e Clareza**: Nomes descritivos, funções concisas com responsabilidade única.
- **Segurança**: Validação rigorosa de inputs, proteção contra injeções e segredos/chaves de API nunca versionados.
- **Tratamento de Erros**: Tratar exceções adequadamente e com mensagens claras, sem blocos `catch` vazios.
- **Testes**: Verificar se novas regras de negócio e fluxos críticos possuem testes automatizados correspondentes.
- **Performance**: Evitar consultas redundantes, loops aninhados desnecessários e consumo excessivo de memória.

## 2. Formato do Feedback
Estruture o retorno sempre da seguinte forma:
1. **Resumo Geral**: Breve avaliação dos pontos fortes e da direção geral da mudança.
2. **Pontos Críticos (Must Fix)**: Bugs potenciais, riscos de quebra ou falhas de segurança.
3. **Sugestões de Melhoria (Nitpicks / Opcional)**: Pequenas melhorias de legibilidade, estilo ou convenção.
