#!/usr/bin/env python3

from __future__ import annotations

import re
import subprocess
from pathlib import Path


UPSTREAM_REPO = "https://github.com/jgarza9788/niri-animation-collection.git"
FORBIDDEN_KEYS_BY_BLOCK = {
    "window-open": {"duration-ms", "curve"},
    "window-close": {"duration-ms", "curve"},
    "window-resize": {"duration-ms", "curve"},
    "screenshot-ui-open": {"curve"},
}


def run(command: list[str], cwd: Path | None = None) -> None:
    subprocess.run(command, cwd=cwd, check=True)


def ensure_source_repo(source_repo: Path) -> None:
    if (source_repo / ".git").exists():
        try:
            run(["git", "-C", str(source_repo), "pull", "--ff-only", "--quiet"])
        except subprocess.CalledProcessError:
            pass
        return

    source_repo.parent.mkdir(parents=True, exist_ok=True)
    run(["git", "clone", "--depth=1", UPSTREAM_REPO, str(source_repo)])


def atom(token: str):
    if token.startswith('"') and token.endswith('"') and len(token) >= 2:
        return ("string", token[1:-1])
    if re.fullmatch(r"-?(?:\d+\.\d+|\d+)", token):
        return ("number", token)
    if token in {"true", "false"}:
        return ("bool", token)
    return ("string", token)


def render_value(value, indent: int = 0) -> str:
    kind = value[0]
    if kind == "string":
        return '"' + value[1].replace('"', '\\"') + '"'
    if kind == "number":
        return value[1]
    if kind == "bool":
        return value[1]
    if kind == "list":
        return "[ " + " ".join(render_value(item, indent) for item in value[1]) + " ]"
    if kind == "attrset":
        lines = ["{"]
        for key, child in value[1]:
            lines.append(" " * (indent + 2) + f"{key} = {render_value(child, indent + 2)};")
        lines.append(" " * indent + "}")
        return "\n".join(lines)
    if kind == "raw":
        body = value[1].replace("''", "'''")
        return "''\n" + body + "\n''"
    raise ValueError(f"Unsupported value kind: {kind}")


def parse_shader(lines: list[str], start_index: int):
    line = lines[start_index]
    first_quote = line.find('"')
    tail = line[first_quote + 1 :]
    shader_lines: list[str] = []

    if tail.strip().endswith('"') and tail.count('"') >= 1:
        inner = tail.rsplit('"', 1)[0]
        if inner:
            shader_lines.append(inner)
        return ("raw", "\n".join(shader_lines)), start_index + 1

    if tail:
        shader_lines.append(tail)

    index = start_index + 1
    while index < len(lines):
        current_line = lines[index]
        stripped = current_line.strip()

        if stripped == '"':
            index += 1
            break

        if stripped.endswith('"') and stripped != '"':
            shader_lines.append(current_line[: current_line.rfind('"')])
            index += 1
            break

        shader_lines.append(current_line)
        index += 1

    return ("raw", "\n".join(shader_lines).rstrip("\n")), index


def parse_block(lines: list[str], start_index: int, block_name: str | None = None):
    items = []
    index = start_index
    in_block_comment = False

    while index < len(lines):
        raw_line = lines[index]
        line = raw_line.strip()

        if in_block_comment:
            if "*/" in line:
                in_block_comment = False
            index += 1
            continue

        if not line:
            index += 1
            continue

        if line.startswith("/*"):
            if "*/" not in line:
                in_block_comment = True
            index += 1
            continue

        if line.startswith("//"):
            index += 1
            continue

        if line == "}":
            return ("attrset", items), index + 1

        if line.startswith("custom-shader"):
            shader, index = parse_shader(lines, index)
            items.append(("custom-shader", shader))
            continue

        nested_block = re.match(r"([A-Za-z0-9_-]+)\s*\{$", line)
        if nested_block:
            key = nested_block.group(1)
            child, index = parse_block(lines, index + 1, key)
            items.append((key, child))
            continue

        property_match = re.match(r"([A-Za-z0-9_-]+)\s+(.*)$", line)
        if property_match:
            key, rest = property_match.group(1), property_match.group(2)
            forbidden_keys = FORBIDDEN_KEYS_BY_BLOCK.get(block_name, set())
            if key in forbidden_keys:
                index += 1
                continue

            tokens = re.findall(r'"[^"]*"|\S+', rest)
            if key == "spring" and any("=" in token for token in tokens):
                spring_items = []
                for token in tokens:
                    if "=" not in token:
                        continue
                    spring_key, spring_value = token.split("=", 1)
                    spring_items.append((spring_key, atom(spring_value)))
                items.append((key, ("attrset", spring_items)))
            else:
                if len(tokens) == 1:
                    value = atom(tokens[0])
                else:
                    value = ("list", [atom(token) for token in tokens])
                items.append((key, value))
            index += 1
            continue

        raise ValueError(f"Cannot parse line {index}: {raw_line!r}")

    return ("attrset", items), index


def parse_file(path: Path):
    lines = path.read_text().splitlines()
    start_index = None
    for index, line in enumerate(lines):
        if line.strip() == "animations {":
            start_index = index + 1
            break

    if start_index is None:
        raise ValueError(f"No animations block found in {path}")

    parsed, _ = parse_block(lines, start_index)
    return parsed


def main() -> int:
    script_dir = Path(__file__).resolve().parent
    source_repo = script_dir / "niri-animation-collection"
    output_path = script_dir / "generated.nix"
    presets_dir = script_dir / "presets"

    ensure_source_repo(source_repo)

    animations_dir = source_repo / "animations"
    animation_files = sorted(animations_dir.glob("*.kdl"))
    entries = []
    for path in animation_files:
        entries.append((path.stem, parse_file(path)))

    presets_dir.mkdir(parents=True, exist_ok=True)
    for existing_file in presets_dir.glob("*.nix"):
        existing_file.unlink()

    for name, parsed in entries:
        (presets_dir / f"{name}.nix").write_text(render_value(parsed, 0) + "\n")

    preset_names_path = script_dir / "preset-names.nix"
    preset_names_path.write_text(
        "[ " + " ".join(f'"{name}"' for name, _ in entries) + " ]\n"
    )

    output_lines = [
        "{",
        "  # NOTE FOR FUTURE EDITORS:",
        "  # Generated automatically from the vendored niri-animation-collection repo.",
        "  # This file is only a loader for the per-preset files in ./presets/.",
        "  # The generated presets themselves are written one file per animation so",
        "  # `programs.niri.animationPreset` can use an enum and the IDE can suggest",
        "  # the available values.",
        "  # If you add new presets with custom shaders, keep unsupported timing",
        "  # fields out of `window-open`, `window-close`, `window-resize`, and",
        "  # `screenshot-ui-open` blocks or rerun this script after syncing upstream",
        "  # changes.",
    ]

    for name, parsed in entries:
        output_lines.append(f"  {name} = import ./presets/{name}.nix;")

    output_lines.append("}")
    output_path.write_text("\n".join(output_lines) + "\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())