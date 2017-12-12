#!/usr/bin/env bash

set -e

case "$(uname -s)" in
    Linux*)     _os=Linux;;
    Darwin*)    _os=Mac;;
    CYGWIN*)    _os=Cygwin;;
    MINGW*)     _os=MinGw;;
    *)          _os="UNKNOWN:${unameOut}"
esac