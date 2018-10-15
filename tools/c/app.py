import os
import subprocess

from environs import Env
from flask import Flask, request

env = Env()
app = Flask(__name__)
storage_backend = env("STORAGE_BACKEND", "disk")
data_dir = env("DATA_DIR", "./data")
empty_gzip = "H4sIAFCsw1sAAwMAAAAAAAAAAAA="

fullpath = "/"
for x in os.path.abspath(data_dir).split("/"):
  fullpath = os.path.join(fullpath, x)
  try:
    os.mkdir(fullpath)
  except:
    pass


def key():
    return request.args.get("c", None) or "trash"


if storage_backend == "redis":
    # may not support all feature or even work at all
    from redis import StrictRedis

    redis = StrictRedis(host=env("REDIS_HOST", "localhost"),
                        port=env.int("REDIS_PORT", 6379),
                        db=env.int("REDIS_DB", 0))


    @app.route("/", methods=["POST"])
    def post():
        redis.set(key(), request.data)
        return "saved as {}\n".format(key())


    @app.route("/", methods=["GET"])
    def get():
        return redis.get(key()) or empty_gzip
else:
    def path(overwrite=None):
        return os.path.join(data_dir, overwrite or key())


    @app.route("/", methods=["POST"])
    def post():
        if os.path.exists(path("." + key().lstrip("."))):
            return "protected\n"

        with open(os.path.join(data_dir, key()), "wb") as f:
            f.write(request.data)
        return "saved as {}\n".format(key())


    @app.route("/", methods=["GET"])
    def get():
        known_commands = {
            "ls": """ls -plah | awk '{printf("%-20s -> %s\\n", $9, $5)}' | grep -v "/" | grep -v -e "^\s*->\s*\$" """,
            "ll": """ls -plah | awk '{printf("%-20s -> %s\\n", $9, $5)}' | grep -v "/" | grep -v -e "^\s*->\s*\$" """,
        }
        if key() in known_commands.keys():
            p = subprocess.Popen(known_commands[key()] + " | gzip | base64", shell=True, cwd=path("."),
                                 stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            return p.communicate()[0]

        actual_key = key()
        if os.path.exists(path("." + key())):
            actual_key = "." + key()
        actual_path = path(actual_key)

        if not os.path.isfile(actual_path):
            print("not a file", actual_path)
            return empty_gzip

        with open(actual_path, "rb") as f:
            return f.read()

if __name__ == "__main__":
    app.run(
        host=env("HOST", "localhost"),
        port=env.int("PORT", 8099),
        debug=env.bool("DEBUG", False)
    )
