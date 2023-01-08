#!/bin/bash

cd $(dirname $0)/..
PROJ_DIR=$(realpath ${0%/*}/..)
cd ${PROJ_DIR}

echo -e ">>> PROJ_DIR=${PROJ_DIR}"


####------------------------------------------------------- ####
#### ---- Find/Setup UCO_VERSION & UCO_LATEST_VERSION: ---- ####
####------------------------------------------------------- ####
UCO_VERSION=${UCO_VERSION:-1.1.0}
function find_UCO_version_latest() {
    UCO_LATEST_VERSION="`curl --silent https://api.github.com/repos/ucoProject/UCO/releases/latest | jq -r .tag_name | sed 's/^v//' `"
    UCO_VERSION=${UCO_VERSION:-$UCO_LATEST_VERSION}
}
find_UCO_version_latest
echo -e ">>> UCO_LATEST_VERSION: ${UCO_LATEST_VERSION}"
echo -e ">>> UCO_VERSION: ${UCO_VERSION}"


####------------------------------------------------------- ####
#### ---- Generate catalog-v001.xml (Protege RDF IDE): ---- ####
####------------------------------------------------------- ####

CATLOG_PRE_XML="<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>
<!-- Automatically built by the UCO infrastructure -->
<catalog prefer=\"public\" xmlns=\"urn:oasis:names:tc:entity:xmlns:xml:catalog\">"

CATLOG_POST_XML="
</catalog>
"

OUTPUT_DIR=${PROJ_DIR}/ontology
CATALOG_FILE="${OUTPUT_DIR}/catalog-v001.xml"

# <?xml version="1.0" encoding="UTF-8" standalone="no"?>
#<catalog prefer="public" xmlns="urn:oasis:names:tc:entity:xmlns:xml:catalog">
#    <group id=\"Folder Repository, directory=, recursive=true, Auto-Update=true, version=2\" prefer=\"public\" xml:base=\"\">
#        <uri id=\"Automatically generated entry\" name=\"https://unifiedcyberontology.org/ontology/uco/uco\" uri=\"./uco.ttl\"/>
#    </group>
#</catalog>


echo -e "${CATLOG_PRE_XML=}" | tee ${CATALOG_FILE}
#    TTL_FILES=$(find . |grep -v  git | grep -v master | grep -v "LoadUCO"| grep -v 'test' | grep ttl | sort)

## -- find all *.ttl files: --
cd ${PROJ_DIR}/ontology
TTL_FILES=$(find . -name "*.ttl" | grep -v "LoadUCO.ttl" | sort -u )

UCO_ONTOLOGY_PREFIX="https://ontology.unifiedcyberontology.org/"
for ttl in ${TTL_FILES}; do
    #echo "ttl=$ttl"
    # <uri id="User Entered Import Resolution" uri="./ont-policy.rdf" name="https://spec.edmcouncil.org/fibo/./ont-policy/"/>
    #ENTRY="<uri id=\"Automatically generated entry\" name=\"https://unifiedcyberontology.org/ontology/uco/uco\" uri=\"./.ttl\"/>"
    #ENTRY="<uri id=\"User Entered Import Resolution\" uri=\"./ont-policy.rdf\" name=\"https://spec.edmcouncil.org/fibo/./ont-policy/\"/>
    # <https://unifiedcyberontology.org/ontology/uco/types-da>
    ENTRY_L="    <uri id=\"User Entered Import Resolution\" uri=\""
    URI="${ttl}"
    ENTRY_M="\" name=\""
    TTL_NAME="`echo $ttl|sed 's#\.\/##' `"
    TTL_NAME=$(dirname ${TTL_NAME})
    ONTOLOGY_NAME="${UCO_ONTOLOGY_PREFIX}${TTL_NAME}/${UCO_VERSION}"
    ENTRY_R="\"/>"
    ENTRY="${ENTRY_L}${URI}${ENTRY_M}${ONTOLOGY_NAME}${ENTRY_R}"
    echo -e "${ENTRY}" | tee -a ${CATALOG_FILE}
done

echo -e "${CATLOG_POST_XML}" | tee -a ${CATALOG_FILE}
cat ${CATALOG_FILE}


####------------------------------------------------------- ####
#### ---- Generate LoadUCO.ttl (Protege RDF IDE):      ---- ####
####------------------------------------------------------- ####

LoadUCO_ttl_prefix=\
'@base <https://ontology.unifiedcyberontology.org/ontology/LoadUCO> .
@prefix : <https://unifiedcyberontology.org/ontology/uco/uco#> .
@prefix owl: <http://www.w3.org/2002/07/owl#> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix uco: <https://unifiedcyberontology.org/ontology/uco/uco#> .
@prefix xml: <http://www.w3.org/XML/1998/namespace> .
@prefix xs: <http://www.w3.org/2001/XMLSchema#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .

<https://ontology.unifiedcyberontology.org/ontology/LoadUCO>
	a owl:Ontology ;
	rdfs:label "uco-master"@en ;
	owl:imports
'
		
LoadUCO_ttl_postfix="
		;
	owl:versionInfo \"{{UCO_VERSION}}\" ;
	.
"

cd ${PROJ_DIR}/ontology
IRI_LIST_1=`ack "imports: https" | grep "#" |awk -F'[ ]' '{print $3}' | sort -u|sed 's/^/</g' | sed 's/$/>/g' `
IRI_LIST=${IRI_LIST_1:-IRI_LIST}
echo -e ">>> IRI_LIST:\n${IRI_LIST}"


LoadUCO_iri_list=""
for iri in ${IRI_LIST}; do
    if [ "${LoadUCO_iri_list}" != "" ]; then
        LoadUCO_iri_list=${LoadUCO_iri_list}" ,\n		${iri}"
    else
        LoadUCO_iri_list="		${iri}"
    fi
done


LoadUCO_ttl_postfix="
		;
	owl:versionInfo \"${UCO_VERSION}\" ;
	.
"
echo -e ">>> LoadUCO_ttl_postfix: ${LoadUCO_ttl_postfix}"

LoadUCO="${LoadUCO_ttl_prefix}${LoadUCO_iri_list}${LoadUCO_ttl_postfix}\n"
LoadUCO_FILE="${OUTPUT_DIR}/LoadUCO.ttl"
echo -e "${LoadUCO}" | tee ${LoadUCO_FILE}

cat ${LoadUCO_FILE}


