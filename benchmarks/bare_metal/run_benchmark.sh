#!/usr/bin/env bash
# Author(s): Yara Awad (https://github.com/awadyn)
#            Seth Moore (https://github.com/m-sef)

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
TEMP_DIR=exp

PORT=11211
SERVER=10.10.1.1
AGENT1=10.10.1.2
AGENT2=10.10.1.3

run_experiment() {
        echo "START MEMCACHED 16 THREADS"
        ssh $SERVER "taskset -c 0-15 memcached -p $PORT -u nobody -t 16 -m 32G -c 8192 -b 8192 -l $SERVER -B binary > mcd_11211.log 2>&1 < /dev/null &"

        echo "START LOAD GENERATION AGENTS"
        ssh $AGENT1 "mutilate --agentmode --threads=16 > agent.log 2>&1 < /dev/null &"
        ssh $AGENT2 "mutilate --agentmode --threads=16 > agent.log 2>&1 < /dev/null &"

        echo "LOAD MEMCACHED DATABASE"
        taskset -c 0 mutilate -vv --binary -s $SERVER:$PORT --loadonly -K fb_key -V fb_value

        sleep 1

        UPDATE=$1
        QPS=$2

        echo "Benchmarking update=$UPDATE qps=$QPS"
        mkdir -p $SCRIPT_DIR/$TEMP_DIR/$UPDATE\_$QPS/

        # start load generation for 1 mcd process
        taskset -c 0 mutilate --binary -s $SERVER:$PORT --noload --agent={$AGENT1,$AGENT2} --threads=1 --keysize=fb_key --valuesize=fb_value --iadist=fb_ia --update=$UPDATE --depth=128 --measure_connections=32 --qps=$QPS --time=30 >> $SCRIPT_DIR/$TEMP_DIR/$UPDATE\_$QPS/leader.log

        ssh $AGENT1 "sudo killall mutilate"
        ssh $AGENT2 "sudo killall mutilate"
        ssh $SERVER "sudo killall memcached"
}

echo "Creating temporary directory '$TEMP_DIR/'"
mkdir -p $SCRIPT_DIR/$TEMP_DIR/

for i in 20000 40000 60000 80000 100000 120000 140000 160000 180000 200000 220000 240000 260000 280000 300000 320000 340000 360000 380000 400000; do
        run_experiment 0.25 $i
        sleep 1
done

echo "Compressing temporary directory '$TEMP_DIR/' into '$TEMP_DIR.tar.gz'"
tar -cvzf $SCRIPT_DIR/$TEMP_DIR.tar.gz $SCRIPT_DIR/$TEMP_DIR
rm -rf $SCRIPT_DIR/$TEMP_DIR