#include "bloomberg_dl_client.h"
#include <iostream>


int main(int iArgc, const char** pszArgv)
{
	if (3 != iArgc)
	{
		std::cerr << "usage bloomberg_dl_test cert cert_pass" << std::endl;
		return -1;
	}
	std::vector<std::string> fields;
	std::vector<std::string> idents;
	fields.push_back("FUT_INIT_SPEC_ML");
	fields.push_back("FUT_INIT_HEDGE_ML");
	idents.push_back("DUA Comdty");
	idents.push_back("OEA Comdt");
	auto table = soapGetData("", pszArgv[1], pszArgv[2], fields, idents);
	for (std::size_t i = 0; i < table.size(); ++i)
	{
		for (std::size_t j = 0; j < table[i].size(); ++j)
		{
			std::cout << table[i][j];
			if (j < table[i].size() - 1)
				std::cout << ",";
		}
		std::cout << std::endl;
	}
	return 0;
}
