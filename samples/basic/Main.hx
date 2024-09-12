package;

import hxserial_api.SerialConnectionAPI;
import hxserial_api.SerialDeviceAPI;
import hxserial_api.Types;

class Main
{
	public static function main():Void
	{
		final devices:cpp.RawPointer<SerialDevice> = untyped __cpp__('nullptr');

		var count:cpp.SizeT = 0;

		if (SerialDeviceAPI.get_serial_devices(cpp.RawPointer.addressOf(devices), cpp.RawPointer.addressOf(count)))
		{
			for (i in 0...count)
				Sys.println('Path: ${devices[i].path}, vID: ${devices[i].vID}, pID: ${devices[i].pID}.');

			SerialDeviceAPI.free_serial_devices(devices, count);
		}
		else
			Sys.println('No devices found.');
	}
}
