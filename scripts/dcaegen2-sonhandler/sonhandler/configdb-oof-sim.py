
import flask
import json
from flask import request
import requests
import threading
import time

app = flask.Flask(__name__)
app.config["DEBUG"] = True


def get_neighbour_cell_list_for_cell_id():
    with open('cell_list.json') as cell_list:
        data = json.load(cell_list)
    if not data:
        return {"Error": "Unable to read file"}, 503
    return data, None

def get_pci_for_cell_id():
    with open('pci_value.json') as pci_value:
        data = json.load(pci_value)
    if not data:
        return {"Error": "Unable to read file"}, 503
    return data, None

def get_cell_data_for_cell_id():
    with open('cell_data.json') as cell_data:
        data = json.load(cell_data)
    if not data:
        return {"Error": "Unable to read file"}, 503
    return data, None

def get_oof_sync_response():
    with open('oof_syn_response.json') as syncRes:
        data = json.load(syncRes)
    if not data:
        return {"Error": "Unale to read file"}, 503
    return data, None

def get_oof_async_response(callback_url, transaction_id):
    time.sleep(10)
    with open('oof_async_response.json') as asyncRes:
        data = json.load(asyncRes)
        data['transactionId'] = transaction_id
    if not data:
        return {"Error": "Unable to read file"}, 503
    res = requests.post(callback_url, json=data)
    print('response from server:',res.text)
    return res

@app.route("/api/sdnc-config-db/v3/getNbrList/<cell_id>/<ts>", methods=["GET"])
def get_neighbour_list(cell_id, ts):
    data, status = get_neighbour_cell_list_for_cell_id()
    if not status:
        return data
    return data, 503

@app.route("/api/sdnc-config-db/v3/getPCI/<cell_id>/<ts>", methods=["GET"])
def get_pci(cell_id, ts):
    data, status = get_pci_for_cell_id()
    if not status:
        return data
    return data, 503
@app.route("/api/sdnc-config-db/v3/getPnfId/<cell_id>/<ts>", methods=["GET"])
def get_pnf_id(cell_id, ts):
    data, status = get_pci_for_cell_id()
    data['value'] = 'ncserver5'
    if not status:
        return data
    return data, 503

@app.route("/api/sdnc-config-db/v3/getCell/<cell_id>", methods=["GET"])
def get_cell_data(cell_id):
    data, status = get_cell_data_for_cell_id()
    if not status:
        return data
    return data, 503

@app.route("/api/oof/v1/pci",methods=["POST"])
def oof_optimizatio_result():
    content = request.get_json()
    callback_url = content['requestInfo']['callbackUrl']
    transaction_id = content['requestInfo']['transactionId']
    try:
        task = threading.Thread(target=get_oof_async_response, args=(callback_url,transaction_id,))
        task.daemon = True
        task.start()
    except:
        print("Error: Unable to start thread")

    data, status = get_oof_sync_response()

    if not status:
        return data, 202
    return data, 503


app.run(host='0.0.0.0')
