---
name: architecture-decision
description: Use esta skill para documentar, estruturar ou propor decisões técnicas e de arquitetura de software (ADR - Architecture Decision Record).
---

# Architecture Decision Record (ADR)

Ao propor mudanças técnicas estruturantes (como troca de banco de dados, adoção de novas bibliotecas ou novos padrões de design), estruture a proposta no formato ADR:

## Modelo de Documento

### ADR-[Número]: [Título Sucinto da Decisão]

* **Status**: [Proposto | Aceito | Depreciado | Substituído]
* **Data**: [AAAA-MM-DD]
* **Contexto**:
  * Qual problema ou desafio técnico estamos tentando resolver?
  * Quais são as restrições e premissas existentes?
* **Decisão Proposta**:
  * Qual solução foi escolhida e como ela será implementada?
* **Alternativas Analisadas**:
  * Alternativa A (e por que não foi escolhida)
  * Alternativa B (e por que não foi escolhida)
* **Consequências**:
  * **Vantagens (Prós)**: O que ganhamos com essa escolha.
  * **Desvantagens / Riscos (Contras)**: Custos, complexidade adicional ou trade-offs.
