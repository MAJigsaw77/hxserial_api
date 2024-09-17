package;

import haxe.io.Bytes;
import hxserial_api.Connection;
import hxserial_api.Device;

class Main
{
	public static function main():Void
	{
		final devices:Array<Device> = Device.getDevices();

		Sys.println('${devices.length} device(s) available');

		for (device in devices)
		{
			Sys.println('Path: ${device.path}, vID: ${device.vID}, pID: ${device.pID}.');

			if (device.vID != 0 && device.pID != 0)
			{
				Sys.println("Connecting to device: " + device.path + ", vID: " + device.vID + ", pID: " + device.pID);

				final serial:Connection = new Connection(device, BAUD_115200);

				if (!serial.connected)
				{
					Sys.println('Failed to open connection.');
					Sys.exit(1);
				}

				Sys.println('Opened connection to device.');

				while (true)
				{
					final bytesRead:Int = serial.readByte();

					if (bytesRead > 0)
						Sys.print(String.fromCharCode(bytesRead));
				}

				serial.close();
			}
		}
	}
}
