#include "serial_connection.hpp"

#include <string.h>

int read_until_byte_serial_connection(SerialConnection *connection, uint8_t *data, uint8_t until)
{
	int bytes_read = 0;

	while (true)
	{
		int bytes = read_serial_connection(connection, data + bytes_read, 1);

		if (bytes == -1)
			return bytes;
		else if (bytes == 0 || data[bytes_read] == until)
			return bytes_read;

		bytes_read++;
	}

	return bytes_read;
}

int read_until_string_serial_connection(SerialConnection *connection, uint8_t *data, const char *until)
{
	int bytes_read = 0;
	size_t until_len = strlen(until);
	size_t matched_len = 0;

	while (true)
	{
		int bytes = read_serial_connection(connection, data + bytes_read, 1);
		if (bytes == -1)
			return -1;
		else if (bytes == 0)
			return bytes_read;

		if (data[bytes_read] == until[matched_len])
		{
			matched_len++;
			if (matched_len == until_len)
				return bytes_read + 1;
		}
		else
			matched_len = 0;

		bytes_read++;
	}
}

int read_until_line_serial_connection(SerialConnection *connection, uint8_t *data)
{
	int bytes_read = 0;

	while (true)
	{
		int bytes = read_serial_connection(connection, data + bytes_read, 1);

		if (bytes == -1)
			return -1;
		else if (bytes == 0 || data[bytes_read] == '\n')
			return bytes_read;
		else if (data[bytes_read] == '\r')
		{
			bytes_read++;

			int bytes = read_serial_connection(connection, data + bytes_read, 1);

			if (bytes == -1)
				return bytes;
			else if (bytes == 0 || data[bytes_read] == '\n')
				return bytes_read;
		}

		bytes_read++;
	}

	return -1;
}