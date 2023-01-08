#!/bin/bash -x

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


## -- find all *.ttl files: --

TTL_FILES=$(cd ${PROJ_DIR} && find ./ontology -name "*.ttl" | grep -v "LoadUCO.ttl" | sed 's#\.\/##' | sort -u )

echo -e "#### >>>> TTL_FILES=${TTL_FILES}"

#### ---- Copy all turtle files into one local folder: ---- ####
OUTPUT_DIR=${PROJ_DIR}/all_ttl
mkdir -p ${OUTPUT_DIR}

function copy_all_ttl_to_one_dir() {
    i=0
    for t in ${TTL_FILES}; do
        i=$((i+1))
        #echo $i
        cp $t ${OUTPUT_DIR}
    done
    echo -e "#### >>>>  Total RDF/TTL files: ${i}"
    ls -al ${OUTPUT_DIR}
}
copy_all_ttl_to_one_dir

#### ---- RDFPro: generate single ONE turtle file for all SHACL files: ---- ####
export RDFPRO_HOME=${PROJ_DIR}/rdfpro
function rdfpro_setup() {
    cd ${PROJ_DIR}
    if [  ! -s "${RDFPRO_HOME}" ]; then
        RDFPRO_URL=`curl -sq https://rdfpro.fbk.eu/install.html | grep "latest version" | grep "tar.gz" | cut -d'"' -f4 `
        wget ${RDFPRO_URL}
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
    rdfpro_out_file=${1:-${OUTPUT_DIR}/rdfpro_all-in-one_file.ttl}
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
}
#rdfpro_generate

#### ---- Jena's RIOT/riot: generate single ONE turtle file for all SHACL files: ---- ####
JENA_ZIP_URL=`curl -s https://jena.apache.org/download/index.cgi | grep "apache-jena-4" | grep "zip\"" | cut -d'"' -f2 `
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
        JENA_ZIP_URL=`curl -s https://jena.apache.org/download/index.cgi | grep "apache-jena-4" | grep "zip\"" | cut -d'"' -f2 `
        wget ${JENA_ZIP_URL}
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
    riot_out_file=${1:-${OUTPUT_DIR}/jena_riot_all-in-one_file.ttl}
    # Jena RIOT/riot:
    # time riot own-pt-fixed.nt wordnet-en-fixed.nt > tudo-riot.nt
    riot_cmd="${JENA_HOME}/bin/riot ${TTL_FILES} > ${riot_out_file}"
    echo -e "#### >>>> riot_cmd=${riot_cmd}"
    ${riot_cmd}
}
#jena_riot_generate
