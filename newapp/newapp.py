#!/usr/bin/python3

import sys, pyodbc, socket, yaml, socketserver, http.server
from itertools import count
from textwrap import dedent

hostname = socket.gethostname()
CREATE_TABLE = """
IF NOT EXISTS
    (SELECT *
     FROM sys.tables t
     WHERE t.name = 'hit_counter')
CREATE TABLE hit_counter(
    server VARCHAR(64) NOT NULL,
    last_start DATETIME NULL,
    count BIGINT NOT NULL DEFAULT 0,
    PRIMARY KEY (server)
)
"""
INSERT_HOSTNAME = """
IF NOT EXISTS
    (SELECT *
     FROM hit_counter
     WHERE server = ?)
INSERT INTO hit_counter(server) VALUES(?)
"""
UPDATE_HOSTNAME_START = """
UPDATE hit_counter
SET last_start = CURRENT_TIMESTAMP
WHERE server = ?
"""
INCREMENT_HOSTNAME = """
UPDATE hit_counter
SET count = count + 1
OUTPUT inserted.count
WHERE server = ?
"""
SELECT_HIT_AGGREGATE = """
SELECT
    count(count) AS count,
    sum  (count) AS sum
FROM hit_counter
"""


def connstr(conf):
    return ("Driver={ODBC Driver 17 for SQL Server};"
            f"Server={conf['dbhost']};"
            f"Database={conf['dbname']};"
            f"UID={conf['dbuser']};"
            f"Pwd={conf['dbpass']}")


# creating this only so we don't have to install and use python 3.8
class ThreadingHTTPServer(socketserver.ThreadingMixIn, http.server.HTTPServer):
    daemon_threads = True


class MyHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        sys.stdout.write(f'"GET {self.path}" [{self.client_address[0]}]\n')
        sys.stdout.flush()
        if self.path == "/":
            with pyodbc.connect(connstr(config)) as conn:
                with conn.cursor() as cursor:
                    cursor.execute(INCREMENT_HOSTNAME, hostname)
                    hits = cursor.fetchone().count
                    cursor.execute(SELECT_HIT_AGGREGATE)
                    allHits = cursor.fetchone()
            self.send_response(200)
            self.send_header("Content-type", "text/html")
            self.end_headers()
            images = config['images']
            img = images[hits % len(images)]
            html = dedent(f"""\
            <!doctype html>
            <html lang="en">
            <head><title>cool site</title></head>
            <body>
            <p>You are connected to backend server {hostname}. Thank you for joining us today!</p>
            <p>This specific server has been accessed <b>{hits} time{'' if hits == 1 else 's'}</b>.</p>
            <p>However, the database has tracked a total of <i>{allHits.sum} hit(s) across {allHits.count} server(s)</i>.</p>
            <p>While you're here, please enjoy this cute martian rover:</p>
            <img src="{img}" alt="cool image of a martian!" width="98%" />
            </body>
            </html>
            """)
            self.wfile.write(html.encode())
        elif self.path == "/health":
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            self.wfile.write('{"status":200,"message":"healthy"}'.encode())
        else:
            self.send_response(404)
            self.send_header("Content-type", "text/html")
            self.end_headers()
            self.wfile.write(dedent('''\
            <!doctype html>
            <html lang="en">
            <head><title>404</title></head>
            <body>
            404: i don't know what you are looking for.  :(
            </body>
            </html>
            ''').encode())


with open('/etc/newapp/config.yaml', 'r') as f:
    config = yaml.load(f, Loader=yaml.SafeLoader)
with pyodbc.connect(connstr(config)) as conn:
    with conn.cursor() as cursor:
        cursor.execute(CREATE_TABLE)
        cursor.execute(INSERT_HOSTNAME, hostname, hostname)
        cursor.execute(UPDATE_HOSTNAME_START, hostname)
listen = (config['listenaddr'] if 'listenaddr' in config else '',
          config['listenport'] if 'listenport' in config else 8000)
httpd = ThreadingHTTPServer(listen, MyHandler)
httpd.serve_forever()
