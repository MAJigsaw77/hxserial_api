#include "serial_device.hpp"

#include <libudev.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

bool get_serial_devices(SerialDevice **devices, size_t *count)
{
	struct udev_list_entry *devices_list, *entry;
	struct udev_device *dev;
	struct udev_device *usb_dev;

	SerialDevice *deviceList = NULL;

	size_t deviceCount = 0;

	struct udev *udev = udev_new();

	if (!udev)
		return false;

	struct udev_enumerate *enumerate = udev_enumerate_new(udev);
	udev_enumerate_add_match_subsystem(enumerate, "tty");
	udev_enumerate_scan_devices(enumerate);

	devices_list = udev_enumerate_get_list_entry(enumerate);

	udev_list_entry_foreach(entry, devices_list)
	{
		const char *path = udev_list_entry_get_name(entry);

		if (path && path[0])
		{
			dev = udev_device_new_from_syspath(udev, path);

			deviceList = (SerialDevice *)realloc(deviceList, sizeof(SerialDevice) * (deviceCount + 1));

			const char *dev_node = udev_device_get_devnode(dev);

			if (dev_node && dev_node[0])
				deviceList[deviceCount].path = strdup(dev_node);

			usb_dev = udev_device_get_parent_with_subsystem_devtype(dev, "usb", "usb_device");

			if (usb_dev)
			{
				const char *vendor_id = udev_device_get_sysattr_value(usb_dev, "idVendor");

				if (vendor_id && vendor_id[0])
					deviceList[deviceCount].vID = (int)strtol(vendor_id, NULL, 16);

				const char *product_id = udev_device_get_sysattr_value(usb_dev, "idProduct");

				if (product_id && product_id[0])
					deviceList[deviceCount].pID = (int)strtol(product_id, NULL, 16);

				deviceCount++;
			}

			udev_device_unref(dev);
		}
	}

	udev_enumerate_unref(enumerate);
	udev_unref(udev);

	(*devices) = deviceList;
	(*count) = deviceCount;

	return true;
}
