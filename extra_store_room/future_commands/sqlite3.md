# Mastering SQLite3 on Android

## Retrieve table names
```
adb shell sqlite3 -line <database_file> "SELECT name FROM sqlite_master WHERE type='table';"
```

## Dump all data from a table
```
adb shell sqlite3 -line <database_file> "SELECT * FROM <table_name>;"
```

## Dumps all schemas and tables from all .db
```
find /data/data -type f -name "*.db" -exec sh -c 'echo "Dumping schema for $1"; sqlite3 -line "$1" ".schema"' _ {} \;
```

## Dump data from multiple databases
```
#!/bin/bash
find /data/data -type f -name "*.db" -exec sh -c '
  echo "-----------------------------------"
  dbfile="$1"
  echo -e "Processing database file: \e[1;32m$dbfile\e[0m"
  for table in $(sqlite3 "$dbfile" ".tables"); do
    echo "Dumping data from table: $table"
    echo "-----------------------------------"
    sqlite3 -line "$dbfile" "SELECT * FROM \"$table\""
  done
' _ {} \;
```

## Dump data from multiple databases (parallel execution)
```
#!/bin/sh
directory="/data/data"
find "$directory" -name "*.db" -print0 | xargs -0 -n1 -P4 sh -c '
  database_file="$1"
  echo "-----------------------------------"
  echo "Dumping data from database: $database_file"
  echo "-----------------------------------"
  table_names=$(sqlite3 "$database_file" ".tables")
  for table_name in $table_names; do
    echo "Dumping data from table: $table_name"
    sqlite3 -line "$database_file" "SELECT * FROM \"$table_name\";"
    echo
  done
' sh|grep -i "<foo>"
```

## Access the log file containing previous commands
```
adb shell su -c cat /data/user_de/0/com.android.providers.telephony/Log/FileLog0.log
```

## Read carrier information
```
adb shell su -c cat //data/user_de/0/com.android.providers.telephony/files/carrierconfig-com.android
```
