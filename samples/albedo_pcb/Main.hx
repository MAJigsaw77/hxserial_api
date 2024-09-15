package main;

import hxserial_api.Connection;
import hxserial_api.Device;

class Main
{
	public static function main():Void
	{
		// Step 1: Retrieve available devices
		final devices:Array<Device> = Device.getDevices();

		// Step 2: Find the Albedo PCB device (replace with actual device path or criteria)
		var albedoDevice:Device = null;

		for (device in devices)
		{
			// Replace with the correct path for your Albedo PCB
			if (device.path == "/dev/ttyUSB0")
			{
				albedoDevice = device;
				break;
			}
		}

		if (albedoDevice == null)
		{
			Sys.println("Albedo PCB device not found.");
			Sys.exit(0);
		}

		// Step 3: Create and open the connection
		final connection:Connection = new Connection(albedoDevice);

		// Step 4: Configure the connection settings
		connection.baud = BaudRate.BAUD_9600;
		connection.charSize = CharSize.CHAR_SIZE_8;
		connection.parity = Parity.NONE;
		connection.stopBits = StopBits.STOP_BITS_1;
		connection.flowControl = FlowControl.NONE;
		connection.timeout = Timeout.READ_WRITE;

		// Step 5: Perform read and write operations
		connection.writeString("Hello, Albedo PCB!");

		Sys.println("Received response: " + connection.read(100).toString());

		// Step 6: Close the connection
		connection.close();
	}
}
