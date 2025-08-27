
/*
  03_queries_aggregations.cypher
  Aggregations and structural patterns.
*/

// Most frequent actor director collaborators
MATCH (a:Person)-[:ACTED_IN]->(m:Movie)<-[:DIRECTED]-(d:Person)
WITH a, d, count(*) AS films
RETURN a.name AS actor, d.name AS director, films
ORDER BY films DESC, actor
LIMIT 10;

// Most represented genres by number of movies
MATCH (m:Movie)-[:HAS_GENRE]->(g:Genre)
RETURN g.name AS genre, count(*) AS movies
ORDER BY movies DESC;

// Actors with the most co acting connections (degree proxy)
MATCH (p:Person)-[:ACTED_IN]->(:Movie)<-[:ACTED_IN]-(:Person)
WITH p, count(*) AS degree
RETURN p.name AS actor, degree
ORDER BY degree DESC
LIMIT 20;
