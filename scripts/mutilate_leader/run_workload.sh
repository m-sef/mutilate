#!/usr/bin/env bash
# Author(s): Seth Moore (https://github.com/m-sef)
# Meant to be called in running pod via kubectl exec

resolve_memcached_domain_name_to_ip() {
        getent hosts memcached-service.memcached.svc.cluster.local | awk '{print $1}'
}

resolve_mutilate_agent_domain_name_to_ip() {
        getent hosts mutilate-agent-$1.mutilate-agent-service.mutilate.svc.cluster.local | awk '{print $1}'
}

run_workload() {
    UPDATE=$1
    QPS=$2

    AGENT1=$(resolve_mutilate_agent_domain_name_to_ip 0)
    AGENT2=$(resolve_mutilate_agent_domain_name_to_ip 1)
    SERVER=$(resolve_memcached_domain_name_to_ip)
    PORT=11211

    taskset -c 0 mutilate -vv --binary -s $SERVER:$PORT --loadonly -K fb_key -V fb_value
    taskset -c 0 mutilate --binary -s $SERVER:$PORT --noload --agent={$AGENT1,$AGENT2} --threads=1 --keysize=fb_key --valuesize=fb_value --iadist=fb_ia --update=$UPDATE --depth=128 --measure_connections=32 --qps=$QPS --time=30
}

run_workload $1 $2

exit 0