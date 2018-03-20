#!/usr/bin/env bash

set -e

rm -Rf public

hugo 

rsync -ravz public/ maexBox:/home/maex/projects/maex.me
