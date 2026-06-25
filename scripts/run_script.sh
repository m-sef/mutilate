#!/bin/bash

port=11211
server=10.10.1.2
agent1=10.10.1.3
agent2=10.10.1.4

echo "START MEMCACHED 16 THREADS"
ssh $server "taskset -c 0-15 ~/memcached/memcached -p $port -u nobody -t 16 -m 32G -c 8192 -b 8192 -l $server -B binary > mcd_11211.log 2>&1 < /dev/null &"

echo "START LOAD GENERATION AGENTS"
ssh $agent1 "~/mutilate/mutilate --agentmode --threads=16 > agent.log 2>&1 < /dev/null &"
ssh $agent2 "~/mutilate/mutilate --agentmode --threads=16 > agent.log 2>&1 < /dev/null &"

echo "LOAD MEMCACHED DATABASE"
taskset -c 0 ~/mutilate/mutilate -vv --binary -s $server:$port --loadonly -K fb_key -V fb_value

echo "CREATE TEMP EXP DIR"
mkdir -p exp/
rm -rf exp/*

sleep 1

update=$1
qps=$2

echo "START RUN UPDATE $update QPS $qps"
mkdir -p exp/$update\_$qps/

# start load generation for 1 mcd process
taskset -c 0 ~/mutilate/mutilate --binary -s $server:$port --noload --agent={$agent1,$agent2} --threads=1 --keysize=fb_key --valuesize=fb_value --iadist=fb_ia --update=$update --qps=$qps --depth=128 --measure_connections=32 --measure_qps=2000 --time=30 >> exp/leader.log

scp -r $agent1:~/agent.log exp/agent1.log
scp -r $agent2:~/agent.log exp/agent2.log
ssh $agent1 "sudo killall mutilate"
ssh $agent2 "sudo killall mutilate"
ssh $server "sudo killall memcached"

