package hxserialapi;

#if !cpp
#error 'Serial API supports only C++ target platforms.'
#end
import hxserialapi.Types;

@:buildXml('<include name="${haxelib:hxserialapi}/project/Build.xml" />')
@:include('serial_device.h')
@:unreflective
extern class SerialDevice
{
	@:native('get_serial_devices')
	static function get_serial_devices(devices:cpp.RawPointer<cpp.RawPointer<SerialDevice>>, count:cpp.RawPointer<cpp.SizeT>):Bool;

	@:native('free_serial_devices')
	static function free_serial_devices(devices:cpp.RawPointer<SerialDevice>, count:cpp.SizeT):Void;
}
