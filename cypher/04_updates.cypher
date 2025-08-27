
/*
  04_updates.cypher
  Write operations for practice.
*/

// Add a new ACTED_IN relationship with a role
:param actor => 'Tom Hanks';
:param title => 'The Matrix';
:param role  => 'Cameo';
MATCH (p:Person {name: $actor}), (m:Movie {title: $title})
MERGE (p)-[:ACTED_IN {role: $role}]->(m)
RETURN p.name AS actor, m.title AS movie;

// Add a missing Genre to a movie
:param title => 'Top Gun';
:param genre => 'Action';
MATCH (m:Movie {title: $title})
MERGE (g:Genre {name: $genre})
MERGE (m)-[:HAS_GENRE]->(g)
RETURN m.title AS movie, g.name AS genre;

// Remove a genre link (example rollback)
:param title => 'Top Gun';
:param genre => 'Action';
MATCH (m:Movie {title: $title})-[r:HAS_GENRE]->(g:Genre {name: $genre})
DELETE r;
