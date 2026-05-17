/* Stable MySQL Health Report - Collapsible & Linked Sections */
/* Run: mysql -N -s -f < script.sql > report.html */

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;


-- 1. HTML Header & Enhanced CSS
SELECT '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><title>MySQL Health Report</title><style>body{font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;background:#f5f5f7;margin:0;padding:40px;color:#1d1d1f;}h1{font-size:32px;font-weight:600;}h2{font-size:22px;margin:0;cursor:pointer;display:inline-block;}.sub-title{font-size:16px;font-weight:600;color:#424245;margin:25px 0 10px 0;display:flex;align-items:center;}.sub-title::before{content:"";width:4px;height:16px;background:#0071e3;margin-right:8px;border-radius:2px;}.card{background:#ffffff;border-radius:16px;padding:25px;margin-bottom:30px;box-shadow:0 8px 24px rgba(0,0,0,0.06);}table{width:100%;border-collapse:collapse;font-size:13px;margin-bottom:15px;}.query-sql{background:#f6f8fa;border:1px solid #e5e5e7;border-radius:10px;color:#424245;font-family:SFMono-Regular,Consolas,"Liberation Mono",monospace;font-size:12px;line-height:1.45;margin:0 0 12px 0;padding:12px;white-space:pre-wrap;}th{padding:10px;text-align:left;border-bottom:1px solid #e5e5e7;background:#fafafa;}td{padding:8px;border-bottom:1px solid #e5e5e7;color:#6e6e73;}tr:hover{background:#fbfbfd;}.directory-grid{display:flex;flex-wrap:wrap;gap:20px;margin-top:15px;}.dir-group{border:1px solid #f0f0f2;padding:15px;border-radius:12px;background:#fbfbfd;min-width:220px;}.dir-group-label{font-size:11px;font-weight:bold;color:#0071e3;text-transform:uppercase;display:block;margin-bottom:8px;}.directory a{display:block;padding:3px 0;color:#1d1d1f;text-decoration:none;font-size:13px;}.directory a:hover{text-decoration:underline;color:#0071e3;}.meta{color:#86868b;font-size:14px;}
/* Collapsible Styling */
details summary{outline:none;list-style:none;border-bottom:2px solid #0071e3;padding-bottom:5px;margin-bottom:15px;}
details summary::-webkit-details-marker{display:none;}
details summary:hover h2{color:#0071e3;}
details[open] summary{margin-bottom:20px;}
</style></head><body>';

-- 2. Report Header
SELECT CONCAT('<div class="card"><h1>MySQL Health Report</h1><div class="meta">Generated: ',DATE_FORMAT(NOW(),'%Y-%m-%d %H:%i:%s'),'</div><div class="meta">Version: v1.0.0 | Author: Rongping</div></div>');

-- 3. Categorized Directory (Now with Main Section Links)
SELECT '<div class="card directory"><h2>Navigation</h2><div class="directory-grid"><div class="dir-group"><a href="#section_host" class="dir-group-label">I. Host Summary</a><a href="#h_1">1.1 Host Summary Overview</a><a href="#h_2">1.2 File IO Overview</a><a href="#h_3">1.3 File IO Type</a><a href="#h_4">1.4 Stages</a><a href="#h_5">1.5 Statement Latency</a><a href="#h_6">1.6 Statement Type</a></div><div class="dir-group"><a href="#section_io" class="dir-group-label">II. IO Summary</a><a href="#io_1">2.1 IO by Thread Latency</a><a href="#io_2">2.2 File Bytes</a><a href="#io_3">2.3 File Latency</a><a href="#io_4">2.4 Wait Bytes</a><a href="#io_5">2.5 Wait Latency</a></div><div class="dir-group"><a href="#section_user" class="dir-group-label">III. User Summary</a><a href="#u_1">3.1 User Overview</a><a href="#u_2">3.2 File IO</a><a href="#u_3">3.3 File IO Type</a><a href="#u_4">3.4 Stages</a><a href="#u_5">3.5 Statement Latency</a><a href="#u_6">3.6 Statement Type</a></div><div class="dir-group"><a href="#section_memory" class="dir-group-label">IV. Memory Summary</a><a href="#m_1">4.1 Memory by Host</a><a href="#m_2">4.2 Memory by Thread</a><a href="#m_3">4.3 Memory by User</a><a href="#m_4">4.4 Memory Global</a></div><div class="dir-group"><a href="#section_wait" class="dir-group-label">V. Wait Summary</a><a href="#w_1">5.1 Global Latency</a><a href="#w_2">5.2 By User</a><a href="#w_3">5.3 By Host</a><a href="#w_4">5.4 Classes Latency</a><a href="#w_5">5.5 Classes Avg Latency</a></div><div class="dir-group"><a href="#section_index" class="dir-group-label">VI. Index Summary</a><a href="#idx_1">6.1 Index Statistics</a><a href="#idx_2">6.2 Redundant Indexes</a><a href="#idx_3">6.3 Unused Indexes</a><a href="#idx_4">6.4 Low Selectivity</a><a href="#idx_5">6.5 Tables Without PK</a></div><div class="dir-group"><a href="#sec_db_tables" class="dir-group-label">VII. DB Tables Info</a><a href="#t_3">Top 20 Largest</a><a href="#t_5">Auto Inc</a><a href="#t_6">Full Scans</a><a href="#t_7">Table Stats</a></div></div></div>';


-- 4. Main Section: Host Summary (Collapsible)
SELECT '<div class="card"><details open id="section_host"><summary><h2 id="main_host">1. Host Summary</h2></summary>';

-- 1.1 Host Summary Overview (sys.x$host_summary)
SELECT * FROM (
    SELECT '<div id="h_1" class="sub-title">1.1 Host Summary Overview</div><pre class="query-sql"># Query:\n#\tSELECT * FROM `sys`.`x$host_summary` ORDER BY x$host_summary.statement_latency DESC</pre><table><tr><th>Host</th><th>Statements</th><th>Statement Latency</th><th>Statement Avg Latency</th><th>Table Scans</th><th>File IOs</th><th>File IO Latency</th><th>Current Connections</th><th>Total Connections</th><th>Unique Users</th><th>Current Memory</th><th>Total Memory Allocated</th></tr>'

    UNION ALL

    SELECT CONCAT(
        '<tr><td>',IFNULL(CONVERT(host USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',FORMAT(statements,0),
        '</td><td>',sys.format_time(statement_latency),
        '</td><td>',sys.format_time(statement_avg_latency),
        '</td><td>',FORMAT(table_scans,0),
        '</td><td>',FORMAT(file_ios,0),
        '</td><td>',sys.format_time(file_io_latency),
        '</td><td>',FORMAT(current_connections,0),
        '</td><td>',FORMAT(total_connections,0),
        '</td><td>',FORMAT(unique_users,0),
        '</td><td>',sys.format_bytes(current_memory),
        '</td><td>',sys.format_bytes(total_memory_allocated),
        '</td></tr>'
    )
    FROM (
        SELECT *
        FROM sys.x$host_summary
        ORDER BY statement_latency DESC
    ) t1

    UNION ALL
    SELECT '</table>'
) x;

-- 1.2 Host Summary by File IO (sys.x$host_summary_by_file_io)
SELECT * FROM (
    SELECT '<div id="h_2" class="sub-title">1.2 Host Summary by File IO</div><pre class="query-sql"># Query:\n#\tSELECT * FROM `sys`.`x$host_summary_by_file_io` ORDER BY x$host_summary_by_file_io.io_latency DESC</pre><table><tr><th>Host</th><th>IOs</th><th>IO Latency</th></tr>'

    UNION ALL

    SELECT CONCAT(
        '<tr><td>',IFNULL(CONVERT(host USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',FORMAT(ios,0),
        '</td><td>',sys.format_time(io_latency),
        '</td></tr>'
    )
    FROM (
        SELECT *
        FROM sys.x$host_summary_by_file_io
        ORDER BY io_latency DESC
    ) t1

    UNION ALL
    SELECT '</table>'
) x;

-- 1.3 Host Summary by File IO Type (sys.x$host_summary_by_file_io_type)
SELECT * FROM (
    SELECT '<div id="h_3" class="sub-title">1.3 Host Summary by File IO Type</div><pre class="query-sql"># Query:\n#\tSELECT * FROM `sys`.`x$host_summary_by_file_io_type` ORDER BY x$host_summary_by_file_io_type.host, x$host_summary_by_file_io_type.total_latency DESC</pre><table><tr><th>Host</th><th>Event Name</th><th>Total</th><th>Total Latency</th><th>Max Latency</th></tr>'

    UNION ALL

    SELECT CONCAT(
        '<tr><td>',IFNULL(CONVERT(host USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',IFNULL(CONVERT(event_name USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',FORMAT(total,0),
        '</td><td>',sys.format_time(total_latency),
        '</td><td>',sys.format_time(max_latency),
        '</td></tr>'
    )
    FROM (
        SELECT *
        FROM sys.x$host_summary_by_file_io_type
        ORDER BY host, total_latency DESC
    ) t1

    UNION ALL
    SELECT '</table>'
) x;

-- 1.4 Host Summary by Stages (sys.x$host_summary_by_stages)
SELECT * FROM (
    SELECT '<div id="h_4" class="sub-title">1.4 Host Summary by Stages</div><pre class="query-sql"># Query:\n#\tSELECT * FROM `sys`.`x$host_summary_by_stages` ORDER BY x$host_summary_by_stages.host, x$host_summary_by_stages.total_latency DESC</pre><table><tr><th>Host</th><th>Event Name</th><th>Total</th><th>Total Latency</th><th>Avg Latency</th></tr>'

    UNION ALL

    SELECT CONCAT(
        '<tr><td>',IFNULL(CONVERT(host USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',IFNULL(CONVERT(event_name USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',FORMAT(total,0),
        '</td><td>',sys.format_time(total_latency),
        '</td><td>',sys.format_time(avg_latency),
        '</td></tr>'
    )
    FROM (
        SELECT *
        FROM sys.x$host_summary_by_stages
        ORDER BY host, total_latency DESC
    ) t1

    UNION ALL
    SELECT '</table>'
) x;

-- 1.5 Host Summary by Statement Latency (sys.x$host_summary_by_statement_latency)
SELECT * FROM (
    SELECT '<div id="h_5" class="sub-title">1.5 Host Summary by Statement Latency</div><pre class="query-sql"># Query:\n#\tSELECT * FROM `sys`.`x$host_summary_by_statement_latency` ORDER BY x$host_summary_by_statement_latency.total_latency DESC</pre><table><tr><th>Host</th><th>Total</th><th>Total Latency</th><th>Max Latency</th><th>Lock Latency</th><th>CPU Latency</th><th>Rows Sent</th><th>Rows Examined</th><th>Rows Affected</th><th>Full Scans</th></tr>'

    UNION ALL

    SELECT CONCAT(
        '<tr><td>',IFNULL(CONVERT(host USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',FORMAT(total,0),
        '</td><td>',sys.format_time(total_latency),
        '</td><td>',sys.format_time(max_latency),
        '</td><td>',sys.format_time(lock_latency),
        '</td><td>',sys.format_time(cpu_latency),
        '</td><td>',FORMAT(rows_sent,0),
        '</td><td>',FORMAT(rows_examined,0),
        '</td><td>',FORMAT(rows_affected,0),
        '</td><td>',FORMAT(full_scans,0),
        '</td></tr>'
    )
    FROM (
        SELECT *
        FROM sys.x$host_summary_by_statement_latency
        ORDER BY total_latency DESC
    ) t1

    UNION ALL
    SELECT '</table>'
) x;

-- 1.6 Host Summary by Statement Type (sys.x$host_summary_by_statement_type)
SELECT * FROM (
    SELECT '<div id="h_6" class="sub-title">1.6 Host Summary by Statement Type</div><pre class="query-sql"># Query:\n#\tSELECT * FROM `sys`.`x$host_summary_by_statement_type` ORDER BY x$host_summary_by_statement_type.host, x$host_summary_by_statement_type.total_latency DESC</pre><table><tr><th>Host</th><th>Statement</th><th>Total</th><th>Total Latency</th><th>Max Latency</th><th>Lock Latency</th><th>CPU Latency</th><th>Rows Sent</th><th>Rows Examined</th><th>Rows Affected</th><th>Full Scans</th></tr>'

    UNION ALL

    SELECT CONCAT(
        '<tr><td>',IFNULL(CONVERT(host USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',IFNULL(CONVERT(statement USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',FORMAT(total,0),
        '</td><td>',sys.format_time(total_latency),
        '</td><td>',sys.format_time(max_latency),
        '</td><td>',sys.format_time(lock_latency),
        '</td><td>',sys.format_time(cpu_latency),
        '</td><td>',FORMAT(rows_sent,0),
        '</td><td>',FORMAT(rows_examined,0),
        '</td><td>',FORMAT(rows_affected,0),
        '</td><td>',FORMAT(full_scans,0),
        '</td></tr>'
    )
    FROM (
        SELECT *
        FROM sys.x$host_summary_by_statement_type
        ORDER BY host, total_latency DESC
    ) t1

    UNION ALL
    SELECT '</table>'
) x;

SELECT '</details></div>';

-- 5. Main Section: IO Summary (Collapsible)
SELECT '<div class="card"><details open id="section_io"><summary><h2 id="main_io">2. IO Summary</h2></summary>';

-- 2.1 IO by Thread by Latency (sys.x$io_by_thread_by_latency)
SELECT * FROM (
    SELECT '<div id="io_1" class="sub-title">2.1 IO by Thread by Latency</div><pre class="query-sql"># Query:\n#\tSELECT * FROM `sys`.`x$io_by_thread_by_latency` ORDER BY x$io_by_thread_by_latency.total_latency DESC</pre><table><tr><th>User</th><th>Total</th><th>Total Latency</th><th>Min Latency</th><th>Avg Latency</th><th>Max Latency</th><th>Thread ID</th><th>Processlist ID</th></tr>'

    UNION ALL

    SELECT CONCAT(
        '<tr><td>',IFNULL(CONVERT(`user` USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',FORMAT(total,0),
        '</td><td>',sys.format_time(total_latency),
        '</td><td>',sys.format_time(min_latency),
        '</td><td>',sys.format_time(avg_latency),
        '</td><td>',sys.format_time(max_latency),
        '</td><td>',IFNULL(thread_id,''),
        '</td><td>',IFNULL(processlist_id,''),
        '</td></tr>'
    )
    FROM (
        SELECT *
        FROM sys.x$io_by_thread_by_latency
        ORDER BY total_latency DESC
    ) t1

    UNION ALL
    SELECT '</table>'
) x;

-- 2.2 IO Global by File by Bytes (sys.x$io_global_by_file_by_bytes)
SELECT * FROM (
    SELECT '<div id="io_2" class="sub-title">2.2 IO Global by File by Bytes</div><pre class="query-sql"># Query:\n#\tSELECT * FROM `sys`.`x$io_global_by_file_by_bytes` ORDER BY x$io_global_by_file_by_bytes.total DESC</pre><table><tr><th>File</th><th>Count Read</th><th>Total Read</th><th>Avg Read</th><th>Count Write</th><th>Total Written</th><th>Avg Write</th><th>Total</th><th>Write Pct</th></tr>'

    UNION ALL

    SELECT CONCAT(
        '<tr><td>',IFNULL(CONVERT(`file` USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',FORMAT(count_read,0),
        '</td><td>',sys.format_bytes(total_read),
        '</td><td>',sys.format_bytes(avg_read),
        '</td><td>',FORMAT(count_write,0),
        '</td><td>',sys.format_bytes(total_written),
        '</td><td>',sys.format_bytes(avg_write),
        '</td><td>',sys.format_bytes(total),
        '</td><td>',IFNULL(CONCAT(ROUND(write_pct,2),'%'),''),
        '</td></tr>'
    )
    FROM (
        SELECT *
        FROM sys.x$io_global_by_file_by_bytes
        ORDER BY total DESC
    ) t1

    UNION ALL
    SELECT '</table>'
) x;

-- 2.3 IO Global by File by Latency (sys.x$io_global_by_file_by_latency)
SELECT * FROM (
    SELECT '<div id="io_3" class="sub-title">2.3 IO Global by File by Latency</div><pre class="query-sql"># Query:\n#\tSELECT * FROM `sys`.`x$io_global_by_file_by_latency` ORDER BY x$io_global_by_file_by_latency.total_latency DESC</pre><table><tr><th>File</th><th>Total</th><th>Total Latency</th><th>Count Read</th><th>Read Latency</th><th>Count Write</th><th>Write Latency</th><th>Count Misc</th><th>Misc Latency</th></tr>'

    UNION ALL

    SELECT CONCAT(
        '<tr><td>',IFNULL(CONVERT(`file` USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',FORMAT(total,0),
        '</td><td>',sys.format_time(total_latency),
        '</td><td>',FORMAT(count_read,0),
        '</td><td>',sys.format_time(read_latency),
        '</td><td>',FORMAT(count_write,0),
        '</td><td>',sys.format_time(write_latency),
        '</td><td>',FORMAT(count_misc,0),
        '</td><td>',sys.format_time(misc_latency),
        '</td></tr>'
    )
    FROM (
        SELECT *
        FROM sys.x$io_global_by_file_by_latency
        ORDER BY total_latency DESC
    ) t1

    UNION ALL
    SELECT '</table>'
) x;

-- 2.4 IO Global by Wait by Bytes (sys.x$io_global_by_wait_by_bytes)
SELECT * FROM (
    SELECT '<div id="io_4" class="sub-title">2.4 IO Global by Wait by Bytes</div><pre class="query-sql"># Query:\n#\tSELECT * FROM `sys`.`x$io_global_by_wait_by_bytes` ORDER BY x$io_global_by_wait_by_bytes.total_requested DESC</pre><table><tr><th>Event Name</th><th>Total</th><th>Total Latency</th><th>Min Latency</th><th>Avg Latency</th><th>Max Latency</th><th>Count Read</th><th>Total Read</th><th>Avg Read</th><th>Count Write</th><th>Total Written</th><th>Avg Written</th><th>Total Requested</th></tr>'

    UNION ALL

    SELECT CONCAT(
        '<tr><td>',IFNULL(CONVERT(event_name USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',FORMAT(total,0),
        '</td><td>',sys.format_time(total_latency),
        '</td><td>',sys.format_time(min_latency),
        '</td><td>',sys.format_time(avg_latency),
        '</td><td>',sys.format_time(max_latency),
        '</td><td>',FORMAT(count_read,0),
        '</td><td>',sys.format_bytes(total_read),
        '</td><td>',sys.format_bytes(avg_read),
        '</td><td>',FORMAT(count_write,0),
        '</td><td>',sys.format_bytes(total_written),
        '</td><td>',sys.format_bytes(avg_written),
        '</td><td>',sys.format_bytes(total_requested),
        '</td></tr>'
    )
    FROM (
        SELECT *
        FROM sys.x$io_global_by_wait_by_bytes
        ORDER BY total_requested DESC
    ) t1

    UNION ALL
    SELECT '</table>'
) x;

-- 2.5 IO Global by Wait by Latency (sys.x$io_global_by_wait_by_latency)
SELECT * FROM (
    SELECT '<div id="io_5" class="sub-title">2.5 IO Global by Wait by Latency</div><pre class="query-sql"># Query:\n#\tSELECT * FROM `sys`.`x$io_global_by_wait_by_latency` ORDER BY x$io_global_by_wait_by_latency.total_latency DESC</pre><table><tr><th>Event Name</th><th>Total</th><th>Total Latency</th><th>Avg Latency</th><th>Max Latency</th><th>Read Latency</th><th>Write Latency</th><th>Misc Latency</th><th>Count Read</th><th>Total Read</th><th>Avg Read</th><th>Count Write</th><th>Total Written</th><th>Avg Written</th></tr>'

    UNION ALL

    SELECT CONCAT(
        '<tr><td>',IFNULL(CONVERT(event_name USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',FORMAT(total,0),
        '</td><td>',sys.format_time(total_latency),
        '</td><td>',sys.format_time(avg_latency),
        '</td><td>',sys.format_time(max_latency),
        '</td><td>',sys.format_time(read_latency),
        '</td><td>',sys.format_time(write_latency),
        '</td><td>',sys.format_time(misc_latency),
        '</td><td>',FORMAT(count_read,0),
        '</td><td>',sys.format_bytes(total_read),
        '</td><td>',sys.format_bytes(avg_read),
        '</td><td>',FORMAT(count_write,0),
        '</td><td>',sys.format_bytes(total_written),
        '</td><td>',sys.format_bytes(avg_written),
        '</td></tr>'
    )
    FROM (
        SELECT *
        FROM sys.x$io_global_by_wait_by_latency
        ORDER BY total_latency DESC
    ) t1

    UNION ALL
    SELECT '</table>'
) x;

SELECT '</details></div>';

-- 3. User Summary
SELECT '<div class="card"><details open id="section_user"><summary><h2 id="main_user">3. User Summary</h2></summary>';

-- 3.1 User Summary Overview (sys.x$user_summary)
SELECT * FROM (
    SELECT '<div id="u_1" class="sub-title">3.1 User Summary Overview</div><pre class="query-sql"># Query:\n#\tSELECT * FROM `sys`.`x$user_summary` ORDER BY x$user_summary.statement_latency DESC</pre><table><tr><th>User</th><th>Statements</th><th>Statement Latency</th><th>Statement Avg Latency</th><th>Table Scans</th><th>File IOs</th><th>File IO Latency</th><th>Current Connections</th><th>Total Connections</th><th>Unique Hosts</th><th>Current Memory</th><th>Total Memory Allocated</th></tr>'

    UNION ALL

    SELECT CONCAT(
        '<tr><td>',IFNULL(CONVERT(`user` USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',FORMAT(statements,0),
        '</td><td>',sys.format_time(statement_latency),
        '</td><td>',sys.format_time(statement_avg_latency),
        '</td><td>',FORMAT(table_scans,0),
        '</td><td>',FORMAT(file_ios,0),
        '</td><td>',sys.format_time(file_io_latency),
        '</td><td>',FORMAT(current_connections,0),
        '</td><td>',FORMAT(total_connections,0),
        '</td><td>',FORMAT(unique_hosts,0),
        '</td><td>',sys.format_bytes(current_memory),
        '</td><td>',sys.format_bytes(total_memory_allocated),
        '</td></tr>'
    )
    FROM (
        SELECT *
        FROM sys.x$user_summary
        ORDER BY statement_latency DESC
    ) t1

    UNION ALL
    SELECT '</table>'
) x;

-- 3.2 User Summary by File IO (sys.x$user_summary_by_file_io)
SELECT * FROM (
    SELECT '<div id="u_2" class="sub-title">3.2 User Summary by File IO</div><pre class="query-sql"># Query:\n#\tSELECT * FROM `sys`.`x$user_summary_by_file_io` ORDER BY x$user_summary_by_file_io.io_latency DESC</pre><table><tr><th>User</th><th>IOs</th><th>IO Latency</th></tr>'

    UNION ALL

    SELECT CONCAT(
        '<tr><td>',IFNULL(CONVERT(`user` USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',FORMAT(ios,0),
        '</td><td>',sys.format_time(io_latency),
        '</td></tr>'
    )
    FROM (
        SELECT *
        FROM sys.x$user_summary_by_file_io
        ORDER BY io_latency DESC
    ) t1

    UNION ALL
    SELECT '</table>'
) x;

-- 3.3 User Summary by File IO Type (sys.x$user_summary_by_file_io_type)
SELECT * FROM (
    SELECT '<div id="u_3" class="sub-title">3.3 User Summary by File IO Type</div><pre class="query-sql"># Query:\n#\tSELECT * FROM `sys`.`x$user_summary_by_file_io_type` ORDER BY x$user_summary_by_file_io_type.user, x$user_summary_by_file_io_type.latency DESC</pre><table><tr><th>User</th><th>Event Name</th><th>Total</th><th>Latency</th><th>Max Latency</th></tr>'

    UNION ALL

    SELECT CONCAT(
        '<tr><td>',IFNULL(CONVERT(`user` USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',IFNULL(CONVERT(event_name USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',FORMAT(total,0),
        '</td><td>',sys.format_time(latency),
        '</td><td>',sys.format_time(max_latency),
        '</td></tr>'
    )
    FROM (
        SELECT *
        FROM sys.x$user_summary_by_file_io_type
        ORDER BY `user`, latency DESC
    ) t1

    UNION ALL
    SELECT '</table>'
) x;

-- 3.4 User Summary by Stages (sys.x$user_summary_by_stages)
SELECT * FROM (
    SELECT '<div id="u_4" class="sub-title">3.4 User Summary by Stages</div><pre class="query-sql"># Query:\n#\tSELECT * FROM `sys`.`x$user_summary_by_stages` ORDER BY x$user_summary_by_stages.user, x$user_summary_by_stages.total_latency DESC</pre><table><tr><th>User</th><th>Event Name</th><th>Total</th><th>Total Latency</th><th>Avg Latency</th></tr>'

    UNION ALL

    SELECT CONCAT(
        '<tr><td>',IFNULL(CONVERT(`user` USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',IFNULL(CONVERT(event_name USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',FORMAT(total,0),
        '</td><td>',sys.format_time(total_latency),
        '</td><td>',sys.format_time(avg_latency),
        '</td></tr>'
    )
    FROM (
        SELECT *
        FROM sys.x$user_summary_by_stages
        ORDER BY `user`, total_latency DESC
    ) t1

    UNION ALL
    SELECT '</table>'
) x;

-- 3.5 User Summary by Statement Latency (sys.x$user_summary_by_statement_latency)
SELECT * FROM (
    SELECT '<div id="u_5" class="sub-title">3.5 User Summary by Statement Latency</div><pre class="query-sql"># Query:\n#\tSELECT * FROM `sys`.`x$user_summary_by_statement_latency` ORDER BY x$user_summary_by_statement_latency.total_latency DESC</pre><table><tr><th>User</th><th>Total</th><th>Total Latency</th><th>Max Latency</th><th>Lock Latency</th><th>CPU Latency</th><th>Rows Sent</th><th>Rows Examined</th><th>Rows Affected</th><th>Full Scans</th></tr>'

    UNION ALL

    SELECT CONCAT(
        '<tr><td>',IFNULL(CONVERT(`user` USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',FORMAT(total,0),
        '</td><td>',sys.format_time(total_latency),
        '</td><td>',sys.format_time(max_latency),
        '</td><td>',sys.format_time(lock_latency),
        '</td><td>',sys.format_time(cpu_latency),
        '</td><td>',FORMAT(rows_sent,0),
        '</td><td>',FORMAT(rows_examined,0),
        '</td><td>',FORMAT(rows_affected,0),
        '</td><td>',FORMAT(full_scans,0),
        '</td></tr>'
    )
    FROM (
        SELECT *
        FROM sys.x$user_summary_by_statement_latency
        ORDER BY total_latency DESC
    ) t1

    UNION ALL
    SELECT '</table>'
) x;

-- 3.6 User Summary by Statement Type (sys.x$user_summary_by_statement_type)
SELECT * FROM (
    SELECT '<div id="u_6" class="sub-title">3.6 User Summary by Statement Type</div><pre class="query-sql"># Query:\n#\tSELECT * FROM `sys`.`x$user_summary_by_statement_type` ORDER BY x$user_summary_by_statement_type.user, x$user_summary_by_statement_type.total_latency DESC</pre><table><tr><th>User</th><th>Statement</th><th>Total</th><th>Total Latency</th><th>Max Latency</th><th>Lock Latency</th><th>CPU Latency</th><th>Rows Sent</th><th>Rows Examined</th><th>Rows Affected</th><th>Full Scans</th></tr>'

    UNION ALL

    SELECT CONCAT(
        '<tr><td>',IFNULL(CONVERT(`user` USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',IFNULL(CONVERT(statement USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',FORMAT(total,0),
        '</td><td>',sys.format_time(total_latency),
        '</td><td>',sys.format_time(max_latency),
        '</td><td>',sys.format_time(lock_latency),
        '</td><td>',sys.format_time(cpu_latency),
        '</td><td>',FORMAT(rows_sent,0),
        '</td><td>',FORMAT(rows_examined,0),
        '</td><td>',FORMAT(rows_affected,0),
        '</td><td>',FORMAT(full_scans,0),
        '</td></tr>'
    )
    FROM (
        SELECT *
        FROM sys.x$user_summary_by_statement_type
        ORDER BY `user`, total_latency DESC
    ) t1

    UNION ALL
    SELECT '</table>'
) x;

SELECT '</details></div>';



-- 4. Memory Summary
SELECT '<div class="card"><details open id="section_memory"><summary><h2 id="main_memory">4. Memory Summary</h2></summary>';

-- 4.1 Memory by Host (sys.memory_by_host_by_current_bytes)
SELECT * FROM (
    SELECT '<div id="m_1" class="sub-title">4.1 Memory by Host</div><pre class="query-sql"># Query:\n#\tselect * from sys.memory_by_host_by_current_bytes</pre><table><tr><th>host</th><th>current_count_used</th><th>current_allocated</th><th>current_avg_alloc</th><th>current_max_alloc</th><th>total_allocated</th></tr>'

    UNION ALL

    SELECT CONCAT(
        '<tr><td>',IFNULL(CONVERT(host USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',FORMAT(current_count_used,0),
        '</td><td>',IFNULL(current_allocated,''),
        '</td><td>',IFNULL(current_avg_alloc,''),
        '</td><td>',IFNULL(current_max_alloc,''),
        '</td><td>',IFNULL(total_allocated,''),
        '</td></tr>'
    )
    FROM sys.memory_by_host_by_current_bytes

    UNION ALL
    SELECT '</table>'
) x;

-- 4.2 Memory by Thread (sys.memory_by_thread_by_current_bytes)
SELECT * FROM (
    SELECT '<div id="m_2" class="sub-title">4.2 Memory by Thread</div><pre class="query-sql"># Query:\n#\tselect * from sys.memory_by_thread_by_current_bytes</pre><table><tr><th>thread_id</th><th>user</th><th>current_count_used</th><th>current_allocated</th><th>current_avg_alloc</th><th>current_max_alloc</th><th>total_allocated</th></tr>'

    UNION ALL

    SELECT CONCAT(
        '<tr><td>',IFNULL(thread_id,''),
        '</td><td>',IFNULL(CONVERT(`user` USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',FORMAT(current_count_used,0),
        '</td><td>',IFNULL(current_allocated,''),
        '</td><td>',IFNULL(current_avg_alloc,''),
        '</td><td>',IFNULL(current_max_alloc,''),
        '</td><td>',IFNULL(total_allocated,''),
        '</td></tr>'
    )
    FROM sys.memory_by_thread_by_current_bytes

    UNION ALL
    SELECT '</table>'
) x;

-- 4.3 Memory by User (sys.memory_by_user_by_current_bytes)
SELECT * FROM (
    SELECT '<div id="m_3" class="sub-title">4.3 Memory by User</div><pre class="query-sql"># Query:\n#\tselect * from sys.memory_by_user_by_current_bytes</pre><table><tr><th>user</th><th>current_count_used</th><th>current_allocated</th><th>current_avg_alloc</th><th>current_max_alloc</th><th>total_allocated</th></tr>'

    UNION ALL

    SELECT CONCAT(
        '<tr><td>',IFNULL(CONVERT(`user` USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',FORMAT(current_count_used,0),
        '</td><td>',IFNULL(current_allocated,''),
        '</td><td>',IFNULL(current_avg_alloc,''),
        '</td><td>',IFNULL(current_max_alloc,''),
        '</td><td>',IFNULL(total_allocated,''),
        '</td></tr>'
    )
    FROM sys.memory_by_user_by_current_bytes

    UNION ALL
    SELECT '</table>'
) x;

-- 4.4 Memory Global Summary (sys.memory_global_by_current_bytes)
SELECT * FROM (
    SELECT '<div id="m_4" class="sub-title">4.4 Memory Global Summary</div><pre class="query-sql"># Query:\n#\tselect * from sys.memory_global_by_current_bytes</pre><table><tr><th>event_name</th><th>current_count</th><th>current_alloc</th><th>current_avg_alloc</th><th>high_count</th><th>high_alloc</th><th>high_avg_alloc</th></tr>'

    UNION ALL

    SELECT CONCAT(
        '<tr><td>',IFNULL(CONVERT(event_name USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',FORMAT(current_count,0),
        '</td><td>',IFNULL(current_alloc,''),
        '</td><td>',IFNULL(current_avg_alloc,''),
        '</td><td>',FORMAT(high_count,0),
        '</td><td>',IFNULL(high_alloc,''),
        '</td><td>',IFNULL(high_avg_alloc,''),
        '</td></tr>'
    )
    FROM sys.memory_global_by_current_bytes

    UNION ALL
    SELECT '</table>'
) x;

SELECT '</details></div>';



-- 5. Wait Summary
SELECT '<div class="card"><details open id="section_wait"><summary><h2 id="main_wait">5. Wait Summary</h2></summary>';

-- 5.1 Waits Global by Latency (sys.x$waits_global_by_latency)
SELECT * FROM (
    SELECT '<div id="w_1" class="sub-title">5.1 Waits Global by Latency</div><pre class="query-sql"># Query:\n#\tSELECT * FROM `sys`.`x$waits_global_by_latency` ORDER BY x$waits_global_by_latency.total_latency DESC</pre><table><tr><th>events</th><th>total</th><th>total_latency</th><th>avg_latency</th><th>max_latency</th></tr>'

    UNION ALL

    SELECT CONCAT(
        '<tr><td>',IFNULL(CONVERT(events USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',FORMAT(total,0),
        '</td><td>',sys.format_time(total_latency),
        '</td><td>',sys.format_time(avg_latency),
        '</td><td>',sys.format_time(max_latency),
        '</td></tr>'
    )
    FROM (
        SELECT *
        FROM sys.x$waits_global_by_latency
        ORDER BY total_latency DESC
    ) t1

    UNION ALL
    SELECT '</table>'
) x;

-- 5.2 Waits by User by Latency (sys.x$waits_by_user_by_latency)
SELECT * FROM (
    SELECT '<div id="w_2" class="sub-title">5.2 Waits by User by Latency</div><pre class="query-sql"># Query:\n#\tSELECT * FROM `sys`.`x$waits_by_user_by_latency` ORDER BY x$waits_by_user_by_latency.user, x$waits_by_user_by_latency.total_latency DESC</pre><table><tr><th>user</th><th>event</th><th>total</th><th>total_latency</th><th>avg_latency</th><th>max_latency</th></tr>'

    UNION ALL

    SELECT CONCAT(
        '<tr><td>',IFNULL(CONVERT(`user` USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',IFNULL(CONVERT(event USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',FORMAT(total,0),
        '</td><td>',sys.format_time(total_latency),
        '</td><td>',sys.format_time(avg_latency),
        '</td><td>',sys.format_time(max_latency),
        '</td></tr>'
    )
    FROM (
        SELECT *
        FROM sys.x$waits_by_user_by_latency
        ORDER BY `user`, total_latency DESC
    ) t1

    UNION ALL
    SELECT '</table>'
) x;

-- 5.3 Waits by Host by Latency (sys.x$waits_by_host_by_latency)
SELECT * FROM (
    SELECT '<div id="w_3" class="sub-title">5.3 Waits by Host by Latency</div><pre class="query-sql"># Query:\n#\tSELECT * FROM `sys`.`x$waits_by_host_by_latency` ORDER BY x$waits_by_host_by_latency.host, x$waits_by_host_by_latency.total_latency DESC</pre><table><tr><th>host</th><th>event</th><th>total</th><th>total_latency</th><th>avg_latency</th><th>max_latency</th></tr>'

    UNION ALL

    SELECT CONCAT(
        '<tr><td>',IFNULL(CONVERT(host USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',IFNULL(CONVERT(event USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',FORMAT(total,0),
        '</td><td>',sys.format_time(total_latency),
        '</td><td>',sys.format_time(avg_latency),
        '</td><td>',sys.format_time(max_latency),
        '</td></tr>'
    )
    FROM (
        SELECT *
        FROM sys.x$waits_by_host_by_latency
        ORDER BY host, total_latency DESC
    ) t1

    UNION ALL
    SELECT '</table>'
) x;

-- 5.4 Wait Classes Global by Latency (sys.x$wait_classes_global_by_latency)
SELECT * FROM (
    SELECT '<div id="w_4" class="sub-title">5.4 Wait Classes Global by Latency</div><pre class="query-sql"># Query:\n#\tSELECT * FROM `sys`.`x$wait_classes_global_by_latency` ORDER BY x$wait_classes_global_by_latency.total_latency DESC</pre><table><tr><th>event_class</th><th>total</th><th>total_latency</th><th>min_latency</th><th>avg_latency</th><th>max_latency</th></tr>'

    UNION ALL

    SELECT CONCAT(
        '<tr><td>',IFNULL(CONVERT(event_class USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',FORMAT(total,0),
        '</td><td>',sys.format_time(total_latency),
        '</td><td>',sys.format_time(min_latency),
        '</td><td>',sys.format_time(avg_latency),
        '</td><td>',sys.format_time(max_latency),
        '</td></tr>'
    )
    FROM (
        SELECT *
        FROM sys.x$wait_classes_global_by_latency
        ORDER BY total_latency DESC
    ) t1

    UNION ALL
    SELECT '</table>'
) x;

-- 5.5 Wait Classes Global by Avg Latency (sys.x$wait_classes_global_by_avg_latency)
SELECT * FROM (
    SELECT '<div id="w_5" class="sub-title">5.5 Wait Classes Global by Avg Latency</div><pre class="query-sql"># Query:\n#\tSELECT * FROM `sys`.`x$wait_classes_global_by_avg_latency` ORDER BY IFNULL(x$wait_classes_global_by_avg_latency.total_latency / NULLIF(x$wait_classes_global_by_avg_latency.total, 0), 0) DESC</pre><table><tr><th>event_class</th><th>total</th><th>total_latency</th><th>min_latency</th><th>avg_latency</th><th>max_latency</th></tr>'

    UNION ALL

    SELECT CONCAT(
        '<tr><td>',IFNULL(CONVERT(event_class USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',FORMAT(total,0),
        '</td><td>',sys.format_time(total_latency),
        '</td><td>',sys.format_time(min_latency),
        '</td><td>',sys.format_time(avg_latency),
        '</td><td>',sys.format_time(max_latency),
        '</td></tr>'
    )
    FROM (
        SELECT *
        FROM sys.x$wait_classes_global_by_avg_latency
        ORDER BY IFNULL(total_latency / NULLIF(total,0),0) DESC
    ) t1

    UNION ALL
    SELECT '</table>'
) x;

SELECT '</details></div>';



-- 9. my.cnf
SELECT '<div class="card"><details open id="sec_tables"><summary><h2 id="main_tables">9. my.cnf Info</h2></summary>';

-- 9.1 Persisted Variables
SELECT * FROM (
    SELECT '<div class="sub-title">9.1 Persisted Variables</div><table><tr><th>VARIABLE_NAME</th><th>VARIABLE_VALUE</th></tr>'
    
    UNION ALL

    SELECT CONCAT(
        '<tr><td>', VARIABLE_NAME,
        '</td><td>', VARIABLE_VALUE,
        '</td></tr>'
    )
    FROM performance_schema.persisted_variables

    UNION ALL
    SELECT '</table>'
) x;


-- 9.2 Global Variables (Explicit)
SELECT * FROM (
    SELECT '<div class="sub-title">9.2 Global Variables (Explicit)</div><table><tr><th>variable_name</th><th>variable_value</th><th>variable_source</th><th>variable_path</th><th>set_time</th><th>set_user</th><th>set_host</th></tr>'

    UNION ALL

    SELECT CONCAT(
        '<tr><td>', g.variable_name,
        '</td><td>', g.variable_value,
        '</td><td>', i.variable_source,
        '</td><td>', IFNULL(i.variable_path,''),
        '</td><td>', IFNULL(i.set_time,''),
        '</td><td>', IFNULL(i.set_user,''),
        '</td><td>', IFNULL(i.set_host,''),
        '</td></tr>'
    )
    FROM performance_schema.global_variables g
    JOIN performance_schema.variables_info i 
      ON g.variable_name = i.variable_name
    WHERE i.variable_source='EXPLICIT'

    UNION ALL
    SELECT '</table>'
) x;


SELECT '</details></div>';




-- 10. XA trx
SELECT '<div class="card"><details open id="sec_tables"><summary><h2 id="main_tables">10. XA_trx_recovery</h2></summary>';
-- 10.1 XA Transaction Recovery
SELECT * FROM (
    SELECT '<div class="sub-title">10.1 XA Transaction Recovery</div><table><tr><th>formatID</th><th>gtrid_length</th><th>bqual_length</th><th>data</th></tr>'

    UNION ALL

    SELECT '<tr><td colspan="4">Run XA RECOVER CONVERT XID manually to inspect prepared XA transactions; MySQL does not expose XA RECOVER as a selectable table in this HTML SELECT block.</td></tr>'

    UNION ALL
    SELECT '</table>'
) x;

SELECT '</details></div>';



-- 11. XA trx
SELECT '<div class="card"><details open id="sec_tables"><summary><h2 id="main_tables">11. Plugins and Components</h2></summary>';

-- 11.1 Plugins info
SELECT * FROM (
    SELECT CONVERT('<div class="sub-title">11.1 Plugins Info</div><table><tr><th>Name</th><th>Status</th><th>Type</th><th>Library</th><th>License</th></tr>' USING utf8mb4) COLLATE utf8mb4_unicode_ci
    
    UNION ALL

    SELECT CONVERT(CONCAT(
        '<tr><td>', IFNULL(CONVERT(PLUGIN_NAME USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>', IFNULL(CONVERT(PLUGIN_STATUS USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>', IFNULL(CONVERT(PLUGIN_TYPE USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>', IFNULL(CONVERT(PLUGIN_LIBRARY USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>', IFNULL(CONVERT(PLUGIN_LICENSE USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td></tr>'
    ) USING utf8mb4) COLLATE utf8mb4_unicode_ci
    FROM (
        SELECT PLUGIN_NAME, PLUGIN_STATUS, PLUGIN_TYPE, PLUGIN_LIBRARY, PLUGIN_LICENSE
        FROM information_schema.PLUGINS
        ORDER BY PLUGIN_NAME
    ) p

    UNION ALL
    SELECT CONVERT('</table>' USING utf8mb4) COLLATE utf8mb4_unicode_ci
) x;


-- 11.2 Components Info

SELECT * FROM (
    SELECT CONVERT('<div class="sub-title">11.2 Components Info</div><table><tr><th>component_id</th><th>component_group_id</th><th>component_urn</th></tr>' USING utf8mb4) COLLATE utf8mb4_unicode_ci
    
    UNION ALL

    SELECT CONVERT(CONCAT(
        '<tr><td>', component_id,
        '</td><td>', component_group_id,
        '</td><td>', IFNULL(CONVERT(component_urn USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td></tr>'
    ) USING utf8mb4) COLLATE utf8mb4_unicode_ci
    FROM (
        SELECT component_id, component_group_id, component_urn
        FROM mysql.component
        ORDER BY component_id
    ) c

    UNION ALL
    SELECT CONVERT('</table>' USING utf8mb4) COLLATE utf8mb4_unicode_ci
) x;


SELECT '</details></div>';








-- 6. Index Summary
SELECT '<div class="card"><details open id="section_index"><summary><h2 id="main_index">6. Index Summary</h2></summary>';

-- 6.1 Schema Index Statistics (sys.x$schema_index_statistics)
SELECT * FROM (
    SELECT '<div id="idx_1" class="sub-title">6.1 Schema Index Statistics</div><pre class="query-sql"># Query:\n#\tSELECT * FROM `sys`.`x$schema_index_statistics` WHERE table_schema not in (''mysql'',''sys'',''performance_schema'',''information_schema'') ORDER BY (x$schema_index_statistics.select_latency+x$schema_index_statistics.insert_latency+x$schema_index_statistics.update_latency+x$schema_index_statistics.delete_latency) DESC</pre><table><tr><th>table_schema</th><th>table_name</th><th>index_name</th><th>rows_selected</th><th>select_latency</th><th>rows_inserted</th><th>insert_latency</th><th>rows_updated</th><th>update_latency</th><th>rows_deleted</th><th>delete_latency</th></tr>'

    UNION ALL

    SELECT CONCAT(
        '<tr><td>',IFNULL(CONVERT(table_schema USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',IFNULL(CONVERT(table_name USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',IFNULL(CONVERT(index_name USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',FORMAT(rows_selected,0),
        '</td><td>',sys.format_time(select_latency),
        '</td><td>',FORMAT(rows_inserted,0),
        '</td><td>',sys.format_time(insert_latency),
        '</td><td>',FORMAT(rows_updated,0),
        '</td><td>',sys.format_time(update_latency),
        '</td><td>',FORMAT(rows_deleted,0),
        '</td><td>',sys.format_time(delete_latency),
        '</td></tr>'
    )
    FROM (
        SELECT *
        FROM sys.x$schema_index_statistics
        WHERE table_schema NOT IN ('mysql','sys','performance_schema','information_schema')
        ORDER BY (select_latency + insert_latency + update_latency + delete_latency) DESC
    ) t1

    UNION ALL
    SELECT '</table>'
) x;

-- 6.2 Schema Redundant Indexes (sys.schema_redundant_indexes)
SELECT * FROM (
    SELECT '<div id="idx_2" class="sub-title">6.2 Schema Redundant Indexes</div><pre class="query-sql"># Query:\n#\tselect * from sys.schema_redundant_indexes</pre><table><tr><th>table_schema</th><th>table_name</th><th>redundant_index_name</th><th>redundant_index_columns</th><th>redundant_index_non_unique</th><th>dominant_index_name</th><th>dominant_index_columns</th><th>dominant_index_non_unique</th><th>subpart_exists</th><th>sql_drop_index</th></tr>'

    UNION ALL

    SELECT CONCAT(
        '<tr><td>',IFNULL(CONVERT(table_schema USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',IFNULL(CONVERT(table_name USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',IFNULL(CONVERT(redundant_index_name USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',IFNULL(CONVERT(redundant_index_columns USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',IFNULL(redundant_index_non_unique,''),
        '</td><td>',IFNULL(CONVERT(dominant_index_name USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',IFNULL(CONVERT(dominant_index_columns USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',IFNULL(dominant_index_non_unique,''),
        '</td><td>',IFNULL(subpart_exists,''),
        '</td><td>',IFNULL(CONVERT(sql_drop_index USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td></tr>'
    )
    FROM sys.schema_redundant_indexes

    UNION ALL
    SELECT '</table>'
) x;

-- 6.3 Schema Unused Indexes (sys.schema_unused_indexes)
SELECT * FROM (
    SELECT '<div id="idx_3" class="sub-title">6.3 Schema Unused Indexes</div><pre class="query-sql"># Query:\n#\tSELECT * FROM sys.schema_unused_indexes where object_schema not in (''performance_schema'',''information_chema'',''mysql'',''sys'');</pre><table><tr><th>object_schema</th><th>object_name</th><th>index_name</th></tr>'

    UNION ALL

    SELECT CONCAT(
        '<tr><td>',IFNULL(CONVERT(object_schema USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',IFNULL(CONVERT(object_name USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',IFNULL(CONVERT(index_name USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td></tr>'
    )
    FROM (
        SELECT *
        FROM sys.schema_unused_indexes
        WHERE object_schema NOT IN ('performance_schema','information_chema','mysql','sys')
    ) t1

    UNION ALL
    SELECT '</table>'
) x;

-- 6.4 Low Selectivity Secondary Indexes (mysql.innodb_index_stats)
SELECT * FROM (
    SELECT '<div id="idx_4" class="sub-title">6.4 Low Selectivity Secondary Indexes</div><pre class="query-sql"># Query:\n#\tSELECT i.database_name AS db_name,i.table_name AS table_name,i.index_name AS index_name,i.stat_value AS def_Rows,\n#\t    t.n_rows AS total_rows,\n#\t    ROUND(((i.stat_value / IFNULL(IF(t.n_rows < i.stat_value,\n#\t                        i.stat_value,\n#\t                        t.n_rows),\n#\t                    0.01))),\n#\t            2) AS sel_persent\n#\t FROM\n#\t    mysql.innodb_index_stats i\n#\t        INNER JOIN\n#\t    mysql.innodb_table_stats t ON i.database_name = t.database_name\n#\t        AND i.table_name = t.table_name\n#\t WHERE\n#\t    i.index_name != ''PRIMARY''\n#\t        AND i.stat_name LIKE ''%n_diff_pfx%''\n#\t        AND ROUND(((i.stat_value / IFNULL(IF(t.n_rows < i.stat_value,\n#\t                        i.stat_value,\n#\t                        t.n_rows),\n#\t                    0.01))),\n#\t            2) < 0.1;</pre><table><tr><th>db_name</th><th>table_name</th><th>index_name</th><th>def_Rows</th><th>total_rows</th><th>sel_persent</th></tr>'

    UNION ALL

    SELECT CONCAT(
        '<tr><td>',IFNULL(CONVERT(db_name USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',IFNULL(CONVERT(table_name USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',IFNULL(CONVERT(index_name USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',FORMAT(def_Rows,0),
        '</td><td>',FORMAT(total_rows,0),
        '</td><td>',sel_persent,
        '</td></tr>'
    )
    FROM (
        SELECT i.database_name AS db_name,
               i.table_name AS table_name,
               i.index_name AS index_name,
               i.stat_value AS def_Rows,
               t.n_rows AS total_rows,
               ROUND(((i.stat_value / IFNULL(IF(t.n_rows < i.stat_value,
                                   i.stat_value,
                                   t.n_rows),
                               0.01))),
                       2) AS sel_persent
        FROM mysql.innodb_index_stats i
        INNER JOIN mysql.innodb_table_stats t
          ON i.database_name = t.database_name
         AND i.table_name = t.table_name
        WHERE i.index_name != 'PRIMARY'
          AND i.stat_name LIKE '%n_diff_pfx%'
          AND ROUND(((i.stat_value / IFNULL(IF(t.n_rows < i.stat_value,
                              i.stat_value,
                              t.n_rows),
                          0.01))),
                  2) < 0.1
    ) t1

    UNION ALL
    SELECT '</table>'
) x;

-- 6.5 Tables Without Primary Key (information_schema.tables/statistics)
SELECT * FROM (
    SELECT '<div id="idx_5" class="sub-title">6.5 Tables Without Primary Key</div><pre class="query-sql"># Query:\n#\tSELECT t.table_schema, t.table_name, t.table_rows, t.engine, t.data_length, t.index_length \n#\t            FROM information_schema.tables t \n#\t              LEFT JOIN information_schema.statistics s on t.table_schema=s.table_schema and t.table_name=s.table_name and s.index_name=''PRIMARY'' \n#\t            WHERE s.index_name is NULL and t.table_type = ''BASE TABLE'' \n#\t                and t.table_schema not in (''performance_schema'', ''sys'', ''mysql'', ''information_schema'')</pre><table><tr><th>TABLE_SCHEMA</th><th>TABLE_NAME</th><th>TABLE_ROWS</th><th>ENGINE</th><th>DATA_LENGTH</th><th>INDEX_LENGTH</th></tr>'

    UNION ALL

    SELECT CONCAT(
        '<tr><td>',IFNULL(CONVERT(table_schema USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',IFNULL(CONVERT(table_name USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',FORMAT(table_rows,0),
        '</td><td>',IFNULL(CONVERT(engine USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',FORMAT(data_length,0),
        '</td><td>',FORMAT(index_length,0),
        '</td></tr>'
    )
    FROM (
        SELECT t.table_schema, t.table_name, t.table_rows, t.engine, t.data_length, t.index_length
        FROM information_schema.tables t
        LEFT JOIN information_schema.statistics s
          ON t.table_schema = s.table_schema
         AND t.table_name = s.table_name
         AND s.index_name = 'PRIMARY'
        WHERE s.index_name IS NULL
          AND t.table_type = 'BASE TABLE'
          AND t.table_schema NOT IN ('performance_schema', 'sys', 'mysql', 'information_schema')
    ) t1

    UNION ALL
    SELECT '</table>'
) x;

SELECT '</details></div>';



-- 7. DB Tables Info
SELECT '<div class="card"><details open id="sec_db_tables"><summary><h2 id="main_db_tables">VII. DB Tables Info</h2></summary>';

-- 4.3 Top 20 Largest Tables
SELECT * FROM (
    SELECT '<div id="t_3" class="sub-title">4.3 Top 20 Largest Tables</div><table><tr><th>Schema</th><th>Table</th><th>Rows</th><th>Engine</th><th>Data(MB)</th><th>Index(MB)</th><th>Frag(MB)</th></tr>'

    UNION ALL

    SELECT CONCAT(
        '<tr><td>',IFNULL(CONVERT(TABLE_SCHEMA USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',IFNULL(CONVERT(table_name USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',IFNULL(table_rows,0),
        '</td><td>',IFNULL(CONVERT(ENGINE USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',truncate(data_length/1024/1024,2),
        '</td><td>',truncate(index_length/1024/1024,2),
        '</td><td>',truncate(DATA_FREE/1024/1024,2),
        '</td></tr>'
    )
    FROM (
        SELECT *
        FROM information_schema.tables
        ORDER BY (data_length + index_length) DESC
        LIMIT 20
    ) t1

    UNION ALL
    SELECT '</table>'
) x;


-- 4.5 Auto Increment
SELECT * FROM (
    SELECT '<div id="t_5" class="sub-title">4.5 Auto Increment (Top 20)</div><table><tr><th>Schema</th><th>Table</th><th>Engine</th><th>Next Auto Inc</th></tr>'

    UNION ALL

    SELECT CONCAT(
        '<tr><td>',IFNULL(CONVERT(table_schema USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',IFNULL(CONVERT(table_name USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',IFNULL(CONVERT(engine USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',auto_increment,
        '</td></tr>'
    )
    FROM (
        SELECT *
        FROM information_schema.tables
        WHERE table_schema NOT IN ("mysql","information_schema","performance_schema","sys")
          AND auto_increment IS NOT NULL
        ORDER BY auto_increment DESC
        LIMIT 20
    ) t2

    UNION ALL
    SELECT '</table>'
) x;


-- 4.6 Full Table Scans
SELECT * FROM (
    SELECT '<div id="t_6" class="sub-title">4.6 Schema Tables with Full Table Scans</div><table><tr><th>Schema</th><th>Table</th><th>Rows Scanned</th><th>Latency</th></tr>'

    UNION ALL

    SELECT CONCAT(
        '<tr><td>',IFNULL(CONVERT(object_schema USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',IFNULL(CONVERT(object_name USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',rows_full_scanned,
        '</td><td>',latency,
        '</td></tr>'
    )
    FROM (
        SELECT *
        FROM sys.x$schema_tables_with_full_table_scans
        ORDER BY rows_full_scanned DESC
    ) t3

    UNION ALL
    SELECT '</table>'
) x;


-- 4.7 Table Statistics
SELECT * FROM (
    SELECT '<div id="t_7" class="sub-title">4.7 Schema Table Statistics</div><table><tr><th>Table</th><th>Latency</th><th>Rows Fetched</th><th>Rows Ins</th><th>Rows Upd</th><th>Rows Del</th><th>IO Read</th><th>IO Write</th></tr>'

    UNION ALL

    SELECT CONCAT(
        '<tr><td>',IFNULL(CONVERT(table_schema USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),'.',IFNULL(CONVERT(table_name USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',total_latency,
        '</td><td>',rows_fetched,
        '</td><td>',rows_inserted,
        '</td><td>',rows_updated,
        '</td><td>',rows_deleted,
        '</td><td>',io_read,
        '</td><td>',io_write,
        '</td></tr>'
    )
    FROM (
        SELECT *
        FROM sys.x$schema_table_statistics
        WHERE table_schema NOT IN ("sys","mysql","performance_schema","information_schema")
        ORDER BY total_latency DESC
        LIMIT 20
    ) t4

    UNION ALL
    SELECT '</table>'
) x;

SELECT '</details></div>';


SELECT '</body></html>';
QUIT;
