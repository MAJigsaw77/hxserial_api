#include "serial_connection.h"

#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <termios.h>

#import <IOKit/IOKitLib.h>
#import <IOKit/usb/IOUSBLib.h>
#import <IOKit/IOBSD.h>
#import <IOKit/serial/IOSerialKeys.h>
#import <CoreFoundation/CoreFoundation.h>

bool configureSerialPort(int fd) {
	struct termios tty;

	if (tcgetattr(fd, &tty) != 0) {
		std::cerr << "Error from tcgetattr: " << strerror(errno) << std::endl;
		return false;
	}

	// Set baud rates
	cfsetospeed(&tty, B9600);
	cfsetispeed(&tty, B9600);

	// 8 bits, no parity, 1 stop bit
	tty.c_cflag &= ~PARENB; // No parity
	tty.c_cflag &= ~CSTOPB; // 1 stop bit
	tty.c_cflag &= ~CSIZE;  // Clear size bits
	tty.c_cflag |= CS8;     // 8 bits per byte

	// Disable hardware flow control
	tty.c_cflag &= ~CRTSCTS;

	// Disable software flow control
	tty.c_iflag &= ~(IXON | IXOFF | IXANY);

	// Raw input/output
	tty.c_lflag &= ~(ICANON | ECHO | ECHOE | ISIG);
	tty.c_oflag &= ~OPOST;

	// Apply the configuration
	if (tcsetattr(fd, TCSANOW, &tty) != 0) {
		std::cerr << "Error from tcsetattr: " << strerror(errno) << std::endl;
		return false;
	}

	return true;
}

bool open_serial_connection(SerialDevice *device, SerialConnection **connection)
{
	SerialConnection *conn = (SerialConnection *)malloc(sizeof(SerialConnection));
	memset(conn, 0, sizeof(SerialConnection));

	conn->fd = open(device->path, O_RDWR | O_NOCTTY | O_NONBLOCK);

	if (conn->fd == -1)
	{
		free(conn);
		return false;
	}

	if (!configureSerialPort(conn->fd))
	{
		close(conn->fd);
		free(conn);
		return false;
	}

	(*connection) = conn;
	return true;
}

bool set_serial_connection_baud(SerialConnection *connection, const int baud)
{
	struct termios tty;

	if (tcgetattr(connection->fd, &tty) != 0) {
		std::cerr << "Error from tcgetattr: " << strerror(errno) << std::endl;
		return false;
	}

	cfsetospeed(&tty, baud);
	cfsetispeed(&tty, baud);

	// Apply the configuration
	if (tcsetattr(connection->fd, TCSANOW, &tty) != 0) {
		std::cerr << "Error from tcsetattr: " << strerror(errno) << std::endl;
		return false;
	}

	return true;
}

bool set_serial_connection_char_size(SerialConnection *connection, const int char_size)
{
	struct termios tty;

	if (tcgetattr(connection->fd, &tty) != 0) {
		std::cerr << "Error from tcgetattr: " << strerror(errno) << std::endl;
		return false;
	}

	tty.c_cflag &= ~CSIZE;
	tty.c_cflag |= char_size;

	// Apply the configuration
	if (tcsetattr(connection->fd, TCSANOW, &tty) != 0) {
		std::cerr << "Error from tcsetattr: " << strerror(errno) << std::endl;
		return false;
	}

	return true;
}

bool set_serial_connection_parity(SerialConnection *connection, const int parity)
{
	struct termios tty;

	if (tcgetattr(connection->fd, &tty) != 0) {
		std::cerr << "Error from tcgetattr: " << strerror(errno) << std::endl;
		return false;
	}

	tty.c_cflag &= ~PARENB;
	tty.c_cflag |= parity;

	// Apply the configuration
	if (tcsetattr(connection->fd, TCSANOW, &tty) != 0) {
		std::cerr << "Error from tcsetattr: " << strerror(errno) << std::endl;
		return false;
	}

	return true;
}

bool set_serial_connection_stop_bits(SerialConnection *connection, const int stop_bits)
{
	struct termios tty;

	if (tcgetattr(connection->fd, &tty) != 0) {
		std::cerr << "Error from tcgetattr: " << strerror(errno) << std::endl;
		return false;
	}

	tty.c_cflag &= ~CSTOPB;
	tty.c_cflag |= stop_bits;

	// Apply the configuration
	if (tcsetattr(connection->fd, TCSANOW, &tty) != 0) {
		std::cerr << "Error from tcsetattr: " << strerror(errno) << std::endl;
		return false;
	}

	return true;
}

bool set_serial_connection_flow_control(SerialConnection *connection, const int flow_control)
{
	struct termios tty;

	if (tcgetattr(connection->fd, &tty) != 0) {
		std::cerr << "Error from tcgetattr: " << strerror(errno) << std::endl;
		return false;
	}

	tty.c_cflag &= ~CRTSCTS;
	tty.c_cflag |= flow_control;

	// Apply the configuration
	if (tcsetattr(connection->fd, TCSANOW, &tty) != 0) {
		std::cerr << "Error from tcsetattr: " << strerror(errno) << std::endl;
		return false;
	}

	return true;
}

bool set_serial_connection_timeout(SerialConnection *connection, const int timeout)
{
	struct timeval tv;
	tv.tv_sec = timeout;
	tv.tv_usec = 0;

	if (setsockopt(connection->fd, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv)) < 0) {
		std::cerr << "Error from setsockopt: " << strerror(errno) << std::endl;
		return false;
	}

	return true;
}

int read_serial_connection(const SerialConnection *connection, uint8_t *data, const size_t size)
{
	return read(connection->fd, data, size);
}

int read_byte_serial_connection(const SerialConnection *connection, uint8_t *data)
{
	return read(connection->fd, data, 1);
}

int read_until_serial_connection(const SerialConnection *connection, uint8_t *data, const char until)
{
	int bytes_read = 0;
	while (bytes_read < size)
	{
		int bytes = read(connection->fd, data + bytes_read, 1);
		if (bytes == -1)
		{
			return -1;
		}
		else if (bytes == 0)
		{
			return bytes_read;
		}
		else if (data[bytes_read] == until)
		{
			return bytes_read;
		}

		bytes_read++;
	}

	return bytes_read;
}

int read_until_line_serial_connection(const SerialConnection *connection, uint8_t *data)
{
	char until = '\n';
	size_t size = 256;
	int bytes_read = 0;

	while (bytes_read < size)
	{
		int bytes = read(connection->fd, data + bytes_read, 1);
		if (bytes == -1)
		{
			return -1;
		}
		else if (bytes == 0)
		{
			return bytes_read;
		}
		else if (data[bytes_read] == until)
		{
			return bytes_read;
		}
		else if (data[bytes_read] == '\r')
		{
			bytes_read++;
			int bytes = read(connection->fd, data + bytes_read, 1);
			if (bytes == -1)
			{
				return -1;
			}
			else if (bytes == 0)
			{
				return bytes_read;
			}
			else if (data[bytes_read] == until)
			{
				return bytes_read;
			}
		}

		bytes_read++;
	}

	return -1;
}

int peek_serial_connection(const SerialConnection *connection, uint8_t *data, const size_t size)
{
	return read(connection->fd, data, size);
}

int has_available_data_serial_connection(const SerialConnection *connection)
{
	int bytes_available = 0;
	ioctl(connection->fd, FIONREAD, &bytes_available);
	return bytes_available;
}

int write_bytes_serial_connection(SerialConnection *connection, const uint8_t *data, const size_t size)
{
	return write(connection->fd, data, size);
}

int write_byte_serial_connection(SerialConnection *connection, const uint8_t data)
{
	return write(connection->fd, &data, 1);
}

int write_string_serial_connection(SerialConnection *connection, const char *data)
{
	return write(connection->fd, data, strlen(data));
}

void close_serial_connection(SerialConnection *connection)
{
	close(connection->fd);
}

void free_serial_connection(SerialConnection *connection)
{
	free(connection);
}