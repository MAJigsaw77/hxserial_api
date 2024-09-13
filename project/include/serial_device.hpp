#pragma once

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

typedef struct SerialDevice
{
	const char *path;
	int pID;
	int vID;
} SerialDevice;

bool get_serial_devices(SerialDevice **devices, size_t *count);
