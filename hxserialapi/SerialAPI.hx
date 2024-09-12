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