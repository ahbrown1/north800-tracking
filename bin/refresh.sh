#!/bin/bash

set -u
#set -x

ESS='https://vpc-n8-elasticsearch-3wr5742lihatxtsndxy6kmb6ci.us-east-1.es.amazonaws.com:443'
LOGSTASH='/usr/share/logstash/bin/logstash'
GDRIVE='/usr/share/logstash/repos/gdrive'

pushd ${GDRIVE} 

    rclone sync  -c -v --syslog \
      'remote:Shared Brown Business/BrownEstate/Properties/LLCs/North800_LLC/reports.north800.com' $(pwd)/remote/
    #pushd remote
    hashdeep -r remote | md5sum > /tmp/new_hash
    diff -N /tmp/new_hash /tmp/old_hash 2>&1 > /dev/null;  rv=$?
    cp /tmp/new_hash /tmp/old_hash
    #git diff --quiet --exit-code; rv=$?
    if [ "$rv" -eq 0 ]; then
        echo "No change"
    else
        echo "Change detected"
	git add .
	git commit -m change
	curl -X DELETE $ESS/es_n800-wf_xns-*
	${LOGSTASH} --pipeline.workers=1 -f /usr/share/logstash/repos/north800-tracking/config/es_wf_accounts.conf
    fi
    #popd

popd

