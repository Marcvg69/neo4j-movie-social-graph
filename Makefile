# ------------------------------------------------------------------------------
# Makefile
# One-liners to start/stop Neo4j, run Cypher packs, and verify setup.
# Uses docker compose and cypher-shell inside the container.
# ------------------------------------------------------------------------------

# Allow overriding these from the environment if desired
NEO4J_USERNAME ?= neo4j
NEO4J_PASSWORD ?= password
NEO4J_CONTAINER ?= neo4j-movies

# Compose wrapper (works with Docker Desktop)
DC := docker compose

# Convenience: run cypher-shell command inside the container
# Usage: make cypher CMD='MATCH (n) RETURN count(n);'
cypher:
	@$(DC) exec -T $(NEO4J_CONTAINER) bash -lc "echo \"$(CMD)\" | cypher-shell -u $(NEO4J_USERNAME) -p $(NEO4J_PASSWORD)"

# Start the stack and wait until healthy
up:
	@$(DC) up -d
	@echo "Waiting for Neo4j to become healthy..."
	@$(DC) wait || true
	@echo "Neo4j containers are up. Verifying basic connectivity..."
	@$(MAKE) cypher CMD='RETURN 1;'
	@echo "Checking GDS plugin..."
	@$(MAKE) cypher CMD='CALL gds.version() YIELD server, edition, version RETURN server, edition, version;'

# Stop (keeps volumes/data)
down:
	@$(DC) down

# Tail logs (Ctrl+C to exit)
logs:
	@$(DC) logs -f $(NEO4J_CONTAINER)

# Remove containers + volumes (DANGER: deletes your local DB)
wipe:
	@$(DC) down -v

# --- Initialization helpers ---------------------------------------------------

# Apply constraints/indexes
constraints:
	@$(DC) exec -T $(NEO4J_CONTAINER) bash -lc "cypher-shell -u $(NEO4J_USERNAME) -p $(NEO4J_PASSWORD) -f /var/lib/neo4j/cypher/00_constraints.cypher" || true

# Enrich genres (optional)
enrich-genres:
	@$(DC) exec -T $(NEO4J_CONTAINER) bash -lc "cypher-shell -u $(NEO4J_USERNAME) -p $(NEO4J_PASSWORD) -f /var/lib/neo4j/cypher/02_enrich_genres_optional.cypher" || true

# Run query packs
queries-basic:
	@$(DC) exec -T $(NEO4J_CONTAINER) bash -lc "cypher-shell -u $(NEO4J_USERNAME) -p $(NEO4J_PASSWORD) -f /var/lib/neo4j/cypher/02_queries_basic.cypher"

queries-aggs:
	@$(DC) exec -T $(NEO4J_CONTAINER) bash -lc "cypher-shell -u $(NEO4J_USERNAME) -p $(NEO4J_PASSWORD) -f /var/lib/neo4j/cypher/03_queries_aggregations.cypher"

updates:
	@$(DC) exec -T $(NEO4J_CONTAINER) bash -lc "cypher-shell -u $(NEO4J_USERNAME) -p $(NEO4J_PASSWORD) -f /var/lib/neo4j/cypher/04_updates.cypher"

gds:
	@$(DC) exec -T $(NEO4J_CONTAINER) bash -lc "cypher-shell -u $(NEO4J_USERNAME) -p $(NEO4J_PASSWORD) -f /var/lib/neo4j/cypher/05_gds.cypher"

# Copy your local cypher/ folder into the container at a fixed path so Make targets can find it
sync-cypher:
	# Create a working directory inside the container (no-op if exists)
	@$(DC) exec -T $(NEO4J_CONTAINER) bash -lc "mkdir -p /var/lib/neo4j/cypher"
	# Copy all local cypher files into the container
	@docker cp ./cypher/. $(NEO4J_CONTAINER):/var/lib/neo4j/cypher/

# Full init: start, sync cypher, apply constraints, add genres
init: up sync-cypher constraints enrich-genres
	@echo "Initialization complete."

# Demo run: show basic queries, aggregations, updates, and GDS examples
demo: queries-basic queries-aggs updates gds
	@echo "Demo run finished."

# Short status helper
status:
	@$(DC) ps
