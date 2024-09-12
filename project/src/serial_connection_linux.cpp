#include "serial_connection.h"

#include <fcntl.h>
#include <termios.h>
#include <unistd.h>
#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <sys/ioctl.h>
#include <stdlib.h>

static bool configureSerialPort(SerialConnection* connection, int fd)
{
    struct termios tty;

    if (tcgetattr(fd, &tty) != 0)
    {
        printf("Error from tcgetattr: %s\n", strerror(errno));
        return false;
    }

    cfsetospeed(&tty, B9600);
    cfsetispeed(&tty, B9600);

    tty.c_cflag &= ~PARENB;   // No parity bit
    tty.c_cflag &= ~CSTOPB;   // 1 stop bit
    tty.c_cflag &= ~CSIZE;
    tty.c_cflag |= CS8;       // 8 data bits
    tty.c_cflag &= ~CRTSCTS;  // Disable RTS/CTS hardware flow control
    tty.c_iflag &= ~(IXON | IXOFF | IXANY); // Disable software flow control
    tty.c_lflag &= ~(ICANON | ECHO | ECHOE | ISIG); // Raw input mode (non-canonical)
    tty.c_oflag &= ~OPOST;    // Raw output mode

    if (tcsetattr(fd, TCSANOW, &tty) != 0)
    {
        printf("Error from tcsetattr: %s\n", strerror(errno));
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

    if (!configureSerialPort(conn, conn->fd))
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
    {
        close(connection->fd);
    }
}

void free_serial_connection(SerialConnection *connection)
{
    if (connection)
    {
        free(connection);
    }
}

bool set_serial_connection_baud(SerialConnection *connection, const int baud)
{
    struct termios tty;

    if (tcgetattr(connection->fd, &tty) != 0)
    {
        printf("Error from tcgetattr: %s\n", strerror(errno));
        return false;
    }

    int baud_enum;

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
            printf("Unsupported baud rate: %d\n", baud);
            return false;
    }

    cfsetospeed(&tty, baud_enum);
    cfsetispeed(&tty, baud_enum);

    if (tcsetattr(connection->fd, TCSANOW, &tty) != 0)
    {
        printf("Error from tcsetattr: %s\n", strerror(errno));
        return false;
    }

    return true;
}

bool set_serial_connection_char_size(SerialConnection *connection, const int char_size)
{
    struct termios tty;

    if (tcgetattr(connection->fd, &tty) != 0)
    {
        printf("Error from tcgetattr: %s\n", strerror(errno));
        return false;
    }

    tty.c_cflag &= ~CSIZE;
    tty.c_cflag |= char_size;

    if (tcsetattr(connection->fd, TCSANOW, &tty) != 0)
    {
        printf("Error from tcsetattr: %s\n", strerror(errno));
        return false;
    }

    return true;
}

bool set_serial_connection_parity(SerialConnection *connection, const int parity)
{
    struct termios tty;

    if (tcgetattr(connection->fd, &tty) != 0)
    {
        printf("Error from tcgetattr: %s\n", strerror(errno));
        return false;
    }

    if (parity == 0)
    {
        tty.c_cflag &= ~PARENB;
    }
    else
    {
        tty.c_cflag |= PARENB;
    }

    if (tcsetattr(connection->fd, TCSANOW, &tty) != 0)
    {
        printf("Error from tcsetattr: %s\n", strerror(errno));
        return false;
    }

    return true;
}

bool set_serial_connection_stop_bits(SerialConnection *connection, const int stop_bits)
{
    struct termios tty;

    if (tcgetattr(connection->fd, &tty) != 0)
    {
        printf("Error from tcgetattr: %s\n", strerror(errno));
        return false;
    }

    if (stop_bits == 1)
    {
        tty.c_cflag &= ~CSTOPB;
    }
    else if (stop_bits == 2)
    {
        tty.c_cflag |= CSTOPB;
    }
    else
    {
        printf("Unsupported number of stop bits: %d\n", stop_bits);
        return false;
    }

    if (tcsetattr(connection->fd, TCSANOW, &tty) != 0)
    {
        printf("Error from tcsetattr: %s\n", strerror(errno));
        return false;
    }

    return true;
}

bool set_serial_connection_flow_control(SerialConnection *connection, const int flow_control)
{
    struct termios tty;

    if (tcgetattr(connection->fd, &tty) != 0)
    {
        printf("Error from tcgetattr: %s\n", strerror(errno));
        return false;
    }

    if (flow_control == 0)
    {
        tty.c_cflag &= ~CRTSCTS;  // No flow control
    }
    else if (flow_control == 1)
    {
        tty.c_cflag |= CRTSCTS;   // Hardware flow control
    }

    if (tcsetattr(connection->fd, TCSANOW, &tty) != 0)
    {
        printf("Error from tcsetattr: %s\n", strerror(errno));
        return false;
    }

    return true;
}

bool set_serial_connection_timeout(SerialConnection *connection, const int timeout)
{
    struct termios tty;

    if (tcgetattr(connection->fd, &tty) != 0)
    {
        printf("Error from tcgetattr: %s\n", strerror(errno));
        return false;
    }

    tty.c_cc[VTIME] = timeout; // Timeout in deciseconds

    if (tcsetattr(connection->fd, TCSANOW, &tty) != 0)
    {
        printf("Error from tcsetattr: %s\n", strerror(errno));
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

    while (true)
    {
        int bytes = read(connection->fd, data + bytes_read, 1);

        if (bytes == -1)
            return bytes;
        else if (bytes == 0 || data[bytes_read] == until)
            return bytes_read;

        bytes_read++;
    }

    return bytes_read;
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
