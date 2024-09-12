package hxserialapi;

#if !cpp
#error "This file is only for cpp targets"
#end

import cpp.ConstCharStar;
import cpp.RawPointer;
import cpp.StdString;

@:buildXml('<include name="${haxelib:hxserialapi}/project/Build.xml" />')
@:include('serial_device.h')
@:native('SerialDevice')
@:structAccess
extern class SerialDevice {
	public var vid:cpp.UInt16;
	public var pid:cpp.UInt16;
	public var path:ConstCharStar;
}

@:buildXml('<include name="${haxelib:hxserialapi}/project/Build.xml" />')
@:include('serial_device.h')
extern class SerialAPI {
	@:native('get_serial_devices')
	public static function getSerialDevices(devices:RawPointer<RawPointer<SerialDevice>>, count:RawPointer<cpp.SizeT>):Bool;

	@:native('free_serial_devices')
	public static function freeSerialDevices(devices:RawPointer<SerialDevice>, count:cpp.UInt32):Void;
}

@:buildXml('<include name="${haxelib:hxserialapi}/project/Build.xml" />')
@:include('serial_connection.h')
extern class SerialConnection {
	public var path:ConstCharStar;
	public var baud:cpp.UInt32;
	public var char_size:cpp.UInt32;
	public var parity:cpp.UInt32;
	public var stop_bits:cpp.UInt32;
	public var flow_control:cpp.UInt32;
	public var timeout:cpp.UInt32;
	public var fd:cpp.Int32;
}

@:buildXml('<include name="${haxelib:hxserialapi}/project/Build.xml" />')
@:include('serial_connection.h')
extern class SerialConnectionAPI {
	@:native('open_serial_connection')
	public static function openSerialConnection(device:RawPointer<SerialDevice>, connection:RawPointer<RawPointer<SerialConnection>>):Bool;

	@:native('set_serial_connection_baud')
	public static function setSerialConnectionBaud(connection:RawPointer<SerialConnection>, baud:cpp.UInt32):Bool;

	@:native('set_serial_connection_char_size')
	public static function setSerialConnectionCharSize(connection:RawPointer<SerialConnection>, char_size:cpp.UInt32):Bool;

	@:native('set_serial_connection_parity')
	public static function setSerialConnectionParity(connection:RawPointer<SerialConnection>, parity:cpp.UInt32):Bool;

	@:native('set_serial_connection_stop_bits')
	public static function setSerialConnectionStopBits(connection:RawPointer<SerialConnection>, stop_bits:cpp.UInt32):Bool;

	@:native('set_serial_connection_flow_control')
	public static function setSerialConnectionFlowControl(connection:RawPointer<SerialConnection>, flow_control:cpp.UInt32):Bool;

	@:native('set_serial_connection_timeout')
	public static function setSerialConnectionTimeout(connection:RawPointer<SerialConnection>, timeout:cpp.UInt32):Bool;

	@:native('read_serial_connection')
	public static function readSerialConnection(connection:RawPointer<SerialConnection>, data:RawPointer<cpp.UInt8>, size:cpp.SizeT):cpp.Int32;

	@:native('read_byte_serial_connection')
	public static function readByteSerialConnection(connection:RawPointer<SerialConnection>, data:RawPointer<cpp.UInt8>):cpp.Int32;

	@:native('read_until_serial_connection')
	public static function readUntilSerialConnection(connection:RawPointer<SerialConnection>, data:RawPointer<cpp.UInt8>, until:cpp.UInt8):cpp.Int32;

	@:native('read_until_line_serial_connection')
	public static function readUntilLineSerialConnection(connection:RawPointer<SerialConnection>, data:RawPointer<cpp.UInt8>):cpp.Int32;

	@:native('peek_serial_connection')
	public static function peekSerialConnection(connection:RawPointer<SerialConnection>, data:RawPointer<cpp.UInt8>, size:cpp.SizeT):cpp.Int32;

	@:native('has_available_data_serial_connection')
	public static function hasAvailableDataSerialConnection(connection:RawPointer<SerialConnection>):Bool;

	@:native('write_bytes_serial_connection')
	public static function writeBytesSerialConnection(connection:RawPointer<SerialConnection>, data:RawPointer<cpp.UInt8>, size:cpp.SizeT):cpp.Int32;

	@:native('write_byte_serial_connection')
	public static function writeByteSerialConnection(connection:RawPointer<SerialConnection>, data:cpp.UInt8):cpp.Int32;

	@:native('write_string_serial_connection')
	public static function writeStringSerialConnection(connection:RawPointer<SerialConnection>, data:ConstCharStar):cpp.Int32;

	@:native('close_serial_connection')
	public static function closeSerialConnection(connection:RawPointer<SerialConnection>):Void;

	@:native('free_serial_connection')
	public static function freeSerialConnection(connection:RawPointer<SerialConnection>):Void;
}