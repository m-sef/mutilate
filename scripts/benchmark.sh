#!/usr/bin/env bash

run_benchmark() {
    UPDATE=$1
    QPS=$2

    sudo kubectl apply -Rf yaml/
    sudo kubectl wait --for=condition=Ready pod --all -n memcached --timeout=120s
    sudo kubectl rollout status statefulset/mutilate-leader -n mutilate --timeout=120s
    sudo kubectl rollout status statefulset/mutilate-agent -n mutilate --timeout=120s

    echo "    BENCHMARK $UPDATE $QPS    "

    sudo kubectl exec -n mutilate mutilate-leader-0 -- ./scripts/mutilate_leader/run_workload.sh $1 $2 >> benchmark/$UPDATE\_$QPS.log

    sudo kubectl delete -Rf yaml/
}

rm -rf benchmark/*

for i in 20000 40000 60000 80000 100000 120000 140000 160000 180000 200000 220000 240000 260000 280000 300000 320000 340000 360000 380000 400000; do
    run_benchmark 0.25 $i
    sleep 1
done

exit 0
