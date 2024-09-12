package hxserial_api;

#if !cpp
#error 'Serial API supports only C++ target platforms.'
#end
import hxserial_api.Types;

@:buildXml('<include name="${haxelib:hxserial_api}/project/Build.xml" />')
@:include('serial_device.hpp')
@:unreflective
extern class SerialDeviceAPI
{
	@:native('get_serial_devices')
	static function get_serial_devices(devices:cpp.RawPointer<cpp.RawPointer<SerialDevice>>, count:cpp.RawPointer<cpp.SizeT>):Bool;

	@:native('free_serial_devices')
	static function free_serial_devices(devices:cpp.RawPointer<SerialDevice>, count:cpp.SizeT):Void;
}
