#! /usr/bin/env bash
set -e

function acl_is_world_readable() {
  jq -e '.[]? | select(.entity=="allUsers") | select(.role=="READER") | any'
}

source refresh.config
for name in $names
do
  theme=node_modules/jsonresume-theme-kendall
  hackmyresume BUILD jrs/${name}.json TO ${site}/${name}/index.html --theme ${theme}
  theme=node_modules/jsonresume-theme-onepage
  hackmyresume BUILD jrs/${name}.json TO ${site}/${name}/print/index.html --theme ${theme}
done

if gsutil defacl get gs://resumes.valenceo.com | acl_is_world_readable
then
  echo ${site} is world-readable, good work
else
  echo gsutil acl ch -r -u AllUsers:R gs://${site}
fi

gsutil rsync -r ${site} gs://${site}
