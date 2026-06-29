# benchmarks/bare_metal

## Notes

| Node | IP | Type | Description
| :- | :- | :- | :- |
| master | 10.10.1.4 | c220g2 | Mutilate Leader |
| worker0 | 10.10.1.1 | c220g2 | Memcached Server|
| worker1 | 10.10.1.2 | c220g2 | Mutilate Agent 1 |
| worker2 | 10.10.1.3 | c220g2 | Mutilate Agent 2 |

__Hyperthreading and Turbo Boost is disabled on all nodes, irqbalance is untouched__

## How to Run Benchmark

```bash
# Runs Memcached on worker0, Mutilate leader on master, Mutilate agent 1 on worker1, and Mutilate agent 2 on worker2. Runs Mutilate leader for 30 seconds with target QPS 20,000 40,000 60,000 ... 400,000
./run_benchmark
```