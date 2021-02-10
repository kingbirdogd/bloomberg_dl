import bloomberg_dl.bloomberg_dl : bloomberg_dl;
import std.array;
import std.stdio;
import std.conv;

void print_usage()
{
	writeln("bloomberg_dl_tools usage:");
	writeln("bloomberg_dl_tools DATA ARRAY <host> <user> <pass> <field1,field2,...> <BBGID1, BBGID2,...> [has_header] [interval] [retry]");
	writeln("bloomberg_dl_tools DATA CSV <host> <user> <pass> <field1,field2,...> <BBGID1, BBGID2,...> [has_header] [interval] [retry]");
	writeln("bloomberg_dl_tools DATA FILE <host> <user> <pass> <field1,field2,...> <BBGID1, BBGID2,...> <file_path> [zip_level 0-9] [has_header] [interval] [retry]");
	writeln("bloomberg_dl_tools HISTORY ARRAY <host> <user> <pass> <field1,field2,...> <BBGID1, BBGID2,...> <source> <start_date> <end_date> [has_header] [interval] [retry]");
	writeln("bloomberg_dl_tools HISTORY CSV <host> <user> <pass> <field1,field2,...> <BBGID1, BBGID2,...> <source> <start_date> <end_date> [has_header] [interval] [retry]");
	writeln("bloomberg_dl_tools HISTORY FILE <host> <user> <pass> <field1,field2,...> <BBGID1, BBGID2,...> <source> <start_date> <end_date> <file_path> [zip_level 0-9] [has_header] [interval] [retry]");
}

int main(string[] args)
{
	if (args.length < 8)
	{
		print_usage();
		return -1;
	}
	auto type = args[1];
	auto format = args[2];
	auto host = args[3];
	auto user = args[4];
	auto pass = args[5];
	auto fields = args[6].split(",");
	auto idents = args[7].split(",");
	long interval = 10;
	long retry = 100;
	if (type == "DATA")
	{
		if (format == "FILE")
		{
			if (args.length < 9 || args.length > 13)
			{
				print_usage();
				return -2;
			}
			auto path = args[8];
			int level = 0;
			bool has_header = true;
			if (args.length > 9)
			{
				level = to!int(args[9]);
			}
			if (args.length > 10)
			{
				has_header = to!bool(args[10]);
			}
			if (args.length > 11)
			{
				interval = to!long(args[11]);
			}
			if (args.length > 12)
			{
				retry = to!long(args[12]);
			}
			bloomberg_dl.downloadData(host, user, pass, fields, idents, path, level, has_header, interval, retry);
		}
		else if (format == "CSV")
		{
			if (args.length > 11)
			{
				print_usage();
				return -3;
			}
			bool has_header = true;
			if (args.length > 8)
			{
				has_header = to!bool(args[8]);
			}
			if (args.length > 9)
			{
				interval = to!long(args[9]);
			}
			if (args.length > 10)
			{
				retry = to!long(args[10]);
			}
			writeln(bloomberg_dl.getDataCsv(host, user, pass, fields, idents, has_header, interval, retry));
		}
		else if (format == "ARRAY")
		{
			if (args.length > 11)
			{
				print_usage();
				return -4;
			}
			bool has_header = true;
			if (args.length > 8)
			{
				has_header = to!bool(args[8]);
			}
			if (args.length > 9)
			{
				interval = to!long(args[9]);
			}
			if (args.length > 10)
			{
				retry = to!long(args[10]);
			}
			writeln(bloomberg_dl.getData(host, user, pass, fields, idents, has_header, interval, retry));
		}
		else
		{
			print_usage();
			return -5;
		}
	}
	else if (type == "HISTORY")
	{
		if (args.length < 11)
		{
			print_usage();
			return -6;
		}
		auto source = args[8];
		long startDate = to!long(args[9]);
		long endDate = to!long(args[10]);
		if (format == "FILE")
		{
			if (args.length < 12 || args.length > 16)
			{
				print_usage();
				return -7;
			}
			auto path = args[11];
			int level = 0;
			bool has_header = true;
			if (args.length > 12)
			{
				level = to!int(args[12]);
			}
			if (args.length > 13)
			{
				has_header = to!bool(args[13]);
			}
			if (args.length > 14)
			{
				interval = to!long(args[14]);
			}
			if (args.length > 15)
			{
				retry = to!long(args[15]);
			}
			bloomberg_dl.downloadHistorical(host, user, pass, fields, idents, source, startDate, endDate,  path, level, has_header, interval, retry);

		}
		else if (format == "CSV")
		{
			if (args.length > 14)
			{
				print_usage();
				return -8;
			}
			bool has_header = true;
			if (args.length > 11)
			{
				has_header = to!bool(args[11]);
			}
			if (args.length > 12)
			{
				interval = to!long(args[12]);
			}
			if (args.length > 13)
			{
				retry = to!long(args[13]);
			}
			writeln(bloomberg_dl.getHistoricalCsv(host, user, pass, fields, idents, source, startDate, endDate, has_header, interval, retry));

		}
		else if (format == "ARRAY")
		{
			if (args.length > 14)
			{
				print_usage();
				return -9;
			}
			bool has_header = true;
			if (args.length > 11)
			{
				has_header = to!bool(args[11]);
			}
			if (args.length > 12)
			{
				interval = to!long(args[12]);
			}
			if (args.length > 13)
			{
				retry = to!long(args[13]);
			}
			writeln(bloomberg_dl.getHistorical(host, user, pass, fields, idents, source, startDate, endDate, has_header, interval, retry));
		}
	}
	else
	{
		print_usage();
		return -10;
	}
	return 0;
}
