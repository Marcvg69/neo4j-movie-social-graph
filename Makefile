# ----------------------------------------------------------------------
# Makefile (no collisions with ./cypher directory)
# ----------------------------------------------------------------------

NEO4J_USERNAME ?= neo4j
NEO4J_PASSWORD ?= password
NEO4J_CONTAINER ?= neo4j-movies
DC := docker compose

# Helper to run a Cypher snippet inside the container
# Usage: make run-cypher CMD='MATCH (n) RETURN count(n);'
run-cypher:
	@$(DC) exec -T $(NEO4J_CONTAINER) bash -lc "echo \"$(CMD)\" | cypher-shell -u $(NEO4J_USERNAME) -p $(NEO4J_PASSWORD)"

# Start stack and wait for the 'neo4j' service
up:
	@$(DC) up -d
	@echo "Waiting for Neo4j service to report healthy..."
	@$(DC) wait neo4j || true
	@echo "Verifying Bolt connectivity..."
	@$(MAKE) run-cypher CMD='RETURN 1;'
	@echo "Checking GDS plugin..."
	@$(MAKE) run-cypher CMD='CALL gds.version() YIELD server, edition, version RETURN server, edition, version;'

down:
	@$(DC) down

logs:
	@$(DC) logs -f $(NEO4J_CONTAINER)

status:
	@$(DC) ps

wipe:
	@$(DC) down -v

# Copy local cypher/ scripts into the container
sync-cypher:
	@$(DC) exec -T $(NEO4J_CONTAINER) bash -lc "mkdir -p /var/lib/neo4j/cypher"
	@docker cp ./cypher/. $(NEO4J_CONTAINER):/var/lib/neo4j/cypher/

constraints:
	@$(DC) exec -T $(NEO4J_CONTAINER) bash -lc "cypher-shell -u $(NEO4J_USERNAME) -p $(NEO4J_PASSWORD) -f /var/lib/neo4j/cypher/00_constraints.cypher" || true

enrich-genres:
	@$(DC) exec -T $(NEO4J_CONTAINER) bash -lc "cypher-shell -u $(NEO4J_USERNAME) -p $(NEO4J_PASSWORD) -f /var/lib/neo4j/cypher/02_enrich_genres_optional.cypher" || true

queries-basic:
	@$(DC) exec -T $(NEO4J_CONTAINER) bash -lc "cypher-shell -u $(NEO4J_USERNAME) -p $(NEO4J_PASSWORD) -f /var/lib/neo4j/cypher/02_queries_basic.cypher"

queries-aggs:
	@$(DC) exec -T $(NEO4J_CONTAINER) bash -lc "cypher-shell -u $(NEO4J_USERNAME) -p $(NEO4J_PASSWORD) -f /var/lib/neo4j/cypher/03_queries_aggregations.cypher"

updates:
	@$(DC) exec -T $(NEO4J_CONTAINER) bash -lc "cypher-shell -u $(NEO4J_USERNAME) -p $(NEO4J_PASSWORD) -f /var/lib/neo4j/cypher/04_updates.cypher"

gds:
	@$(DC) exec -T $(NEO4J_CONTAINER) bash -lc "cypher-shell -u $(NEO4J_USERNAME) -p $(NEO4J_PASSWORD) -f /var/lib/neo4j/cypher/05_gds.cypher"

# One-shot: start, sync scripts, apply constraints, add genres
init: up sync-cypher constraints enrich-genres
	@echo "Initialization complete."
