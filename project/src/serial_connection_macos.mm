#include "serial_connection.hpp"

#include <stdbool.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <termios.h>

#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>

static int get_baud_rate(int baud)
{
	int baud_enum = B9600;

	switch (baud)
	{
	case 1200:
		baud_enum = B1200;
		break;
	case 2400:
		baud_enum = B2400;
		break;
	case 4800:
		baud_enum = B4800;
		break;
	case 9600:
		baud_enum = B9600;
		break;
	case 19200:
		baud_enum = B19200;
		break;
	case 38400:
		baud_enum = B38400;
		break;
	case 57600:
		baud_enum = B57600;
		break;
	case 115200:
		baud_enum = B115200;
		break;
	case 230400:
		baud_enum = B230400;
		break;
	default:
		NSLog(@"Unsupported baud rate: %s, defaulting to 9600", strerror(errno));
		return B9600;
	}

	return baud_enum;
}

static bool configureSerialPort(SerialConnection *connection, int fd, int baud)
{
	struct termios tty;

	if (tcgetattr(fd, &tty) != 0)
	{
		NSLog(@"Error from tcgetattr: %s", strerror(errno));
		return false;
	}

	int baud_enum = get_baud_rate(baud);

	cfsetospeed(&tty, baud_enum);
	cfsetispeed(&tty, baud_enum);

	tty.c_cflag &= ~PARENB;
	tty.c_cflag &= ~CSTOPB;
	tty.c_cflag &= ~CSIZE;
	tty.c_cflag |= CS8;
	tty.c_cflag &= ~CRTSCTS;
	tty.c_iflag &= ~(IXON | IXOFF | IXANY);
	tty.c_lflag &= ~(ICANON | ECHO | ECHOE | ISIG);
	tty.c_oflag &= ~OPOST;

	connection->parity = 0;
	connection->stop_bits = 1;
	connection->char_size = 8;
	connection->flow_control = 0;

	// TODO: set connection fields

	if (tcsetattr(fd, TCSANOW, &tty) != 0)
	{
		NSLog(@"Error from tcsetattr: %s", strerror(errno));
		return false;
	}

	return true;
}

bool open_serial_connection(SerialDevice *device, SerialConnection **connection, int baud)
{
	SerialConnection *conn = (SerialConnection *)malloc(sizeof(SerialConnection));
	memset(conn, 0, sizeof(SerialConnection));

	conn->fd = open(device->path, O_RDWR | O_NOCTTY | O_NONBLOCK);

	if (conn->fd == -1)
	{
		free(conn);
		return false;
	}

	if (!configureSerialPort(conn, conn->fd, baud))
	{
		close(conn->fd);
		free(conn);
		return false;
	}

	(*connection) = conn;

	return true;
}

void close_serial_connection(SerialConnection *connection)
{
	if (connection)
		close(connection->fd);
}

void free_serial_connection(SerialConnection *connection)
{
	if (connection)
		free(connection);
}

bool set_serial_connection_baud(SerialConnection *connection, int baud)
{
	struct termios tty;

	if (tcgetattr(connection->fd, &tty) != 0)
	{
		NSLog(@"Error from tcgetattr: %s", strerror(errno));
		return false;
	}

	int baud_enum = get_baud_rate(baud);

	cfsetospeed(&tty, baud_enum);
	cfsetispeed(&tty, baud_enum);

	if (tcsetattr(connection->fd, TCSANOW, &tty) != 0)
	{
		NSLog(@"Error from tcsetattr: %s", strerror(errno));
		return false;
	}

	connection->baud = baud;

	return true;
}

bool set_serial_connection_char_size(SerialConnection *connection, int char_size)
{
	struct termios tty;

	if (tcgetattr(connection->fd, &tty) != 0)
	{
		NSLog(@"Error from tcgetattr: %s", strerror(errno));
		return false;
	}

	int realCharSize = CS8;
	switch (char_size)
	{
	case 5:
		realCharSize = CS5;
		break;
	case 6:
		realCharSize = CS6;
		break;
	case 7:
		realCharSize = CS7;
		break;
	case 8:
		realCharSize = CS8;
		break;
	default:
		NSLog(@"Unsupported character size: %d, defaulting to 8", char_size);
		break;
	}

	tty.c_cflag &= ~CSIZE;
	tty.c_cflag |= realCharSize;

	if (tcsetattr(connection->fd, TCSANOW, &tty) != 0)
	{
		NSLog(@"Error from tcsetattr: %s", strerror(errno));
		return false;
	}

	connection->char_size = char_size;

	return true;
}

bool set_serial_connection_parity(SerialConnection *connection, int parity)
{
	struct termios tty;

	if (tcgetattr(connection->fd, &tty) != 0)
	{
		NSLog(@"Error from tcgetattr: %s", strerror(errno));
		return false;
	}

	if (parity == 0)
		tty.c_cflag &= ~PARENB;
	else
		tty.c_cflag |= PARENB;

	if (tcsetattr(connection->fd, TCSANOW, &tty) != 0)
	{
		NSLog(@"Error from tcsetattr: %s", strerror(errno));
		return false;
	}

	connection->parity = parity;

	return true;
}

bool set_serial_connection_stop_bits(SerialConnection *connection, int stop_bits)
{
	struct termios tty;

	if (tcgetattr(connection->fd, &tty) != 0)
	{
		NSLog(@"Error from tcgetattr: %s", strerror(errno));
		return false;
	}

	if (stop_bits == 1)
		tty.c_cflag &= ~CSTOPB;
	else if (stop_bits == 2)
		tty.c_cflag |= CSTOPB;
	else
	{
		NSLog(@"Unsupported number of stop bits: %d", stop_bits);
		return false;
	}

	if (tcsetattr(connection->fd, TCSANOW, &tty) != 0)
	{
		NSLog(@"Error from tcsetattr: %s", strerror(errno));
		return false;
	}

	connection->stop_bits = stop_bits;

	return true;
}

bool set_serial_connection_flow_control(SerialConnection *connection, int flow_control)
{
	struct termios tty;

	if (tcgetattr(connection->fd, &tty) != 0)
	{
		NSLog(@"Error from tcgetattr: %s", strerror(errno));
		return false;
	}

	if (flow_control == 0)
		tty.c_cflag &= ~CRTSCTS;
	else if (flow_control == 1)
		tty.c_cflag |= CRTSCTS;

	if (tcsetattr(connection->fd, TCSANOW, &tty) != 0)
	{
		NSLog(@"Error from tcsetattr: %s", strerror(errno));
		return false;
	}

	connection->flow_control = flow_control;

	return true;
}

bool set_serial_connection_timeout(SerialConnection *connection, int timeout)
{
	struct timeval tv;
	tv.tv_sec = timeout;
	tv.tv_usec = 0;

	if (setsockopt(connection->fd, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv)) < 0)
	{
		NSLog(@"Error from setsockopt: %s", strerror(errno));
		return false;
	}

	connection->timeout = timeout;

	return true;
}

int read_serial_connection(SerialConnection *connection, uint8_t *data, size_t size)
{
	return read(connection->fd, data, size);
}

int has_available_data_serial_connection(SerialConnection *connection)
{
	int bytes_available = 0;
	ioctl(connection->fd, FIONREAD, &bytes_available);
	return bytes_available;
}

int write_bytes_serial_connection(SerialConnection *connection, const uint8_t *data, size_t size)
{
	return write(connection->fd, data, size);
}
