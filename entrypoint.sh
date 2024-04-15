#!/bin/sh
set -euo pipefail

git config --global --add safe.directory '*'

python /entrypoint.py \
    ${ROOT:+"-p=$ROOT"} \
    ${HEAD:+"-r=$HEAD"} \
    ${BASE:+"-b=$BASE"} \
    ${IGNORED:+"-x=$IGNORED"} \
    ${INCLUDE:+"-i=$INCLUDE"} \
    ${LOG_LEVEL:+"--log-level=$LOG_LEVEL"} \
    ${TYPES:+"-t=$TYPES"} \
    ${N_PARENT:+"--n_parents=$N_PARENTS"} \