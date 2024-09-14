package hxserial_api;

import hxserial_api.externs.SerialConnectionAPI;
import hxserial_api.externs.SerialDeviceAPI;
import hxserial_api.externs.Types;

class Serial
{
	public static inline final FLOW_CONTROL_NONE = 0;
	public static inline final FLOW_CONTROL_RTS_CTS = 1;
	public static inline final FLOW_CONTROL_DSR_DTR = 2;

	public static inline final STOP_BITS_1 = 1;
	public static inline final STOP_BITS_2 = 2;

	public static inline final PARITY_NONE = 0;
	public static inline final PARITY_ODD = 1;
	public static inline final PARITY_EVEN = 2;
	public static inline final PARITY_MARK = 3;
	public static inline final PARITY_SPACE = 4;

	public static inline final BAUD_1200 = 1200;
	public static inline final BAUD_1800 = 1800;
	public static inline final BAUD_2400 = 2400;
	public static inline final BAUD_4800 = 4800;
	public static inline final BAUD_9600 = 9600;
	public static inline final BAUD_19200 = 19200;
	public static inline final BAUD_38400 = 38400;
	public static inline final BAUD_57600 = 57600;
	public static inline final BAUD_115200 = 115200;
	public static inline final BAUD_230400 = 230400;

	public static inline final CHAR_SIZE_5 = 5;
	public static inline final CHAR_SIZE_6 = 6;
	public static inline final CHAR_SIZE_7 = 7;
	public static inline final CHAR_SIZE_8 = 8;

	public static inline final TIMEOUT_NONE = 0;
	public static inline final TIMEOUT_READ = 1;
	public static inline final TIMEOUT_WRITE = 2;
	public static inline final TIMEOUT_READ_WRITE = 3;

	var connection:cpp.RawPointer<SerialConnection>;
	var device:Device;

	public var connected(default, null):Bool = false;

	public function new(device:Device)
	{
		this.connection = untyped __cpp__('nullptr');
		this.device = device;
		open();
	}

	public function open():Bool
	{
		connected = SerialConnectionAPI.open_serial_connection(cpp.RawPointer.addressOf(this.device.device), null);
		return connected;
	}

	public function close():Void
	{
		SerialConnectionAPI.close_serial_connection(this.connection);
	}

	public function setBaud(baud:Int):Bool
	{
		return SerialConnectionAPI.set_serial_connection_baud(this.connection, baud);
	}

	public function setCharSize(charSize:Int):Bool
	{
		return SerialConnectionAPI.set_serial_connection_char_size(this.connection, charSize);
	}

	public function setParity(parity:Int):Bool
	{
		return SerialConnectionAPI.set_serial_connection_parity(this.connection, parity);
	}

	public function setStopBits(stopBits:Int):Bool
	{
		return SerialConnectionAPI.set_serial_connection_stop_bits(this.connection, stopBits);
	}

	#if windows
	public function setDataBits(dataBits:Int):Bool
	{
		return SerialConnectionAPI.set_serial_connection_data_bits(this.connection, dataBits);
	}
	#end

	public function setFlowControl(flowControl:Int):Bool
	{
		return SerialConnectionAPI.set_serial_connection_flow_control(this.connection, flowControl);
	}

	public function setTimeout(timeout:Int):Bool
	{
		return SerialConnectionAPI.set_serial_connection_timeout(this.connection, timeout);
	}

	public function readByte():Int
	{
		final data:cpp.UInt8 = 0;
		SerialConnectionAPI.read_serial_connection(this.connection, cpp.RawPointer.addressOf(data), 1);
		return cast data;
	}

	public function readUntilByte(until:Int):String
	{
		if (until < 0 || until > 255)
			return "";
		// TODO: Implement
		return "";
	}

	public function readUntilString(until:String):String
	{
		// TODO: Implement
		return "";
	}

	public function readUntilLine():String
	{
		// TODO: Implement
		return "";
	}

	public function hasAvailableData():Bool
	{
		return SerialConnectionAPI.has_available_data_serial_connection(this.connection);
	}

	public function writeBytes(data:String):Int
	{
		var length = data.length;
		var data:cpp.RawPointer<cpp.UInt8> = cast data;
		return SerialConnectionAPI.write_bytes_serial_connection(this.connection, data, length);
	}

	public function writeByte(data:Int):Int
	{
		return SerialConnectionAPI.write_byte_serial_connection(this.connection, data);
	}

	public function writeString(data:String):Int
	{
		var data:cpp.ConstCharStar = cast data;
		return SerialConnectionAPI.write_string_serial_connection(this.connection, data);
	}
}
