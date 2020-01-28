#!/bin/bash

COURS_DIR=cours
IMG_DIR=images
LIST=cours.json
LANGUAGE=fr
FALLBACK_LANGUAGE=fr

TITLE=""
DATE=""

DOCKER_TAG=$(printenv DOCKER_TAG)

if [ -z ${DOCKER_TAG} ]; then
  DOCKER_TAG="stable"
fi

build-html() {
  mkdir -p output-html
  ln -fs ../images output-html

  echo $REVEALJSURL | grep -q http
  if [ $? == 1 ]; then
    cp styles/"$THEME".css $REVEALJSURL/css/theme/"$THEME".css
    cp -r styles/"$THEME" $REVEALJSURL/css/theme/
  fi

  for cours in $((jq keys | jq -r '.[]') < $LIST); do
    for module in $(jq -r '.["'"$cours"'"].modules[]' $LIST); do
      if [ -f "$COURS_DIR"/"$module"."$LANGUAGE".md ]; then
        cat $COURS_DIR/"$module"."$LANGUAGE".md >> "$COURS_DIR"/slide-"$cours"
      elif [ -f "$COURS_DIR"/"$module"."$FALLBACK_LANGUAGE".md ]; then
        echo "$module doesn't exist in $LANGUAGE. Falling back into $FALLBACK_LANGUAGE..."
        cat "$COURS_DIR"/"$module"."$FALLBACK_LANGUAGE".md >> "$COURS_DIR"/slide-"$cours"
      else
        echo "module "$module" doesn't exist in any of the languages"
      fi
    done
    TITLE=$(jq -r '.["'"$cours"'"].course_name' $LIST)

    # Build TP
    jq -r '.["'"$cours"'"].tp[]' $LIST  &> /dev/null
    if [ $? -eq 0 ]; then
      mkdir -p output-html/tp
      for tp in $(jq -r '.["'"$cours"'"].tp[]' $LIST); do
        if [ -f tp/"$tp"."$LANGUAGE".md ]; then
          echo "Build TP $(basename $tp)" "$LANGUAGE"
          docker run --rm -u root -v $PWD:/formations particule/markdown-pdf:"$DOCKER_TAG" \
            -o /formations/output-html/tp/$(basename $tp)."$LANGUAGE".pdf /formations/tp/$tp.$LANGUAGE.md
        elif [ -f tp/"$tp"."$FALLBACK_LANGUAGE".md ]; then
          echo "$tp doesn't exist in $LANGUAGE. Falling back into $FALLBACK_LANGUAGE..."
          echo "Build TP $(basename $tp)" "$FALLBACK_LANGUAGE"
          docker run --rm -u root -v $PWD:/formations particule/markdown-pdf:"$DOCKER_TAG" \
            -o /formations/output-html/tp/$(basename $tp)."$FALLBACK_LANGUAGE".pdf /formations/tp/$tp.$FALLBACK_LANGUAGE.md
        else
          echo "TP $(basename $tp) doesn't exist in any of the languages"
        fi
      done
    fi

    # Header2 are only usefull for beamer, they need to be replaced with Header3 for revealjs interpretation
    sed -i 's/^## /### /' "$COURS_DIR"/slide-"$cours"
    echo "Build "$TITLE" "$LANUGAGE" ("$OUTPUT")"
    docker run --rm -v $PWD:/formations particule/revealjs-builder:"$DOCKER_TAG" \
      --standalone \
      --template=/formations/templates/template.revealjs \
      --slide-level 3 \
      --no-highlight \
      -V theme="$THEME" \
      -V navigation=frame \
      -V revealjs-url="$REVEALJSURL" \
      -V slideNumber=\"c/t\" \
      -V title="$TITLE" \
      -V institute="particule" \
      -o /formations/output-html/"$cours"."$LANGUAGE".html \
      /formations/"$COURS_DIR"/slide-"$cours"
    rm -f "$COURS_DIR"/slide-"$cours"
  done
}

build-pdf() {
  mkdir -p output-pdf
  for cours in $((jq keys | jq -r '.[]') < $LIST); do
    docker run --rm \
      -v $PWD/output-pdf:/output \
      -v $PWD/output-html/"$cours"."$LANGUAGE".html:/index.html \
      -v $PWD/images:/images particule/wkhtmltopdf:$DOCKER_TAG \
          -O landscape \
          -s A5 \
          -T 0 -B 0 file:///index.html\?print-pdf /output/"$cours"."$LANGUAGE".pdf
  done
}

display_help() {
  cat <<EOF

  USAGE : $0 options

    -o output           Output format (html, pdf or all). Default: all

    -t theme            Theme to use. Default: particule

    -u revealjsURL      RevealJS URL that need to be use. If you build formation
                        supports on local environment you should git
                        clone https://github.com/hakimel/reveal.js and set
                        this variable to your local copy.
                        This option is also necessary even if you only want PDF
                        output. Default: https://particule.io/formations/revealjs

    -c course           Course to build, "all" for build them all !

    -l language         Language in which you want the course to be built. Default: fr
EOF

exit 0
}

while getopts ":o:t:u:c:l:h" OPT; do
    case $OPT in
        h) display_help ;;
        c) COURSE="$OPTARG";;
        o) OUTPUT="$OPTARG";;
        t) THEME="$OPTARG";;
        u) REVEALJSURL="$OPTARG";;
        l) LANGUAGE="$OPTARG";;
        ?)
            echo "Invalid option: -$OPTARG" >&2
            display_help
            exit 1
            ;;
    esac
done

[[ $REVEALJSURL == "" ]] && REVEALJSURL="https://particule.io/formations/revealjs"

if [[ $THEME == "" ]]; then
  THEME="particule"
else
  ls styles/"$THEME".css &> /dev/null
  [ $? -eq 2 ] && echo "Theme $THEME doesn't exist" && exit 1
fi

if [[ $COURSE != "" ]]; then
  (echo "{ \"$COURSE\":" && jq -r '.["'"$COURSE"'"]' $LIST && echo "}") | jq '.' > cours.json.tmp
  [ $? -eq 1 ] && echo "Course $COURSE doesn't exist, please refer to cours.list" && exit 1
  LIST=cours.json.tmp
else
  LIST=cours.json
fi

OUTPUT=${OUTPUT:-all}
if [[ ! $OUTPUT =~ html|pdf|all ]]; then
    echo "Invalid option: either html, pdf or all" >&2
    display_help
    exit 1
elif [[ $OUTPUT == "html" ]]; then
    build-html
elif [[ $OUTPUT == "pdf" || $OUTPUT == "all" ]]; then
    build-html
    build-pdf
fi
rm -f cours.json.tmp
