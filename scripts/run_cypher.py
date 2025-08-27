"""
scripts/run_cypher.py
Run one or more Cypher files against your Neo4j database using the Python driver.

Usage:
  # Load environment (NEO4J_USERNAME/PASSWORD) from .env and run a single file
  python scripts/run_cypher.py cypher/00_constraints.cypher

  # Run multiple files in order
  python scripts/run_cypher.py cypher/00_constraints.cypher cypher/02_enrich_genres_optional.cypher

Notes:
- Requires `pip install -r requirements.txt`.
- Reads NEO4J_USERNAME, NEO4J_PASSWORD, and Bolt URI (defaults to bolt://localhost:7687).
- Prints each query block and summary stats for visibility.
"""

import os
import sys
from pathlib import Path
from neo4j import GraphDatabase
from dotenv import load_dotenv

def load_env():
    """Load .env if present and return (uri, user, password)."""
    load_dotenv()
    uri = os.getenv("NEO4J_URI", "bolt://localhost:7687")
    user = os.getenv("NEO4J_USERNAME", "neo4j")
    pwd = os.getenv("NEO4J_PASSWORD", "password")
    return uri, user, pwd

def read_cypher_file(path: Path) -> str:
    """
    Read a .cypher file entirely as text.
    We will split on semicolons for simple batching,
    ignoring semicolons appearing inside line comments.
    """
    text = path.read_text(encoding="utf-8")
    return text

def split_queries(raw: str):
    """
    Very naive splitter: splits on ';' and keeps non-empty trimmed parts.
    Suitable for our example scripts. For complex scripts, consider a proper parser.
    """
    parts = [p.strip() for p in raw.split(";")]
    return [p for p in parts if p]

def run_file(session, file_path: Path):
    """Run all statements from a .cypher file and print summaries."""
    print(f"\n=== Running: {file_path} ===")
    raw = read_cypher_file(file_path)
    statements = split_queries(raw)

    success = 0
    for i, stmt in enumerate(statements, start=1):
        # Skip lines that are all comments or Browser commands (e.g., :param)
        if stmt.startswith("//") or stmt.startswith(":"):
            print(f"-> Skipping meta/comment block #{i}")
            continue
        print(f"-> Executing statement #{i}:\n{stmt}\n")
        try:
            result = session.run(stmt)
            # Pull the results to expose counters/summary
            _ = list(result)
            summary = result.consume()
            c = summary.counters
            print(f"   Counters: nodes_created={c.nodes_created}, nodes_deleted={c.nodes_deleted}, "
                  f"rels_created={c.relationships_created}, rels_deleted={c.relationships_deleted}, "
                  f"props_set={c.properties_set}\n")
            success += 1
        except Exception as e:
            print(f"   ERROR on statement #{i}: {e}\n")
    print(f"=== Done: {file_path} (executed {success} statements) ===\n")

def main(paths):
    uri, user, pwd = load_env()
    driver = GraphDatabase.driver(uri, auth=(user, pwd))
    try:
        with driver.session() as session:
            for p in paths:
                run_file(session, Path(p))
    finally:
        driver.close()

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python scripts/run_cypher.py <file1.cypher> [file2.cypher ...]")
        sys.exit(1)
    main(sys.argv[1:])
