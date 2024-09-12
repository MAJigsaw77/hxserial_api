#include "serial_connection.h"

#include <windows.h>
#include <iostream>

bool open_serial_connection(SerialDevice *device, SerialConnection **connection) {
    HANDLE handle = CreateFileA(device->path, GENERIC_READ | GENERIC_WRITE, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
    if (handle == INVALID_HANDLE_VALUE) {
        std::cerr << "Failed to open device: " << GetLastError() << std::endl;
        return false;
    }

    DCB dcb = {0};  // Ensure the DCB structure is zero-initialized
    dcb.DCBlength = sizeof(dcb);
    if (!GetCommState(handle, &dcb)) {
        std::cerr << "Failed to get comm state: " << GetLastError() << std::endl;
        CloseHandle(handle);
        return false;
    }

    dcb.BaudRate = CBR_9600;  // Example baud rate
    dcb.ByteSize = 8;         // 8 data bits
    dcb.Parity = NOPARITY;    // No parity
    dcb.StopBits = ONESTOPBIT; // 1 stop bit

    if (!SetCommState(handle, &dcb)) {
        std::cerr << "Failed to set comm state: " << GetLastError() << std::endl;
        CloseHandle(handle);
        return false;
    }

    COMMTIMEOUTS timeouts = {0}; // Zero-initialize the COMMTIMEOUTS struct
    timeouts.ReadIntervalTimeout = MAXDWORD;
    timeouts.ReadTotalTimeoutMultiplier = 0;
    timeouts.ReadTotalTimeoutConstant = 0;
    timeouts.WriteTotalTimeoutMultiplier = 0;
    timeouts.WriteTotalTimeoutConstant = 0;

    if (!SetCommTimeouts(handle, &timeouts)) {
        std::cerr << "Failed to set timeouts: " << GetLastError() << std::endl;
        CloseHandle(handle);
        return false;
    }

    // Allocate and set up the SerialConnection structure
    SerialConnection *conn = (SerialConnection *)malloc(sizeof(SerialConnection));
    if (!conn) {
        std::cerr << "Memory allocation failed" << std::endl;
        CloseHandle(handle);
        return false;
    }

    conn->fd = handle;  // Correct assignment to HANDLE type
    conn->path = device->path;
    conn->baud = 9600;
    conn->char_size = 8;
    conn->parity = NOPARITY;
    conn->stop_bits = ONESTOPBIT;
    conn->flow_control = 0;
    conn->timeout = 0;

    *connection = conn; // Correct assignment to pass back the pointer
    return true;
}

bool set_serial_connection_baud(SerialConnection *connection, const int baud) {
    // Set the baud rate
    DCB dcb;
    dcb.DCBlength = sizeof(dcb);
    if (!GetCommState(connection->fd, &dcb)) {
        return false;
    }
    dcb.BaudRate = baud;
    if (!SetCommState(connection->fd, &dcb)) {
        return false;
    }

    connection->baud = baud;
    return true;
}

bool set_serial_connection_char_size(SerialConnection *connection, const int char_size) {
    // Set the character size
    DCB dcb;
    dcb.DCBlength = sizeof(dcb);
    if (!GetCommState(connection->fd, &dcb)) {
        return false;
    }
    dcb.ByteSize = char_size;
    if (!SetCommState(connection->fd, &dcb)) {
        return false;
    }

    connection->char_size = char_size;
    return true;
}

bool set_serial_connection_parity(SerialConnection *connection, const int parity) {
    // Set the parity
    DCB dcb;
    dcb.DCBlength = sizeof(dcb);
    if (!GetCommState(connection->fd, &dcb)) {
        return false;
    }
    dcb.Parity = parity;
    if (!SetCommState(connection->fd, &dcb)) {
        return false;
    }

    connection->parity = parity;
    return true;
}

bool set_serial_connection_stop_bits(SerialConnection *connection, const int stop_bits) {
    // Set the stop bits
    DCB dcb;
    dcb.DCBlength = sizeof(dcb);
    if (!GetCommState(connection->fd, &dcb)) {
        return false;
    }
    dcb.StopBits = stop_bits;
    if (!SetCommState(connection->fd, &dcb)) {
        return false;
    }

    connection->stop_bits = stop_bits;
    return true;
}

bool set_serial_connection_data_bits(SerialConnection *connection, const int data_bits) {
    // Set the data bits
    DCB dcb;
    dcb.DCBlength = sizeof(dcb);
    if (!GetCommState(connection->fd, &dcb)) {
        return false;
    }
    dcb.ByteSize = data_bits;
    if (!SetCommState(connection->fd, &dcb)) {
        return false;
    }

    connection->data_bits = data_bits;
    return true;
}

bool set_serial_connection_parity(SerialConnection *connection, const int parity) {
    // Set the parity
    DCB dcb;
    dcb.DCBlength = sizeof(dcb);
    if (!GetCommState(connection->fd, &dcb)) {
        return false;
    }
    dcb.Parity = parity;
    if (!SetCommState(connection->fd, &dcb)) {
        return false;
    }

    connection->parity = parity;
    return true;
}

bool set_serial_connection_flow_control(SerialConnection *connection, const int flow_control) {
    // Set the flow control
    if (!SetCommMask(connection->fd, flow_control)) {
        return false;
    }

    connection->flow_control = flow_control;
    return true;
}

bool set_serial_connection_timeout(SerialConnection *connection, const int timeout) {
    // Set the timeout
    COMMTIMEOUTS timeouts;
    timeouts.ReadIntervalTimeout = 0;
    timeouts.ReadTotalTimeoutMultiplier = 0;
    timeouts.ReadTotalTimeoutConstant = 0;
    timeouts.WriteTotalTimeoutMultiplier = 0;
    timeouts.WriteTotalTimeoutConstant = 0;
    if (!SetCommTimeouts(connection->fd, &timeouts)) {
        return false;
    }

    connection->timeout = timeout;
    return true;
}

/**
 * Read data from a serial connection.
 *
 * @param connection The connection to read from.
 * @param data Output parameter that will point to a buffer to store the read data.
 * @param size The size of the buffer.
 * @return The number of bytes read, or -1 on failure.
 */
int read_serial_connection(const SerialConnection *connection, uint8_t *data, const size_t size) {
    DWORD bytes_read = 0;
    if (!ReadFile(connection->fd, data, size, &bytes_read, NULL)) {
        return -1;
    }
    return bytes_read;
}

int read_byte_serial_connection(const SerialConnection *connection, uint8_t *data) {
    return read_serial_connection(connection, data, 1);
}

int read_until_serial_connection(const SerialConnection *connection, uint8_t *data, const char until) {
    int bytes_read = 0;
    while (bytes_read < 1) {
        int bytes = read_serial_connection(connection, data + bytes_read, 1);
        if (bytes < 0) {
            return -1;
        }
        bytes_read += bytes;
        if (data[bytes_read - 1] == until) {
            break;
        }
    }
    return bytes_read;
}

int read_until_line_serial_connection(const SerialConnection *connection, uint8_t *data) {
    int bytes_read = 0;
    while (bytes_read < 1) {
        int bytes = read_serial_connection(connection, data + bytes_read, 1);
        if (bytes < 0) {
            return -1;
        }
        bytes_read += bytes;
        if (data[bytes_read - 1] == '\n') {
            break;
        }
    }
    data[bytes_read - 1] = '\0';
    return bytes_read;
}

int has_available_data_serial_connection(const SerialConnection *connection) {
    COMSTAT comstat;
    if (!ClearCommError(connection->fd, &comstat, NULL)) {
        return 0;
    }
    return comstat.cbInQue;
}

/**
 * Write data to a serial connection.
 *
 * @param connection The connection to write to.
 * @param data The data to write.
 * @param size The size of the data to write.
 * @return The number of bytes written, or -1 on failure.
 */
int write_bytes_serial_connection(SerialConnection *connection, const uint8_t *data, const size_t size) {
    DWORD bytes_written = 0;
    if (!WriteFile(connection->fd, data, size, &bytes_written, NULL)) {
        return -1;
    }
    return bytes_written;
}

int write_byte_serial_connection(SerialConnection *connection, const uint8_t data) {
    return write_bytes_serial_connection(connection, &data, 1);
}

int write_string_serial_connection(SerialConnection *connection, const char *data) {
    return write_bytes_serial_connection(connection, (uint8_t *)data, strlen(data));
}

/**
 * Close a serial connection.
 *
 * @param connection The connection to close.
 */
void close_serial_connection(SerialConnection *connection) {
    CloseHandle(connection->fd);
}

/**
 * Free the memory allocated for the connection.
 *
 * @param connection The connection to free.
 */
void free_serial_connection(SerialConnection *connection) {
    free(connection);
}