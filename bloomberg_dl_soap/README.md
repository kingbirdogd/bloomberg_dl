# bloomberg_dl

# Purpose
Provide a C++ library using gsoap to access Bloomberg Data License

# Preparation
Must install the openssl development library
ubuntu: sudo apt-get install libssl-dev

# Build
## Build Debug
./build_debug.sh
## Build Release
./build.sh
## Windows Build
Cmake Ready, TODO for Visualstudio

# API Overriew
## Get Data API:
###
```
*********************************************************************************
host -- default "" or bloomberg new webservice address in future
cert --  p12_certificate_path
pass --  p12_certificate_password
fields -- Data fields
idents -- BBGIDs
withHeader -- Whether the result first line has header
interval -- Check SFTP server interval in seconds
retry -- how many time to retry check SFTP server for the result
<Return Type> -- std::vector<std::vector<std::string>>
*********************************************************************************
std::vector<std::vector<std::string>> soapGetData
(
        const std::string& host,
        const std::string& cert,
        const std::string& pass,
        const std::vector<std::string>& fields,
        const std::vector<std::string>& ident,
        bool withHeader = true,
        long interval = 10,
        long retry = 100
);
```
###
```
*********************************************************************************
host -- default "" or bloomberg new webservice address in future
cert --  p12_certificate_path
pass --  p12_certificate_password
fields -- Data fields
idents -- BBGIDs
withHeader -- Whether the result first line has header
interval -- Check SFTP server interval in seconds
retry -- how many time to retry check SFTP server for the result
<Return Type> -- char const***
* C style function for D language call interface
*********************************************************************************
char const*** soapGetData
(
        char const* host,
        char const* cert,
        char const* pass,
        char const** fields,
        char const** ident,
        bool withHeader = true,
        long interval = 10,
        long retry = 100
);
```



## Get Historical Data API:

###
```
*********************************************************************************
host -- default "" or bloomberg new webservice address in future
cert --  p12_certificate_path
pass --  p12_certificate_password
fields -- Data fields
idents -- BBGIDs
source -- Historical data source, BGN as an example
startDate -- Historical data start date
endDate -- Historical data start date
withHeader -- Whether the result first line has header
interval -- Check SFTP server interval in seconds
retry -- how many time to retry check SFTP server for the result
<Return Type> -- std::vector<std::vector<std::string>>
*********************************************************************************
std::vector<std::vector<std::string>> soapGetHistorical
(
        const std::string& host,
        const std::string& cert,
        const std::string& pass,
        const std::vector<std::string>& fields,
        const std::vector<std::string>& ident,
        const std::string& source,
        long startDate,
        long endDate,
        bool withHeader = true,
        long interval = 10,
        long retry = 100
);
```

```
*********************************************************************************
host -- default "" or bloomberg new webservice address in future
cert --  p12_certificate_path
pass --  p12_certificate_password
fields -- Data fields
idents -- BBGIDs
source -- Historical data source, BGN as an example
startDate -- Historical data start date
endDate -- Historical data start date
path -- file save path
level -- gzip level, 0-9, input 0 will not zip, 1-9 will zip the file to path.gz
withHeader -- Whether the result first line has header
interval -- Check SFTP server interval in seconds
retry -- how many time to retry check SFTP server for the result
<Return Type> -- char const***
* C style function for D language call interface
*********************************************************************************
char const*** soapGetHistorical
(
        char const* host,
        char const* cert,
        char const* pass,
        char const** fields,
        char const** ident,
        char const* source,
        long startDate,
        long endDate,
        bool withHeader = true,
        long interval = 10,
        long retry = 100
);
```

## D Release Table Helper function:

###
```
*********************************************************************************
table -- C style CSV table
<Return Type> -- void
*********************************************************************************
void releaseTalbe(char const*** table);
```



# Example

##Debug Version:
run build_debug/bloomberg_dl_soap_test <p12_certificate_file> <p12_certificate_file_password>

##Release Version:
run build/bloomberg_dl_soap_test <p12_certificate_file> <p12_certificate_file_password>



refer bloomberg_dl_client.h to learn how to use the API





