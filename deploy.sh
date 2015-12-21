#!/bin/env bash

jekyll build
rsync -ravnz _site/* blog:/var/www/html/maex.me/
