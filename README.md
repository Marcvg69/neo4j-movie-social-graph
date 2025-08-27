
# Movie Social Graph (Neo4j)

A clean, data first mini project for learning graph modelling and Cypher with Neo4j.  
This repo uses the official **Movies** sample dataset as the base and adds a tidy folder of reusable Cypher scripts.

## Quick start

### 1) Start Neo4j
Use any of the following:
- **Neo4j Desktop**: Create a new DBMS with Neo4j 5.x and start it.
- **Docker**:
  ```bash
  docker run -p7474:7474 -p7687:7687 -e NEO4J_AUTH=neo4j/password neo4j:5
  ```

### 2) Load the sample data
Choose one route:

**A. Load dump (fastest)**
1. Download the Movies dump from the official repo:
   - Repo: `neo4j-graph-examples/movies`
   - File: `data/movies-40.dump`
2. Place the dump where your Neo4j installation can read it and run:
   ```bash
   neo4j-admin database load --from=movies-40.dump --database=neo4j --force
   ```
   Then start the database.

**B. Run the Cypher loader**
1. From the same repo, run `scripts/movies.cypher` via Neo4j Browser or Cypher Shell:
   ```bash
   cypher-shell -u neo4j -p password -f scripts/movies.cypher
   ```

After loading, you will have `:Movie` and `:Person` nodes, with `:ACTED_IN` and `:DIRECTED` relationships.  
This project adds `:Genre` nodes optionally and supplies query scripts.

### 3) Apply indexes and optional Genre enrichment
Open Neo4j Browser and run:
```
:play
```
or run the scripts in this folder through Cypher Shell in this order:

```bash
# Adjust host, user, pass as needed
cypher-shell -u neo4j -p password -f cypher/00_constraints.cypher
cypher-shell -u neo4j -p password -f cypher/02_enrich_genres_optional.cypher
```

> The enrichment file is optional and safe to run multiple times. It only adds Genre nodes and links where sensible, based on movie titles we know are present in the sample.

### 4) Explore and learn
Run the query packs in any order:
```bash
cypher-shell -u neo4j -p password -f cypher/02_queries_basic.cypher
cypher-shell -u neo4j -p password -f cypher/03_queries_aggregations.cypher
cypher-shell -u neo4j -p password -f cypher/04_updates.cypher
cypher-shell -u neo4j -p password -f cypher/05_gds.cypher
```

## Folder layout

```
movie-social-graph/
├─ cypher/
│  ├─ 00_constraints.cypher
│  ├─ 01_notes_loading.txt
│  ├─ 02_enrich_genres_optional.cypher
│  ├─ 02_queries_basic.cypher
│  ├─ 03_queries_aggregations.cypher
│  ├─ 04_updates.cypher
│  └─ 05_gds.cypher
└─ README.md
```

## Notes
- The base dataset sometimes lacks explicit Genre nodes. The optional enrichment file creates a small but useful set so you can exercise `(:Movie)-[:HAS_GENRE]->(:Genre)` without changing the core sample.
- All scripts are idempotent where it matters. You can rerun them safely.
- Replace credentials in commands with your own.
