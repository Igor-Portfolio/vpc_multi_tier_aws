from flask import Flask, request, jsonify
from flask_cors import CORS
import db

app = Flask(__name__)
CORS(app)  # permite chamadas do Nginx durante desenvolvimento


# ── Inicialização ──────────────────────────────────────────────────────────────

with app.app_context():
    db.init_db()


# ── Helpers ────────────────────────────────────────────────────────────────────

def error(message: str, status: int):
    return jsonify({"error": message}), status


# ── Rotas ──────────────────────────────────────────────────────────────────────

@app.route("/api/count", methods=["GET"])
def get_count():
    """
    Chamada pelo frontend ao carregar a página.
    Incrementa o contador e devolve o valor actual.

    Response 200:
        { "count": 42 }
    """
    count = db.increment_and_get_count()
    return jsonify({"count": count}), 200


@app.route("/api/register", methods=["POST"])
def register():
    """
    Guarda ou actualiza a mensagem de um visitante.
    Se o nome já existir, a mensagem é substituída.

    Body (JSON):
        { "name": "...", "message": "..." }

    Response 201:
        { "id": 1, "name": "...", "message": "...", "created_at": "..." }
    """
    body = request.get_json(silent=True)

    if not body:
        return error("corpo da requisição inválido ou ausente", 400)

    name    = (body.get("name")    or "").strip()
    message = (body.get("message") or "").strip()

    if not name:
        return error("o campo 'name' é obrigatório", 400)
    if not message:
        return error("o campo 'message' é obrigatório", 400)
    if len(name) > 60:
        return error("o nome não pode exceder 60 caracteres", 400)
    if len(message) > 280:
        return error("a mensagem não pode exceder 280 caracteres", 400)

    visitor = db.save_visitor(name, message)

    # converte o datetime para string para ser serializável em JSON
    visitor["created_at"] = visitor["created_at"].isoformat()

    return jsonify(visitor), 201


@app.route("/api/message", methods=["GET"])
def get_message():
    """
    Devolve a mensagem de um visitante pelo nome.
    A pesquisa é case-insensitive.

    Query param:
        ?name=joao

    Response 200:
        { "id": 1, "name": "joao", "message": "...", "created_at": "..." }

    Response 404:
        { "error": "..." }
    """
    name = (request.args.get("name") or "").strip()

    if not name:
        return error("o parâmetro 'name' é obrigatório", 400)

    visitor = db.get_visitor_by_name(name)

    if not visitor:
        return error(f"nenhuma mensagem encontrada para '{name}'", 404)

    visitor["created_at"] = visitor["created_at"].isoformat()

    return jsonify(visitor), 200


# ── Entry point ────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=False)