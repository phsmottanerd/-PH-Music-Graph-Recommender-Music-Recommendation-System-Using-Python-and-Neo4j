// Personalized recommendation for Ana (user-001).
// Score: shared genre * 2 + same artist * 3 + overlapping listeners * 1.
// Excludes tracks the target user already likes.

MATCH (u:User {userId: 'user-001'})-[:LIKES]->(seed:Track)
MATCH (seed)-[:IN_GENRE]->(genre:Genre)<-[:IN_GENRE]-(candidate:Track)
WHERE NOT (u)-[:LIKES]->(candidate)
WITH u, candidate, count(DISTINCT genre) * 2 AS genreScore
OPTIONAL MATCH (candidate)<-[:LIKES]-(other:User)-[:LIKES]->(seedTrack:Track)<-[:LIKES]-(u)
WITH u, candidate, genreScore, count(DISTINCT other) AS collaborativeScore
OPTIONAL MATCH (u)-[:LIKES]->(:Track)-[:CREATED_BY]->(artist:Artist)<-[:CREATED_BY]-(candidate)
WITH candidate, genreScore, collaborativeScore,
     count(DISTINCT artist) * 3 AS artistScore
WITH candidate,
     genreScore + collaborativeScore + artistScore AS totalScore,
     genreScore, artistScore, collaborativeScore
RETURN candidate.trackId AS trackId,
       candidate.title AS recommendation,
       totalScore,
       genreScore,
       artistScore,
       collaborativeScore
ORDER BY totalScore DESC, recommendation
LIMIT 10;
