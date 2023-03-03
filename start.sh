#!/bin/bash

export FLASK_APP=api.py
#cd src
cd src
flask run -h 0.0.0.0 -p 8080
