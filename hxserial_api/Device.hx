package hxserial_api;

import hxserial_api.externs.SerialDeviceAPI;
import hxserial_api.externs.Types;

/**
 * Represents a serial device and provides methods to retrieve available devices
 * and device-specific information such as path, vendor ID (vID), and product ID (pID).
 */
@:allow(hxserial_api.Connection)
class Device
{
	/**
	 * Retrieves a list of available serial devices connected to the system.
	 *
	 * @return An array of `Device` objects representing the available serial devices.
	 */
	public static function getDevices():Array<Device>
	{
		final devices:cpp.RawPointer<SerialDevice> = untyped __cpp__('nullptr');

		final count:cpp.SizeT = 0;

		if (SerialDeviceAPI.get_serial_devices(cpp.RawPointer.addressOf(devices), cpp.RawPointer.addressOf(count)))
		{
			final devicesList:Array<Device> = [for (i in 0...count) new Device(devices[i])];

			cpp.Stdlib.nativeFree(untyped devices);

			return devicesList;
		}

		return [];
	}

	/**
	 * The file path of the serial device.
	 */
	public var path(get, never):String;

	/**
	 * The vendor ID (vID) of the serial device.
	 */
	public var vID(get, never):Int;

	/**
	 * The product ID (pID) of the serial device.
	 */
	public var pID(get, never):Int;

	/**
	 * Internal structure representing the serial device.
	 */
	@:noCompletion
	private var device:cpp.Struct<SerialDevice>;

	/**
	 * Constructor for creating a new `Device` instance based on a `SerialDevice` structure.
	 *
	 * @param device The `SerialDevice` structure representing the serial device.
	 */
	public function new(device:cpp.Struct<SerialDevice>):Void
	{
		this.device = device;
	}

	@:noCompletion
	private function get_path():String
	{
		return this.device.path;
	}

	@:noCompletion
	private function get_vID():Int
	{
		return this.device.vID;
	}

	@:noCompletion
	private function get_pID():Int
	{
		return this.device.pID;
	}
}
