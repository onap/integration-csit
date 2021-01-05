import flask
import json
from flask import Flask, render_template
from flask import request
from flask import jsonify
import requests
import threading
import time

app = flask.Flask(__name__)
app.config["DEBUG"] = True


def get_du_list_for_nssai(snssai):
    if str(snssai) == '001-00110':
        with open('du_list_001_00110.json') as du_list:
            data = json.load(du_list)
    else:
        with open('du_list_001_010000.json') as du_list:
            data = json.load(du_list)
    if not data:
        return {"Error": "Unable to read file"}, 503
    return data, None


def get_du_cell_list_for_nssai(snssai):
    if str(snssai) == '001-00110':
        with open('du_cell_list_001_00110.json') as du_cell_list:
            data = json.load(du_cell_list)
    else:
        with open('du_cell_list_001_010000.json') as du_cell_list:
            data = json.load(du_cell_list)
    if not data:
        return {"Error": "Unable to read file"}, 503
    return data, None


def get_slice_config_for_nssai(snssai):
    if str(snssai) == '001-00110':
        with open('slice_config_001_00110.json') as slice_config:
            data = json.load(slice_config)
    else:
        with open('slice_config_001_010000.json') as slice_config:
            data = json.load(slice_config)
    if not data:
        return {"Error": "Unable to read file"}, 503
    return data, None


def get_profile_config_for_nssai(snssai):
    if str(snssai) == '001-00110':
        with open('profile_config_001_00110.json') as profile_config:
            data = json.load(profile_config)
    else:
        with open('profile_config_001_010000.json') as profile_config:
            data = json.load(profile_config)
    if not data:
        return {"Error": "Unable to read file"}, 503
    return data, None


def get_subscriber_details_for_nssai(snssai):
    if str(snssai) == '001-00110':
        with open('subscriber-details_001_00110.json') as subscriber_details:
            data = json.load(subscriber_details)
    else:
        with open('subscriber-details_001_010000.json') as subscriber_details:
            data = json.load(subscriber_details)
    if not data:
        return {"Error": "Unable to read file"}, 503
    return data, None


@app.route("/api/sdnc-config-db/v4/du-list/<snssai>", methods=["GET"])
def get_du_list(snssai):
    data, status = get_du_list_for_nssai(snssai)
    if not status:
        return jsonify(data)
    return data, 503


@app.route("/api/sdnc-config-db/v4/du-cell-list/<snssai>", methods=["GET"])
def get_du_cell_list(snssai):
    data, status = get_du_cell_list_for_nssai(snssai)
    if not status:
        return jsonify(data)
    return data, 503


@app.route("/api/sdnc-config-db/v4/slice-config/<snssai>", methods=["GET"])
def get_slice_config(snssai):
    data, status = get_slice_config_for_nssai(snssai)
    if not status:
        return jsonify(data)
    return data, 503


@app.route("/api/sdnc-config-db/v4/profile-config/<snssai>", methods=["GET"])
def get_profile_config(snssai):
    data, status = get_profile_config_for_nssai(snssai)
    if not status:
        return jsonify(data)
    return data, 503


@app.route("/api/sdnc-config-db/v4/subscriber-details/<snssai>",
           methods=["GET"])
def get_subscriber_details(snssai):
    data, status = get_subscriber_details_for_nssai(snssai)
    if not status:
        return jsonify(data)
    return data, 503


app.run(host='0.0.0.0')
