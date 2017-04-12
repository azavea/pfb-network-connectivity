#!/bin/bash

DEFAULT_OUPUT='analysis_neighborhood_score_inputs.csv'

USAGE="usage: $(basename {$0}) VERIFIED_FILE [FILE_TO_VERIFY]

VERIFIED_FILE is name of a CSV in the verified_output directory
FILE_TO_VERIFY is name of a CSV in the data/output directory; defaults to ${DEFAULT_OUPUT}
"

if [ $# -eq 0 ]; then
    echo "Missing argument for name of existing CSV file from verified_output to check against."
    exit 1
fi

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  echo $USAGE
  exit 0
fi

VERIFIED=verified_output/$1
UNVERIFIED=output/${2:-$DEFAULT_OUPUT}

echo "Comparing ${VERIFIED} to ${UNVERIFIED}"

csvdiff -q id ${VERIFIED} ${UNVERIFIED}

if [ $? -eq 0 ]; then
    echo "Output matches!"
    exit 0
else
    echo "Output mismatch:"
    csvdiff id --style summary ${VERIFIED} ${UNVERIFIED}
    echo ""
    exit 1
fi
