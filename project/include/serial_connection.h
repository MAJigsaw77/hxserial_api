#pragma once

#include "serial_device.h"

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
	int fd;
} SerialConnection;

/**
 * Open a serial connection.
 *
 * @param device The device to open.
 * @param connection Output parameter that will point to a SerialConnection structure.
 * @return true on success, false on failure.
 */
bool open_serial_connection(SerialDevice *device, SerialConnection **connection);

bool set_serial_connection_baud(SerialConnection *connection, const int baud);
bool set_serial_connection_char_size(SerialConnection *connection, const int char_size);
bool set_serial_connection_parity(SerialConnection *connection, const int parity);
bool set_serial_connection_stop_bits(SerialConnection *connection, const int stop_bits);
bool set_serial_connection_flow_control(SerialConnection *connection, const int flow_control);
bool set_serial_connection_timeout(SerialConnection *connection, const int timeout);

/**
 * Read data from a serial connection.
 *
 * @param connection The connection to read from.
 * @param data Output parameter that will point to a buffer to store the read data.
 * @param size The size of the buffer.
 * @return The number of bytes read, or -1 on failure.
 */
int read_serial_connection(const SerialConnection *connection, uint8_t *data, const size_t size);
int read_byte_serial_connection(const SerialConnection *connection, uint8_t *data);
int read_until_serial_connection(const SerialConnection *connection, uint8_t *data, const char until);
int read_until_line_serial_connection(const SerialConnection *connection, uint8_t *data);

int peek_serial_connection(const SerialConnection *connection, uint8_t *data, const size_t size);

int has_available_data_serial_connection(const SerialConnection *connection);

/**
 * Write data to a serial connection.
 *
 * @param connection The connection to write to.
 * @param data The data to write.
 * @param size The size of the data to write.
 * @return The number of bytes written, or -1 on failure.
 */
int write_bytes_serial_connection(SerialConnection *connection, const uint8_t *data, const size_t size);
int write_byte_serial_connection(SerialConnection *connection, const uint8_t data);
int write_string_serial_connection(SerialConnection *connection, const char *data);

/**
 * Close a serial connection.
 *
 * @param connection The connection to close.
 */
void close_serial_connection(SerialConnection *connection);

/**
 * Free the memory allocated for the connection.
 *
 * @param connection The connection to free.
 */
void free_serial_connection(SerialConnection *connection);
