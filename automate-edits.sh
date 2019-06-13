source variables.cfg
# download latest version of the property 
akamai property --config $MYEDGERC --section $MYPAPIEDGERC retrieve $MYCONFIG.edgesuite.net --file $MYRULES 
# Merge all snippets into a custom configuration 
ORIGINAL=$MYBASEFILE ; for SNIPPET in $MYSNIPPETLIST ; do jq ".rules.children += [`jq -c . ${SNIPPET}.json` ]" $ORIGINAL > $MYRULES ; cp $MYRULES $ORIGINAL ; done 
# Update Akamai configuration based on the generated JSON rules
akamai property --config $MYEDGERC --section $MYPAPIEDGERC update $MYCONFIG.edgesuite.net --file $MYRULES 
# Activate Akamai configuration on staging
akamai property --config $MYEDGERC --section $MYPAPIEDGERC activate $MYCONFIG.edgesuite.net --network staging
# Put file on source control
#git add $MYRULES ; git commit -m "Adding $SNIPPETLIST TO: $BASEFILE" ; git push origin master
# Wait for activation to complete and start functionality testing (Jenkins)
