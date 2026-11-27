#!/usr/bin/env python3
"""
validate-skills.py
Valida todas as skills organizadas por álbuns em skills/<album>/<skill>/SKILL.md garantindo:
- Álbuns válidos com ao menos 1 skill
- Existência de SKILL.md com conteúdo não vazio
- Frontmatter YAML válido com 'name' e 'description'
- 'name' em formato slug (a-z, 0-9, hifens) e idêntico ao nome da pasta da skill
- Ausência de nomes duplicados entre todos os álbuns (case-insensitive)
"""

import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
SKILLS_DIR = REPO_ROOT / "skills"
SLUG_PATTERN = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")


def validate_skill_dir(album_name: str, skill_dir: Path, seen_names: dict[str, str]) -> list[str]:
    errors: list[str] = []
    folder_name = skill_dir.name
    label = f"{album_name}/{folder_name}"
    skill_md = skill_dir / "SKILL.md"

    if not SLUG_PATTERN.match(folder_name):
        errors.append(
            f"[{label}] Nome da pasta inválido. Use apenas letras minúsculas, números e hifens (ex: minha-skill)."
        )

    if not skill_md.exists():
        errors.append(f"[{label}] Arquivo obrigatório 'SKILL.md' não encontrado.")
        return errors

    content = skill_md.read_text(encoding="utf-8")
    if not content.strip():
        errors.append(f"[{label}] 'SKILL.md' está vazio.")
        return errors

    match = re.match(r"^---\s*\n(.*?)\n---\s*\n(.*)$", content, re.DOTALL)
    if not match:
        errors.append(
            f"[{label}] Frontmatter YAML ausente ou malformado (deve começar com '---' e fechar com '---')."
        )
        return errors

    frontmatter, body = match.group(1), match.group(2)

    name_match = re.search(r"^name:\s*([^\n]+)", frontmatter, re.MULTILINE)
    if not name_match or not name_match.group(1).strip():
        errors.append(f"[{label}] Campo obrigatório 'name' ausente no frontmatter.")
    else:
        skill_name = name_match.group(1).strip().strip("\"'")
        if not SLUG_PATTERN.match(skill_name):
            errors.append(
                f"[{label}] Campo 'name' ('{skill_name}') deve estar em formato slug (a-z, 0-9, hifens)."
            )
        if skill_name != folder_name:
            errors.append(
                f"[{label}] Campo 'name' ('{skill_name}') deve ser idêntico ao nome da pasta ('{folder_name}')."
            )
        lowered = skill_name.lower()
        if lowered in seen_names:
            errors.append(
                f"[{label}] Nome duplicado '{skill_name}' (já declarado em '{seen_names[lowered]}')."
            )
        else:
            seen_names[lowered] = label

    desc_match = re.search(
        r"^description:\s*(?:>-\s*|\|\s*|\s*)(.*?)(?=\n[a-zA-Z0-9_-]+:|\Z)",
        frontmatter,
        re.DOTALL | re.MULTILINE,
    )
    if not desc_match:
        errors.append(
            f"[{label}] Campo obrigatório 'description' ausente no frontmatter."
        )
    else:
        desc = " ".join(
            line.strip() for line in desc_match.group(1).splitlines() if line.strip()
        ).strip("\"'")
        if len(desc) < 10:
            errors.append(
                f"[{label}] Campo 'description' muito curto ou vazio (mínimo 10 caracteres)."
            )

    if not body.strip():
        errors.append(
            f"[{label}] O corpo Markdown após o frontmatter está vazio."
        )

    return errors


def main() -> int:
    if not SKILLS_DIR.exists():
        print(f"❌ Diretório {SKILLS_DIR} não encontrado.")
        return 1

    all_errors: list[str] = []
    seen_names: dict[str, str] = {}
    album_count = 0
    skill_count = 0

    for album_entry in sorted(SKILLS_DIR.iterdir()):
        if album_entry.name == ".DS_Store":
            continue
        if not album_entry.is_dir():
            all_errors.append(
                f"[{album_entry.name}] Item inesperado na raiz de 'skills/' (esperado apenas diretórios de álbuns, ex: vol-1-core)."
            )
            continue

        if not SLUG_PATTERN.match(album_entry.name):
            all_errors.append(
                f"[{album_entry.name}] Nome de álbum inválido. Use apenas letras minúsculas, números e hifens."
            )

        album_count += 1
        album_skills = 0
        for skill_entry in sorted(album_entry.iterdir()):
            if skill_entry.name == ".DS_Store":
                continue
            if not skill_entry.is_dir():
                all_errors.append(
                    f"[{album_entry.name}/{skill_entry.name}] Item inesperado dentro do álbum (esperado apenas pastas de skills)."
                )
                continue

            album_skills += 1
            skill_count += 1
            all_errors.extend(validate_skill_dir(album_entry.name, skill_entry, seen_names))

        if album_skills == 0:
            all_errors.append(f"[{album_entry.name}] Álbum vazio (nenhuma skill encontrada).")

    if skill_count == 0:
        print("❌ Nenhuma skill encontrada em 'skills/<album>/<skill>/'.")
        return 1

    if all_errors:
        print(f"❌ Falha na validação ({len(all_errors)} erro(s) encontrado(s)):\n")
        for err in all_errors:
            print(f"  - {err}")
        return 1

    print(
        f"✔ {skill_count} skills em {album_count} álbum(ns) validadas com sucesso! Nenhum conflito ou erro encontrado."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
