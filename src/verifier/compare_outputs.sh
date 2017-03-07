#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Missing argument for name of existing CSV file from verified_output to check against."
    exit $1
fi

VERIFIED=verified_output/$1
UNVERIFIED=output/${2:-analysis_neighborhood_overall_scores.csv}

echo "Comparing ${VERIFIED} to ${UNVERIFIED}"

csvdiff -q id ${VERIFIED} ${UNVERIFIED}

if [ $? -eq 0 ]; then
    echo "Output matches!"
else
    echo "Output mismatch:"
    csvdiff id --style pretty ${VERIFIED} ${UNVERIFIED}
    echo ""
fi