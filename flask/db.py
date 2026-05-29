import os
import psycopg2
from psycopg2.extras import RealDictCursor


def get_connection():
    return psycopg2.connect(
        host=os.environ["DB_HOST"],
        port=os.environ.get("DB_PORT", 5432),
        dbname=os.environ["DB_NAME"],
        user=os.environ["DB_USER"],
        password=os.environ["DB_PASSWORD"],
    )


def init_db():
    """Cria as tabelas se ainda não existirem."""
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("""
                CREATE TABLE IF NOT EXISTS visitors (
                    id         SERIAL PRIMARY KEY,
                    name       VARCHAR(60)  UNIQUE NOT NULL,
                    message    VARCHAR(280) NOT NULL,
                    created_at TIMESTAMP    DEFAULT NOW()
                );
            """)
            cur.execute("""
                CREATE TABLE IF NOT EXISTS access_log (
                    id    INTEGER PRIMARY KEY DEFAULT 1,
                    count INTEGER NOT NULL    DEFAULT 0
                );
            """)
            # Garante que existe sempre exactamente uma linha no contador
            cur.execute("""
                INSERT INTO access_log (id, count)
                VALUES (1, 0)
                ON CONFLICT (id) DO NOTHING;
            """)
        conn.commit()
    finally:
        conn.close()


# ── Visitors ──────────────────────────────────────────────────────────────────

def save_visitor(name: str, message: str) -> dict:
    """
    Insere ou actualiza a mensagem de um visitante.
    Devolve o registo guardado.
    """
    conn = get_connection()
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("""
                INSERT INTO visitors (name, message)
                VALUES (%s, %s)
                ON CONFLICT (name) DO UPDATE
                    SET message    = EXCLUDED.message,
                        created_at = NOW()
                RETURNING id, name, message, created_at;
            """, (name, message))
            row = cur.fetchone()
        conn.commit()
        return dict(row)
    finally:
        conn.close()


def get_visitor_by_name(name: str) -> dict | None:
    """Devolve o registo do visitante ou None se não existir."""
    conn = get_connection()
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("""
                SELECT id, name, message, created_at
                FROM visitors
                WHERE LOWER(name) = LOWER(%s);
            """, (name,))
            row = cur.fetchone()
        return dict(row) if row else None
    finally:
        conn.close()


# ── Access counter ─────────────────────────────────────────────────────────────

def increment_and_get_count() -> int:
    """Incrementa o contador de acessos e devolve o valor actualizado."""
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("""
                UPDATE access_log
                SET count = count + 1
                WHERE id = 1
                RETURNING count;
            """)
            count = cur.fetchone()[0]
        conn.commit()
        return count
    finally:
        conn.close()