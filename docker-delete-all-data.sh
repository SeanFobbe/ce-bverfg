#!/bin/bash
set -e

time docker build -t ce-bverfg:4.4.0 .

time docker-compose run --rm ce-bverfg Rscript delete_all_data.R
