import os
import re
import sys

def strip_lua_comments(code):
    # Remove multi-line comments
    code = re.sub(r'--\[\[.*?\]\]', '', code, flags=re.DOTALL)
    # Remove single-line comments
    code = re.sub(r'--.*$', '', code, flags=re.MULTILINE)
    # Remove polyfill declarations
    code = re.sub(r'function\s+IsInRaid\s*\(.*?\)', '', code)
    return code

def test_addon_sanity():
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    print(f"Testing addon directory: {base_dir}")

    # 1. Verify required documentation files
    required_docs = [
        "README.md", "CHANGELOG.md", "LICENSE", "NOTICE.md",
        "API.md", "AGENTS.md", "INSTALL.md", "SECURITY.md",
        "ECOSYSTEM_REGISTRY.md", ".gitignore", ".gitattributes"
    ]
    for doc in required_docs:
        path = os.path.join(base_dir, doc)
        assert os.path.exists(path), f"Missing required file: {doc}"
    print("[PASS] All required repository documentation files exist.")

    # 2. Check Lua files for forbidden Retail APIs (excluding comments and method names)
    for root, dirs, files in os.walk(base_dir):
        if ".git" in root or "Tests" in root or "Libs" in root:
            continue
        for f in files:
            if f.endswith(".lua"):
                file_path = os.path.join(root, f)
                with open(file_path, "r", encoding="utf-8", errors="ignore") as lf:
                    raw_content = lf.read()
                    content = strip_lua_comments(raw_content)
                    assert not re.search(r'\bSetColorTexture\s*\(', content), f"Forbidden SetColorTexture found in {f}"
                    assert not re.search(r'\bC_Timer\.After\s*\(', content), f"Forbidden C_Timer.After found in {f}"
                    assert not re.search(r'(?<![:\.\w])IsInRaid\s*\(', content), f"Forbidden global IsInRaid found in {f}"
    print("[PASS] All Lua files adhere to 3.3.5a engine rules.")

    print("\n>>> ALL WoWPeru_BattlePass SANITY CHECKS PASSED 100% <<<")

if __name__ == "__main__":
    test_addon_sanity()
