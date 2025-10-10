-- Use the system schema to run the given statement

SELECT s.sid, s.serial#, p.spid as "OS PID",s.username,s.module, st.value/100 as "CPU sec"
FROM v$sesstat st, v$statname sn, v$session s, v$process p
WHERE sn.name = 'CPU used by this session'
AND st.statistic# = sn.statistic#
AND st.sid = s.sid
AND s.paddr = p.addr
AND s.last_call_et < 1800
AND s.logon_time > (SYSDATE - 240/1440)
ORDER BY st.value;
