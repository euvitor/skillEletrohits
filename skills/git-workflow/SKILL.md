---
name: git-workflow
description: Use esta skill para planejar commits no padrão Conventional Commits, criar branches organizadas e preparar descrições de Pull Requests.
---

# Fluxo de Trabalho Git & Conventional Commits

## 1. Padrão de Commits (Conventional Commits)
Sempre sugira commits no formato:
`<tipo>(<escopo>): <descrição objetiva no imperativo>`

### Tipos Comuns:
- `feat`: Nova funcionalidade para o usuário final.
- `fix`: Correção de bug.
- `docs`: Atualizações exclusivas de documentação.
- `refactor`: Alteração de código sem mudar o comportamento externo nem corrigir bug.
- `perf`: Otimização de desempenho.
- `test`: Criação ou correção de testes automatizados.
- `chore`: Atualização de dependências, builds ou scripts de infraestrutura.

## 2. Nomenclatura de Branches
- `feat/<identificador-ou-resumo>`
- `fix/<identificador-ou-resumo>`
- `refactor/<identificador-ou-resumo>`

## 3. Checklist de Pull Request
- [ ] O código passa em todos os testes e linters locais (`npm test`, `pytest`, etc.).
- [ ] Não há logs temporários de depuração deixados para trás (`console.log`, `print`).
- [ ] A descrição do PR explica claramente **o que** mudou e o **motivo** da mudança.
