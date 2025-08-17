#!/usr/bin/env bash
git clone --depth 1 https://github.com/andrewozh/devops-sandbox.git
cd devops-sandbox
make killercoda -C demo
