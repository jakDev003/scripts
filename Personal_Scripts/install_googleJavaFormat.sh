#!/bin/bash

# Install Google Java Format
curl -sSL -o google-java-format-all-deps.jar https://github.com/google/google-java-format/releases/download/v1.23.0/google-java-format-1.23.0-all-deps.jar
sudo mkdir -p /usr/local/bin/googleJavaFormat
sudo mv google-java-format-all-deps.jar /usr/local/bin/googleJavaFormat
