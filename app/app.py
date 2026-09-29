from flask import Flask, jsonify
import os
import socket

app = Flask(__name__)

VERSION = os.getenv("APP_VERSION", "v2.0")
ENVIRONMENT = os.getenv("ENVIRONMENT", "local")

@app.route("/")
def home():
    return jsonify({
        "application": "Deployment Strategy Lab",
        "version": VERSION,
        "environment": ENVIRONMENT,
        "hostname": socket.gethostname()
    })


@app.route("/version")
def version():
    return jsonify({
        "version": VERSION,
        "hostname": socket.gethostname()
    })


@app.route("/health")
def health():
    return jsonify({
        "status": "healthy",
        "version": VERSION
    })


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
