// Uniqueness constraints: prevent duplicate business identifiers.
CREATE CONSTRAINT user_id IF NOT EXISTS
FOR (u:User) REQUIRE u.userId IS UNIQUE;

CREATE CONSTRAINT track_id IF NOT EXISTS
FOR (t:Track) REQUIRE t.trackId IS UNIQUE;

CREATE CONSTRAINT artist_id IF NOT EXISTS
FOR (a:Artist) REQUIRE a.artistId IS UNIQUE;

CREATE CONSTRAINT genre_id IF NOT EXISTS
FOR (g:Genre) REQUIRE g.genreId IS UNIQUE;
