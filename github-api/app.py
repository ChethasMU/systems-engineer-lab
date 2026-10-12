from flask import Flask, jsonify
import requests

app = Flask(__name__)

@app.route("/")
def home():
    return "GitHub Lookup API — try /user/<username>\n"

@app.route("/user/<username>")
def lookup(username):
    resp = requests.get(f"https://api.github.com/users/{username}", timeout=10)
    if resp.status_code == 404:
        return jsonify({"error": f"user '{username}' not found"}), 404
    resp.raise_for_status()
    data = resp.json()
    return jsonify({
        "login": data["login"],
        "public_repos": data["public_repos"],
        "followers": data["followers"],
    })

@app.route("/health")
def health():
    return "ok\n", 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)