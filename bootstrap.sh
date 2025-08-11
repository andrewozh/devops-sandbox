#!/usr/bin/env bash
# sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain demo/ca.crt
make demo -C demo
make init
