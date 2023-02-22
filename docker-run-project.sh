#!/bin/bash
set -e

time docker build -t ce-bverfg:4.2.2 .

time docker-compose run --rm ce-bverfg Rscript run_project.R
