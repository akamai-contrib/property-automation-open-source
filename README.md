# property-automation-open-source
Sample files for automating property manager configuration changes

This repository contains the source files and instructions on how you can automate the management of your Akamai properties using open source tools without having to write a lot of code 

## Open source tools we will use

* [Akamai CLI](https://github.com/akamai/cli): brew install akamai
* [Akamai CLI property package](https://github.com/akamai/cli-property): akamai install property
* [jq](https://stedolan.github.io/jq/): brew install jq
* [curl](https://curl.haxx.se/download.html)
* [Akamai Property Manager](https://control.akamai.com/apps/property-manager/)

## Script

Example of how you can create a modular pipeline that uses source control using open source tools.

### Create barebones property you can clone

Use Property Manager, create a new configuration with the minimum amount of features and save the JSON. You can call it property_template.json

### Create library of snippet functionality 

Use Property Manager to create modular rules that implement specific logic, and build a library over time. 

For example:
* mpulse.json
* SureRoute.json
* http2.json
* gzip.json
* cache-error-responses.json
* cache-h.json
* static-files-caching.json
* non-cacheable-paths.json
* image-manager.json
* cloudlets.json
* mobile-app-redirect.json
* dynamic-debug-page.json
* offload-static-assets.json
* edge-redirect.json
* stitch-micro-service.json
* inject-response-header.json
* inject-robots.txt.json
* block-embargo-countries.json


### Write code to easily create a new configuration based on a cocktail of rules

Use jq to add a bunch of snipets into our configuration template (new files), or to existing files

#### Variable Definitions (variables.cfg)
``MYEDGERC=~/.edgerc
MYPAPIEDGERC=devtrial-open
MYIMEDGERC=devtrial-im
MYCONFIG=javiergarza3
MYORIGIN=origin.example.com
MYGROUPID=`akamai property --section $MYPAPIEDGERC groups 2> /dev/null | jq -r .[0].groupId`
MYCONTRACTID=`akamai property --section $MYPAPIEDGERC groups 2> /dev/null | jq -r .[0].contractIds[0]`
MYPROD=prd_Fresca
MYRULES=rules.json
MYCPID=857555
MYCPNAME=ION1
LIBRARYLOCATION=https://raw.githubusercontent.com/akamai-contrib/property-automation-open-source/master/
BASEFILE=property_template.json
SNIPPETLIST="http2 gzip cache-h dynamic-debug-page"``

#### 5 lines of Code to put together a custom config and activate it on the staging, and store it on source control
``source variables.cfg
# Merge all snippets into a custom configuration 
ORIGINAL=$BASEFILE ; for SNIPPET in $SNIPPETLIST ; do jq ".rules.children += [`jq -c . $SNIPPET` ]" $ORIGINAL > $MYRULES
; cp $MYRULES $ORIGINAL ; done 
# Create Akamai configuration based on the generated JSON rules
akamai property --config $MYEDGERC --section $MYPAPIEDGERC create $MYCONFIG.edgesuite.net --forward origin --hostnames $MYCONFIG.edgesuite.net --edgehostname $MYCONFIG.edgesuite.net --origin $MYORIGIN --group $MYGROUPID --contract $MYCONTRACTID --product $MYPROD --file $MYRULES --newcpcodename $MYCONFIG
# Activate Akamai configuration on staging
akamai property --config $MYEDGERC --section $MYPAPIEDGERC activate $MYCONFIG.edgesuite.net --network staging
# Put file on source control
git add $MYRULES ; git commit -m "Adding $SNIPPETLIST TO: $BASEFILE" ; git push origin master
# Wait for activation to complete and start functionality testing (Jenkins)``


