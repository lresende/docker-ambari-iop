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

rm /tmp/*.pid

# disable iptables firewall
/etc/init.d/iptables save
/etc/init.d/iptables stop

# Force Ipv6 to stop
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
echo 1 > /proc/sys/net/ipv6/conf/default/disable_ipv6

# sync with time server
HOST="$(/bin/hostname -f)"
if [[ $HOST == *"svl.ibm.com"* ]]
then
  ntpdate timeserver.svl.ibm.com;
else
  ntpdate pool.ntp.org;
fi
service ntpd start

# start ssh server
service sshd start

#dnsMask
service dnsmasq start

# start ambari
/usr/sbin/ambari-server start

#start ambari agent
/usr/sbin/ambari-agent start

echo "all boostrap commands executed"

if [[ $1 = "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 = "-bash" ]]; then
  /bin/bash
fi
