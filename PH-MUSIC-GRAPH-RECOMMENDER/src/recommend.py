"""Command-line music recommender backed by Neo4j."""
import argparse
import os
import sys

from dotenv import load_dotenv
from neo4j import GraphDatabase
from neo4j.exceptions import Neo4jError, ServiceUnavailable, AuthError

RECOMMENDATION_QUERY = """
MATCH (u:User {userId: $user_id})-[:LIKES]->(seed:Track)
MATCH (seed)-[:IN_GENRE]->(genre:Genre)<-[:IN_GENRE]-(candidate:Track)
WHERE NOT (u)-[:LIKES]->(candidate)
WITH u, candidate, count(DISTINCT genre) * 2 AS genre_score
OPTIONAL MATCH (candidate)<-[:LIKES]-(other:User)-[:LIKES]->(seed_track:Track)<-[:LIKES]-(u)
WITH u, candidate, genre_score, count(DISTINCT other) AS collaborative_score
OPTIONAL MATCH (u)-[:LIKES]->(:Track)-[:CREATED_BY]->(artist:Artist)<-[:CREATED_BY]-(candidate)
WITH candidate, genre_score, collaborative_score,
     count(DISTINCT artist) * 3 AS artist_score
RETURN candidate.trackId AS track_id,
       candidate.title AS title,
       genre_score + artist_score + collaborative_score AS score,
       genre_score, artist_score, collaborative_score
ORDER BY score DESC, title
LIMIT 10
"""

def main():
    load_dotenv()
    parser = argparse.ArgumentParser(
        description="Recommend tracks using graph relationships in Neo4j."
    )
    parser.add_argument("user_id", help="User identifier, e.g. user-001")
    args = parser.parse_args()

    uri = os.getenv("NEO4J_URI")
    username = os.getenv("NEO4J_USERNAME")
    password = os.getenv("NEO4J_PASSWORD")
    database = os.getenv("NEO4J_DATABASE", "neo4j")

    if not all([uri, username, password]):
        print("Configuration missing. Set NEO4J_URI, NEO4J_USERNAME and NEO4J_PASSWORD in .env.")
        sys.exit(2)

    try:
        with GraphDatabase.driver(uri, auth=(username, password)) as driver:
            driver.verify_connectivity()
            records, summary, keys = driver.execute_query(
                RECOMMENDATION_QUERY,
                user_id=args.user_id,
                database_=database,
            )

        if not records:
            print("No recommendations found. Check that this user exists and has liked tracks.")
            return

        print(f"\nMusic recommendations for {args.user_id}\n" + "-" * 62)
        for index, record in enumerate(records, start=1):
            print(
                f"{index:>2}. {record['title']} [{record['track_id']}] "
                f"| score={record['score']} "
                f"(genre={record['genre_score']}, artist={record['artist_score']}, "
                f"community={record['collaborative_score']})"
            )
        print(f"\nReturned {len(records)} recommendation(s).")
    except AuthError:
        print("Authentication failed. Check NEO4J_USERNAME and NEO4J_PASSWORD.")
        sys.exit(1)
    except ServiceUnavailable:
        print("Could not reach Neo4j. Check that the database is running and NEO4J_URI is correct.")
        sys.exit(1)
    except Neo4jError as exc:
        print(f"Neo4j query failed: {exc}")
        sys.exit(1)

if __name__ == "__main__":
    main()
