#!/usr/bin/env bash

sudo apt update

sudo apt install emacs awscli unzip python3 -y

wget https://github.com/duckdb/duckdb/releases/download/v0.7.1/duckdb_cli-linux-amd64.zip

unzip duckdb_cli-linux-amd64.zip