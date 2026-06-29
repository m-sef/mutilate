#!/usr/bin/env bash
# Author(s): Yara Awad (https://github.com/awadyn)
#            Seth Moore (slmoore@hamilton.edu)

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

PORT=11211
AGENT1=10.10.1.2
AGENT2=10.10.1.3

run_experiment() {
        echo "START MEMCACHED 16 THREADS"
        sudo kubectl apply -f $SCRIPT_DIR/../../yaml/memcached.yaml
        sudo kubectl wait --for=condition=Ready pod -l app=memcached -n memcached --timeout=120s

        SERVER="$(sudo kubectl get svc memcached-service -n memcached -o jsonpath='{.spec.clusterIP}')"

        echo "START LOAD GENERATION AGENTS"
        ssh $AGENT1 "mutilate --agentmode --threads=16 > agent.log 2>&1 < /dev/null &"
        ssh $AGENT2 "mutilate --agentmode --threads=16 > agent.log 2>&1 < /dev/null &"

        echo "LOAD MEMCACHED DATABASE"
        taskset -c 0 mutilate -vv --binary -s $SERVER:$PORT --loadonly -K fb_key -V fb_value

        sleep 1

        UPDATE=$1
        QPS=$2

        echo "START RUN UPDATE $UPDATE QPS $QPS"
        mkdir -p $SCRIPT_DIR/exp/$UPDATE\_$QPS/

        # start load generation for 1 mcd process
        taskset -c 0 mutilate --binary -s $SERVER:$PORT --noload --agent={$AGENT1,$AGENT2} --threads=1 --keysize=fb_key --valuesize=fb_value --iadist=fb_ia --update=$UPDATE --depth=128 --measure_connections=32 --qps=$QPS --time=30 >> $SCRIPT_DIR/exp/$UPDATE\_$QPS/leader.log

        scp -r $AGENT1:~/agent.log $SCRIPT_DIR/exp/$UPDATE\_$QPS/agent1.log
        scp -r $AGENT2:~/agent.log $SCRIPT_DIR/exp/$UPDATE\_$QPS/agent2.log
        ssh $AGENT1 "sudo killall mutilate"
        ssh $AGENT2 "sudo killall mutilate"
        sudo kubectl delete -f yaml/memcached.yaml
}

echo "CREATE TEMP EXP DIR"
mkdir -p exp/
rm -rf exp/*

for i in 20000 40000 60000 80000 100000 120000 140000 160000 180000 200000 220000 240000 260000 280000 300000 320000 340000 360000 380000 400000; do
        run_experiment 0.25 $i
        sleep 1
done