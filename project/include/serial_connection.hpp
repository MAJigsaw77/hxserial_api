#pragma once

#include "serial_device.hpp"

#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN
#define NOGDI
#define NOIME
#define NOCOMM
#define NOMCX

#include <windows.h>
#endif

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

typedef struct SerialConnection
{
	const char *path;
	int baud;
	int char_size;
	int parity;
	int stop_bits;
	int flow_control;
	int timeout;
#ifdef _WIN32
	HANDLE fd;
#else
	int fd;
#endif
} SerialConnection;

bool open_serial_connection(SerialDevice *device, SerialConnection **connection, int baud);
void close_serial_connection(SerialConnection *connection);
void free_serial_connection(SerialConnection *connection);

bool set_serial_connection_baud(SerialConnection *connection, int baud);
bool set_serial_connection_char_size(SerialConnection *connection, int char_size);
bool set_serial_connection_parity(SerialConnection *connection, int parity);
bool set_serial_connection_stop_bits(SerialConnection *connection, int stop_bits);
bool set_serial_connection_flow_control(SerialConnection *connection, int flow_control);
bool set_serial_connection_timeout(SerialConnection *connection, int timeout);

int read_serial_connection(SerialConnection *connection, uint8_t *data, size_t size);
int has_available_data_serial_connection(SerialConnection *connection);
int write_bytes_serial_connection(SerialConnection *connection, const uint8_t *data, size_t size);
