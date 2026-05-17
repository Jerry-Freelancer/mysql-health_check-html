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
SELECT '<div class="card directory"><h2>Navigation</h2><div class="directory-grid"><div class="dir-group"><a href="#section_host" class="dir-group-label">I. Host Summary</a><a href="#h_1">1.1 Host Summary Overview</a><a href="#h_2">1.2 File IO Overview</a><a href="#h_3">1.3 File IO Type</a><a href="#h_4">1.4 Stages</a><a href="#h_5">1.5 Statement Latency</a><a href="#h_6">1.6 Statement Type</a></div><div class="dir-group"><a href="#section_system" class="dir-group-label">II. Instance Health</a><a href="#health_info">2.1 Basic Health</a></div><div class="dir-group"><a href="#section_storage" class="dir-group-label">III. Storage & Objects</a><a href="#db_info">3.1 DB Capacity</a></div><div class="dir-group"><a href="#sec_db_tables" class="dir-group-label">IV. DB Tables Info</a><a href="#t_3">4.3 Top 20 Largest</a><a href="#t_5">4.5 Auto Inc</a><a href="#t_6">4.6 Full Scans</a><a href="#t_7">4.7 Table Stats</a></div></div></div>';


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

-- 5. Main Section: System (Collapsible)
SELECT '<div class="card"><details open id="section_system"><summary><h2 id="main_system">2. Instance Health</h2></summary>';
    SELECT '<div id="health_info" class="sub-title">2.1 Basic Health Check</div><table><tr><th>Time</th><th>User</th><th>Port</th><th>Version</th></tr>' UNION ALL
    SELECT CONCAT('<tr><td>',NOW(),'</td><td>',USER(),'</td><td>',@@port,'</td><td>',VERSION(),'</td></tr>') UNION ALL
    SELECT '</table>';
SELECT '</details></div>';

-- 6. Main Section: Storage (Collapsible)
SELECT '<div class="card"><details open id="section_storage"><summary><h2 id="main_storage">3. Storage and Objects</h2></summary>';
    SELECT '<div id="db_info" class="sub-title">3.1 Database Capacity</div><table><tr><th>Schema</th><th>Charset</th><th>Data(MB)</th></tr>' UNION ALL
    SELECT CONCAT('<tr><td>',IFNULL(CONVERT(SCHEMA_NAME USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),'</td><td>',IFNULL(CONVERT(DEFAULT_CHARACTER_SET_NAME USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),'</td><td>',DataMB,'</td></tr>') FROM (SELECT a.SCHEMA_NAME, a.DEFAULT_CHARACTER_SET_NAME, SUM(TRUNCATE(IFNULL(data_length,0)/1024/1024,2)) AS DataMB FROM INFORMATION_SCHEMA.SCHEMATA a LEFT JOIN information_schema.tables b ON a.SCHEMA_NAME=b.TABLE_SCHEMA WHERE a.SCHEMA_NAME NOT IN ("mysql","information_schema","sys","performance_schema") GROUP BY 1,2) t UNION ALL
    SELECT '</table>';
SELECT '</details></div>';






-- 2. SQL Summary (Collapsible)
SELECT '<div class="card"><details open id="sec_tables"><summary><h2 id="main_tables">3. SQL Summary</h2></summary>';

-- 2.1 Top 95th Percentile Slow SQL (by Avg Time)
    SELECT * FROM (

    SELECT CONVERT('<div class="sub-title">12.1 Top 95th Percentile Slow SQL (by Avg Time)</div><table><tr><th>QUERY</th><th>SCHEMA_NAME</th><th>fullscan</th><th>COUNT_STAR</th><th>Total_time</th><th>Max_time</th><th>Avg_time</th><th>avg_rows</th><th>avg_scan_rows</th></tr>' USING utf8mb4) COLLATE utf8mb4_unicode_ci

    UNION ALL
select * from (
    SELECT CONVERT(CONCAT(
        '<tr><td>',
            REPLACE(CONVERT(sys.format_statement(DIGEST_TEXT) USING utf8mb4),'<','&lt;'),
        '</td><td>', IFNULL(CONVERT(SCHEMA_NAME USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',
            IF(SUM_NO_GOOD_INDEX_USED > 0 OR SUM_NO_INDEX_USED > 0,'*',''),
        '</td><td>', COUNT_STAR,
        '</td><td>', IFNULL(CONVERT(sys.format_time(SUM_TIMER_WAIT) USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>', IFNULL(CONVERT(sys.format_time(MAX_TIMER_WAIT) USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>', IFNULL(CONVERT(sys.format_time(AVG_TIMER_WAIT) USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>', ROUND(IFNULL(SUM_ROWS_SENT / NULLIF(COUNT_STAR, 0), 0)),
        '</td><td>', ROUND(IFNULL(SUM_ROWS_EXAMINED / NULLIF(COUNT_STAR, 0),0)),
        '</td></tr>'
    ) USING utf8mb4) COLLATE utf8mb4_unicode_ci
    FROM performance_schema.events_statements_summary_by_digest stmts
    JOIN sys.x$ps_digest_95th_percentile_by_avg_us AS top_percentile
      ON ROUND(stmts.avg_timer_wait / 1000000) >= top_percentile.avg_us
ORDER BY AVG_TIMER_WAIT DESC
LIMIT 10
) as y
    UNION ALL
    SELECT CONVERT('</table>' USING utf8mb4) COLLATE utf8mb4_unicode_ci
) x;







SELECT '</details></div>';







-- 3. Database Variables (Collapsible)
SELECT '<div class="card"><details open id="sec_tables"><summary><h2 id="main_tables">3. Database Variables</h2></summary>';

-- 3.1 Global Variables Configuration
SELECT * FROM (
    SELECT '<div id="cfg_1" class="sub-title">3.1 Global Configuration Variables</div><table><tr><th>Variable Name</th><th>Value</th></tr>'

    UNION ALL

    SELECT CONCAT(
        '<tr><td>',VARIABLE_NAME,
        '</td><td>',IFNULL(VARIABLE_VALUE,''),
        '</td></tr>'
    )
    FROM (
        SELECT VARIABLE_NAME, VARIABLE_VALUE
        FROM performance_schema.global_variables
        WHERE VARIABLE_NAME IN (
        'version','datadir','sql_mode','gtid_mode','enforce_gtid_consistency','time_zone','transaction_isolation',
        'autocommit','innodb_lock_wait_timeout','max_connections','max_user_connections','slow_query_log','log_output',
        'slow_query_log_file','long_query_time','log_queries_not_using_indexes','log_throttle_queries_not_using_indexes',
        'sort_buffer_size','pid_file','log_error','lower_case_table_names','secure_file_priv',
        'innodb_buffer_pool_size','innodb_flush_log_at_trx_commit','sync_binlog','innodb_io_capacity',
        'query_cache_type','query_cache_size','max_connect_errors','innodb_file_per_table',
        'innodb_log_file_size','innodb_log_files_in_group','innodb_autoinc_lock_mode','event_scheduler',
        'max_allowed_packet','lock_wait_timeout','plugin_dir','open_files_limit','join_buffer_size',
        'innodb_log_buffer_size','innodb_adaptive_hash_index','binlog_format','bind_address',
        'log_bin_basename','innodb_page_size','innodb_redo_log_capacity','key_buffer_size',
        'tmp_table_size','read_buffer_size','read_rnd_buffer_size','binlog_cache_size',
        'innodb_purge_threads','innodb_ddl_threads','innodb_ddl_buffer_size','log_bin',
        'wait_timeout','interactive_timeout','innodb_flush_neighbors',
        'auto_increment_increment','auto_increment_offset','innodb_flush_method',
        'explicit_defaults_for_timestamp','innodb_print_all_deadlocks',
        'innodb_write_io_threads','innodb_read_io_threads','innodb_parallel_read_threads'
        )
        ORDER BY VARIABLE_NAME
    ) t1

    UNION ALL
    SELECT '</table>'
) x;


-- 3.2 Replication Related Global Variables
SELECT * FROM (
    SELECT '<div id="cfg_repl" class="sub-title">3.2 Replication Related Variables</div><table><tr><th>Variable Name</th><th>Value</th></tr>'

    UNION ALL

    SELECT CONCAT(
        '<tr><td>',VARIABLE_NAME,
        '</td><td>',IFNULL(VARIABLE_VALUE,''),
        '</td></tr>'
    )
    FROM (
        SELECT VARIABLE_NAME, VARIABLE_VALUE
        FROM performance_schema.global_variables
        WHERE VARIABLE_NAME IN (
        'server_id',
        'server_uuid',
        'log_bin',
        'log_bin_basename',
        'log_bin_index',
        'sql_log_bin',
        'log_slave_updates',
        'read_only',
        'super_read_only',
        'slave_skip_errors',
        'slave_max_allowed_packet',
        'sql_slave_skip_counter',
        'slave_exec_mode',
        'relay_log_recovery',
        'relay_log_info_repository',
        'binlog_format',
        'expire_logs_days',
        'binlog_expire_logs_seconds',
        'max_binlog_size',
        'binlog_rows_query_log_events',
        'event_scheduler'
        )
        ORDER BY VARIABLE_NAME
    ) t1

    UNION ALL
    SELECT '</table>'
) x;


SELECT '</details></div>';




-- 5. User Summary
SELECT '<div class="card"><details open id="sec_tables"><summary><h2 id="main_tables">5. User Summary</h2></summary>';

-- 5.1 Account Overview
SELECT * FROM (
    SELECT '<div id="account_1" class="sub-title">5.1 Account Overview</div><table><tr><th>Account</th><th>Super Priv</th><th>Password Expired</th><th>Password Last Changed</th><th>Password Lifetime</th><th>Account Locked</th><th>Auth Plugin</th></tr>'

    UNION ALL

    SELECT CONCAT(
        '<tr><td>',Account,
        '</td><td>',IFNULL(Super_priv,''),
        '</td><td>',IFNULL(password_expired,''),
        '</td><td>',IFNULL(password_last_changed,''),
        '</td><td>',IFNULL(password_lifetime,''),
        '</td><td>',IFNULL(account_locked,''),
        '</td><td>',IFNULL(plugin,''),
        '</td></tr>'
    )
    FROM (
        SELECT 
            CONCAT(User,'@',Host) AS Account,
            Super_priv,
            password_expired,
            password_last_changed,
            password_lifetime,
            account_locked,
            plugin
        FROM mysql.user
        ORDER BY User,Host
    ) t1

    UNION ALL

    SELECT '</table>'
) x;


-- 5.2 User Summary
SELECT * FROM (
    SELECT '<div id="perf_user" class="sub-title">5.2 User Performance Summary</div><table><tr><th>user</th><th>statements</th><th>statement_latency (sec)</th><th>statement_avg_latency (ms)</th><th>table_scans</th><th>file_ios</th><th>file_io_latency (sec)</th><th>current_connections</th><th>total_connections</th><th>unique_hosts</th><th>current_memory</th><th>total_memory_allocated</th></tr>'

    UNION ALL

    SELECT CONCAT(
        '<tr><td>',IFNULL(CONVERT(user USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',statements,
        '</td><td>',ROUND(statement_latency/1000000000000,6),
        '</td><td>',ROUND(statement_avg_latency/1000000000,3),
        '</td><td>',table_scans,
        '</td><td>',file_ios,
        '</td><td>',ROUND(file_io_latency/1000000000000,6),
        '</td><td>',current_connections,
        '</td><td>',total_connections,
        '</td><td>',unique_hosts,
        '</td><td>',current_memory,
        '</td><td>',total_memory_allocated,
        '</td></tr>'
    )
    FROM sys.x$user_summary

    UNION ALL

    SELECT '</table>'
) x;


-- 5.3 User File IO Summary
SELECT * FROM (
    SELECT '<div id="perf_user_io" class="sub-title">5.3 User File IO Summary</div><table><tr><th>user</th><th>ios</th><th>io_latency (sec)</th></tr>'

    UNION ALL

    SELECT CONCAT(
        '<tr><td>',IFNULL(CONVERT(user USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',ios,
        '</td><td>',ROUND(io_latency/1000000000000,6),
        '</td></tr>'
    )
    FROM (
        SELECT *
        FROM sys.x$user_summary_by_file_io
        ORDER BY io_latency DESC
    ) t

    UNION ALL

    SELECT '</table>'
) x;


-- 5.4 User File IO Type Summary
SELECT * FROM (
    SELECT '<div id="perf_user_io_type" class="sub-title">5.4 User File IO Type Summary</div><table><tr><th>user</th><th>event_name</th><th>total</th><th>latency (sec)</th><th>max_latency (ms)</th></tr>'

    UNION ALL

    SELECT CONCAT(
        '<tr><td>',IFNULL(CONVERT(user USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',IFNULL(CONVERT(event_name USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',total,
        '</td><td>',ROUND(latency/1000000000000,6),
        '</td><td>',ROUND(max_latency/1000000000,3),
        '</td></tr>'
    )
    FROM (
        SELECT *
        FROM sys.x$user_summary_by_file_io_type
        ORDER BY user, latency DESC
    ) t

    UNION ALL

    SELECT '</table>'
) x;


-- 5.5 User Stage Summary (Unit Normalized)
SELECT * FROM (
    SELECT '<div id="perf_user_stage" class="sub-title">5.5 User Stage Summary</div><table><tr><th>user</th><th>event_name</th><th>total</th><th>total_latency (sec)</th><th>avg_latency (ms)</th></tr>'

    UNION ALL

    SELECT CONCAT(
        '<tr><td>',IFNULL(CONVERT(user USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',IFNULL(CONVERT(event_name USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',total,
        '</td><td>',ROUND(total_latency/1000000000000,6),
        '</td><td>',ROUND(avg_latency/1000000000,3),
        '</td></tr>'
    )
    FROM (
        SELECT *
        FROM sys.x$user_summary_by_stages
        ORDER BY user, total_latency DESC
    ) t

    UNION ALL

    SELECT '</table>'
) x;


-- 5.6 User Statement Type Summary
SELECT * FROM (
    SELECT '<div id="perf_user_stmt" class="sub-title">5.6 User Statement Type Summary</div><table><tr><th>user</th><th>statement</th><th>total</th><th>total_latency (sec)</th><th>max_latency (ms)</th><th>lock_latency (ms)</th><th>cpu_latency (ms)</th><th>rows_sent</th><th>rows_examined</th><th>rows_affected</th><th>full_scans</th></tr>'

    UNION ALL

    SELECT CONCAT(
        '<tr><td>',IFNULL(CONVERT(user USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',IFNULL(CONVERT(statement USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',total,
        '</td><td>',ROUND(total_latency/1000000000000,6),
        '</td><td>',ROUND(max_latency/1000000000,3),
        '</td><td>',ROUND(lock_latency/1000000000,3),
        '</td><td>',ROUND(cpu_latency/1000000000,3),
        '</td><td>',rows_sent,
        '</td><td>',rows_examined,
        '</td><td>',rows_affected,
        '</td><td>',full_scans,
        '</td></tr>'
    )
    FROM (
        SELECT *
        FROM sys.x$user_summary_by_statement_type
        ORDER BY user, total_latency DESC
    ) t

    UNION ALL

    SELECT '</table>'
) x;


-- 5.7 User Statement Latency Summary (Unit Normalized)
SELECT * FROM (
    SELECT '<div id="perf_user_stmt_latency" class="sub-title">5.7 User Statement Latency Summary</div><table><tr><th>user</th><th>total</th><th>total_latency (sec)</th><th>max_latency (ms)</th><th>lock_latency (ms)</th><th>cpu_latency (ms)</th><th>rows_sent</th><th>rows_examined</th><th>rows_affected</th><th>full_scans</th></tr>'

    UNION ALL

    SELECT CONCAT(
        '<tr><td>',IFNULL(CONVERT(user USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',total,
        '</td><td>',ROUND(total_latency/1000000000000,6),
        '</td><td>',ROUND(max_latency/1000000000,3),
        '</td><td>',ROUND(lock_latency/1000000000,3),
        '</td><td>',ROUND(cpu_latency/1000000000,3),
        '</td><td>',rows_sent,
        '</td><td>',rows_examined,
        '</td><td>',rows_affected,
        '</td><td>',full_scans,
        '</td></tr>'
    )
    FROM (
        SELECT *
        FROM sys.x$user_summary_by_statement_latency
        ORDER BY total_latency DESC
    ) t

    UNION ALL

    SELECT '</table>'
) x;

SELECT '</details></div>';




-- 6. Memory Info
SELECT '<div class="card"><details open id="sec_tables"><summary><h2 id="main_tables">6. Memory Info</h2></summary>';

-- 6.1 memory_by_host_by_current_bytes

SELECT * FROM (
    SELECT '<div id="mem_host" class="sub-title">6.1 Memory by Host</div><table><tr><th>host</th><th>current_count_used</th><th>current_allocated</th><th>current_avg_alloc</th><th>current_max_alloc</th><th>total_allocated</th></tr>'

    UNION ALL

    SELECT CONCAT(
        '<tr><td>',
        IFNULL(CONVERT(host USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',current_count_used,
        '</td><td>',current_allocated,
        '</td><td>',current_avg_alloc,
        '</td><td>',current_max_alloc,
        '</td><td>',total_allocated,
        '</td></tr>'
    )
    FROM sys.memory_by_host_by_current_bytes

    UNION ALL

    SELECT '</table>'
) x;


-- 6.2 memory_by_thread_by_current_bytes

SELECT * FROM (
    SELECT '<div class="sub-title">6.2 Memory by Thread</div><table><tr><th>thread_id</th><th>user</th><th>current_count_used</th><th>current_allocated</th><th>current_avg_alloc</th><th>current_max_alloc</th><th>total_allocated</th></tr>'

    UNION ALL

    SELECT CONCAT(
        '<tr><td>',thread_id,
        '</td><td>',IFNULL(CONVERT(user USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',current_count_used,
        '</td><td>',current_allocated,
        '</td><td>',current_avg_alloc,
        '</td><td>',current_max_alloc,
        '</td><td>',total_allocated,
        '</td></tr>'
    )
    FROM (
        SELECT *
        FROM sys.memory_by_thread_by_current_bytes
        ORDER BY thread_id DESC
    ) t

    UNION ALL

    SELECT '</table>'
) x;


-- 6.3 memory_by_user_by_current_bytes

SELECT * FROM (
    SELECT '<div id="mem_user" class="sub-title">6.3 Memory by User (Current)</div><table><tr><th>user</th><th>current_count_used</th><th>current_allocated</th><th>current_avg_alloc</th><th>current_max_alloc</th><th>total_allocated</th></tr>'

    UNION ALL

    SELECT CONCAT(
        '<tr><td>',IFNULL(CONVERT(user USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',current_count_used,
        '</td><td>',current_allocated,
        '</td><td>',current_avg_alloc,
        '</td><td>',current_max_alloc,
        '</td><td>',total_allocated,
        '</td></tr>'
    )
    FROM (
        SELECT *
        FROM sys.memory_by_user_by_current_bytes
        ORDER BY current_allocated DESC
    ) t

    UNION ALL

    SELECT '</table>'
) x;


-- 6.4 memory_global_by_current_bytes

SELECT * FROM (
    SELECT '<div id="mem_global" class="sub-title">6.4 Memory Global Summary (Current)</div><table><tr><th>event_name</th><th>current_count</th><th>current_alloc</th><th>current_avg_alloc</th><th>high_count</th><th>high_alloc</th><th>high_avg_alloc</th></tr>'

    UNION ALL

    SELECT CONCAT(
        '<tr><td>',IFNULL(CONVERT(event_name USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',current_count,
        '</td><td>',current_alloc,
        '</td><td>',current_avg_alloc,
        '</td><td>',high_count,
        '</td><td>',high_alloc,
        '</td><td>',high_avg_alloc,
        '</td></tr>'
    )
    FROM (
        SELECT *
        FROM sys.memory_global_by_current_bytes
        ORDER BY current_alloc DESC
    ) t

    UNION ALL

    SELECT '</table>'
) x;



SELECT '</details></div>';



-- 7. Wait Info
SELECT '<div class="card"><details open id="sec_tables"><summary><h2 id="main_tables">7. Wait Info</h2></summary>';

-- 7.1 Waits by Host
SELECT * FROM (
SELECT '<div class="sub-title">7.1 Waits by Host</div><table><tr><th>host</th><th>event</th><th>total</th><th>total_seconds</th><th>avg_ms</th><th>max_ms</th></tr>'
UNION ALL
SELECT CONCAT(
'<tr><td>',IFNULL(CONVERT(host USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
'</td><td>',IFNULL(CONVERT(event USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
'</td><td>',total,
'</td><td>',ROUND(total_latency/1000000000000,2),
'</td><td>',ROUND(avg_latency/1000000000,2),
'</td><td>',ROUND(max_latency/1000000000,2),
'</td></tr>'
)
FROM (
SELECT *
FROM sys.x$waits_by_host_by_latency
ORDER BY host, total_latency DESC
) t
UNION ALL
SELECT '</table>'
) x;


-- 7.2 Waits by User
SELECT * FROM (
SELECT '<div class="sub-title">7.2 Waits by User</div><table><tr><th>user</th><th>event</th><th>total</th><th>total_seconds</th><th>avg_ms</th><th>max_ms</th></tr>'
UNION ALL
SELECT CONCAT(
'<tr><td>',IFNULL(CONVERT(user USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
'</td><td>',IFNULL(CONVERT(event USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
'</td><td>',total,
'</td><td>',ROUND(total_latency/1000000000000,2),
'</td><td>',ROUND(avg_latency/1000000000,2),
'</td><td>',ROUND(max_latency/1000000000,2),
'</td></tr>'
)
FROM (
SELECT *
FROM sys.x$waits_by_user_by_latency
ORDER BY user, total_latency DESC
) t
UNION ALL
SELECT '</table>'
) x;


-- 7.3 Waits Global by Latency
SELECT * FROM (
SELECT '<div class="sub-title">7.3 Waits Global by Latency</div><table><tr><th>event</th><th>total</th><th>total_seconds</th><th>avg_ms</th><th>max_ms</th></tr>'
UNION ALL
SELECT CONCAT(
'<tr><td>',events,
'</td><td>',total,
'</td><td>',ROUND(total_latency/1000000000000,2),
'</td><td>',ROUND(avg_latency/1000000000,2),
'</td><td>',ROUND(max_latency/1000000000,2),
'</td></tr>'
)
FROM (
SELECT *
FROM sys.x$waits_global_by_latency
ORDER BY total_latency DESC
) t
UNION ALL
SELECT '</table>'
) x;


-- 7.4 Wait Classes Global by Latency
SELECT * FROM (
SELECT '<div class="sub-title">7.4 Wait Classes Global by Latency</div><table><tr><th>event_class</th><th>total</th><th>total_seconds</th><th>min_ms</th><th>avg_ms</th><th>max_ms</th></tr>'
UNION ALL
SELECT CONCAT(
'<tr><td>',event_class,
'</td><td>',total,
'</td><td>',ROUND(total_latency/1000000000000,2),
'</td><td>',ROUND(min_latency/1000000000,2),
'</td><td>',ROUND(avg_latency/1000000000,2),
'</td><td>',ROUND(max_latency/1000000000,2),
'</td></tr>'
)
FROM (
SELECT *
FROM sys.x$wait_classes_global_by_latency
ORDER BY total_latency DESC
) t
UNION ALL
SELECT '</table>'
) x;


-- 7.5 Wait Classes Global by Avg Latency
SELECT * FROM (
SELECT '<div class="sub-title">7.5 Wait Classes Global by Avg Latency</div><table><tr><th>event_class</th><th>total</th><th>total_seconds</th><th>min_ms</th><th>avg_ms</th><th>max_ms</th></tr>'
UNION ALL
SELECT CONCAT(
'<tr><td>',event_class,
'</td><td>',total,
'</td><td>',ROUND(total_latency/1000000000000,2),
'</td><td>',ROUND(min_latency/1000000000,2),
'</td><td>',ROUND(avg_latency/1000000000,2),
'</td><td>',ROUND(max_latency/1000000000,2),
'</td></tr>'
)
FROM (
SELECT *
FROM sys.x$wait_classes_global_by_avg_latency
ORDER BY IFNULL(total_latency / NULLIF(total,0),0) DESC
) t
UNION ALL
SELECT '</table>'
) x;



SELECT '</details></div>';




-- 8. IO Info
SELECT '<div class="card"><details open id="sec_tables"><summary><h2 id="main_tables">8. IO Info</h2></summary>';


-- 8.1 IO by Thread by Latency
SELECT * FROM (
SELECT '<div class="sub-title">8.1 IO by Thread by Latency</div><table><tr><th>user</th><th>thread_id</th><th>processlist_id</th><th>total</th><th>total_seconds</th><th>min_ms</th><th>avg_ms</th><th>max_ms</th></tr>'
UNION ALL
SELECT CONCAT(
'<tr><td>',IFNULL(CONVERT(user USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
'</td><td>',thread_id,
'</td><td>',IFNULL(processlist_id,''),
'</td><td>',total,
'</td><td>',ROUND(total_latency/1000000000000,2),
'</td><td>',ROUND(min_latency/1000000000,2),
'</td><td>',ROUND(avg_latency/1000000000,2),
'</td><td>',ROUND(max_latency/1000000000,2),
'</td></tr>'
)
FROM (
SELECT *
FROM sys.x$io_by_thread_by_latency
ORDER BY total_latency DESC
) t
UNION ALL
SELECT '</table>'
) x;


-- 8.2 IO Global by File by Bytes

SELECT * FROM (
    SELECT '<div class="sub-title">8.2 IO Global by File by Bytes</div><table><tr><th>file</th><th>count_read</th><th>total_read (MB)</th><th>avg_read (KB)</th><th>count_write</th><th>total_written (MB)</th><th>avg_write (KB)</th><th>total (MB)</th><th>write_pct</th></tr>'
    
    UNION ALL

    SELECT CONCAT(
        '<tr><td>',IFNULL(CONVERT(file USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>',count_read,
        '</td><td>',ROUND(total_read/1024/1024,2),
        '</td><td>',ROUND(avg_read/1024,2),
        '</td><td>',count_write,
        '</td><td>',ROUND(total_written/1024/1024,2),
        '</td><td>',ROUND(avg_write/1024,2),
        '</td><td>',ROUND(total/1024/1024,2),
        '</td><td>',write_pct,
        '</td></tr>'
    )
    FROM (
        SELECT *
        FROM sys.x$io_global_by_file_by_bytes
        ORDER BY total DESC
    ) t

    UNION ALL
    SELECT '</table>'
) x;


-- 8.3 IO Global by File by Latency

SELECT * FROM (
    SELECT '<div class="sub-title">8.3 IO Global by File by Latency</div><table><tr><th>file</th><th>total</th><th>total_latency (sec)</th><th>count_read</th><th>read_latency (sec)</th><th>count_write</th><th>write_latency (sec)</th><th>count_misc</th><th>misc_latency (sec)</th></tr>'

    UNION ALL

    SELECT CONCAT(
        '<tr><td>', file,
        '</td><td>', total,
        '</td><td>', ROUND(total_latency/1000000000,6),
        '</td><td>', count_read,
        '</td><td>', ROUND(read_latency/1000000000,6),
        '</td><td>', count_write,
        '</td><td>', ROUND(write_latency/1000000000,6),
        '</td><td>', count_misc,
        '</td><td>', ROUND(misc_latency/1000000000,6),
        '</td></tr>'
    )
    FROM (
        SELECT *
        FROM sys.x$io_global_by_file_by_latency
        ORDER BY total_latency DESC
    ) t

    UNION ALL
    SELECT '</table>'
) x;


-- 8.4 IO Global by Wait by Bytes
SELECT * FROM (
    SELECT '<div class="sub-title">8.4 IO Global by Wait by Bytes</div><table><tr><th>event_name</th><th>total</th><th>total_latency (sec)</th><th>min_latency (sec)</th><th>avg_latency (sec)</th><th>max_latency (sec)</th><th>count_read</th><th>total_read</th><th>avg_read</th><th>count_write</th><th>total_written</th><th>avg_written</th><th>total_requested</th></tr>'
    
    UNION ALL

    SELECT CONCAT(
        '<tr><td>', IFNULL(CONVERT(event_name USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>', total,
        '</td><td>', ROUND(total_latency/1000000000,6),
        '</td><td>', ROUND(min_latency/1000000000,6),
        '</td><td>', ROUND(avg_latency/1000000000,6),
        '</td><td>', ROUND(max_latency/1000000000,6),
        '</td><td>', count_read,
        '</td><td>', total_read,
        '</td><td>', ROUND(avg_read,4),
        '</td><td>', count_write,
        '</td><td>', total_written,
        '</td><td>', ROUND(avg_written,4),
        '</td><td>', total_requested,
        '</td></tr>'
    )
    FROM (
        SELECT *
        FROM sys.x$io_global_by_wait_by_bytes
        ORDER BY total_requested DESC
    ) t

    UNION ALL
    SELECT '</table>'
) x;


-- 8.5 IO Global by Wait by Latency

SELECT * FROM (
    SELECT '<div class="sub-title">8.5 IO Global by Wait by Latency</div><table><tr><th>event_name</th><th>total</th><th>total_latency (sec)</th><th>avg_latency (sec)</th><th>max_latency (sec)</th><th>read_latency (sec)</th><th>write_latency (sec)</th><th>misc_latency (sec)</th><th>count_read</th><th>total_read</th><th>avg_read</th><th>count_write</th><th>total_written</th><th>avg_written</th></tr>'
    
    UNION ALL

    SELECT CONCAT(
        '<tr><td>', IFNULL(CONVERT(event_name USING utf8mb4) COLLATE utf8mb4_unicode_ci,''),
        '</td><td>', total,
        '</td><td>', ROUND(total_latency/1000000000,6),
        '</td><td>', ROUND(avg_latency/1000000000,6),
        '</td><td>', ROUND(max_latency/1000000000,6),
        '</td><td>', ROUND(read_latency/1000000000,6),
        '</td><td>', ROUND(write_latency/1000000000,6),
        '</td><td>', ROUND(misc_latency/1000000000,6),
        '</td><td>', count_read,
        '</td><td>', total_read,
        '</td><td>', ROUND(avg_read,4),
        '</td><td>', count_write,
        '</td><td>', total_written,
        '</td><td>', ROUND(avg_written,4),
        '</td></tr>'
    )
    FROM (
        SELECT *
        FROM sys.x$io_global_by_wait_by_latency
        ORDER BY total_latency DESC
    ) t

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







-- 4. NEW SECTION: IV. DB Tables Info
SELECT '<div class="card"><details open id="sec_db_tables"><summary><h2 id="main_db_tables">IV. DB Tables Info</h2></summary>';

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
