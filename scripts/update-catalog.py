#!/usr/bin/env python3
"""
update-catalog.py
Varre os diretórios em skills/*/SKILL.md, extrai o nome e a descrição do frontmatter YAML,
e atualiza a tabela entre <!-- AUTO_SKILLS_TABLE:START --> e <!-- AUTO_SKILLS_TABLE:END --> no README.md.
"""

import os
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
SKILLS_DIR = REPO_ROOT / "skills"
README_FILE = REPO_ROOT / "README.md"

START_MARKER = "<!-- AUTO_SKILLS_TABLE:START -->"
END_MARKER = "<!-- AUTO_SKILLS_TABLE:END -->"

def parse_frontmatter(skill_md_path: Path):
    content = skill_md_path.read_text(encoding="utf-8")
    match = re.match(r"^---\s*\n(.*?)\n---\s*\n", content, re.DOTALL)
    if not match:
        return None, None
    
    frontmatter = match.group(1)
    
    # Extrair 'name:'
    name_match = re.search(r"^name:\s*([^\n]+)", frontmatter, re.MULTILINE)
    name = name_match.group(1).strip() if name_match else skill_md_path.parent.name
    
    # Extrair 'description:' (suporta linha única ou bloco)
    desc_match = re.search(r"^description:\s*(?:>-\s*|\s*)(.*?)(?=\n[a-zA-Z0-9_-]+:|\Z)", frontmatter, re.DOTALL | re.MULTILINE)
    if desc_match:
        # Limpar quebras de linha e espaços extras
        desc = " ".join(line.strip() for line in desc_match.group(1).splitlines() if line.strip())
    else:
        desc = "Sem descrição."
        
    return name, desc

def main():
    if not SKILLS_DIR.exists():
        print(f"Diretório {SKILLS_DIR} não encontrado.")
        sys.exit(1)
        
    skills = []
    for skill_path in sorted(SKILLS_DIR.iterdir()):
        if skill_path.is_dir():
            skill_md = skill_path / "SKILL.md"
            if skill_md.exists():
                name, desc = parse_frontmatter(skill_md)
                if name:
                    rel_link = f"skills/{skill_path.name}/SKILL.md"
                    skills.append((name, desc, rel_link))
                    
    # Ordenar: colocar ai-app-audit (orquestrador) no topo, e as demais em ordem alfabética
    def sort_key(item):
        name = item[0]
        if name == "ai-app-audit":
            return (0, name)
        return (1, name)
        
    skills.sort(key=sort_key)
    
    # Montar tabela Markdown
    table_lines = [
        START_MARKER,
        "| Skill | Descrição | Arquivo |",
        "| :--- | :--- | :--- |",
    ]
    
    for name, desc, link in skills:
        badge = "🪩 " if name == "ai-app-audit" else ""
        table_lines.append(f"| {badge}`{name}` | {desc} | [`SKILL.md`]({link}) |")
        
    table_lines.append(END_MARKER)
    new_table_str = "\n".join(table_lines)
    
    if not README_FILE.exists():
        print(f"Arquivo {README_FILE} não encontrado.")
        sys.exit(1)
        
    readme_content = README_FILE.read_text(encoding="utf-8")
    
    pattern = re.compile(
        rf"{re.escape(START_MARKER)}.*?{re.escape(END_MARKER)}",
        re.DOTALL
    )
    
    if pattern.search(readme_content):
        updated_content = pattern.sub(new_table_str, readme_content)
    else:
        # Se os marcadores ainda não existirem, insere após a introdução
        print("Marcadores não encontrados, inserindo marcadores no README.md...")
        updated_content = readme_content.replace(
            "## 📁 Estrutura do Repositório",
            f"## 📚 Catálogo de Skills\n\n{new_table_str}\n\n## 📁 Estrutura do Repositório"
        )
        
    README_FILE.write_text(updated_content, encoding="utf-8")
    print(f"✔ Tabela atualizada com {len(skills)} skills no README.md!")

if __name__ == "__main__":
    main()
