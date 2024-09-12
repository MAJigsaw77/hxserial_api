#pragma once

#include "serial_device.h"

#if HX_WINDOWS
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
	#ifdef HX_WINDOWS
	HANDLE fd;
	int data_bits;
	#endif
	#ifndef HX_WINDOWS
	int fd;
	#endif
} SerialConnection;

bool open_serial_connection(SerialDevice *device, SerialConnection **connection);

bool set_serial_connection_baud(SerialConnection *connection, const int baud);
bool set_serial_connection_char_size(SerialConnection *connection, const int char_size);
bool set_serial_connection_parity(SerialConnection *connection, const int parity);
bool set_serial_connection_stop_bits(SerialConnection *connection, const int stop_bits);
bool set_serial_connection_flow_control(SerialConnection *connection, const int flow_control);
bool set_serial_connection_timeout(SerialConnection *connection, const int timeout);

int read_serial_connection(const SerialConnection *connection, uint8_t *data, const size_t size);
int read_byte_serial_connection(const SerialConnection *connection, uint8_t *data);
int read_until_serial_connection(const SerialConnection *connection, uint8_t *data, const char until);
int read_until_line_serial_connection(const SerialConnection *connection, uint8_t *data);

int has_available_data_serial_connection(const SerialConnection *connection);

int write_bytes_serial_connection(SerialConnection *connection, const uint8_t *data, const size_t size);
int write_byte_serial_connection(SerialConnection *connection, const uint8_t data);
int write_string_serial_connection(SerialConnection *connection, const char *data);

void close_serial_connection(SerialConnection *connection);

void free_serial_connection(SerialConnection *connection);
