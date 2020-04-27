#!/usr/bin/env bash

# share
put $auth '/role/felles' '{
  "roleId": "felles",
  "description": "",
  "privileges": {
    "includes": []
  },
  "paths": {
    "includes": ["/felles/"]
  },
  "maxValuation": "SENSITIVE"
}' 201

# kilde skatteetaten skatt person
put $auth '/role/kilde.ske.skatt.person' '{
  "roleId": "kilde.ske.skatt.person",
  "description": "",
  "privileges": {
    "includes": []
  },
  "paths": {
    "includes": ["/kilde/ske/skatt/person/"],
    "excludes": [
      "/kilde/ske/skatt/person/fastsatt/rådata/",
      "/kilde/ske/skatt/person/utkast/rådata/"
    ]
  },
  "maxValuation": "SENSITIVE",
  "states": {
    "excludes": ["RAW"]
  }
}' 201

# skatt person rådata
put $auth '/role/kilde.ske.skatt.person.raadata' '{
  "roleId": "kilde.ske.skatt.person.raadata",
  "description": "",
  "privileges": {
    "includes": [ "READ" ]
  },
  "paths": {
    "includes": [
      "/kilde/ske/skatt/person/fastsatt/rådata/",
      "/kilde/ske/skatt/person/utkast/rådata/"
    ]
  },
  "maxValuation": "SENSITIVE",
  "states": {
    "includes": ["RAW"]
  }
}' 201

# produkt skatt person
put $auth '/role/produkt.skatt.person' '{
  "roleId": "produkt.skatt.person",
  "description": "",
  "privileges": {
    "includes": []
  },
  "paths": {
    "includes": ["/produkt/skatt/person/"]
  },
  "maxValuation": "SENSITIVE",
  "states": {
    "excludes": ["RAW"]
  }
}' 201

put $auth '/group/felles' '{
  "groupId": "felles",
  "description": "",
  "roles": ["felles"]
}' 201

put $auth '/group/skatt.person' '{
  "groupId": "skatt.person",
  "description": "",
  "roles": ["kilde.ske.skatt.person", "kilde.ske.skatt.person.raadata", "produkt.skatt.person"]
}' 201

for user in "aleksander.berge" \
  "ole.vangen" \
  "remy.brathen" \
  "ole.bredesen-vestby" \
  "simen.svenkerud" \
  "ane.seierstad" \
  "rolf.rolfsen" \
  "oda.torgan" \
  "matz.ivan.faldmo"; do
  put $auth "/role/user.$user" '{
    "roleId": "user.'$user'",
    "description": "",
    "privileges": {
      "includes": []
    },
    "paths": {
      "includes": ["/user/'$user'"]
    },
    "maxValuation": "SENSITIVE",
    "states": {
      "excludes": ["RAW"]
    }
  }' 201
  put $auth "/user/$user@ssb.no" '{
    "userId": "'$user'@ssb.no",
    "roles": ["user.'$user'"],
    "groups": ["felles", "skatt.person"]
  }' 201
done

put $auth '/group/datastammen' '{
  "groupId": "skatt.person",
  "description": "",
  "roles": ["kilde.ske.skatt.person", "kilde.ske.skatt.person.raadata", "produkt.skatt.person"]
}' 201

for user in "trygve.falch" \
  "kim.gaarder" \
  "magnus.jenssen" \
  "hadrien.kohl" \
  "rune.lind" \
  "marianne.mellem" \
  "mehran.raja" \
  "ove.ranheim" \
  "kenneth.schulstad" \
  "bjorn.skaar" \
  "oyvind.strommen" \
  "arild.takvam-borge" \
  "rannveig.aasen"; do
  put $auth "/role/user.$user" '{
    "roleId": "user.'$user'",
    "description": "",
    "privileges": {
      "includes": []
    },
    "paths": {
      "includes": ["/user/'$user'"]
    },
    "maxValuation": "SENSITIVE",
    "states": {
      "excludes": ["RAW"]
    }
  }' 201
  put $auth "/user/$user@ssb.no" '{
    "userId": "'$user'@ssb.no",
    "roles": ["user.'$user'"],
    "groups": ["felles", "datastammen"]
  }' 201
done
