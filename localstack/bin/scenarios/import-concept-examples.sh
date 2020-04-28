#!/usr/bin/env bash

for i in $(find bin/testdata/concept/examples/_main -type f); do
  ENTITY=$(echo "$i" | sed 's:bin/testdata/concept/examples/_main/::' | sed 's:\([^_]*\).*:\1:')
  ID=$(jq -r .id "$i")
  curl -i -X PUT http://localhost:29090/ns/"${ENTITY}"/"${ID}" --data-binary "@$i" &
done

wait