from flask import Flask, jsonify

app = Flask(__name__)

@app.get("/")
def root():
    return jsonify(
        message="Hello from Flask in Docker & Kubernetes 🚀",
        docs="/healthz",
    )

@app.get("/healthz")
def health():
    return "ok", 200

if __name__ == "__main__":
    # ascultă pe 0.0.0.0 ca să fie vizibil din container
    app.run(host="0.0.0.0", port=8080)
