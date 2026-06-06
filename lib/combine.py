import os
import sys

# Number of lines to keep from the beginning and end of large files
HEAD_TAIL_LINES = 150

# Files to truncate (filename match) and the specific subdirectory that should be truncated
TRUNCATE_RULES = [
    {
        "filename": "config_items.dart",
        "required_subdir": "config",  # Only truncate if this subdir appears in the path
    }
]


def get_dart_files(root_dir):
    dart_files = []
    for subdir, _, files in os.walk(root_dir):
        for file in files:
            if file.endswith(".dart"):
                full_path = os.path.join(subdir, file)
                relative_path = os.path.relpath(full_path, root_dir)
                dart_files.append((full_path, relative_path))
    return dart_files


def should_truncate(relative_path: str) -> bool:
    """
    Returns True if this file matches a truncation rule.
    Checks both the filename and whether the required subdirectory
    appears anywhere in the relative path (using forward slashes for consistency).
    """
    normalized = relative_path.replace("\\", "/")
    parts = normalized.split("/")
    filename = parts[-1]
    dirs = parts[:-1]

    for rule in TRUNCATE_RULES:
        if filename == rule["filename"] and rule["required_subdir"] in dirs:
            return True
    return False


def read_truncated(full_path: str) -> str:
    """
    Reads a file and returns a truncated version:
    - First HEAD_TAIL_LINES lines
    - A notice that the file was truncated
    - Last HEAD_TAIL_LINES lines
    """
    with open(full_path, "r", encoding="utf-8") as f:
        lines = f.readlines()

    total = len(lines)

    # If the file is short enough, no truncation needed
    if total <= HEAD_TAIL_LINES * 2:
        return "".join(lines)

    head = lines[:HEAD_TAIL_LINES]
    tail = lines[total - HEAD_TAIL_LINES:]
    omitted = total - HEAD_TAIL_LINES * 2

    notice_lines = [
        "\n",
        "// " + "=" * 76 + "\n",
        f"// NOTE: This file is very large ({total} lines total).\n",
        f"//       {omitted} lines have been omitted from this combined output.\n",
        f"//       Showing first {HEAD_TAIL_LINES} and last {HEAD_TAIL_LINES} lines only.\n",
        "// " + "=" * 76 + "\n",
        "\n",
    ]

    return "".join(head) + "".join(notice_lines) + "".join(tail)


def combine_dart_files(root_dir, output_filename="combined_output.dart"):
    dart_files = get_dart_files(root_dir)
    output_path = os.path.join(root_dir, output_filename)

    with open(output_path, "w", encoding="utf-8") as outfile:
        for full_path, relative_path in sorted(dart_files):
            outfile.write(f"// BEGIN: {relative_path}\n")

            if should_truncate(relative_path):
                content = read_truncated(full_path)
                print(f"  [truncated] {relative_path}")
            else:
                with open(full_path, "r", encoding="utf-8") as infile:
                    content = infile.read()

            outfile.write(content)
            outfile.write(f"\n// END: {relative_path}\n\n")

    print(f"? Combined file written to: {output_path}")


if __name__ == "__main__":
    if len(sys.argv) > 1:
        root_directory = sys.argv[1]
    else:
        root_directory = os.getcwd()

    if not os.path.isdir(root_directory):
        print(f"? Error: {root_directory} is not a valid directory.")
        sys.exit(1)

    combine_dart_files(root_directory)
