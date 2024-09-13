package hxserial_api;

#if !cpp
#error 'Serial API supports only C++ target platforms.'
#end
class Types {}

@:buildXml('<include name="${haxelib:hxserial_api}/project/Build.xml" />')
@:include('serial_device.hpp')
@:unreflective
@:structAccess
@:native('SerialDevice')
extern class SerialDevice
{
	@:native('SerialDevice')
	static function create():SerialDevice;

	var path:cpp.ConstCharStar;
	var vID:Int;
	var pID:Int;
}

@:buildXml('<include name="${haxelib:hxserial_api}/project/Build.xml" />')
@:include('serial_connection.hpp')
@:unreflective
@:structAccess
@:native('SerialConnection')
extern class SerialConnection
{
	@:native('SerialConnection')
	static function create():SerialConnection;

	var path:cpp.ConstCharStar;
	var baud:Int;
	var char_size:Int;
	var parity:Int;
	var stop_bits:Int;
	#if windows
	var data_bits:Int;
	#end
	var flow_control:Int;
	var timeout:Int;
}
