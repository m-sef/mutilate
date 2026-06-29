#!/usr/bin/env bash
# Author(s): Seth Moore (https://github.com/m-sef)

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
TEMP_DIR=exp

run_benchmark() {
    UPDATE=$1
    QPS=$2

    sudo kubectl apply -Rf $SCRIPT_DIR/../../yaml/
    sudo kubectl wait --for=condition=Ready pod --all -n memcached --timeout=120s
    sudo kubectl rollout status statefulset/mutilate-leader -n mutilate --timeout=120s
    sudo kubectl rollout status statefulset/mutilate-agent -n mutilate --timeout=120s

    echo "Benchmarking update=$UPDATE qps=$QPS"
    mkdir -p $SCRIPT_DIR/$TEMP_DIR/$UPDATE\_$QPS/

    sudo kubectl exec -n mutilate mutilate-leader-0 -- ./scripts/mutilate_leader/run_workload.sh $1 $2 >> $SCRIPT_DIR/$TEMP_DIR/$UPDATE\_$QPS/leader.log

    sudo kubectl delete -Rf $SCRIPT_DIR/../../yaml/
}

echo "Creating temporary directory '$TEMP_DIR/'"
mkdir -p $SCRIPT_DIR/$TEMP_DIR/

for i in 20000 40000 60000 80000 100000 120000 140000 160000 180000 200000 220000 240000 260000 280000 300000 320000 340000 360000 380000 400000; do
    run_benchmark 0.25 $i
    sleep 1
done

echo "Compressing temporary directory '$TEMP_DIR/' into '$TEMP_DIR.tar.gz'"
tar -cvzf $SCRIPT_DIR/$TEMP_DIR.tar.gz $SCRIPT_DIR/$TEMP_DIR
rm -rf $SCRIPT_DIR/$TEMP_DIR

exit 0