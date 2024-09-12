package;

import hxserialapi.SerialConnectionAPI;
import hxserialapi.SerialDeviceAPI;
import hxserialapi.Types;

class Main
{
	public static function main():Void
	{
		final devices:cpp.RawPointer<SerialDevice> = untyped __cpp__('nullptr');

		var count:cpp.SizeT = 0;

		if (SerialDeviceAPI.getSerialDevices(cpp.RawPointer.addressOf(devices), cpp.RawPointer.addressOf(count)))
		{
			for (i in 0...count)
				Sys.println('Path: ${devices[i].path}, vID: ${devices[i].vid}, pID: ${devices[i].pid}.');

			freeSerialDevices(devices, count);
		}
		else
			Sys.println('No devices found.');
	}
}
