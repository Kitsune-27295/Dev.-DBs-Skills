-- Target: SQL Server 2025 (17.x). Same query as the sql2022 pack unless a note below says otherwise.
-- Target permissions: as on 2022, the narrower VIEW SERVER ... STATE permissions instead of VIEW SERVER STATE.
-- Vector indexes of the current database (sys.vector_indexes, new in SQL Server 2025).
-- Read-only: a SELECT over a catalog view. Run it in each user database; the view is per database.
-- Ran on 17.0.4065.4 (see sql2025-porting.md); the column names come from the Microsoft Learn reference page.
SELECT TOP (200)
    CAST(OBJECT_SCHEMA_NAME(vi.object_id) + N'.' + OBJECT_NAME(vi.object_id) AS NVARCHAR(512)) AS tableName,
    vi.index_id AS indexId,
    CAST(vi.vector_index_type AS NVARCHAR(60)) AS vectorIndexType,
    CAST(vi.distance_metric AS NVARCHAR(60)) AS distanceMetric,
    CAST(vi.build_parameters AS NVARCHAR(4000)) AS buildParameters
FROM sys.vector_indexes AS vi
ORDER BY tableName, vi.index_id
