#!/bin/env bash

jekyll build
rsync -ravz _site/* blog:/var/www/html/maex.me/
