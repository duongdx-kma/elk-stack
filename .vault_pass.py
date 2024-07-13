#!/usr/bin/env python3

import os

# must export VAULT_PASSWORD
# for example 
# export VAULT_PASSWORD=my_vault_password
# chmod +x .vault_pass.py
print(os.environ['VAULT_PASSWORD'])