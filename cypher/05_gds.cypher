/*
  05_gds.cypher (GDS 2.x compatible)
  - Projects a Person–Person co-starring graph
  - Runs PageRank
  - Finds the shortest path (Yen's k-shortest) between two people
  Notes:
  * GDS 2.x expects the graph name as the first argument to algorithms, not just a config map.
  * We use a Person–Person co-star graph (no Movie nodes in this projection).
*/

////////////////////////////////////////////////////////////////////////
// (Re)create in-memory graph
////////////////////////////////////////////////////////////////////////

CALL gds.graph.drop('peopleCoStar', false);

CALL gds.graph.project.cypher(
  'peopleCoStar',
  // Node query: all people
  'MATCH (p:Person) RETURN id(p) AS id',
  // Relationship query: undirected co-star edges between people who acted in the same movie
  'MATCH (p1:Person)-[:ACTED_IN]->(:Movie)<-[:ACTED_IN]-(p2:Person)
   WHERE id(p1) < id(p2)
   RETURN id(p1) AS source, id(p2) AS target'
);

////////////////////////////////////////////////////////////////////////
// PageRank on the co-star graph
////////////////////////////////////////////////////////////////////////

CALL gds.pageRank.stream('peopleCoStar')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).name AS person, score
ORDER BY score DESC
LIMIT 20;

////////////////////////////////////////////////////////////////////////
// Shortest path (Yen's algorithm) between two actors on the co-star graph
////////////////////////////////////////////////////////////////////////

:param from => 'Tom Hanks';
:param to   => 'Keanu Reeves';

MATCH (a:Person {name: $from}), (b:Person {name: $to})
CALL gds.shortestPath.yens.stream(
  'peopleCoStar',                             // <-- graph name required in GDS 2.x
  { sourceNode: id(a), targetNode: id(b), k: 1 }
)
YIELD index, path, totalCost
RETURN index,
       [n IN nodes(path) | n.name] AS hops,
       length(path)                AS hopsCount,
       totalCost
ORDER BY index;
