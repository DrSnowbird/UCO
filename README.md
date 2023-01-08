> *“An ontology defines the basic terms and relations comprising the vocabulary of a topic area, as well as the rules for combining terms and relations to define extensions to the vocabulary. ” (Neches R, Fikes R, Finin T, Gruber T, Patil R, Senator T, Swartout WR (1991) “Enabling Technology for Knowledge Sharing” AI Magazine. Winter 1991. 36-56.)*

> *“An ontology is a formal, explicit specification of a shared conceptualization. ” (Studer, Benjamins, Fensel. Knowledge Engineering: Principles and Methods. Data and Knowledge Engineering. 25 (1998) 161-197)*

# Unified Cyber Ontology (UCO)

Unified Cyber Ontology (UCO) is a community-developed ontology/model, which is intended to serve as a consistent foundation for standardized information representation across the cyber security domain/ecosystem.

Specific information representations focused on individual cyber security subdomains (cyber investigation, computer/network defense, threat intelligence, malware analysis, vulnerability research, offensive/hack-back operations, etc.) can be be based on UCO and defined as appropriate subsets of UCO constructs.

Through this approach not only are domain-focused representations defined consistently but they also can take advantage of shared APIs and information can flow in an automated fashion across subdomain boundaries.

The purpose of this repository is to provide a foundation for broader community involvement in defining what to represent and how.

### Current Release
The current release of UCO is 1.1.0.

UCO 1.1.0 incorporates required refinements and updates, building on the stable 1.0.0 release.  Following [SemVer](https://semver.org/spec/v2.0.0.html), additive improvements will continue to be accepted, but backwards-incompatible changes will be scheduled only for the 2.0.0 release, which will come after at least 6 months to possibly 12 months.

More detail of improvements is documented in the [UCO 1.1.0 release notes](https://unifiedcyberontology.org/releases/1.1.0/).


# Use Protege (Stanford University's RDF IDE) for UCO:
0. (Optional) If you need to re-generate the needed files for loading UCO into Protege tool, run the following command:
```
bin/create-catalog-v001.xml.sh
```
1. Run your local Protege RDF IDE tool, then
2. Choose 'File / Open ...' from the drop-down menu, then
3. Go to the './ontology' folder, and then select the 'LoadUCO.ttl' file to open.
4. That's it! All the needed UCO ontology files (ttl) will be loaded at once.

# Generate all-in-one UCO ontology shapes SHCAL file:
* Run the command below and the resulting all-in-one UCL shapes file is 'local_ttl/all-in-one_SHACL-shapes.ttl':
```
bin/generate_all-in-one_SHACL-shapes.sh
```

# Ontology Resources
* [UCO Ontology](https://github.com/ucoProject/UCO)
* [CASE Onotlogy](https://github.com/casework)
* [Casework-Examples Github](https://github.com/casework/CASE-Examples)
* [Casework-Examples Illustration](https://github.com/casework/CASE-Examples/tree/master/examples/illustrations)
* [UCO App Docker (SHACL validation + RDF Store + GraphQL (Ultra GraphQL automation)](https://github.com/DrSnowbird/uco-app-docker) - to be released soon - estimated on 2023-01-31.
  * Fully integrated automation as end-to-end pipeline:
    * User upload UCO-based ontologies, then
    * This docker will call SHACL-validator REST Service, if the compliance (v1.1.0 as latest) is successful, 
    * Then, the automation will continue to upload / convert the users's RDF/JSON-LD ontologies into RDF Store, i.e., Jena-Fuseki-Docker
    * Then, the automation will continue to automatically feed the just-loaded UCO-compliant ontology to UltraGraphQL-docker to automatically convert input into GraphQL schema,
    * Then, UltraGraphQL-docker will automatically use the aut-generated GraphQL schma to publish the ```live``` GraphQL Web REST API service + Web UI for other client applications to start using 'GraphQL' API to query the user's UCO-compliant ontologies.
    * QED: the entire End-to-End automation!

# RDF + GraphQL Resources
* RDF Stores:
   * [Jena-fuseki-docker](https://github.com/DrSnowbird/jena-fuseki-docker)
   * [RDF4J-docker](https://github.com/DrSnowbird/rdf4j-docker)
* UltraGraphQL:
   * [UltraGraphQL-Upstream](https://git.rwth-aachen.de/i5/ultragraphql)
   * [UltraGraphQL](https://github.com/DrSnowbird/UltraGraphQL)
   * [UltraGraphQL-docker](https://github.com/DrSnowbird/UltraGraphQL-docker)
* HyperGrahQL:
   * [HyperGraphQL-Upstream](https://github.com/hypergraphql/hypergraphql)
   * [HyperGraphQL](https://github.com/DrSnowbird/HyperGraphQL)
   * [HyperGraphQL-docker](https://github.com/DrSnowbird/HyperGraphQL-docker)
