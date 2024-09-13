package hxserial_api;

import hxserial_api.externs.SerialDeviceAPI;
import hxserial_api.externs.Types;

@:allow(hxserial_api.Serial)
class Device
{
	public static function getDevices():Array<Device>
	{
		final devices:cpp.RawPointer<SerialDevice> = untyped __cpp__('nullptr');

		var count:cpp.SizeT = 0;

		if (SerialDeviceAPI.get_serial_devices(cpp.RawPointer.addressOf(devices), cpp.RawPointer.addressOf(count)))
		{
			final devicesList:Array<Device> = [];

			for (i in 0...count)
				devicesList.push(new Device(devices[i]));

			SerialDeviceAPI.free_serial_devices(devices, count);

			return devicesList;
		}

		return [];
	}

	public var path(get, never):String;
	public var vID(get, never):Int;
	public var pID(get, never):Int;

	@:noCompletion
	private var device:cpp.Struct<SerialDevice>;

	public function new(device:cpp.Struct<SerialDevice>):Void
	{
		this.device = device;
	}

	private function get_path():String
	{
		return this.device.path;
	}

	private function get_vID():Int
	{
		return this.device.vID;
	}

	private function get_pID():Int
	{
		return this.device.pID;
	}
}
