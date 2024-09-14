package;

import hxserial_api.externs.SerialConnectionAPI;
import hxserial_api.externs.SerialDeviceAPI;
import hxserial_api.externs.Types;
import hxserial_api.Serial;
import hxserial_api.Device;

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

			for (i in 0...count)
			{
				var device = new Device(devices[i]);

				if (device.vID != 0 && device.pID != 0)
				{
					Sys.println("Connecting to device: " + device.path + ", vID: " + device.vID + ", pID: " + device.pID);
					var serial = new Serial(device);
					if (!serial.connected)
					{
						Sys.println('Failed to open connection.');
						Sys.exit(1);
					}
					serial.setBaud(Serial.BAUD_115200);
					// serial.setCharSize(Serial.CHAR_SIZE_8);
					// serial.setParity(Serial.PARITY_NONE);
					// serial.setStopBits(Serial.STOP_BITS_1);
					// serial.setDataBits(Serial.CHAR_SIZE_8);
					// serial.setFlowControl(Serial.FLOW_CONTROL_NONE);

					Sys.println('Opened connection.');

					while (true)
					{
						var bytesRead = serial.readByte();

						if (bytesRead > 0)
							Sys.print(String.fromCharCode(bytesRead));
						// Sys.println(String.fromCharCode(data) + " " + data);
					}

					// final connection:cpp.RawPointer<SerialConnection> = untyped __cpp__('nullptr');

					/*if (SerialConnectionAPI.open_serial_connection(cpp.RawPointer.addressOf(device), cpp.RawPointer.addressOf(connection)))
						{
							SerialConnectionAPI.set_serial_connection_baud(connection, 115200);
							// SerialConnectionAPI.set_serial_connection_char_size(connection, 8);
							// SerialConnectionAPI.set_serial_connection_parity(connection, 0);
							// SerialConnectionAPI.set_serial_connection_stop_bits(connection, SerialConnectionAPI.STOP_BITS_1);
							// SerialConnectionAPI.set_serial_connection_flow_control(connection, SerialConnectionAPI.FLOW_CONTROL_NONE);
							Sys.println('Opened connection.');

							

							/*var data:cpp.UInt8 = 0;

							while (true)
							{
								var bytesRead = SerialConnectionAPI.read_serial_connection(connection, cpp.RawPointer.addressOf(data), 1);

								if (bytesRead > 0)
									Sys.print(String.fromCharCode(data));
								// Sys.println(String.fromCharCode(data) + " " + data);
							}

							SerialConnectionAPI.close_serial_connection(connection);

							serial.setBaud(Serial.BAUD_115200);
					}*/
					// else
					//	Sys.println('Failed to open connection.');
					// }
				}
			}
			cpp.Stdlib.nativeFree(untyped devices);
		}
		else
			Sys.println('No devices found.');
	}
}
