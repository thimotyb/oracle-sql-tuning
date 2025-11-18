# Autotrace Snapshot (SCOTT/PDB1)

## Raw Statistics
```
buffer is not pinned count              172
buffer is pinned count                  32
bytes received via SQL*Net from client  2671
bytes sent via SQL*Net to client        92075
calls to get snapshot scn: kcmgss       96
calls to kcmgcs                         18
cluster key scan block gets             26
cluster key scans                       19
consistent gets                         273
consistent gets examination             93
consistent gets examination (fastpath)  93
consistent gets from cache              273
consistent gets pin                     180
consistent gets pin (fastpath)          180
CPU used by this session                6
CPU used when call started              5
cursor authentications                  1
cursor reload failures                  3
db block gets                           6
db block gets from cache                6
db block gets from cache (fastpath)     6
DB time                                 5
enqueue releases                        16
enqueue requests                        16
execute count                           87
index fetch by key                      32
index range scans                       45
logical read bytes from cache           2285568
no work - consistent read gets          145
non-idle wait count                     71
opened cursors cumulative               91
parse count (hard)                      16
parse count (total)                     41
parse time cpu                          2
parse time elapsed                      3
process last non-idle time              1
recursive calls                         511
recursive cpu usage                     5
Requests to/from client                 45
rows fetched via callback               8
session cursor cache count              -1
session cursor cache hits               80
session logical reads                   279
session pga memory                      262144
session pga memory max                  524288
session uga memory                      65480
session uga memory max                  651000
sorts (memory)                          28
sorts (rows)                            4206
sql area evicted                        3
SQL*Net roundtrips to/from client       45
table fetch by rowid                    35
table scan blocks gotten                80
table scan disk non-IMC rows gotten     4019
table scan rows gotten                  4019
table scans (short tables)              12
user calls                              49
workarea executions - optimal           17
workarea memory allocated               21
```

## Interpretation
- **Access pattern**: 12 short table scans returning ~4K rows (`table scan rows gotten 4019`, blocks 80) plus 45 index range scans/32 key fetches and 35 rowid fetches; scans dominate rows, mixes with index lookups.
- **Logical I/O**: 279 logical reads (`consistent gets 273`, `db block gets 6`), all from cache; no physical reads; pinned/not-pinned counts show normal cached access.
- **Parsing & cursors**: 41 parses, 16 hard; 80 cursor cache hits; 3 reload failures ⇒ some churn/multiple executions of similar SQL.
- **CPU/runtime**: CPU used 6 cs vs DB time 5 cs ⇒ trivial elapsed time.
- **Network**: 45 SQL*Net round-trips, ~92 KB sent / 2.7 KB received ⇒ small results with moderate chatty exchanges.
- **Recursive/metadata**: 511 recursive calls and 96 SCN snapshots indicate metadata/recursive SQL overhead relative to the small workload.
- **Sorts/workareas**: 28 memory sorts over ~4.2K rows; all optimal (no spills); PGA/UGA usage minimal.
- **Locks/cluster**: 16 enqueue requests/releases; minor cluster key scans (19) with 26 block gets; nothing heavy.

## Quick tuning takeaways
1) Reduce hard parses/reloads via bind use and cursor reuse.  
2) Batch or coalesce SQL to trim the 45 round-trips if latency matters.  
3) Workload is cache-only and CPU-light; no immediate I/O or memory pressure indicated.
