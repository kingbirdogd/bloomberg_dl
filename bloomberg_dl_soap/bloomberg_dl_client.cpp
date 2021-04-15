#include "PerSecurityWSBinding.nsmap"
#include "bloomberg_dl_client.h"
#include <cstring>
#ifndef _WIN32
#include <unistd.h>
#else
#include <windows.h>
#define sleep(seconds) ::Sleep(seconds * 1000)
#endif

const static int DataNotAvailable = 100;
const static int Success = 0;
const static int RequestError = 200;
const static int PollInterval = 30000;

inline xsd__date toDate(long dt)
{
	xsd__date date = "";
	long day = dt % 100;
	dt /= 100;
	long month = dt % 100;
	dt /= 100;
	long year = dt;
	date += std::to_string(year);
	date += "-";
	if (month < 10)
		date += "0";
	date += std::to_string(month);
	date += "-";
	if (day < 10)
		date += "0";
	date += std::to_string(day);
	return date;
}

static int init_soap()
{
	soap_ssl_init();
	return 0;
}


static void client_init()
{
	static int init_result = init_soap();
	return;
}

inline bool setCert
(
	PerSecurityWSBindingProxy& ps,
	const std::string& cert,
	const std::string& pass
)
{
	if (soap_ssl_client_context(ps.soap, 
  		SOAP_SSL_DEFAULT, 
		cert.c_str(),  
		pass.c_str(),     
		NULL,       
		NULL,           
		NULL 
	)) 
		return false;
	else
		return true;
}

std::vector<std::vector<std::string>> soapGetData
(	
	const std::string& host,
	const std::string& cert, 
	const std::string& pass, 
	const std::vector<std::string>& fields, 
	const std::vector<std::string>& ident,
	bool withHeader,  
	long interval, 
	long retry
)
{
	client_init();
	std::vector<std::vector<std::string>> result;
	PerSecurityWSBindingProxy ps;
	if (host != "")
	{
		ps = PerSecurityWSBindingProxy(host.c_str());
	}
	if (!setCert(ps, cert, pass))
		return result;
	GetDataHeaders getDataHeader;

	std::vector<Instrument> Instrument_list;
	Instrument_list.resize(ident.size());
	Instruments instruments;
	for (std::size_t i = 0; i < ident.size(); ++i)
	{
		Instrument& inst = Instrument_list[i];
		inst.id = ident[i];
		instruments.instrument.push_back(&inst);
	}

	Fields field;
	field.field = fields;

	SubmitGetDataRequest sbmtGtDtReq;
	sbmtGtDtReq.headers = &getDataHeader;
	sbmtGtDtReq.fields = &field;
	sbmtGtDtReq.instruments = &instruments;

	SubmitGetDataResponse sbmtGtDtResp;
	if (ps.submitGetDataRequest(&sbmtGtDtReq, sbmtGtDtResp))
	{
		return result;
	}
	if (sbmtGtDtResp.statusCode->code != Success)
	{
		return result;
	}
	RetrieveGetDataRequest rtrvGtDrReq;
	rtrvGtDrReq.responseId = sbmtGtDtResp.responseId;
	RetrieveGetDataResponse rtrvGtDrResp;
	for(long i = 0; i < retry; ++i)
	{
		sleep(static_cast<int>(interval));
		if (ps.retrieveGetDataResponse(&rtrvGtDrReq, rtrvGtDrResp))
		{
			return result;
		}
		if (rtrvGtDrResp.statusCode->code == Success)
		{
			break;
		}
		else if (rtrvGtDrResp.statusCode->code != DataNotAvailable)
		{
			return result;
		}
	}
	if (rtrvGtDrResp.statusCode->code != Success)
	{
		return result;
	}
	if (withHeader)
	{
		result.push_back(std::vector<std::string>());
		result[0].push_back("BbgID");
		result[0].insert(result[0].end(), fields.begin(), fields.end());
	}
	for (std::size_t i = 0; i < rtrvGtDrResp.instrumentDatas->instrumentData.size(); ++i)
	{
		std::vector<std::string> line;
		line.push_back(rtrvGtDrResp.instrumentDatas->instrumentData[i]->instrument->id);
		for (std::size_t j = 0; j < rtrvGtDrResp.instrumentDatas->instrumentData[i]->data.size(); ++j)
		{
			line.push_back(*(rtrvGtDrResp.instrumentDatas->instrumentData[i]->data[j]->value));
		}
		result.push_back(line);
	}
	return result;
}

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
	bool withHeader,  
	long interval, 
	long retry
)
{
	client_init();
	std::vector<std::vector<std::string>> result;
	PerSecurityWSBindingProxy ps;
	if (host != "")
	{
		ps = PerSecurityWSBindingProxy(host.c_str());
	}
	if (!setCert(ps, cert, pass))
	{
		return result;
	} 

	GetHistoryHeaders getHistHeaders;
	Version versoin = Version::ns1__Version__new_;
	std::string pricing_source = source;
	DateRange dtRange;
	Period period;
	period.start = toDate(startDate);
	period.end = toDate(endDate);
	dtRange.period = &period;
	getHistHeaders.pricing_USCOREsource = &pricing_source;
	getHistHeaders.version = &versoin;
	getHistHeaders.daterange = &dtRange;


	std::vector<Instrument> Instrument_list;
	Instrument_list.resize(ident.size());
	Instruments instruments;
	for (std::size_t i = 0; i < ident.size(); ++i)
	{
		Instrument& inst = Instrument_list[i];
		inst.id = ident[i];
		instruments.instrument.push_back(&inst);
	}

	Fields field;
	field.field = fields;

	SubmitGetHistoryRequest sbmtGtHistReq;
	sbmtGtHistReq.headers = &getHistHeaders;
	sbmtGtHistReq.instruments = &instruments;
	sbmtGtHistReq.fields = &field;
	
	SubmitGetHistoryResponse sbmtGtHisRsp;
	if (ps.submitGetHistoryRequest(&sbmtGtHistReq, sbmtGtHisRsp))
	{
		return result;
	}
	if (sbmtGtHisRsp.statusCode->code != Success)
	{
		return result;
	}
	RetrieveGetHistoryRequest rtrvGtHistRespReq;
	RetrieveGetHistoryResponse rtrvGtHistResp;
	rtrvGtHistRespReq.responseId = sbmtGtHisRsp.responseId;
	for(long i = 0; i < retry; ++i)
	{
		::sleep(static_cast<int>(interval));
		if (ps.retrieveGetHistoryResponse(&rtrvGtHistRespReq, rtrvGtHistResp))
		{
			return result;
		}
		if (rtrvGtHistResp.statusCode->code == Success)
		{
			break;
		}
		else if (rtrvGtHistResp.statusCode->code != DataNotAvailable)
		{
			return result;
		}
	}
	if (rtrvGtHistResp.statusCode->code != Success)
	{
		return result;
	}
	if (withHeader)
	{
		result.push_back(std::vector<std::string>());
		result[0].push_back("BbgID");
		result[0].push_back("Date");
		result[0].insert(result[0].end(), fields.begin(), fields.end());
	}

	for (std::size_t i = 0; i < rtrvGtHistResp.instrumentDatas->instrumentData.size(); ++i)
	{
		std::vector<std::string> line;
		HistInstrumentData* data = rtrvGtHistResp.instrumentDatas->instrumentData[i];
		line.push_back(data->instrument->id);
		line.push_back(*(data->date));
		for (std::size_t j = 0; j < data->data.size(); ++j)
		{
			HistData* hisData = data->data[j];
			line.push_back(*(hisData->value));
		}
		result.push_back(line);
	}
	
	return result;
}

inline std::vector<std::string> toStrVec(char const** strings)
{
	std::vector<std::string> result;
	for (std::size_t i = 0; strings[i] != nullptr; ++i)
	{
		result.push_back(strings[i]);
	}
	return result;
}

inline char const*** toTable(const std::vector<std::vector<std::string>>& table)
{
	const char*** result = new const char**[table.size() + 1];
	result[table.size()] = nullptr;
	for (std::size_t i = 0; i < table.size(); ++i)
	{
		result[i] = new const char*[table[i].size() + 1];
		result[i][table[i].size()] = nullptr;
		for (std::size_t j = 0; j < table[i].size(); ++j)
		{
			auto ptr = new char[table[i][j].length() + 1];
			std::memcpy(ptr, table[i][j].c_str(), table[i][j].length() + 1);
			result[i][j] = ptr;
		}
	}
	return result;
}

void releaseTalbe(char const*** table)
{
	for (std::size_t i = 0; table[i] != nullptr; ++i)
	{
		for (std::size_t j = 0; table[i][j] != nullptr; ++j)
		{
			delete[] table[i][j];
		}
		delete[] table[i];
	}
	delete[] table;
}

char const*** soapGetData
(
        char const* host,
        char const* cert,
        char const* pass,
        char const** fields,
        char const** ident,
        bool withHeader,
        long interval,
        long retry
)
{
	return toTable(soapGetData(host, cert, pass, toStrVec(fields), toStrVec(ident), withHeader, interval, retry));
}

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
        bool withHeader,
        long interval,
        long retry
)
{
	return toTable(soapGetHistorical(host, cert, pass, toStrVec(fields), toStrVec(ident), source, startDate, endDate, withHeader, interval, retry));
}





