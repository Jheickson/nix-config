#!/usr/bin/env python3

from pathlib import Path


FORBIDDEN_BLOCKS = {
    "window-open",
    "window-close",
    "window-resize",
}

FORBIDDEN_KEYS = {
    "duration-ms",
    "curve",
}


def main() -> None:
    target_path = Path(__file__).with_name("generated.nix")
    lines = target_path.read_text().splitlines()

    output_lines = []
    block_stack = []
    current_block = None
    skip_comment_block = False

    for raw_line in lines:
        line = raw_line.strip()

        if skip_comment_block:
            output_lines.append(raw_line)
            if "*/" in line:
                skip_comment_block = False
            continue

        if line.startswith("/*"):
            output_lines.append(raw_line)
            if "*/" not in line:
                skip_comment_block = True
            continue

        if line in ("{", "}"):
            if line == "}" and block_stack:
                block_stack.pop()
                current_block = block_stack[-1] if block_stack else None
            output_lines.append(raw_line)
            continue

        if line.endswith("= {"):
            key = line.split("=", 1)[0].strip()
            block_stack.append(key)
            current_block = key
            output_lines.append(raw_line)
            continue

        if current_block in FORBIDDEN_BLOCKS:
            stripped = line.rstrip(";")
            key = stripped.split("=", 1)[0].strip() if "=" in stripped else None
            if key in FORBIDDEN_KEYS:
                continue

        output_lines.append(raw_line)

    target_path.write_text("\n".join(output_lines) + "\n")


if __name__ == "__main__":
    main()