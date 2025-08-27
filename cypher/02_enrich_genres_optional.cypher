/*
  02_enrich_genres_optional.cypher (robust)
  Adds a small set of Genre nodes and HAS_GENRE links to well-known titles.
  Idempotent: safe to re-run; MERGE prevents duplicates.
*/

UNWIND ['Action','Sci-Fi','Drama','Comedy','Thriller','Romance','Crime','Adventure'] AS gname
MERGE (:Genre {name: gname});

UNWIND [
  {title:'The Matrix',               genres:['Action','Sci-Fi']},
  {title:'The Matrix Reloaded',      genres:['Action','Sci-Fi']},
  {title:'The Matrix Revolutions',   genres:['Action','Sci-Fi']},
  {title:'A Few Good Men',           genres:['Drama','Thriller']},
  {title:'Jerry Maguire',            genres:['Drama','Romance']},
  {title:'Top Gun',                  genres:['Action','Drama']}
] AS row
MATCH (m:Movie {title: row.title})
UNWIND row.genres AS gname
MERGE (g:Genre {name: gname})
MERGE (m)-[:HAS_GENRE]->(g);
