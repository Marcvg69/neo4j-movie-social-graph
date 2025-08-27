/*
  00_constraints.cypher (safe)
  Minimal, idempotent indexes/constraints that match the official Movies dataset.
  Note: We intentionally DO NOT enforce relationship property existence on :ACTED_IN
  because the dataset uses 'roles' (plural) and relationships are not uniform.
*/

/// Movie
CREATE INDEX movie_title IF NOT EXISTS FOR (m:Movie) ON (m.title);
CREATE INDEX movie_year  IF NOT EXISTS FOR (m:Movie) ON (m.released);

/// Person
CREATE INDEX person_name IF NOT EXISTS FOR (p:Person) ON (p.name);

/// Genre
CREATE CONSTRAINT genre_name_unique IF NOT EXISTS
FOR (g:Genre) REQUIRE g.name IS UNIQUE;
