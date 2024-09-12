#include "serial_connection.h"

#include <stdbool.h>
#include <stdlib.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <termios.h>

#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <IOKit/IOBSD.h>
#import <IOKit/IOKitLib.h>
#import <IOKit/serial/IOSerialKeys.h>
#import <IOKit/usb/IOUSBLib.h>

bool configureSerialPort(int fd)
{
	struct termios tty;

	if (tcgetattr(fd, &tty) != 0)
	{
		NSLog(@"Error from tcgetattr: %s", strerror(errno));
		return false;
	}

	cfsetospeed(&tty, B9600);
	cfsetispeed(&tty, B9600);

	tty.c_cflag &= ~PARENB;
	tty.c_cflag &= ~CSTOPB;
	tty.c_cflag &= ~CSIZE;
	tty.c_cflag |= CS8;
	tty.c_cflag &= ~CRTSCTS;
	tty.c_iflag &= ~(IXON | IXOFF | IXANY);
	tty.c_lflag &= ~(ICANON | ECHO | ECHOE | ISIG);
	tty.c_oflag &= ~OPOST;

	if (tcsetattr(fd, TCSANOW, &tty) != 0)
	{
		NSLog(@"Error from tcsetattr: %s", strerror(errno));
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

	if (tcgetattr(connection->fd, &tty) != 0)
	{
		NSLog(@"Error from tcgetattr: %s", strerror(errno));
		return false;
	}

	cfsetospeed(&tty, baud);
	cfsetispeed(&tty, baud);

	if (tcsetattr(connection->fd, TCSANOW, &tty) != 0)
	{
		NSLog(@"Error from tcsetattr: %s", strerror(errno));
		return false;
	}

	return true;
}

bool set_serial_connection_char_size(SerialConnection *connection, const int char_size)
{
	struct termios tty;

	if (tcgetattr(connection->fd, &tty) != 0)
	{
		NSLog(@"Error from tcgetattr: %s", strerror(errno));
		return false;
	}

	tty.c_cflag &= ~CSIZE;
	tty.c_cflag |= char_size;

	if (tcsetattr(connection->fd, TCSANOW, &tty) != 0)
	{
		NSLog(@"Error from tcsetattr: %s", strerror(errno));
		return false;
	}

	return true;
}

bool set_serial_connection_parity(SerialConnection *connection, const int parity)
{
	struct termios tty;

	if (tcgetattr(connection->fd, &tty) != 0)
	{
		NSLog(@"Error from tcgetattr: %s", strerror(errno));
		return false;
	}

	tty.c_cflag &= ~PARENB;
	tty.c_cflag |= parity;

	if (tcsetattr(connection->fd, TCSANOW, &tty) != 0)
	{
		NSLog(@"Error from tcsetattr: %s", strerror(errno));
		return false;
	}

	return true;
}

bool set_serial_connection_stop_bits(SerialConnection *connection, const int stop_bits)
{
	struct termios tty;

	if (tcgetattr(connection->fd, &tty) != 0)
	{
		NSLog(@"Error from tcgetattr: %s", strerror(errno));
		return false;
	}

	tty.c_cflag &= ~CSTOPB;
	tty.c_cflag |= stop_bits;

	if (tcsetattr(connection->fd, TCSANOW, &tty) != 0)
	{
		NSLog(@"Error from tcsetattr: %s", strerror(errno));
		return false;
	}

	return true;
}

bool set_serial_connection_flow_control(SerialConnection *connection, const int flow_control)
{
	struct termios tty;

	if (tcgetattr(connection->fd, &tty) != 0)
	{
		NSLog(@"Error from tcgetattr: %s", strerror(errno));
		return false;
	}

	tty.c_cflag &= ~CRTSCTS;
	tty.c_cflag |= flow_control;

	if (tcsetattr(connection->fd, TCSANOW, &tty) != 0)
	{
		NSLog(@"Error from tcsetattr: %s", strerror(errno));
		return false;
	}

	return true;
}

bool set_serial_connection_timeout(SerialConnection *connection, const int timeout)
{
	struct timeval tv;
	tv.tv_sec = timeout;
	tv.tv_usec = 0;

	if (setsockopt(connection->fd, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv)) < 0)
	{
		NSLog(@"Error from setsockopt: %s", strerror(errno));
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
	size_t size = 256;
	int bytes_read = 0;

	while (bytes_read < size)
	{
		int bytes = read(connection->fd, data + bytes_read, 1);

		if (bytes == -1)
			return -1;
		else if (bytes == 0 || data[bytes_read] == until)
			return bytes_read;

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
			return -1;
		else if (bytes == 0 || data[bytes_read] == until)
			return bytes_read;
		else if (data[bytes_read] == '\r')
		{
			bytes_read++;

			int bytes = read(connection->fd, data + bytes_read, 1);

			if (bytes == -1)
				return -1;
			else if (bytes == 0)
				return bytes_read;
			else if (data[bytes_read] == until)
				return bytes_read;
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
