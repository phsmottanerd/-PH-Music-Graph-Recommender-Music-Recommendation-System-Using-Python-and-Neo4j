// Q1. What tracks does a user like?
MATCH (u:User {userId: 'user-001'})-[r:LIKES]->(t:Track)
RETURN u.name AS listener, t.title AS track, r.rating AS rating
ORDER BY rating DESC;

// Q2. Which genres are most common among this user's liked tracks?
MATCH (:User {userId: 'user-001'})-[:LIKES]->(:Track)-[:IN_GENRE]->(g:Genre)
RETURN g.name AS genre, count(*) AS likedTrackCount
ORDER BY likedTrackCount DESC;

// Q3. Which artists appear in the user's liked tracks?
MATCH (:User {userId: 'user-001'})-[:LIKES]->(t:Track)-[:CREATED_BY]->(a:Artist)
RETURN a.name AS artist, count(t) AS likedTracks
ORDER BY likedTracks DESC;

// Q4. Show the graph schema.
CALL db.schema.visualization();

// Q5. Count nodes by label.
MATCH (n)
UNWIND labels(n) AS label
RETURN label, count(*) AS nodeCount
ORDER BY label;
