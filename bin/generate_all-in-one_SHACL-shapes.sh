#!/bin/bash

# ref: 
#    https://www.w3.org/TR/shacl/
#    https://arademaker.github.io/blog/2015/08/18/combine-rdf.html
# 

cd $(dirname $0)/..
PROJ_DIR=$(realpath ${0%/*}/..)
cd ${PROJ_DIR}

echo
echo "#### >>>> $0: PROJ_DIR: ${PROJ_DIR}"
echo

cd ${PROJ_DIR}

ONTOLOGY_DIR=${ONTOLOGY_DIR:-${PROJ_DIR}/ontology}
SKIP_FILES="LoadUCO.ttl SHACL-shapes.ttl"

PARAMS=""
while (( "$#" )); do
  case "$1" in
    -i|--input_dir)
      ONTOLOGY_DIR=$2
      shift 2
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done
# set positional arguments in their proper place
eval set -- "$PARAMS"

echo "-i (ONTOLOGY_DIR): $ONTOLOGY_DIR"

echo "remiaing args:"
echo $@



## -- find all *.ttl files: --
SKIP_FILES="`echo ${SKIP_FILES} | sed -E 's#[, ]+#\\\|#g'`"
#SKIP_FILES='LoadUCO.ttl\|SHACL-shapes.ttl'

TTL_FILES=$(cd ${PROJ_DIR} && find ./ontology -name "*.ttl" | grep -v "${SKIP_FILES}" | sed 's#\.\/##' | sort -u )
echo $TTL_FILES

echo -e "#### >>>> TTL_FILES=${TTL_FILES}"

#### ---- Copy all turtle files into one local folder: ---- ####
OUTPUT_DIR=${PROJ_DIR}/local_ttl
mkdir -p ${OUTPUT_DIR}

function copy_local_ttl_to_one_dir() {
    i=0
    for t in ${TTL_FILES}; do
        i=$((i+1))
        #echo $i
        cp $t ${OUTPUT_DIR}
    done
    echo -e "#### >>>>  Total RDF/TTL files: ${i}"
    ls -al ${OUTPUT_DIR}
}
copy_local_ttl_to_one_dir

#### ---- RDFPro: generate single ONE turtle file for all SHACL files: ---- ####
export RDFPRO_HOME=${PROJ_DIR}/rdfpro
function rdfpro_setup() {
    cd ${PROJ_DIR}
    if [  ! -s "${RDFPRO_HOME}" ]; then
        RDFPRO_URL=`curl -s https://rdfpro.fbk.eu/install.html | grep "latest version" | grep "tar.gz" | cut -d'"' -f4 `
        wget --no-check-certificate ${RDFPRO_URL}
        tar xvf $(basename ${RDFPRO_URL} )
        rm -f $(basename ${RDFPRO_URL} )

        echo "RDFPRO_HOME=$RDFPRO_HOME"
        export PATH=${RDFPO_HOME}/rdfpro:$PATH
        echo "PATH=$PATH"
    fi
}
if [ ! -s ${RDFPRO_HOME} ]; then
    rdfpro_setup
fi

function rdfpro_generate() {
    rdfpro_out_file=${1:-${OUTPUT_DIR}/all-in-one_SHACL-shapes.ttl}
    rdfpro_cmd="${RDFPRO_HOME}/rdfpro @r "
    # rdfpro @r -w own-pt-fixed.nt wordnet-en-fixed.nt @w tudo-pro.nt
    i=0
    for t in ${TTL_FILES}; do
        i=$((i+1))
        #echo $i
        rdfpro_cmd="${rdfpro_cmd} $t"
    done
    rdfpro_cmd="${rdfpro_cmd} @w ${rdfpro_out_file}"
    echo -e "#### >>>> rdfpro_cmd=${rdfpro_cmd}"
    ${rdfpro_cmd}
    if [ ! -s ${rdfpro_out_file} ]; then
        echo -e ">>> ERROR: something went wrong! Can't generate ${rdfpro_out_file}! Abort!"
        exit 1
    else
        cat ${rdfpro_out_file} |grep -v "owl:imports" > ${rdfpro_out_file}.tmp
        mv ${rdfpro_out_file}.tmp ${rdfpro_out_file}
        echo -e ".............................................................................."
        echo -e ">>> SUCCESS: generate all-in-one 'SHACL' file:\n ${rdfpro_out_file}"
        echo -e ".............................................................................."
        ls -al ${rdfpro_out_file}
    fi
}
rdfpro_generate

exit 0


#### ---- Jena's RIOT/riot: generate single ONE turtle file for all SHACL files: ---- ####
JENA_ZIP_URL=`curl -sq https://jena.apache.org/download/index.cgi | grep "apache-jena-4" | grep "zip\"" | cut -d'"' -f2 `
JENA_ZIP=$(basename ${JENA_ZIP_URL} )
JENA_VERSION=$(echo ${JENA_ZIP} | cut -d '-' -f3)
JENA_VERSION=4.7.0
JENA_HOME=${PROJ_DIR}/${JENA_ZIP%.*}
export PATH=${JENA_HOME}/bin:$PATH
echo "JENA_HOME=$JENA_HOME"
echo "PATH=$PATH"

export JENA_HOME=${PROJ_DIR}/apache-jena-${JENA_VERSION}
echo "JENA_HOME=$JENA_HOME"


function jena_setup() {
    cd ${PROJ_DIR}
    if [  ! -s "${JENA_HOME}" ]; then
        #JENA_ZIP_URL=`curl -s https://jena.apache.org/download/index.cgi | grep "apache-jena-4" | grep "zip\"" | cut -d'"' -f2 `
        wget --no-check-certificate ${JENA_ZIP_URL}
        #JENA_ZIP=$(basename ${JENA_ZIP_URL} )
        #JENA_HOME=${PROJ_DIR}/${JENA_ZIP%.*}
        tar xvf $(basename ${JENA_ZIP_URL} )
        rm -f $(basename ${JENA_ZIP_URL} )

    fi
}
if [ ! -s ${JENA_HOME} ]; then
    jena_setup
fi
ls -al ${JENA_HOME}


function jena_riot_generate() {
    riot_out_file=${1:-${OUTPUT_DIR}/jena_riot_all-in-one_SHACL-shapes.ttl}
    # Jena RIOT/riot:
    # time riot own-pt-fixed.nt wordnet-en-fixed.nt > tudo-riot.nt
    riot_cmd="${JENA_HOME}/bin/riot ${TTL_FILES} > ${riot_out_file}"
    echo -e "#### >>>> riot_cmd=${riot_cmd}"
    ${riot_cmd}
}
jena_riot_generate
