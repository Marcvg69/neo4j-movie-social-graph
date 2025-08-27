# ------------------------------------------------------------------------------
# Makefile (service vs container names fixed)
# ------------------------------------------------------------------------------

NEO4J_USERNAME ?= neo4j
NEO4J_PASSWORD ?= password

# Compose service name in docker-compose.yml
SERVICE ?= neo4j
# Container name (from .env) used for docker cp
CONTAINER ?= neo4j-movies

DC := docker compose

# Run an inline Cypher via Compose (service name!)
# Usage: make run-cypher CMD='MATCH (n) RETURN count(n);'
run-cypher:
	@$(DC) exec -T $(SERVICE) bash -lc "echo \"$(CMD)\" | cypher-shell -u $(NEO4J_USERNAME) -p $(NEO4J_PASSWORD)"

# Start and wait for health
up:
	@$(DC) up -d
	@echo "Waiting for Neo4j service to report healthy..."
	@$(DC) wait $(SERVICE) || (echo 'Neo4j not healthy yet'; exit 1)
	@echo "Verifying Bolt connectivity..."
	@$(MAKE) run-cypher CMD='RETURN 1;'
	@echo "Checking GDS plugin..."
	@$(MAKE) run-cypher CMD='CALL gds.version() YIELD server, edition, version RETURN server, edition, version;'

down:
	@$(DC) down

logs:
	@$(DC) logs -f $(SERVICE)

status:
	@$(DC) ps

# Danger: removes volumes (erases data)
wipe:
	@$(DC) down -v

# Copy local cypher/ into container (needs container name for docker cp)
sync-cypher:
	@$(DC) exec -T $(SERVICE) bash -lc "mkdir -p /var/lib/neo4j/cypher"
	@docker cp ./cypher/. $(CONTAINER):/var/lib/neo4j/cypher/

constraints:
	@$(DC) exec -T $(SERVICE) bash -lc "cypher-shell -u $(NEO4J_USERNAME) -p $(NEO4J_PASSWORD) -f /var/lib/neo4j/cypher/00_constraints.cypher" || true

enrich-genres:
	@$(DC) exec -T $(SERVICE) bash -lc "cypher-shell -u $(NEO4J_USERNAME) -p $(NEO4J_PASSWORD) -f /var/lib/neo4j/cypher/02_enrich_genres_optional.cypher" || true

queries-basic:
	@$(DC) exec -T $(SERVICE) bash -lc "cypher-shell -u $(NEO4J_USERNAME) -p $(NEO4J_PASSWORD) -f /var/lib/neo4j/cypher/02_queries_basic.cypher"

queries-aggs:
	@$(DC) exec -T $(SERVICE) bash -lc "cypher-shell -u $(NEO4J_USERNAME) -p $(NEO4J_PASSWORD) -f /var/lib/neo4j/cypher/03_queries_aggregations.cypher"

updates:
	@$(DC) exec -T $(SERVICE) bash -lc "cypher-shell -u $(NEO4J_USERNAME) -p $(NEO4J_PASSWORD) -f /var/lib/neo4j/cypher/04_updates.cypher"

gds:
	@$(DC) exec -T $(SERVICE) bash -lc "cypher-shell -u $(NEO4J_USERNAME) -p $(NEO4J_PASSWORD) -f /var/lib/neo4j/cypher/05_gds.cypher"

# Full init: start, sync scripts, apply constraints, enrich genres
init: up sync-cypher constraints enrich-genres
	@echo "Initialization complete."
