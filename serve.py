import http.server
import os
import functools

port = int(os.environ.get("PORT", 8080))
directory = os.path.join(os.path.dirname(os.path.abspath(__file__)), "build", "web")

handler = functools.partial(http.server.SimpleHTTPRequestHandler, directory=directory)

with http.server.HTTPServer(("", port), handler) as httpd:
    print(f"Serving {directory} on port {port}")
    httpd.serve_forever()
