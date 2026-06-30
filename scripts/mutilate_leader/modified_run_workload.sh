#!/usr/bin/env bash
# Author(s): Seth Moore (https://github.com/m-sef)
# Meant to be called in running pod via kubectl exec

resolve_memcached_replica_ip() {
        # $1 = StatefulSet ordinal (0, 1, 2, ...)
        getent hosts memcached-$1.memcached-service.memcached.svc.cluster.local | awk '{print $1}'
}

resolve_memcached_clusterip_to_ip() {
        getent hosts memcached-clusterip-service.memcached.svc.cluster.local | awk '{print $1}'
}

resolve_mutilate_agent_domain_name_to_ip() {
        getent hosts mutilate-agent-$1.mutilate-agent-service.mutilate.svc.cluster.local | awk '{print $1}'
}

load_replicas() {
    REPLICA_COUNT=$1
    PORT=11211

    for i in $(seq 0 $((REPLICA_COUNT - 1))); do
        REPLICA_IP=$(resolve_memcached_replica_ip $i)
        taskset -c 0 mutilate -vv --binary -s $REPLICA_IP:$PORT --loadonly -K fb_key -V fb_value
    done
}

run_workload() {
    UPDATE=$1
    QPS=$2
    REPLICA_COUNT=$3

    AGENT1=$(resolve_mutilate_agent_domain_name_to_ip 0)
    AGENT2=$(resolve_mutilate_agent_domain_name_to_ip 1)
    SERVER=$(resolve_memcached_clusterip_to_ip)
    PORT=11211

    load_replicas $REPLICA_COUNT

    taskset -c 0 mutilate --binary -s $SERVER:$PORT --noload --agent={$AGENT1,$AGENT2} --threads=1 --keysize=fb_key --valuesize=fb_value --iadist=fb_ia --update=$UPDATE --depth=128 --measure_connections=32 --qps=$QPS --time=30
}

run_workload $1 $2 $3

exit 0
