package hxserial_api;

#if !cpp
#error 'Serial API supports only C++ target platforms.'
#end
import hxserial_api.Types;

/**
 * API for managing serial devices.
 * This class provides functions for retrieving and freeing serial device
 * information. It allows you to list available serial devices and
 * release the allocated memory for device data.
 */
@:buildXml('<include name="${haxelib:hxserial_api}/project/Build.xml" />')
@:include('serial_device.hpp')
@:unreflective
extern class SerialDeviceAPI
{
	/**
	 * Retrieves a list of serial devices.
	 *
	 * @param devices A pointer to a pointer where the list of serial devices
	 *                will be stored. This should be a pointer to a pointer
	 *                to `SerialDevice` structures.
	 * @param count A pointer to a size_t variable where the number of devices
	 *              will be stored.
	 * @return True if the devices were successfully retrieved, false otherwise.
	 *
	 * This function populates the `devices` pointer with an array of `SerialDevice`
	 * structures and sets `count` to the number of devices found. The caller
	 * is responsible for freeing this memory using `free_serial_devices`.
	 */
	@:native('get_serial_devices')
	static function get_serial_devices(devices:cpp.RawPointer<cpp.RawPointer<SerialDevice>>, count:cpp.RawPointer<cpp.SizeT>):Bool;

	/**
	 * Frees the memory allocated for the serial devices list.
	 *
	 * @param devices A pointer to the list of serial devices to be freed.
	 * @param count The number of devices in the list.
	 *
	 * This function should be called to release the memory allocated by
	 * `get_serial_devices` once the devices are no longer needed.
	 */
	@:native('free_serial_devices')
	static function free_serial_devices(devices:cpp.RawPointer<SerialDevice>, count:cpp.SizeT):Void;
}
