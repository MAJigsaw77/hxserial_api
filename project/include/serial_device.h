#pragma once

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

typedef struct SerialDevice
{
	const char *path;
	int pid;
	int vid;
} SerialDevice;

/**
 * Get the list of connected serial devices.
 *
 * @param devices Output parameter that will point to an array of SerialDevice structures.
 * @param count Output parameter for the number of devices found.
 * @return true on success, false on failure.
 */
bool get_serial_devices(SerialDevice **devices, size_t *count);

/**
 * Free the memory allocated for the device list.
 *
 * @param devices The array of SerialDevice structures to be freed.
 * @param count The number of devices in the array.
 */
void free_serial_devices(SerialDevice *devices, size_t count);
