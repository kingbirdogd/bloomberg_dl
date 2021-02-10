# bloomberg_dl

# Purpose
Support BloomBerg Data License SFTP get data and get historical data

# Preparation
Must install the libssh develop library
ubuntu: sudo apt-get install libssh-dev

# Build
## Build Library
dub build
## Build Tools
dub build -c tools

# API Overriew
## Get Data API:
###
```
*********************************************************************************
host -- Bloomberg Host
user -- UserName
pass -- Password
idents -- BBGIDs
withHeader -- Whether the result first line has header
interval -- Check SFTP server interval in seconds
retry -- how many time to retry check SFTP server for the result
<Return Type> -- string[][] Array
*********************************************************************************
static string[][] getData(string host, string user, string pass, string[] fields, string[] idents, bool withHeader = true,  long interval = 10, long retry = 100)
```

###
```
*********************************************************************************
host -- Bloomberg Host
user -- UserName
pass -- Password
idents -- BBGIDs
withHeader -- Whether the result first line has header
interval -- Check SFTP server interval in seconds
retry -- how many time to retry check SFTP server for the result
<Return Type> A CSV format string
*********************************************************************************
static string getDataCsv(string host, string user, string pass, string[] fields, string[] idents, bool withHeader = true,  long interval = 10, long retry = 100)
```

###
```
*********************************************************************************
host -- Bloomberg Host
user -- UserName
pass -- Password
idents -- BBGIDs
path -- file save path
level -- gzip level, 0-9, input 0 will not zip, 1-9 will zip the file to path.gz
withHeader -- Whether the result first line has header
interval -- Check SFTP server interval in seconds
retry -- how many time to retry check SFTP server for the result
<Return Type> void
*********************************************************************************
static void downloadData(string host, string user, string pass, string[] fields, string[] idents, string path, int level = 0,  bool withHeader = true,  long interval = 10, long retry = 100)
```

## Get Historical Data API:
###
```
*********************************************************************************
host -- Bloomberg Host
user -- UserName
pass -- Password
idents -- BBGIDs
source -- Historical data source, BGN as an example
startDate -- Historical data start date
endDate -- Historical data start date
withHeader -- Whether the result first line has header
interval -- Check SFTP server interval in seconds
retry -- how many time to retry check SFTP server for the result
<Return Type> -- string[][] Array
*********************************************************************************
static string[][] getHistorical(string host, string user, string pass, string[] fields, string[] idents, string source, long startDate, long endDate, bool withHeader = true,  long interval = 10, long retry = 100)
```

```
*********************************************************************************
host -- Bloomberg Host
user -- UserName
pass -- Password
idents -- BBGIDs
source -- Historical data source, BGN as an example
startDate -- Historical data start date
endDate -- Historical data start date
withHeader -- Whether the result first line has header
interval -- Check SFTP server interval in seconds
retry -- how many time to retry check SFTP server for the result
<Return Type> -- A CSV format string
*********************************************************************************
static string[][] getHistoricalCsv(string host, string user, string pass, string[] fields, string[] idents, string source, long startDate, long endDate, bool withHeader = true,  long interval = 10, long retry = 100)
```

```
*********************************************************************************
host -- Bloomberg Host
user -- UserName
pass -- Password
idents -- BBGIDs
source -- Historical data source, BGN as an example
startDate -- Historical data start date
endDate -- Historical data start date
path -- file save path
level -- gzip level, 0-9, input 0 will not zip, 1-9 will zip the file to path.gz
withHeader -- Whether the result first line has header
interval -- Check SFTP server interval in seconds
retry -- how many time to retry check SFTP server for the result
<Return Type> -- A CSV format string
*********************************************************************************
static void downloadHistorical(string host, string user, string pass, string[] fields, string[] idents, string source, long startDate, long endDate, string path, int level = 0, bool withHeader = true,  long interval = 10, long retry = 100)
```

# Example
run example ./example.sh <host> <user> <pass>

refer tools/tools.d to learn how to use the API





