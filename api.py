from bottle import request, Bottle, abort, response, template
import json
import os
import csv
import datetime

from gevent.pywsgi import WSGIServer
import gevent
from geventwebsocket import WebSocketError
from geventwebsocket.handler import WebSocketHandler
from multiprocessing import Process

app = Bottle()
dictionary = {}
tmp_file_dir = "./tmp"



def put_upload_file(file):
    now = datetime.datetime.now().strftime("%Y%m%d%H%M%s")
    file_id = now
    file_path = os.path.join(tmp_file_dir, "upload", file_id+".csv")
    with open(file_path, "w") as f:
        f.write(file)
    return file_id



@app.route("/", method="GET")
def show_index():
    return template("index")

def handler(wsock, message):
    d = dictionary[wsock]
    try:
        j = json.loads(message)
        print(j)
        if j["action"] == "upload":
            pass

    except (UnicodeDecodeError, json.decoder.JSONDecodeError):
        d["size"] += len(message)
        d["uploading_file"] += message
        response = {"status": "loading", "loadedSize": d["size"]}
        print(response)
        wsock.send(json.dumps(response))
        if d["size"] == int(d["file_size"]):
            uploading_file = d["uploading_file"]
            file_id = put_upload_file(uploading_file)
            response = {"status": "loaded", "fileId": file_id}
            wsock.send(json.dumps(response))


@app.route('/websocket')
def handle_websocket():
    wsock = request.environ.get('wsgi.websocket')
    if not wsock:
        abort(400, 'Expected WebSocket request.')
    global dictionary

    if wsock not in dictionary:
        dictionary[wsock] = {
            "num": None,
            "file_size": 0,
            "size": 0,
            "uploading_file": bytearray()
        }

    while True:
        try:
            message = wsock.receive()
            gevent.spawn(handler, wsock, message)
        except WebSocketError:
            break


server = WSGIServer(("0.0.0.0", 80), app, handler_class=WebSocketHandler)
server.serve_forever()
