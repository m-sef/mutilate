# benchmarks/all_deployed_via_kubernetes

## Notes

| Node | IP | Type | Description
| :- | :- | :- | :- |
| master | 10.10.1.4 | c220g2 | Control plane |
| worker0 | 10.10.1.1 | c220g2 | Can run either Memcached server or Mutilate agent |
| worker1 | 10.10.1.2 | c220g2 | Can run either Memcached server or Mutilate agent |
| worker2 | 10.10.1.3 | c220g2 | Can run either Memcached server or Mutilate agent |

| Pod | Description |
| :- | :- |
| yaml/memcached.yaml | Will never be on the same node as a Mutilate agent |
| yaml/mutilate_leader.yaml | Will be forced onto the master node |
| yaml/mutilate_agent.yaml | Will never be on the same node as the Memcached pod, or another Mutilate agent |

__Hyperthreading and Turbo Boost is disabled on all nodes__

## How to Run Benchmark

```bash
# Deploys Memcached, Mutilate leader, and 2x Mutilate agents across the Kubernetes cluster. Runs Mutilate leader for 30 seconds for QPS 20,000 40,000 ... 400,000
./run_benchmark
```