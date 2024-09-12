#include "serial_device.h"

#include <stdio.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <linux/serial.h>

#define MAX_PATH 256


bool get_serial_devices(SerialDevice **devices, size_t *count)
{
	SerialDevice *deviceList = NULL;
	size_t deviceCount = 0;

	DIR *dir = opendir("/dev");

	if (dir == NULL)
		return false;

	struct dirent *entry;

	while ((entry = readdir(dir)) != NULL)
	{
		if (strncmp(entry->d_name, "tty", 3) == 0)
		{
			SerialDevice *device = (SerialDevice *)malloc(sizeof(SerialDevice));
			memset(device, 0, sizeof(SerialDevice));

			snprintf(device->path, MAX_PATH, "/dev/%s", entry->d_name);

			int fd = open(device->path, O_RDWR | O_NOCTTY | O_NONBLOCK);
			if (fd == -1)
			{
				free(device);
				continue;
			}

			struct serial_struct serial;
			if (ioctl(fd, TIOCGSERIAL, &serial) == -1)
			{
				free(device);
				continue;
			}

			device->vid = serial.vendor_id;
			device->pid = serial.product_id;

			deviceList = (SerialDevice *)realloc(deviceList, sizeof(SerialDevice) * (deviceCount + 1));
			deviceList[deviceCount] = *device;
			deviceCount++;
		}
	}

	closedir(dir);

	(*devices) = deviceList;
	(*count) = deviceCount;

	return true;
}

void free_serial_devices(SerialDevice *devices, size_t count)
{
	for (size_t i = 0; i < count; i++)
	{
		free((void *)devices[i].path);
	}

	free(devices);
}