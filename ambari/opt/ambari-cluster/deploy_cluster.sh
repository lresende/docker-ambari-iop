#!/bin/bash
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
# 
#   http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations

ROOT=`dirname $0`
ROOT=`cd $ROOT; pwd`

SERVER="$(/bin/hostname -i)"
SERVER="localhost"

printf "Deploying server $SERVER"

## wait for server startup
sleep 30s

## Deploy
printf "\n\nRegistered Hosts"
curl --silent -H "X-Requested-By: ambari" -X GET -u admin:admin http://$SERVER:8081/api/v1/hosts
sleep 3s
printf "\n\nRegistered Blueprints"
curl --silent -H "X-Requested-By: ambari" -X GET -u admin:admin http://$SERVER:8081/api/v1/blueprints
sleep 3s
printf "\n\nRegister IOP Blueprint"
curl --silent -H "X-Requested-By: ambari" -X POST -u admin:admin -d @$ROOT/blueprint_single_node.json http://$SERVER:8081/api/v1/blueprints/iop?validate_topology=false
sleep 3s
printf "\n\nRegistered Blueprints"
curl --silent -H "X-Requested-By: ambari" -X GET -u admin:admin http://$SERVER:8081/api/v1/blueprints
sleep 3s
printf "\n\nRegistered Cluster"
curl --silent -H "X-Requested-By: ambari" -X GET -u admin:admin http://$SERVER:8081/api/v1/clusters
sleep 3s
printf "\n\nRegister IOP Cluster"
curl --silent -H "X-Requested-By: ambari" -X POST -u admin:admin -d @$ROOT/hostmapping.json http://$SERVER:8081/api/v1/clusters/iop

## wait for finishing deploying
while true; 
   STATUS="$(curl --silent -H 'X-Requested-By: ambari' -X GET -u admin:admin http://$SERVER:8081/api/v1/clusters/iop/requests/1 | grep request_status)"
   if [[ $STATUS == *"COMPLETED"* ]]
   then
      printf "Deployment $STATUS";
      break;
   elif [[ $STATUS == *"FAILED"* ]]
   then
      printf "Deployment $STATUS";
      break;
   elif [[ $STATUS == *"ABORTED"* ]]
   then
      printf "Deployment $STATUS";
      break;
   else
      echo "Deployment $STATUS"
   fi
   do sleep 60s; 
done
