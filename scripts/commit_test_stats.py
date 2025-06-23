#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# 🤖 Make a python script hat counts the number of test modules,
# classes and methods and admonishes the user if the number reduced,
# gives a neutral comment if the number stayed the same and praises
# them if there are now more tests. It will be called by a pre-commit
# hook from git.

import ast
import json
import os
import sys
from pathlib import Path

TEST_DIR = Path(__file__).parent.parent / "tests"
STATS_FILE = Path(__file__).parent / ".test_stats.json"


def count_tests():
    """
    Counts the number of test modules, test classes, and test methods in the test directory.

    Iterates through all Python files in the specified test directory that start with "test_".
    For each file, it parses the AST to count:
      - Test modules (files starting with "test_")
      - Test classes (classes starting with "Test")
      - Test methods (functions within test classes or at module level starting with "test_")

    Returns:
        dict: A dictionary with the counts of test modules, test classes, and test methods.
            Example: {"modules": int, "classes": int, "methods": int}
    """
    modules = 0
    classes = 0
    methods = 0

    for root, _, files in os.walk(TEST_DIR):
        for file in files:
            if file.startswith("test_") and file.endswith(".py"):
                modules += 1
                with open(os.path.join(root, file), "r", encoding="utf-8") as f:
                    tree = ast.parse(f.read(), filename=file)
                    for node in ast.iter_child_nodes(tree):
                        if isinstance(node, ast.ClassDef):
                            if node.name.startswith("Test"):
                                classes += 1
                                for item in node.body:
                                    if isinstance(
                                        item, ast.FunctionDef
                                    ) and item.name.startswith("test_"):
                                        methods += 1
                        elif isinstance(node, ast.FunctionDef) and node.name.startswith(
                            "test_"
                        ):
                            methods += 1
    return {"modules": modules, "classes": classes, "methods": methods}


def load_previous_stats():
    """
    Loads statistics from a JSON file if it exists.

    Returns:
        dict or None: The loaded statistics as a dictionary if the file exists, otherwise None.
    """
    if STATS_FILE.exists():
        with open(STATS_FILE, "r") as f:
            return json.load(f)
    return None


def save_stats(stats):
    """
    Saves the provided statistics dictionary to a JSON file.

    Args:
        stats (dict): A dictionary containing statistics to be saved.
    """
    with open(STATS_FILE, "w") as f:
        json.dump(stats, f)


def compare_stats(old, new):
    """
    Compares the number of test modules, classes, and methods between two sets of statistics and prints a summary.

    Args:
        old (dict): A dictionary containing the previous counts for 'modules', 'classes', and 'methods'.
        new (dict): A dictionary containing the current counts for 'modules', 'classes', and 'methods'.

    Prints:
        A summary indicating whether the number of test modules, classes, or methods has increased, decreased, or remained unchanged.
    """
    verdict = []
    praise = False
    admonish = False
    for key in ["modules", "classes", "methods"]:
        if old[key] > new[key]:
            verdict.append(f"Number of test {key} decreased: {old[key]} -> {new[key]}")
            admonish = True
        elif old[key] < new[key]:
            verdict.append(
                f"Great! Number of test {key} increased: {old[key]} -> {new[key]}"
            )
            praise = True
        else:
            verdict.append(f"Number of test {key} unchanged: {new[key]}")
    if admonish:
        print("WARNING: Some test counts have decreased!\n" + "\n".join(verdict))
        sys.exit(1)
    elif praise:
        print("🎉 Well done! Test coverage has improved.\n" + "\n".join(verdict))
    else:
        print("Test counts unchanged.\n" + "\n".join(verdict))


def main():
    """
    Main function to compare current and previous test statistics.
    This function performs the following steps:
    1. Counts the current test statistics.
    2. Loads previously saved test statistics, if available.
    3. Compares the old and new statistics if previous stats exist.
    4. Prints a message if no previous stats are found and saves the current stats for future comparison.
    5. Saves the current test statistics.
    Returns:
        None
    """

    new_stats = count_tests()
    old_stats = load_previous_stats()
    if old_stats:
        compare_stats(old_stats, new_stats)
    else:
        print(
            "No previous test stats found. Saving current stats for future comparison."
        )
    save_stats(new_stats)


if __name__ == "__main__":
    main()
