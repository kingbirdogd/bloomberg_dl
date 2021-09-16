#ifndef __BLOOMBREG_DL_CLIENT__
#define __BLOOMBREG_DL_CLIENT__
#include "soapPerSecurityWSBindingProxy.h"
#include <string>
#include <vector>

typedef ns1__Version Version;
typedef ns1__GetDataHeaders GetDataHeaders;
typedef ns1__GetHistoryHeaders GetHistoryHeaders;
typedef ns1__DateRange DateRange;
typedef ns1__Period Period;
typedef ns1__Instrument Instrument;
typedef ns1__Instruments Instruments;
typedef ns1__Fields Fields;
typedef ns1__SubmitGetHistoryRequest SubmitGetHistoryRequest;
typedef ns1__SubmitGetHistoryResponse SubmitGetHistoryResponse;
typedef ns1__RetrieveGetHistoryRequest RetrieveGetHistoryRequest;
typedef ns1__RetrieveGetHistoryResponse RetrieveGetHistoryResponse;
typedef ns1__HistInstrumentDatas HistInstrumentDatas;
typedef ns1__HistInstrumentData HistInstrumentData;
typedef ns1__HistData HistData;
typedef ns1__SubmitGetDataRequest SubmitGetDataRequest;
typedef ns1__SubmitGetDataRequest SubmitGetDataRequest;
typedef ns1__SubmitGetDataResponse SubmitGetDataResponse;
typedef ns1__RetrieveGetDataRequest RetrieveGetDataRequest;
typedef ns1__RetrieveGetDataResponse RetrieveGetDataResponse;
typedef ns1__InstrumentDatas InstrumentDatas;
typedef ns1__InstrumentData InstrumentData;
typedef ns1__Data Data;

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

void releaseTalbe(char const*** table);

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

#endif //__BLOOMBREG_DL_CLIENT__
