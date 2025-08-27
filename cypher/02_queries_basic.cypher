
/*
  02_queries_basic.cypher
  Core read queries for exploration.
*/

// Movies by a given director
:param director => 'Lana Wachowski';
MATCH (p:Person {name: $director})-[:DIRECTED]->(m:Movie)
RETURN m.title AS title, m.released AS year
ORDER BY year DESC;

// Co-stars of a given actor
:param actor => 'Tom Hanks';
MATCH (a:Person {name: $actor})-[:ACTED_IN]->(:Movie)<-[:ACTED_IN]-(co:Person)
RETURN DISTINCT co.name AS co_star
ORDER BY co_star;

// Movies in a genre after a year
:param genre => 'Drama';
:param year  => 2010;
MATCH (g:Genre {name: $genre})<-[:HAS_GENRE]-(m:Movie)
WHERE m.released >= $year
RETURN m.title AS title, m.released AS year
ORDER BY year DESC, title;
