#!/usr/bin/env/python

# Imports
from uuid import uuid4
from json import dumps

# Create the Flask secret key
flask_secret_key = uuid4().hex

# Print the result in JSON for Terraform
print(dumps({ "flask_secret_key": flask_secret_key }))
