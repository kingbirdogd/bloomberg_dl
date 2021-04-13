#include "PerSecurityWSBinding.nsmap"
#include "bloomberg_dl_client.h"
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

inline xsd__date toDate(unsigned long long dt)
{
	xsd__date date = "";
	unsigned long long day = dt % 100;
	dt /= 100;
	unsigned long long month = dt % 100;
	dt /= 100;
	unsigned long long year = dt;
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

std::vector<std::vector<std::string>> soapGetData
(	
	const std::string& host,
	const std::string& cert, 
	const std::string& pass, 
	const std::vector<std::string>& fields, 
	const std::vector<std::string>& ident,
	bool withHeader,  
	unsigned long long interval, 
	unsigned long long retry
)
{
	client_init();
	std::vector<std::vector<std::string>> result;
	PerSecurityWSBindingProxy ps;
	if (host != "")
	{
		ps = PerSecurityWSBindingProxy(host.c_str());
	}
	if (soap_ssl_client_context(ps.soap, 
  		SOAP_SSL_DEFAULT, 
		cert.c_str(),  
		pass.c_str(),     
		NULL,       
		NULL,           
		NULL 
	)) 
	{
		return result;
	} 
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
	for(unsigned long long i = 0; i < retry; ++i)
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
	unsigned long long startDate, 
	unsigned long long endDate,
	bool withHeader,  
	unsigned long long interval, 
	unsigned long long retry
)
{
	client_init();
	std::vector<std::vector<std::string>> result;
	PerSecurityWSBindingProxy ps;
	if (host != "")
	{
		ps = PerSecurityWSBindingProxy(host.c_str());
	}
	if (soap_ssl_client_context(ps.soap, 
  		SOAP_SSL_DEFAULT, 
		cert.c_str(),  
		pass.c_str(),     
		NULL,       
		NULL,           
		NULL 
	)) 
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
	for(unsigned long long i = 0; i < retry; ++i)
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

