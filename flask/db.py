import os
import psycopg2
from psycopg2.extras import RealDictCursor
import sqlite3
from datetime import datetime


# usar a versao abaixo na versão cloud
# def get_connection():
#     return psycopg2.connect(
#         host=os.environ["DB_HOST"],
#         port=os.environ.get("DB_PORT", 5432),
#         dbname=os.environ["DB_NAME"],
#         user=os.environ["DB_USER"],
#         password=os.environ["DB_PASSWORD"],
#     )




# def init_db():
#     """Cria as tabelas se ainda não existirem."""
#     conn = get_connection()
#     try:
#         with conn.cursor() as cur:
#             cur.execute("""
#                 CREATE TABLE IF NOT EXISTS visitors (
#                     id         SERIAL PRIMARY KEY,
#                     name       VARCHAR(60)  UNIQUE NOT NULL,
#                     message    VARCHAR(280) NOT NULL,
#                     created_at TIMESTAMP    DEFAULT NOW()
#                 );
#             """)
#             cur.execute("""
#                 CREATE TABLE IF NOT EXISTS access_log (
#                     id    INTEGER PRIMARY KEY DEFAULT 1,
#                     count INTEGER NOT NULL    DEFAULT 0
#                 );
#             """)
#             # Garante que existe sempre exactamente uma linha no contador
#             cur.execute("""
#                 INSERT INTO access_log (id, count)
#                 VALUES (1, 0)
#                 ON CONFLICT (id) DO NOTHING;
#             """)
#         conn.commit()
#     finally:
#         conn.close()



# # ── Visitors ──────────────────────────────────────────────────────────────────

# def save_visitor(name: str, message: str) -> dict:
#     """
#     Insere ou actualiza a mensagem de um visitante.
#     Devolve o registo guardado.
#     """
#     conn = get_connection()
#     try:
#         with conn.cursor(cursor_factory=RealDictCursor) as cur:
#             cur.execute("""
#                 INSERT INTO visitors (name, message)
#                 VALUES (%s, %s)
#                 ON CONFLICT (name) DO UPDATE
#                     SET message    = EXCLUDED.message,
#                         created_at = NOW()
#                 RETURNING id, name, message, created_at;
#             """, (name, message))
#             row = cur.fetchone()
#         conn.commit()
#         return dict(row)
#     finally:
#         conn.close()


# def get_visitor_by_name(name: str) -> dict | None:
#     """Devolve o registo do visitante ou None se não existir."""
#     conn = get_connection()
#     try:
#         with conn.cursor(cursor_factory=RealDictCursor) as cur:
#             cur.execute("""
#                 SELECT id, name, message, created_at
#                 FROM visitors
#                 WHERE LOWER(name) = LOWER(%s);
#             """, (name,))
#             row = cur.fetchone()
#         return dict(row) if row else None
#     finally:
#         conn.close()


# # ── Access counter ─────────────────────────────────────────────────────────────

# # def increment_and_get_count() -> int:

#     """Incrementa o contador de acessos e devolve o valor actualizado."""
#     conn = get_connection()
#     try:
#         with conn.cursor() as cur:
#             cur.execute("""
#                 UPDATE access_log
#                 SET count = count + 1
#                 WHERE id = 1
#                 RETURNING count;
#             """)
#             count = cur.fetchone()[0]
#         conn.commit()
#         return count
#     finally:
#         conn.close()


####################################################


# ── Visitors ──────────────────────────────────────────────────────────────────

def save_visitor(name: str, message: str) -> dict:
    """Insere ou actualiza a mensagem de um visitante."""
    conn = get_connection()
    try:
        # No SQLite o 'with' gerencia a transação direto na conexão
        with conn:
            conn.execute("""
                INSERT OR REPLACE INTO visitors (name, message, created_at)
                VALUES (?, ?, datetime('now'));
            """, (name, message))
            
            # Busca o registro que acabou de ser salvo
            cursor = conn.execute("""
                SELECT id, name, message, created_at 
                FROM visitors 
                WHERE name = ?;
            """, (name,))
            row = cursor.fetchone()
            
            # Converte para dicionário e ajusta a data para o formato esperado
            res = dict(row)
            res["created_at"] = datetime.fromisoformat(res["created_at"].replace(" ", "T"))
            return res
    finally:
        conn.close()


def get_visitor_by_name(name: str) -> dict | None:
    """Devolve o registo do visitante ou None se não existir."""
    conn = get_connection()
    try:
        # Consultas simples (SELECT) não precisam de 'with conn'
        cursor = conn.execute("""
            SELECT id, name, message, created_at
            FROM visitors
            WHERE LOWER(name) = LOWER(?);
        """, (name,))
        row = cursor.fetchone()
        
        if row:
            res = dict(row)
            res["created_at"] = datetime.fromisoformat(res["created_at"].replace(" ", "T"))
            return res
        return None
    finally:
        conn.close()


# ── Access counter ─────────────────────────────────────────────────────────────

def increment_and_get_count() -> int:
    """Incrementa o contador de acessos e devolve o valor actualizado."""
    conn = get_connection()
    try:
        with conn:
            # Atualiza o contador
            conn.execute("""
                UPDATE access_log
                SET count = count + 1
                WHERE id = 1;
            """)
            # Busca o valor atualizado para retornar
            cursor = conn.execute("SELECT count FROM access_log WHERE id = 1;")
            count = cursor.fetchone()[0]
            return count
    finally:
        conn.close()

# teste nessa maquina
def get_connection():
    # Cria um arquivo de banco chamado 'local_database.db' na sua pasta
    conn = sqlite3.connect("local_database.db")
    conn.row_factory = sqlite3.Row  # Isso faz o SQLite devolver dados como se fossem dicionários
    return conn

    

# Testar localmente com SQLite. O código é quase idêntico, só muda a sintaxe SQL e o driver de conexão.
def init_db():
    """Cria as tabelas se ainda não existirem."""
    conn = get_connection()
    try:
        # No SQLite, o 'with' vai na CONEXÃO (conn). Ele gerencia a transação automaticamente.
        with conn:
            conn.execute("""
                CREATE TABLE IF NOT EXISTS visitors (
                    id         INTEGER PRIMARY KEY AUTOINCREMENT,
                    name       TEXT UNIQUE NOT NULL,
                    message    TEXT NOT NULL,
                    created_at TEXT DEFAULT CURRENT_TIMESTAMP
                );
            """)
            conn.execute("""
                CREATE TABLE IF NOT EXISTS access_log (
                    id   INTEGER PRIMARY KEY DEFAULT 1,
                    count INTEGER NOT NULL DEFAULT 0
                );
            """)
            # Garante que existe sempre exactamente uma linha no contador
            conn.execute("""
                INSERT OR IGNORE INTO access_log (id, count)
                VALUES (1, 0);
            """)
    finally:
        conn.close()