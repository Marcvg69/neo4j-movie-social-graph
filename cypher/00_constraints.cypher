
/*
  00_constraints.cypher
  Light weight indexes and constraints for faster lookups.
  Safe to run multiple times due to IF NOT EXISTS.
*/

// Movie: title index (titles are not guaranteed unique in real life)
CREATE INDEX movie_title IF NOT EXISTS FOR (m:Movie) ON (m.title);
CREATE INDEX movie_year IF NOT EXISTS FOR (m:Movie) ON (m.released);

// Person: name index
CREATE INDEX person_name IF NOT EXISTS FOR (p:Person) ON (p.name);

// Genre: unique name (we make Genre names unique in our project)
CREATE CONSTRAINT genre_name_unique IF NOT EXISTS
FOR (g:Genre) REQUIRE g.name IS UNIQUE;

// Relationship property existence examples (Neo4j 5 supports property existence constraints on rels)
CREATE CONSTRAINT acted_in_role_exists IF NOT EXISTS
FOR ()-[r:ACTED_IN]-() REQUIRE r.role IS NOT NULL
OPTIONS {indexProvider: 'range-1.0'};

// The constraint above will only succeed if you already have ACTED_IN.role set everywhere.
// If it fails, you can comment it out or set roles before re enabling.
