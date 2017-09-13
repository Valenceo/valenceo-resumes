#! /usr/bin/env bash
set -e

function acl_is_world_readable() {
  jq -e '.[]? | select(.entity=="allUsers") | select(.role=="READER") | any'
}

source config
for name in $names
do
  dest=${site}
  theme=node_modules/jsonresume-theme-kendall
  if hackmyresume BUILD jrs/${name}.json TO ${dest}/${name}/index.html --theme ${theme}
  then
    echo HTML
  fi
  theme=node_modules/jsonresume-theme-onepage
  if hackmyresume BUILD jrs/${name}.json TO ${dest}/${name}/print/index.html --theme ${theme}
  then
    echo 'PRINT (html)'
  fi
  if pandoc ${dest}/${name}/print/index.html -o ${dest}/${name}/${name}.doc
  then
    echo DOC
  fi
  if hackmyresume BUILD jrs/${name}.json TO ${dest}/${name}/${name}.pdf -p wkhtmltopdf --theme ${theme}
  then
    echo PDF
  fi
done

read -p "Push to server [YyNn]> "
case $REPLY in
	Y|y) echo Pushing to ${site} ;;
	N|n) exit 0 ;;
	*) echo Not pushing to ${site} ;;
esac

if gsutil defacl get gs://resumes.valenceo.com | acl_is_world_readable
then
  echo ${site} is world-readable, good work
else
  echo gsutil acl ch -r -u AllUsers:R gs://${site}
fi

src=${site}
gsutil rsync -r ${src} gs://${site}
