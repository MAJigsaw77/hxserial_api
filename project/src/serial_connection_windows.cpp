#include "serial_connection.hpp"

#define WIN32_LEAN_AND_MEAN
#define NOGDI
#define NOIME
#define NOCOMM
#define NOMCX

#include <windows.h>
#include <iostream>

bool open_serial_connection(SerialDevice *device, SerialConnection **connection)
{
	HANDLE handle = CreateFileA(device->path, GENERIC_READ | GENERIC_WRITE, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);

	if (handle == INVALID_HANDLE_VALUE)
	{
		std::cerr << "Failed to open device: " << GetLastError() << std::endl;
		return false;
	}

	DCB dcb = {0};
	dcb.DCBlength = sizeof(dcb);

	if (!GetCommState(handle, &dcb))
	{
		std::cerr << "Failed to get comm state: " << GetLastError() << std::endl;
		CloseHandle(handle);
		return false;
	}

	dcb.BaudRate = CBR_9600;
	dcb.ByteSize = 8;
	dcb.Parity = NOPARITY;
	dcb.StopBits = ONESTOPBIT;

	if (!SetCommState(handle, &dcb))
	{
		std::cerr << "Failed to set comm state: " << GetLastError() << std::endl;
		CloseHandle(handle);
		return false;
	}

	COMMTIMEOUTS timeouts = {0};
	timeouts.ReadIntervalTimeout = MAXDWORD;
	timeouts.ReadTotalTimeoutMultiplier = 0;
	timeouts.ReadTotalTimeoutConstant = 0;
	timeouts.WriteTotalTimeoutMultiplier = 0;
	timeouts.WriteTotalTimeoutConstant = 0;

	if (!SetCommTimeouts(handle, &timeouts))
	{
		std::cerr << "Failed to set timeouts: " << GetLastError() << std::endl;
		CloseHandle(handle);
		return false;
	}

	SerialConnection *conn = (SerialConnection *)malloc(sizeof(SerialConnection));

	if (!conn)
	{
		std::cerr << "Memory allocation failed" << std::endl;
		CloseHandle(handle);
		return false;
	}

	conn->fd = handle;
	conn->path = device->path;
	conn->baud = 9600;
	conn->char_size = 8;
	conn->parity = NOPARITY;
	conn->stop_bits = ONESTOPBIT;
	conn->flow_control = 0;
	conn->timeout = 0;

	(*connection) = conn;

	return true;
}

void close_serial_connection(SerialConnection *connection)
{
	if (connection)
		CloseHandle(connection->fd);
}

void free_serial_connection(SerialConnection *connection)
{
	if (connection)
		free(connection);
}

bool set_serial_connection_baud(SerialConnection *connection, int baud)
{
	DCB dcb;
	dcb.DCBlength = sizeof(dcb);

	if (!GetCommState(connection->fd, &dcb))
		return false;

	int realBaud = baud;

	switch (baud)
	{
	case 1200:
		realBaud = CBR_1200;
		break;
	case 2400:
		realBaud = CBR_2400;
		break;
	case 4800:
		realBaud = CBR_4800;
		break;
	case 9600:
		realBaud = CBR_9600;
		break;
	case 19200:
		realBaud = CBR_19200;
		break;
	case 38400:
		realBaud = CBR_38400;
		break;
	case 57600:
		realBaud = CBR_57600;
		break;
	case 115200:
		realBaud = CBR_115200;
		break;
	default:
		std::cerr << "Invalid baud rate: " << baud << std::endl;
		return false;
	}

	dcb.BaudRate = realBaud;

	if (!SetCommState(connection->fd, &dcb))
		return false;

	connection->baud = baud;

	return true;
}

bool set_serial_connection_char_size(SerialConnection *connection, int char_size)
{
	DCB dcb;

	dcb.DCBlength = sizeof(dcb);

	if (!GetCommState(connection->fd, &dcb))
		return false;

	dcb.ByteSize = char_size;

	if (!SetCommState(connection->fd, &dcb))
		return false;

	connection->char_size = char_size;

	return true;
}

bool set_serial_connection_parity(SerialConnection *connection, int parity)
{
	DCB dcb;

	dcb.DCBlength = sizeof(dcb);

	if (!GetCommState(connection->fd, &dcb))
		return false;

	dcb.Parity = parity;

	if (!SetCommState(connection->fd, &dcb))
		return false;

	connection->parity = parity;

	return true;
}

bool set_serial_connection_stop_bits(SerialConnection *connection, int stop_bits)
{
	DCB dcb;

	dcb.DCBlength = sizeof(dcb);

	if (!GetCommState(connection->fd, &dcb))
		return false;

	dcb.StopBits = stop_bits;

	if (!SetCommState(connection->fd, &dcb))
		return false;

	connection->stop_bits = stop_bits;

	return true;
}

bool set_serial_connection_data_bits(SerialConnection *connection, int data_bits)
{
	DCB dcb;

	dcb.DCBlength = sizeof(dcb);

	if (!GetCommState(connection->fd, &dcb))
		return false;

	dcb.ByteSize = data_bits;

	if (!SetCommState(connection->fd, &dcb))
		return false;

	connection->data_bits = data_bits;

	return true;
}

bool set_serial_connection_flow_control(SerialConnection *connection, int flow_control)
{
	if (!SetCommMask(connection->fd, flow_control))
		return false;

	connection->flow_control = flow_control;

	return true;
}

bool set_serial_connection_timeout(SerialConnection *connection, int timeout)
{
	COMMTIMEOUTS timeouts;
	timeouts.ReadIntervalTimeout = 0;
	timeouts.ReadTotalTimeoutMultiplier = 0;
	timeouts.ReadTotalTimeoutConstant = 0;
	timeouts.WriteTotalTimeoutMultiplier = 0;
	timeouts.WriteTotalTimeoutConstant = 0;

	if (!SetCommTimeouts(connection->fd, &timeouts))
		return false;

	connection->timeout = timeout;

	return true;
}

int read_serial_connection(SerialConnection *connection, uint8_t *data, size_t size)
{
	DWORD bytes_read = 0;

	if (!ReadFile(connection->fd, data, size, &bytes_read, NULL))
		return -1;

	return bytes_read;
}

int read_byte_serial_connection(SerialConnection *connection, uint8_t *data)
{
	return read_serial_connection(connection, data, 1);
}

int has_available_data_serial_connection(SerialConnection *connection)
{
	COMSTAT comstat;
	DWORD errors;

	if (!ClearCommError(connection->fd, &errors, &comstat))
		return 0;

	return comstat.cbInQue;
}

int write_bytes_serial_connection(SerialConnection *connection, const uint8_t *data, size_t size)
{
	DWORD bytes_written = 0;

	if (!WriteFile(connection->fd, data, size, &bytes_written, NULL))
		return -1;

	return bytes_written;
}

int write_byte_serial_connection(SerialConnection *connection, uint8_t data)
{
	return write_bytes_serial_connection(connection, &data, 1);
}

int write_string_serial_connection(SerialConnection *connection, const char *data)
{
	return write_bytes_serial_connection(connection, (uint8_t *)data, strlen(data));
}
