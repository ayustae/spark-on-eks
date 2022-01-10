#!/usr/bin/env python

# Imports
from cryptography.fernet import Fernet
from json import dumps

# Create the Fernet key
fernet_key = Fernet.generate_key().decode()

# Print the output in JSON for Terraform
print(dumps({ "fernet_key": fernet_key }))
