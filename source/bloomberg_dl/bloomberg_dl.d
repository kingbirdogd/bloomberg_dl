module bloomberg_dl.bloomberg_dl;
import libssh.session;
import libssh.sftp;
import libssh.errors;
import std.array;
import std.conv;
import std.datetime.systime : SysTime, Clock;
import std.datetime : UTC;
import std.zlib;
import std.algorithm;
import std.file;
import std.string : toStringz, fromStringz;
version(Windows)
{
	import core.stdc.stdio;
}
else
{
	import core.sys.posix.fcntl;
}


extern (C++)
void releaseTalbe(const (char)*** table);

extern (C++)
const (char)*** soapGetData
(
        const (char)* host,
        const (char)* cert,
        const (char)* pass,
        const (char)** fields,
        const (char)** ident,
        bool withHeader,
        long interval,
        long retry
);

extern (C++)
const (char)*** soapGetHistorical
(
        const (char)* host,
        const (char)* cert,
        const (char)* pass,
        const (char)** fields,
        const (char)** ident,
        const (char)* source,
        long startDate,
        long endDate,
        bool withHeader,
        long interval,
        long retry
);


const (char)** toStrings(ref string[] strs)
{
	const (char)* [] lines;
	const (char)** result;
	lines.length = strs.length + 1;
	for (ulong i = 0; i < strs.length; ++i)
	{
		lines[i] = toStringz(strs[i]);
	}
	lines[strs.length] = null;
	result = lines.ptr;
	return result;
}

string[][] converTalbe(const (char)*** table)
{
	import std.conv;
	string[][] result;
	for (ulong i = 0; table[i] != null; ++i)
	{
		string[] line;
		for (ulong j = 0; table[i][j] != null; ++j)
		{
			line ~= to!string(fromStringz(table[i][j]));
		}
		result ~= line;
	}
	releaseTalbe(table);
	return result;
}

string[][] soapGetData(string host, string cert, string pass, string[] fields, string[] idents, bool withHeader,  long interval, long retry)
{
	return converTalbe(soapGetData(toStringz(host), toStringz(cert), toStringz(pass), toStrings(fields), toStrings(idents), withHeader, interval, retry));
}

string[][] soapGetHistorical(string host, string cert, string pass, string[] fields, string[] idents, string source, long startDate, long endDate, bool withHeader, long interval, long retry)
{
	return converTalbe(soapGetHistorical(toStringz(host), toStringz(cert), toStringz(pass), toStrings(fields), toStrings(idents), toStringz(source), startDate, endDate, withHeader, interval, retry));
}

class bloomberg_dl
{
private:
	static immutable string fileTemplate = 
"START-OF-FILE
FIRMNAME=USER_XXX
COMPRESS=yes
FILETYPE=pc
REPLYFILENAME=REPLY_XXX
RANG_XXX
PROGRAMNAME=PROGRAM_XXX

START-OF-FIELDSFILED_XXX
END-OF-FIELDS

START-OF-DATADATA_XXX
END-OF-DATA
END-OF-FILE";
	version(Windows)
	{
		static immutable string new_line = "\r\n";
		static immutable string start_split = "START-OF-DATA\r\n";
		static immutable string end_split = "\r\nEND-OF-DATA";
	}
	else
	{
		static immutable string new_line = "\n";
		static immutable string start_split = "START-OF-DATA\n";
		static immutable string end_split = "\nEND-OF-DATA";
	}
private:
	static string getFileName(string prefix)
	{
		string name = "api_";
		name ~= prefix;
		SysTime currentTime = Clock.currTime(UTC());
		long num = currentTime.fracSecs.total!"nsecs" / 1000000L;
		num += currentTime.second * 1000L;
		num += currentTime.minute * 100000L;
		num += currentTime.hour * 10000000L;
		num += currentTime.day * 1000000000L;
		num += to!long(currentTime.month) * 100000000000L;
		num += currentTime.year * 10000000000000L;
		name ~= to!string(num);
		return name;
	}
	static SSHSession getSession(string host, string user, string pass)
	{
		auto session = new SSHSession();
		session.host = host;
		session.user = user;
		session.logVerbosity = LogVerbosity.NoLog;
		session.connect();
		auto rc = session.userauthPassword(user, pass);
		if (AuthState.Success != rc)
			return null;
		return session; 
	}
	static string[] list(SFTPSession session)
	{
		SFTPAttributes attr;
		string[] result;
		auto dir = session.openDir("/");
		while (!dir.eof)
		{
			try
			{
				dir.readdir(attr);
				result ~= attr.name;
			}
			catch(SSHException)
			{
				break;
			}
		}
		dir.close();
		return result;
	}
	static bool wait_file(SFTPSession session, string file_name, long interval = 10, long retry = 100)
	{
		for (int i = 0; i < retry; ++i)
		{
			auto files = list(session);
			foreach (string file; files)
			{
				if (file == file_name)
				{
					return true;
				}
			}
			import core.thread;
			Thread.sleep( dur!("seconds")(interval));
		}
		return false;
	}
	static string getDataTemplateStringBase(string user, string[] fields, string[] idents)
	{
		string tmpStr = fileTemplate;
		string strFields = "";
		string strDatas = "";
		foreach (string field; fields)
		{
			strFields ~= "\n";
			strFields ~= field;
		}
		foreach (string ident; idents)
		{
			strDatas ~= "\n";
			strDatas ~= ident;
		}
		tmpStr = replace(tmpStr, "USER_XXX", user);
		tmpStr = replace(tmpStr, "FILED_XXX", strFields);
		tmpStr = replace(tmpStr, "DATA_XXX", strDatas);
		return tmpStr;
	}
	static string getDataTemplateString(string user, string[] fields, string[] idents)
	{
		auto result = getDataTemplateStringBase(user, fields, idents);
		auto range = "SECMASTER=yes";
		result  = replace(result, "RANG_XXX", range);
		result  = replace(result, "PROGRAM_XXX", "getdata");
		return result;
	}
	static string getHistoricalTemplateString(string user, string[] fields, string[] idents, string source, long startDate, long endDate)
	{
		auto result = getDataTemplateStringBase(user, fields, idents);
		string range = "PRICING_SOURCE=";
		range ~= source;
		range ~= "\nDATERANGE=";
		range ~= to!string(startDate);
		range ~= "|";
		range ~= to!string(endDate);
		range ~= "\nHIST_FORMAT=horizontal\n";
		result  = replace(result, "RANG_XXX", range);
		result  = replace(result, "PROGRAM_XXX", "gethistory");
		return result;
	}
	static void write_file(SFTPSession session, string path, string content)
	{
		auto tmp_path = path;
		tmp_path ~= ".tmp";
		int access_type = O_WRONLY | O_CREAT | O_TRUNC;
		int mode = S_IRWXU;
		auto file = session.open(tmp_path, access_type, mode);
		ubyte[] buffer = cast(ubyte[])content;
		file.write(buffer);
		file.close();
		session.rename(tmp_path, path);
	}
	static string read_file(SFTPSession session, string path)
	{
		int access_type = O_RDONLY;
		int mode = 0;
		SFTPFile file = null;
		try
		{
			file = session.open(path, access_type, mode);
		}
		catch(SFTPException)
		{
			return "";
		}
		ubyte[] all_buff;
		while (true)
		{
			ubyte[] rd_buff;
			rd_buff.length = 1024;
			try
			{
				auto cnt = file.read(rd_buff);
				if (cnt < 0)
				{
					return "";
				}
				else if (cnt == 0)
				{
					break;
				}
				rd_buff.length = cnt;
				all_buff ~= rd_buff;
			}
			catch(SFTPException)
			{
				return "";
			}
		}
		file.close();
		void[] result_buffer;
		auto uc = new UnCompress(HeaderFormat.gzip);
		result_buffer ~= uc.uncompress(all_buff);
		result_buffer ~= uc.flush();
		return cast(string)result_buffer;
	}
	static string[][] decode_file(SFTPSession session, string path)
	{
		string[][] result;
		auto str = read_file(session, path);
		if (str == "")
		{
			return result;
		}
		str = str.findSplit(start_split)[2];
		str = str.findSplit(end_split)[0];
		auto lines = str.split(new_line);
		foreach (string line;  lines)
		{
			auto columns = line.split("|");
			string[] line_array;
			for (long i = 0; i < columns.length; ++i)
			{
				if ((i < 1 || i > 2) && i != columns.length - 1)
				{
					line_array ~= columns[i];
				}
			}
			result ~= line_array;
		}
		return result;

	}
	static string convertCsv(string[][] data)
	{
		string result;
		for (long i = 0; i < data.length; ++i)
		{
			string line = "";
			auto column = data[i];
			for (long j = 0; j < column.length; ++j)
			{
				line ~= column[j];
				if (j != column.length - 1)
				{
					line ~= ",";
				}
			}
			result ~= line;
			result ~= "\n";
		}
		return result;
	}
	static void saveData(string str, string path, int level)
	{
		if (level < 0 || level > 9)
			level = 0;
		if (0 == level)
		{
			std.file.write(path, str);
		}
		else
		{
			auto cmp = new Compress(level, HeaderFormat.gzip);
			auto result_buffer = cmp.compress(cast(void[])str);
			result_buffer ~= cmp.flush();
			path ~= ".gz";
			std.file.write(path, result_buffer);
		}
	}
public:
	static string[][] getData(string host, string user, string pass, string[] fields, string[] idents, bool withHeader = true,  long interval = 10, long retry = 100)
	{
		import std.string;
		if (host == "" || 0 == indexOf(host, "http"))
		{
			return soapGetData(host, user, pass, fields, idents, withHeader, interval, retry);
		}
		string[][] result;
		if (withHeader)
		{
			string[] header = ["BbgID"];
			header ~= fields;
			result ~= header;
		}
		auto file_name = getFileName("D");
		auto req_file_name = "/";
		auto res_file_name =  "/";
		auto wait_name = file_name;
		wait_name ~= ".gz";
		req_file_name ~= file_name;
		req_file_name ~= ".req";
		res_file_name ~= file_name;
		res_file_name ~= ".gz";
		auto sshSession = getSession(host, user, pass);
		if (sshSession is null)
			return result;
		auto session = sshSession.newSFTP();
		auto upload_str = getDataTemplateString(user, fields, idents);
		upload_str = replace(upload_str, "REPLY_XXX", file_name);
		write_file(session, req_file_name, upload_str);
		if (!wait_file(session, wait_name, interval, retry))
			return result;
		result ~= decode_file(session, res_file_name);
		session.dispose();
		sshSession.dispose();
		return result;

	}
	static string[][] getHistorical(string host, string user, string pass, string[] fields, string[] idents, string source, long startDate, long endDate, bool withHeader = true,  long interval = 10, long retry = 100)
	{
		import std.string;
		if (host == "" || 0 == indexOf(host, "http"))
		{
			return soapGetHistorical(host, user, pass, fields, idents, source, startDate, endDate, withHeader, interval, retry);
		}
		string[][] result;
		if (withHeader)
		{
			string[] header = ["BbgID", "Date"];
			header ~= fields;
			result ~= header;
		}
		auto file_name = getFileName("H");
		auto req_file_name = "/";
		auto res_file_name =  "/";
		auto wait_name = file_name;
		wait_name ~= ".gz";
		req_file_name ~= file_name;
		req_file_name ~= ".req";
		res_file_name ~= file_name;
		res_file_name ~= ".gz";
		auto sshSession = getSession(host, user, pass);
		if (sshSession is null)
			return result;
		auto session = sshSession.newSFTP();
		auto upload_str = getHistoricalTemplateString(user, fields, idents, source, startDate, endDate);
		upload_str = replace(upload_str, "REPLY_XXX", file_name);
		write_file(session, req_file_name, upload_str);
		if (!wait_file(session, wait_name, interval, retry))
			return result;
		result ~= decode_file(session, res_file_name);
		session.dispose();
		sshSession.dispose();
		return result;
	}
	static string getDataCsv(string host, string user, string pass, string[] fields, string[] idents, bool withHeader = true,  long interval = 10, long retry = 100)
	{
		return convertCsv(getData(host, user, pass, fields, idents, withHeader, interval, retry));
	}
	static string getHistoricalCsv(string host, string user, string pass, string[] fields, string[] idents, string source, long startDate, long endDate, bool withHeader = true,  long interval = 10, long retry = 100)
	{
		return convertCsv(getHistorical(host, user, pass, fields, idents, source, startDate, endDate, withHeader, interval, retry));
	}
	static void downloadData(string host, string user, string pass, string[] fields, string[] idents, string path, int level = 0,  bool withHeader = true,  long interval = 10, long retry = 100)
	{
		saveData(convertCsv(getData(host, user, pass, fields, idents, withHeader, interval, retry)), path, level);
	}
	static void downloadHistorical(string host, string user, string pass, string[] fields, string[] idents, string source, long startDate, long endDate, string path, int level = 0, bool withHeader = true,  long interval = 10, long retry = 100)
	{
		saveData(convertCsv(getHistorical(host, user, pass, fields, idents, source, startDate, endDate, withHeader, interval, retry)), path, level);
	}
};
