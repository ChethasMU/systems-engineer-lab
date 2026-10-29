import os

import psycopg2
import requests
from flask import Flask, jsonify

app = Flask(__name__)


def get_conn():
    """Open a connection to Postgres using settings from environment variables."""
    return psycopg2.connect(
        host=os.environ["DB_HOST"],
        dbname=os.environ.get("DB_NAME", "labdb"),
        user=os.environ["DB_USER"],
        password=os.environ["DB_PASSWORD"],
        connect_timeout=5,
        sslmode="require",
    )


def run_sql(sql, params=None, fetch=False):
    """Run one SQL statement, commit it, and always close the connection."""
    conn = get_conn()
    try:
        with conn:
            with conn.cursor() as cur:
                cur.execute(sql, params)
                return cur.fetchall() if fetch else None
    finally:
        conn.close()


def init_db():
    run_sql("""
        CREATE TABLE IF NOT EXISTS lookups (
            id           SERIAL PRIMARY KEY,
            username     TEXT NOT NULL,
            public_repos INTEGER,
            looked_up_at TIMESTAMPTZ DEFAULT now()
        )
    """)


@app.route("/")
def home():
    return "GitHub Lookup API — try /user/<username> or /history\n"


@app.route("/user/<username>")
def lookup(username):
    resp = requests.get(f"https://api.github.com/users/{username}", timeout=10)
    resp.raise_for_status()
    data = resp.json()
    run_sql(
        "INSERT INTO lookups (username, public_repos) VALUES (%s, %s)",
        (data["login"], data["public_repos"]),
    )
    return jsonify({
        "login": data["login"],
        "public_repos": data["public_repos"],
        "followers": data["followers"],
    })


@app.route("/history")
def history():
    rows = run_sql(
        "SELECT username, public_repos, looked_up_at FROM lookups "
        "ORDER BY looked_up_at DESC LIMIT 10",
        fetch=True,
    )
    return jsonify([
        {"username": r[0], "public_repos": r[1], "looked_up_at": r[2].isoformat()}
        for r in rows
    ])


@app.route("/health")
def health():
    return "ok\n", 200


if __name__ == "__main__":
    init_db()
    app.run(host="0.0.0.0", port=8080)
