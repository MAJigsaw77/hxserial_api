package hxserial_api.externs;

#if !cpp
#error 'Serial API supports only C++ target platforms.'
#end
import hxserial_api.externs.Types;

/**
 * API for managing serial devices.
 * This class provides functions for retrieving and freeing serial device information.
 * It allows you to list available serial devices and release the allocated memory for device data.
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
	 * @return true if the devices were successfully retrieved, false otherwise.
	 *
	 * This function populates the `devices` pointer with an array of `SerialDevice`
	 * structures and sets `count` to the number of devices found. The caller
	 * is responsible for freeing this memory using `free_serial_devices`.
	 */
	@:native('get_serial_devices')
	static function get_serial_devices(devices:cpp.RawPointer<cpp.RawPointer<SerialDevice>>, count:cpp.RawPointer<cpp.SizeT>):Bool;
}
