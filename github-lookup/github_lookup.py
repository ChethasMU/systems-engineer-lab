import argparse
import logging
import requests

logging.basicConfig(level=logging.INFO,
                    format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger(__name__)

def main():
    parser = argparse.ArgumentParser(description="Look up a GitHub user.")
    parser.add_argument("username", help="GitHub username")
    args = parser.parse_args()

    log.info("Looking up: %s", args.username)
    resp = requests.get(f"https://api.github.com/users/{args.username}", timeout=10)
    resp.raise_for_status()
    data = resp.json()
    log.info("%s has %s public repos", data["login"], data["public_repos"])

if __name__ == "__main__":
    main()

    
