# PH-MUSIC-GRAPH-RECOMMENDER
### Graph-based music recommendation system with Python and Neo4j

An educational portfolio project that models listeners, artists, genres, and tracks as a property graph, then generates personalized music recommendations with Cypher queries.

> **Project status:** source code, sample dataset, graph model, and execution instructions are provided. A live Neo4j instance is required to run the database scripts. No production database credentials or fabricated execution screenshots are included.

## 1. Problem

Traditional tabular queries can find songs by genre or artist, but music preferences are naturally connected: listeners enjoy tracks, tracks belong to genres, and artists create tracks. A graph makes these relationships explicit and makes it practical to explore paths between a listener's preferences and undiscovered music.

## 2. Solution

This project uses:
- **Neo4j** as the graph database.
- **Cypher** to create the graph, load CSV data, and query recommendations.
- **Python** with the official Neo4j driver to connect to the database and request recommendations.

The recommendation query combines:
1. **Content similarity:** tracks share genres and/or artists with tracks the listener likes.
2. **Collaborative signal:** other listeners who like the same tracks also like candidate tracks.
3. **Filtering:** already-liked tracks are excluded.

The result is an explainable ranked list with reasons such as shared genre, shared artist, and listeners with similar preferences.

## 3. Graph data model

### Nodes
| Label | Properties |
|---|---|
| `User` | `userId`, `name`, `country` |
| `Track` | `trackId`, `title`, `year`, `durationSeconds` |
| `Artist` | `artistId`, `name` |
| `Genre` | `genreId`, `name` |

### Relationships
- `(User)-[:LIKES {rating, since}]->(Track)`
- `(User)-[:LISTENED {playCount}]->(Track)`
- `(Track)-[:CREATED_BY]->(Artist)`
- `(Track)-[:IN_GENRE]->(Genre)`

See [`docs/graph-model.md`](docs/graph-model.md) for the diagram.

## 4. Repository structure

```text
PH-MUSIC-GRAPH-RECOMMENDER/
├── data/
│   ├── users.csv
│   ├── artists.csv
│   ├── genres.csv
│   ├── tracks.csv
│   └── likes.csv
├── cypher/
│   ├── 01_constraints.cypher
│   ├── 02_load_data.cypher
│   ├── 03_recommendations.cypher
│   └── 04_business_questions.cypher
├── docs/
│   └── graph-model.md
├── src/
│   └── recommend.py
├── .env.example
├── .gitignore
└── requirements.txt
```

## 5. Requirements

- Neo4j 5.x (Neo4j Desktop or a Neo4j AuraDB instance).
- Python 3.10+.
- Internet access only to install the Python dependency (unless already installed).

## 6. Configure Neo4j

1. Create or start a Neo4j database.
2. Open Neo4j Browser.
3. Copy the Bolt connection URI, database name, username, and password.
4. In Neo4j Browser, run the scripts in this order:
   - `cypher/01_constraints.cypher`
   - `cypher/02_load_data.cypher`
5. For the CSV import script, place the five CSV files in Neo4j's configured `import` directory and keep their filenames unchanged. In AuraDB, upload the CSV files to the import area using the supported import workflow for your instance, then adapt the `LOAD CSV` URLs as required.

### Important CSV note
The `LOAD CSV` statements use `file:///filename.csv`, which is suitable for a local Neo4j import directory. Managed Neo4j services may require HTTPS-accessible CSV URLs or their import tooling. Do not expose private data in public CSV hosting.

## 7. Run the Python recommender

From the repository root:

```bash
python -m venv .venv
```

Windows CMD:
```cmd
.venv\Scripts\activate
pip install -r requirements.txt
copy .env.example .env
```

Linux/macOS:
```bash
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
```

Edit `.env` and provide your own Neo4j connection details:

```env
NEO4J_URI=neo4j+s://your-instance.databases.neo4j.io
NEO4J_USERNAME=neo4j
NEO4J_PASSWORD=your_password
NEO4J_DATABASE=neo4j
```

Run:
```bash
python src/recommend.py user-001
```

For a local database, the URI may look like `bolt://localhost:7687`. Keep `.env` private; it is excluded by `.gitignore`.

## 8. Business questions answered

1. Which tracks does a user already like?
2. Which artists and genres are most represented in a user's liked tracks?
3. Which tracks can be recommended based on shared genres or artists?
4. Which tracks are liked by users with overlapping preferences?
5. Why was a specific track recommended?

Run `cypher/04_business_questions.cypher` in Neo4j Browser to explore these questions.

## 9. Recommendation logic

The Cypher query scores each candidate using:
- `2` points for each shared genre;
- `3` points for a shared artist;
- `1` point for each other listener who likes both a seed track and the candidate track.

These weights are intentionally simple and transparent for an educational example. They can be tuned and evaluated with real interaction data. This is not a machine-learning model and does not claim production recommendation quality.

## 10. Sample data

The included dataset is fictional and created only for demonstration. It contains sample users, tracks, artists, genres, and likes. It does not represent real listening behavior or real-world rankings.

## 11. Troubleshooting

| Problem | What to check |
|---|---|
| `ServiceUnavailable` | Confirm Neo4j is running and `NEO4J_URI` is correct. |
| Authentication error | Verify username and password in `.env`. |
| `Couldn't load the external resource` | Put CSV files in the local Neo4j import directory or use an accessible HTTPS URL for a managed instance. |
| No recommendations returned | Confirm the selected user has at least one `LIKES` relationship and that candidate tracks exist. |
| `ModuleNotFoundError: neo4j` | Activate the virtual environment and run `pip install -r requirements.txt`. |
| CSV rows are not imported | Check filenames, headers, import permissions, and run the scripts in order. |

## 12. Evidence to add after running

After loading the dataset, capture your own screenshots from Neo4j Browser:
1. `CALL db.schema.visualization()` for the graph schema.
2. A graph view showing users, tracks, artists, and genres.
3. The result of a recommendation query for `user-001`.

Save the screenshots under `docs/screenshots/` and link them here. Screenshots are intentionally not fabricated or included because they must show the result from your own running database.

## 13. Future improvements

- Add explicit negative feedback and skip events.
- Evaluate recommendations with precision@k and recall@k.
- Add a REST API using Flask or FastAPI.
- Add a web interface.
- Add temporal decay so recent likes have more influence.
- Add a larger public music dataset with licensing checked.

## 14. Author

**Paulo Henrique Santana Motta**

Portfolio project: graph databases, Neo4j, Cypher, and Python.
