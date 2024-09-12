#pragma once

#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct SerialDevice
{
	//const char *name;
	uint16_t pid;
	uint16_t vid;
	const char* path;
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

#ifdef __cplusplus
}
#endif