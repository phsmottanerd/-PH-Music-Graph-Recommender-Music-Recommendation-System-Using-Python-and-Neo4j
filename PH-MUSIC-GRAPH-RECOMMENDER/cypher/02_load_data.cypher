// Run from Neo4j Browser after copying CSV files into the local Neo4j import directory.
// For AuraDB/managed instances, replace file:/// URLs with accessible HTTPS CSV URLs
// or use the import workflow supported by your Neo4j instance.

// 1) Users
LOAD CSV WITH HEADERS FROM 'file:///users.csv' AS row
MERGE (u:User {userId: row.userId})
SET u.name = row.name,
    u.country = row.country;

// 2) Artists
LOAD CSV WITH HEADERS FROM 'file:///artists.csv' AS row
MERGE (a:Artist {artistId: row.artistId})
SET a.name = row.name;

// 3) Genres
LOAD CSV WITH HEADERS FROM 'file:///genres.csv' AS row
MERGE (g:Genre {genreId: row.genreId})
SET g.name = row.name;

// 4) Tracks and artist relationships
LOAD CSV WITH HEADERS FROM 'file:///tracks.csv' AS row
MATCH (a:Artist {artistId: row.artistId})
MERGE (t:Track {trackId: row.trackId})
SET t.title = row.title,
    t.year = toInteger(row.year),
    t.durationSeconds = toInteger(row.durationSeconds)
MERGE (t)-[:CREATED_BY]->(a);

// 5) Track-genre relationships (genreIds separated by |)
LOAD CSV WITH HEADERS FROM 'file:///tracks.csv' AS row
MATCH (t:Track {trackId: row.trackId})
UNWIND split(row.genreIds, '|') AS genreId
MATCH (g:Genre {genreId: genreId})
MERGE (t)-[:IN_GENRE]->(g);

// 6) User likes
LOAD CSV WITH HEADERS FROM 'file:///likes.csv' AS row
MATCH (u:User {userId: row.userId})
MATCH (t:Track {trackId: row.trackId})
MERGE (u)-[r:LIKES]->(t)
SET r.rating = toInteger(row.rating),
    r.since = date(row.since);
