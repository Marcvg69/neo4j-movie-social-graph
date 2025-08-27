
/*
  02_enrich_genres_optional.cypher
  Adds Genre nodes and HAS_GENRE relationships for a handful of known titles
  from the Movies sample. Safe to run multiple times.
*/

// Create a few common genres
UNWIND ['Action','Sci-Fi','Drama','Comedy','Thriller','Romance','Crime','Adventure'] AS g
MERGE (:Genre {name: g});

// Helper to attach a genre by movie title
WITH 1 AS dummy
CALL {
  WITH 'The Matrix' AS title, ['Action','Sci-Fi'] AS genreList
  MATCH (m:Movie {title: title})
  UNWIND genreList AS g
  MATCH (gen:Genre {name: g})
  MERGE (m)-[:HAS_GENRE]->(gen);
  RETURN count(*) AS _
}
CALL {
  WITH 'The Matrix Reloaded' AS title, ['Action','Sci-Fi'] AS genreList
  MATCH (m:Movie {title: title})
  UNWIND genreList AS g
  MATCH (gen:Genre {name: g})
  MERGE (m)-[:HAS_GENRE]->(gen);
  RETURN count(*) AS _
}
CALL {
  WITH 'The Matrix Revolutions' AS title, ['Action','Sci-Fi'] AS genreList
  MATCH (m:Movie {title: title})
  UNWIND genreList AS g
  MATCH (gen:Genre {name: g})
  MERGE (m)-[:HAS_GENRE]->(gen);
  RETURN count(*) AS _
}
CALL {
  WITH 'A Few Good Men' AS title, ['Drama','Thriller'] AS genreList
  MATCH (m:Movie {title: title})
  UNWIND genreList AS g
  MATCH (gen:Genre {name: g})
  MERGE (m)-[:HAS_GENRE]->(gen);
  RETURN count(*) AS _
}
CALL {
  WITH 'Jerry Maguire' AS title, ['Drama','Romance'] AS genreList
  MATCH (m:Movie {title: title})
  UNWIND genreList AS g
  MATCH (gen:Genre {name: g})
  MERGE (m)-[:HAS_GENRE]->(gen);
  RETURN count(*) AS _
}
CALL {
  WITH 'Top Gun' AS title, ['Action','Drama'] AS genreList
  MATCH (m:Movie {title: title})
  UNWIND genreList AS g
  MATCH (gen:Genre {name: g})
  MERGE (m)-[:HAS_GENRE]->(gen);
  RETURN count(*) AS _
}
RETURN 'Genres enriched' AS status;
