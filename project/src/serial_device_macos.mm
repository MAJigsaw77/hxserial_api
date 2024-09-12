#include "serial_device.hpp"

#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

#import <CoreFoundation/CoreFoundation.h>
#import <IOKit/IOBSD.h>
#import <IOKit/IOKitLib.h>
#import <IOKit/serial/IOSerialKeys.h>
#import <IOKit/usb/IOUSBLib.h>

bool get_serial_devices(SerialDevice **devices, size_t *count)
{
	CFMutableDictionaryRef matchingDict = IOServiceMatching(kIOSerialBSDServiceValue);
	io_iterator_t iterator;
	kern_return_t kr = IOServiceGetMatchingServices(kIOMasterPortDefault, matchingDict, &iterator);

	if (kr != KERN_SUCCESS)
		return false;

	io_service_t usbDevice;
	size_t deviceCount = 0;
	SerialDevice *deviceList = NULL;

	while ((usbDevice = IOIteratorNext(iterator)))
	{
		CFStringRef devicePathRef =
		    (CFStringRef)IORegistryEntryCreateCFProperty(usbDevice, CFSTR(kIOCalloutDeviceKey), kCFAllocatorDefault, 0);
		io_registry_entry_t parent;
		kr = IORegistryEntryGetParentEntry(usbDevice, kIOServicePlane, &parent);

		if (kr == KERN_SUCCESS)
		{
			CFNumberRef vendorIDRef =
			    (CFNumberRef)IORegistryEntryCreateCFProperty(parent, CFSTR(kUSBVendorID), kCFAllocatorDefault, 0);
			CFNumberRef productIDRef =
			    (CFNumberRef)IORegistryEntryCreateCFProperty(parent, CFSTR(kUSBProductID), kCFAllocatorDefault, 0);

			char devicePath[1024] = "Unknown Path";

			if (devicePathRef)
			{
				CFStringGetCString(devicePathRef, devicePath, sizeof(devicePath), kCFStringEncodingUTF8);
				CFRelease(devicePathRef);
			}

			int vendorID = 0;

			if (vendorIDRef)
			{
				CFNumberGetValue(vendorIDRef, kCFNumberIntType, &vendorID);
				CFRelease(vendorIDRef);
			}

			int productID = 0;

			if (productIDRef)
			{
				CFNumberGetValue(productIDRef, kCFNumberIntType, &productID);
				CFRelease(productIDRef);
			}

			deviceList = (SerialDevice *)realloc(deviceList, sizeof(SerialDevice) * (deviceCount + 1));

			deviceList[deviceCount].path = strdup(devicePath);
			deviceList[deviceCount].pID = productID;
			deviceList[deviceCount].vID = vendorID;

			IOObjectRelease(usbDevice);

			deviceCount++;
		}
	}

	IOObjectRelease(iterator);

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
