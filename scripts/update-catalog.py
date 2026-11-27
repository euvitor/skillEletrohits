#!/usr/bin/env python3
"""
update-catalog.py
Varre os álbuns e skills em skills/<album>/<skill>/SKILL.md, extrai nome e descrição
do frontmatter YAML e atualiza as tabelas agrupadas por álbum entre
<!-- AUTO_SKILLS_TABLE:START --> e <!-- AUTO_SKILLS_TABLE:END --> no README.md.
"""

import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
SKILLS_DIR = REPO_ROOT / "skills"
README_FILE = REPO_ROOT / "README.md"

START_MARKER = "<!-- AUTO_SKILLS_TABLE:START -->"
END_MARKER = "<!-- AUTO_SKILLS_TABLE:END -->"

ALBUM_TITLES = {
    "vol-1-core": "### 💿 Vol. 1 — Técnico, Segurança & Performance",
    "vol-2-estetica": "### ✨ Vol. 2 — Estética, UI/UX & Acabamento",
}


def parse_frontmatter(skill_md_path: Path):
    content = skill_md_path.read_text(encoding="utf-8")
    match = re.match(r"^---\s*\n(.*?)\n---\s*\n", content, re.DOTALL)
    if not match:
        return None, None

    frontmatter = match.group(1)

    name_match = re.search(r"^name:\s*([^\n]+)", frontmatter, re.MULTILINE)
    name = name_match.group(1).strip().strip("\"'") if name_match else skill_md_path.parent.name

    desc_match = re.search(
        r"^description:\s*(?:>-\s*|\|\s*|\s*)(.*?)(?=\n[a-zA-Z0-9_-]+:|\Z)",
        frontmatter,
        re.DOTALL | re.MULTILINE,
    )
    if desc_match:
        desc = " ".join(
            line.strip() for line in desc_match.group(1).splitlines() if line.strip()
        ).strip("\"'")
    else:
        desc = "Sem descrição."

    return name, desc


def main():
    if not SKILLS_DIR.exists():
        print(f"Diretório {SKILLS_DIR} não encontrado.")
        sys.exit(1)

    sections = [START_MARKER]
    total_skills = 0
    total_albums = 0

    for album_path in sorted(SKILLS_DIR.iterdir()):
        if not album_path.is_dir() or album_path.name == ".DS_Store":
            continue

        skills = []
        for skill_path in sorted(album_path.iterdir()):
            if skill_path.is_dir():
                skill_md = skill_path / "SKILL.md"
                if skill_md.exists():
                    name, desc = parse_frontmatter(skill_md)
                    if name:
                        rel_link = f"skills/{album_path.name}/{skill_path.name}/SKILL.md"
                        skills.append((name, desc, rel_link))

        if not skills:
            continue

        total_albums += 1
        total_skills += len(skills)

        # Manter ai-app-audit no topo do seu álbum e ordenar demais alfabeticamente
        skills.sort(key=lambda item: (0 if item[0] == "ai-app-audit" else 1, item[0]))

        album_title = ALBUM_TITLES.get(
            album_path.name, f"### 🎵 {album_path.name}"
        )
        sections.append(album_title)
        sections.append("")
        sections.append("| Skill | Descrição | Arquivo |")
        sections.append("| :--- | :--- | :--- |")
        for name, desc, link in skills:
            badge = "🪩 " if name == "ai-app-audit" else ""
            sections.append(f"| {badge}`{name}` | {desc} | [`SKILL.md`]({link}) |")
        sections.append("")

    sections.append(END_MARKER)
    new_catalog_str = "\n".join(sections)

    if not README_FILE.exists():
        print(f"Arquivo {README_FILE} não encontrado.")
        sys.exit(1)

    readme_content = README_FILE.read_text(encoding="utf-8")

    pattern = re.compile(
        rf"{re.escape(START_MARKER)}.*?{re.escape(END_MARKER)}",
        re.DOTALL,
    )

    if pattern.search(readme_content):
        updated_content = pattern.sub(new_catalog_str, readme_content)
    else:
        print("Marcadores não encontrados no README.md.")
        sys.exit(1)

    README_FILE.write_text(updated_content, encoding="utf-8")
    print(f"✔ Catálogo atualizado com {total_skills} skills em {total_albums} álbum(ns) no README.md!")


if __name__ == "__main__":
    main()
