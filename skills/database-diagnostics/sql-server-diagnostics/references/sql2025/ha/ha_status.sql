-- Target: SQL Server 2025 (17.x). Same query as the sql2022 pack unless a note below says otherwise.
-- Target permissions: as on 2022, the narrower VIEW SERVER ... STATE permissions instead of VIEW SERVER STATE.
-- State of the high-availability features: AlwaysOn, cluster (FCI), mirroring,
-- log shipping and replication. Sources: SERVERPROPERTY, sys.availability_groups,
-- sys.dm_os_cluster_nodes, sys.database_mirroring, msdb log_shipping tables and
-- sys.databases. Read-only: a SELECT over views, DMVs and msdb tables.
SELECT TOP (20)
    h.feature,
    h.isEnabled,
    h.detail
FROM (
    SELECT 1 AS sortOrder,
           CAST(N'AlwaysOnAvailabilityGroups' AS NVARCHAR(60)) AS feature,
           CAST(ISNULL(SERVERPROPERTY('IsHadrEnabled'), 0) AS BIT) AS isEnabled,
           CAST(CONCAT((SELECT COUNT(*) FROM sys.availability_groups), N' availability group(s); ',
                       (SELECT COUNT(*) FROM sys.dm_hadr_database_replica_states AS drs WHERE drs.is_local = 1),
                       N' local database(s) in an AG') AS NVARCHAR(400)) AS detail
    UNION ALL
    SELECT 2,
           N'FailoverClusterInstance',
           CAST(ISNULL(SERVERPROPERTY('IsClustered'), 0) AS BIT),
           CAST(CONCAT((SELECT COUNT(*) FROM sys.dm_os_cluster_nodes), N' node(s) in the cluster') AS NVARCHAR(400))
    UNION ALL
    SELECT 3,
           N'DatabaseMirroring',
           CAST(CASE WHEN EXISTS (SELECT 1 FROM sys.database_mirroring AS dm WHERE dm.mirroring_guid IS NOT NULL)
                     THEN 1 ELSE 0 END AS BIT),
           CAST(CONCAT((SELECT COUNT(*) FROM sys.database_mirroring AS dm WHERE dm.mirroring_guid IS NOT NULL),
                       N' mirrored database(s)') AS NVARCHAR(400))
    UNION ALL
    SELECT 4,
           N'LogShipping',
           CAST(CASE WHEN EXISTS (SELECT 1 FROM msdb.dbo.log_shipping_primary_databases)
                       OR EXISTS (SELECT 1 FROM msdb.dbo.log_shipping_secondary_databases)
                     THEN 1 ELSE 0 END AS BIT),
           CAST(CONCAT((SELECT COUNT(*) FROM msdb.dbo.log_shipping_primary_databases), N' primary database(s); ',
                       (SELECT COUNT(*) FROM msdb.dbo.log_shipping_secondary_databases), N' secondary database(s)')
                AS NVARCHAR(400))
    UNION ALL
    SELECT 5,
           N'Replication',
           CAST(CASE WHEN EXISTS (
                    SELECT 1 FROM sys.databases AS d
                    WHERE d.is_published = 1 OR d.is_merge_published = 1
                       OR d.is_subscribed = 1 OR d.is_distributor = 1)
                     THEN 1 ELSE 0 END AS BIT),
           CAST(CONCAT((SELECT COUNT(*) FROM sys.databases AS d WHERE d.is_published = 1 OR d.is_merge_published = 1),
                       N' published; ',
                       (SELECT COUNT(*) FROM sys.databases AS d WHERE d.is_subscribed = 1), N' subscribed; ',
                       (SELECT COUNT(*) FROM sys.databases AS d WHERE d.is_distributor = 1), N' distributor(s)')
                AS NVARCHAR(400))
) AS h
ORDER BY h.sortOrder
