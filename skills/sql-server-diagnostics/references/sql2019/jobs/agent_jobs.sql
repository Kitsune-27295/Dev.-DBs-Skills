-- Target: SQL Server 2019 (15.x). Same query as the sql2022 pack: every object it reads exists on 2019.
-- Target permissions: on 2019 the DMVs and DMFs it reads need VIEW SERVER STATE (2022 split this into narrower ones).
-- SQL Server Agent jobs and the last result of each one (msdb.dbo.sysjobs,
-- sysjobhistory, sysjobactivity and syssessions). Read-only: a SELECT over msdb tables;
-- no job is started or changed.
-- A job running in the current Agent session appears as 'In Progress', with the start time
-- and the seconds elapsed so far. Times in the instance's local time zone.
WITH lastRun AS (
    SELECT
        h.job_id,
        h.run_status,
        h.run_date,
        h.run_time,
        h.run_duration,
        ROW_NUMBER() OVER (PARTITION BY h.job_id ORDER BY h.run_date DESC, h.run_time DESC, h.instance_id DESC) AS rn
    FROM msdb.dbo.sysjobhistory AS h
    WHERE h.step_id = 0
),
running AS (
    SELECT ja.job_id, MAX(ja.start_execution_date) AS startedAt
    FROM msdb.dbo.sysjobactivity AS ja
    WHERE ja.session_id = (SELECT MAX(ss.session_id) FROM msdb.dbo.syssessions AS ss)
      AND ja.start_execution_date IS NOT NULL
      AND ja.stop_execution_date IS NULL
    GROUP BY ja.job_id
)
SELECT TOP (100)
    CAST(j.name AS NVARCHAR(128)) AS jobName,
    CAST(j.enabled AS BIT) AS isEnabled,
    CAST(CASE
            WHEN r.job_id IS NOT NULL THEN N'In Progress'
            WHEN lr.run_status = 0 THEN N'Failed'
            WHEN lr.run_status = 1 THEN N'Succeeded'
            WHEN lr.run_status = 2 THEN N'Retry'
            WHEN lr.run_status = 3 THEN N'Canceled'
            WHEN lr.run_status = 4 THEN N'In Progress'
         END AS NVARCHAR(20)) AS lastRunStatus,
    CASE
        WHEN r.job_id IS NOT NULL THEN CAST(r.startedAt AS DATETIME2)
        WHEN lr.run_date > 0 THEN DATETIME2FROMPARTS(
            lr.run_date / 10000, lr.run_date / 100 % 100, lr.run_date % 100,
            lr.run_time / 10000, lr.run_time / 100 % 100, lr.run_time % 100, 0, 0)
    END AS lastRunTime,
    CASE
        WHEN r.job_id IS NOT NULL THEN DATEDIFF(SECOND, r.startedAt, GETDATE())
        WHEN lr.run_duration IS NOT NULL THEN
            lr.run_duration / 10000 * 3600 + lr.run_duration / 100 % 100 * 60 + lr.run_duration % 100
    END AS lastRunDurationSeconds
FROM msdb.dbo.sysjobs AS j
LEFT JOIN lastRun AS lr
  ON lr.job_id = j.job_id AND lr.rn = 1
LEFT JOIN running AS r
  ON r.job_id = j.job_id
ORDER BY j.name, j.job_id
