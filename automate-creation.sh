source variables.cfg
# Merge all snippets into a custom configuration 
ORIGINAL=$MYBASEFILE ; for SNIPPET in $MYSNIPPETLIST ; do jq ".rules.children += [`jq -c . ${SNIPPET}.json` ]" $ORIGINAL > $MYRULES ; cp $MYRULES $ORIGINAL ; done 
# Create Akamai configuration based on the generated JSON rules
akamai property --config $MYEDGERC --section $MYPAPIEDGERC create $MYCONFIG.edgesuite.net --forward origin --hostnames $MYCONFIG.edgesuite.net --edgehostname $MYCONFIG.edgesuite.net --origin $MYORIGIN --group $MYGROUPID --contract $MYCONTRACTID --product $MYPROD --file $MYRULES --newcpcodename $MYCONFIG
# Activate Akamai configuration on staging
akamai property --config $MYEDGERC --section $MYPAPIEDGERC activate $MYCONFIG.edgesuite.net --network staging
# Put file on source control
git add $MYRULES ; git commit -m "Adding $SNIPPETLIST TO: $BASEFILE" ; git push origin master
# Wait for activation to complete and start functionality testing (Jenkins)
