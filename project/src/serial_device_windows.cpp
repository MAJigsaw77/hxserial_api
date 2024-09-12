#include "serial_device.hpp"

#include <windows.h>
#include <devguid.h>
#include <initguid.h>
#include <regstr.h>
#include <setupapi.h>
#include <tchar.h>

#include <iostream>

bool get_serial_devices(SerialDevice **devices, size_t *count)
{
	HDEVINFO deviceInfoSet;
	SP_DEVINFO_DATA deviceInfoData;
	DWORD index = 0;
	DWORD requiredSize = 0;
	bool foundDevice = false;
	SerialDevice *deviceList = nullptr;
	size_t deviceCount = 0;

	deviceInfoSet = SetupDiGetClassDevs(&GUID_DEVCLASS_PORTS, NULL, NULL, DIGCF_PRESENT | DIGCF_PROFILE);

	if (deviceInfoSet == INVALID_HANDLE_VALUE)
		return false;

	deviceInfoData.cbSize = sizeof(SP_DEVINFO_DATA);

	while (SetupDiEnumDeviceInfo(deviceInfoSet, index, &deviceInfoData))
	{
		HKEY hDeviceRegistryKey = SetupDiOpenDevRegKey(deviceInfoSet, &deviceInfoData, DICS_FLAG_GLOBAL, 0, DIREG_DEV, KEY_READ);

		if (hDeviceRegistryKey == INVALID_HANDLE_VALUE)
		{
			index++;
			continue;
		}

		TCHAR portName[256];
		DWORD portNameSize = sizeof(portName);

		if (RegQueryValueEx(hDeviceRegistryKey, _T("PortName"), NULL, NULL, (LPBYTE)portName, &portNameSize) == ERROR_SUCCESS)
		{
			if (_tcsstr(portName, _T("COM")) != NULL)
			{
				TCHAR friendlyName[256];
				DWORD friendlyNameSize = sizeof(friendlyName);

				if (SetupDiGetDeviceRegistryProperty(deviceInfoSet,
								     &deviceInfoData,
								     SPDRP_FRIENDLYNAME,
								     NULL,
								     (PBYTE)friendlyName,
								     friendlyNameSize,
								     &requiredSize))
				{
					DWORD vendorID = 0;
					DWORD productID = 0;
					TCHAR hardwareID[256];

					if (SetupDiGetDeviceRegistryProperty(deviceInfoSet,
									     &deviceInfoData,
									     SPDRP_HARDWAREID,
									     NULL,
									     (PBYTE)hardwareID,
									     sizeof(hardwareID),
									     &requiredSize))
						_stscanf_s(hardwareID, _T("USB\\VID_%04x&PID_%04x"), &vendorID, &productID);

					deviceList = (SerialDevice *)realloc(deviceList, sizeof(SerialDevice) * (deviceCount + 1));

					deviceList[deviceCount].path = _strdup(portName);
					deviceList[deviceCount].pID = productID;
					deviceList[deviceCount].vID = vendorID;

					deviceCount++;
				}
			}
		}

		RegCloseKey(hDeviceRegistryKey);
		index++;
	}

	SetupDiDestroyDeviceInfoList(deviceInfoSet);

	if (deviceCount > 0)
	{
		(*devices) = deviceList;
		(*count) = deviceCount;

		return true;
	}

	return false;
}

void free_serial_devices(SerialDevice *devices, size_t count)
{
	for (size_t i = 0; i < count; i++)
		free((void *)devices[i].path);

	free(devices);
}
