package hxserialapi;

#if !cpp
#error 'Serial API supports only C++ target platforms.'
#end
import hxserialapi.Types;

@:buildXml('<include name="${haxelib:hxserialapi}/project/Build.xml" />')
@:include('serial_connection.h')
@:unreflective
extern class SerialConnection
{
	@:native('open_serial_connection')
	static function open_serial_connection(device:cpp.RawPointer<SerialDevice>, connection:cpp.RawPointer<cpp.RawPointer<SerialConnection>>):Bool;

	@:native('set_serial_connection_baud')
	static function set_serial_connection_baud(connection:cpp.RawPointer<SerialConnection>, baud:Int):Bool;

	@:native('set_serial_connection_char_size')
	static function set_serial_connection_char_size(connection:cpp.RawPointer<SerialConnection>, char_size:Int):Bool;

	@:native('set_serial_connection_parity')
	static function set_serial_connection_parity(connection:cpp.RawPointer<SerialConnection>, parity:Int):Bool;

	@:native('set_serial_connection_stop_bits')
	static function set_serial_connection_stop_bits(connection:cpp.RawPointer<SerialConnection>, stop_bits:Int):Bool;

	@:native('set_serial_connection_flow_control')
	static function set_serial_connection_flow_control(connection:cpp.RawPointer<SerialConnection>, flow_control:Int):Bool;

	@:native('set_serial_connection_timeout')
	static function set_serial_connection_timeout(connection:cpp.RawPointer<SerialConnection>, timeout:Int):Bool;

	@:native('read_serial_connection')
	static function read_serial_connection(connection:cpp.RawPointer<SerialConnection>, data:cpp.RawPointer<cpp.UInt8>, size:cpp.SizeT):Int;

	@:native('read_byte_serial_connection')
	static function read_byte_serial_connection(connection:cpp.RawPointer<SerialConnection>, data:cpp.RawPointer<cpp.UInt8>):Int;

	@:native('read_until_serial_connection')
	static function read_until_serial_connection(connection:cpp.RawPointer<SerialConnection>, data:cpp.RawPointer<cpp.UInt8>, until:cpp.UInt8):Int;

	@:native('read_until_line_serial_connection')
	static function read_until_line_serial_connection(connection:cpp.RawPointer<SerialConnection>, data:cpp.RawPointer<cpp.UInt8>):Int;

	@:native('peek_serial_connection')
	static function peek_serial_connection(connection:cpp.RawPointer<SerialConnection>, data:cpp.RawPointer<cpp.UInt8>, size:cpp.SizeT):Int;

	@:native('has_available_data_serial_connection')
	static function has_available_data_serial_connection(connection:cpp.RawPointer<SerialConnection>):Bool;

	@:native('write_bytes_serial_connection')
	static function write_bytes_serial_connection(connection:cpp.RawPointer<SerialConnection>, data:cpp.RawPointer<cpp.UInt8>, size:cpp.SizeT):Int;

	@:native('write_byte_serial_connection')
	static function write_byte_serial_connection(connection:cpp.RawPointer<SerialConnection>, data:cpp.UInt8):Int;

	@:native('write_string_serial_connection')
	static function write_string_serial_connection(connection:cpp.RawPointer<SerialConnection>, data:cpp.ConstCharStar):Int;

	@:native('close_serial_connection')
	static function close_serial_connection(connection:cpp.RawPointer<SerialConnection>):Void;

	@:native('free_serial_connection')
	static function free_serial_connection(connection:cpp.RawPointer<SerialConnection>):Void;
}
