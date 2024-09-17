#include "serial_connection.hpp"

#define WIN32_LEAN_AND_MEAN
#define NOGDI
#define NOIME
#define NOCOMM
#define NOMCX

#include <windows.h>
#include <iostream>

static int get_baud_rate(int baud)
{
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
		std::cerr << "Invalid baud rate: " << baud << ", defaulting to 9600" << std::endl;
		return CBR_9600;
	}
	return realBaud;
}

bool open_serial_connection(SerialDevice *device, SerialConnection **connection, int baud)
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

	int realBaud = get_baud_rate(baud);

	dcb.BaudRate = realBaud;

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
	conn->baud = baud;
	conn->char_size = 8;
	conn->parity = NOPARITY;
	conn->stop_bits = 1;
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

	int realBaud = get_baud_rate(baud);

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

	int realStopBits = ONESTOPBIT;

	switch (stop_bits)
	{
	case 1:
		realStopBits = ONESTOPBIT;
		break;
	case 2:
		realStopBits = TWOSTOPBITS;
		break;
	default:
		// sadly we can't support 1.5 bits since linux and mac
		std::cerr << "Unsupported number of stop bits: " << stop_bits << ", defaulting to 1" << std::endl;
		break;
	}

	dcb.StopBits = realStopBits;

	if (!SetCommState(connection->fd, &dcb))
		return false;

	connection->stop_bits = stop_bits;

	return true;
}

bool set_serial_connection_flow_control(SerialConnection *connection, int flow_control)
{
	DCB dcb;

	dcb.DCBlength = sizeof(dcb);

	if (!GetCommState(connection->fd, &dcb))
		return false;

	switch (flow_control)
	{
	case 0: // NONE
		dcb.fOutxCtsFlow = false;
		dcb.fRtsControl = RTS_CONTROL_DISABLE;
		dcb.fOutxDsrFlow = false;
		dcb.fDtrControl = DTR_CONTROL_DISABLE;
		break;

	case 1: // RTS/CTS
		dcb.fOutxCtsFlow = true;
		dcb.fRtsControl = RTS_CONTROL_HANDSHAKE;
		dcb.fOutxDsrFlow = false;
		dcb.fDtrControl = DTR_CONTROL_DISABLE;
		break;

	case 2: // DSR/DTR
		dcb.fOutxCtsFlow = false;
		dcb.fRtsControl = RTS_CONTROL_DISABLE;
		dcb.fOutxDsrFlow = true;
		dcb.fDtrControl = DTR_CONTROL_HANDSHAKE;
		break;

	default:
		std::cerr << "Invalid flow control setting: " << flow_control << ", defaulting to NONE" << std::endl;
		dcb.fOutxCtsFlow = false;
		dcb.fRtsControl = RTS_CONTROL_DISABLE;
		dcb.fOutxDsrFlow = false;
		dcb.fDtrControl = DTR_CONTROL_DISABLE;
		break;
	}

	if (!SetCommState(connection->fd, &dcb))
		return false;

	connection->flow_control = flow_control;

	return true;
}

// todo: fix this
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
