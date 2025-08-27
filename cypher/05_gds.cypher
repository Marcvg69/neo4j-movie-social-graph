
/*
  05_gds.cypher
  Graph Data Science examples. Requires GDS plugin.
*/

// Drop projection if exists
CALL gds.graph.drop('peopleCoStar', false);

// Project Person Person co star graph via Cypher projection
CALL gds.graph.project.cypher(
  'peopleCoStar',
  'MATCH (p:Person) RETURN id(p) AS id',
  'MATCH (p1:Person)-[:ACTED_IN]->(:Movie)<-[:ACTED_IN]-(p2:Person)
   WHERE id(p1) < id(p2)
   RETURN id(p1) AS source, id(p2) AS target'
);

// PageRank top actors
CALL gds.pageRank.stream('peopleCoStar')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).name AS person, score
ORDER BY score DESC LIMIT 20;

// Shortest path between two people through ACTED_IN
:param from => 'Tom Hanks';
:param to   => 'Keanu Reeves';
MATCH (a:Person {name: $from}), (b:Person {name: $to})
CALL gds.shortestPath.yens.stream({
  sourceNode: id(a),
  targetNode: id(b),
  k: 1,
  nodeProjection: ['Person','Movie'],
  relationshipProjection: { ACTED_IN: {type:'ACTED_IN', orientation:'UNDIRECTED'} }
})
YIELD path
RETURN [n IN nodes(path) | coalesce(n.name, n.title)] AS hops, length(path) AS len;
