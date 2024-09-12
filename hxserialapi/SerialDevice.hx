package hxserialapi;

#if !cpp
#error 'Serial API supports only C++ target platforms.'
#end
@:buildXml('<include name="${haxelib:hxserialapi}/project/Build.xml" />')
@:include('serial_device.h')
@:unreflective
extern class SerialDevice
{
	@:native('get_serial_devices')
	static function getSerialDevices(devices:cpp.RawPointer<cpp.RawPointer<SerialDevice>>, count:cpp.RawPointer<cpp.SizeT>):Bool;

	@:native('free_serial_devices')
	static function freeSerialDevices(devices:cpp.RawPointer<SerialDevice>, count:cpp.SizeT):Void;
}
