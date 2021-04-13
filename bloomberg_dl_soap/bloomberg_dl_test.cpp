#include "bloomberg_dl_client.h"


int main(void)
{
	std::vector<std::string> v;
	soapGetData("", "", "", v, v);
	soapGetHistorical("", "", "", v, v, "", 0, 0);
	return 0;
}
