#!/bin/bash

npm install -g @anthropic-ai/claude-code
npm install -g prettier
npm install -g baedal

if [ -f /workspaces/ai-config-toolkit/.env ]; then
  grep -v '^#' /workspaces/ai-config-toolkit/.env | sed 's/^/export /' >> ~/.bashrc
fi
