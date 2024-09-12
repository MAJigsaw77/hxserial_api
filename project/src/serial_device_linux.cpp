#include "serial_device.h"

#include <libudev.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

bool get_serial_devices(SerialDevice **devices, size_t *count)
{
    struct udev *udev;
    struct udev_enumerate *enumerate;
    struct udev_list_entry *devices_list, *entry;
    struct udev_device *dev;
    struct udev_device *usb_dev;
    SerialDevice *deviceList = NULL;
    size_t deviceCount = 0;

    udev = udev_new();

    if (!udev)
        return false;

    enumerate = udev_enumerate_new(udev);
    udev_enumerate_add_match_subsystem(enumerate, "tty");
    udev_enumerate_scan_devices(enumerate);
    devices_list = udev_enumerate_get_list_entry(enumerate);

    udev_list_entry_foreach(entry, devices_list)
    {
        const char *path;
        path = udev_list_entry_get_name(entry);
        dev = udev_device_new_from_syspath(udev, path);

        const char *dev_node = udev_device_get_devnode(dev);
        usb_dev = udev_device_get_parent_with_subsystem_devtype(dev, "usb", "usb_device");

        if (usb_dev)
        {
            const char *vendor_id = udev_device_get_sysattr_value(usb_dev, "idVendor");
            const char *product_id = udev_device_get_sysattr_value(usb_dev, "idProduct");

            if (vendor_id && product_id)
            {
                deviceList = (SerialDevice *)realloc(deviceList, sizeof(SerialDevice) * (deviceCount + 1));

                deviceList[deviceCount].path = strdup(dev_node);
                deviceList[deviceCount].vID = (int)strtol(vendor_id, NULL, 16);
                deviceList[deviceCount].pID = (int)strtol(product_id, NULL, 16);

                deviceCount++;
            }
        }

        udev_device_unref(dev);
    }

    udev_enumerate_unref(enumerate);
    udev_unref(udev);

    (*devices) = deviceList;
    (*count) = deviceCount;

    return true;
}

void free_serial_devices(SerialDevice *devices, size_t count)
{
    for (size_t i = 0; i < count; i++)
        free((void *)devices[i].path);

    free(devices);
}
