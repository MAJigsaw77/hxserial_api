package hxserialapi;

#if !cpp
#error 'Serial API supports only C++ target platforms.'
#end
class Types {}

@:buildXml('<include name="${haxelib:hxserialapi}/project/Build.xml" />')
@:include('serial_device.h')
@:unreflective
@:structAccess
@:native('SerialDevice')
extern class SerialDevice
{
	@:native('SerialDevice')
	static function create():SerialDevice;

	var path:ConstCharStar;
	var vid:cpp.UInt16;
	var pid:cpp.UInt16;
}

@:buildXml('<include name="${haxelib:hxserialapi}/project/Build.xml" />')
@:include('serial_connection.h')
@:unreflective
@:structAccess
@:native('SerialConnection')
extern class SerialConnection
{
	@:native('SerialConnection')
	static function create():SerialConnection;

	var path:ConstCharStar;
	var baud:Int;
	var char_size:Int;
	var parity:Int;
	var stop_bits:Int;
	var flow_control:Int;
	var timeout:Int;
	var fd:Int;
}
