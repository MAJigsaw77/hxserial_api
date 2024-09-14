package hxserial_api;

import haxe.io.Bytes;
import haxe.io.BytesData;
import hxserial_api.externs.SerialConnectionAPI;
import hxserial_api.externs.Types;

enum abstract BaudRate(Int) from Int to Int
{
	var BAUD_1200 = 1200;
	var BAUD_1800 = 1800;
	var BAUD_2400 = 2400;
	var BAUD_4800 = 4800;
	var BAUD_9600 = 9600;
	var BAUD_19200 = 19200;
	var BAUD_38400 = 38400;
	var BAUD_57600 = 57600;
	var BAUD_115200 = 115200;
	var BAUD_230400 = 230400;
}

enum abstract CharSize(Int) from Int to Int
{
	var CHAR_SIZE_5 = 5;
	var CHAR_SIZE_6 = 6;
	var CHAR_SIZE_7 = 7;
	var CHAR_SIZE_8 = 8;
}

enum abstract Parity(Int) from Int to Int
{
	var NONE = 0;
	var ODD = 1;
	var EVEN = 2;
	var MARK = 3;
	var SPACE = 4;
}

enum abstract StopBits(Int) from Int to Int
{
	var STOP_BITS_1 = 1;
	var STOP_BITS_2 = 2;
}

enum abstract DataBits(Int) from Int to Int
{
	var DATA_BITS_5 = 5;
	var DATA_BITS_6 = 6;
	var DATA_BITS_7 = 7;
	var DATA_BITS_8 = 8;
}

enum abstract FlowControl(Int) from Int to Int
{
	var NONE = 0;
	var RTS_CTS = 1;
	var DSR_DTR = 2;
}

enum abstract Timeout(Int) from Int to Int
{
	var NONE = 0;
	var READ = 1;
	var WRITE = 2;
	var READ_WRITE = 3;
}

class Connection
{
	public var connected(get, never):Bool;
	public var baud(default, set):BaudRate;
	public var charSize(default, set):CharSize;
	public var parity(default, set):Parity;
	public var stopBits(default, set):StopBits;
	#if windows
	public var dataBits(default, set):DataBits;
	#end
	public var flowControl(default, set):FlowControl;
	public var timeout(default, set):Timeout;

	@:noCompletion
	private var connection:cpp.RawPointer<SerialConnection>;

	public function new(?device:Device):Void
	{
		if (device != null)
			open(device);
	}

	public function open(device:Device):Void
	{
		if (connection != null)
			close();

		connection = untyped __cpp__('nullptr');

		if (!SerialConnectionAPI.open_serial_connection(cpp.RawPointer.addressOf(device.device), cpp.RawPointer.addressOf(connection)))
			Sys.println('Failed to open connection.');
	}

	public function close():Void
	{
		SerialConnectionAPI.close_serial_connection(connection);
		SerialConnectionAPI.free_serial_connection(connection);
	}

	public function hasAvailableData():Int
	{
		return connection != null ? SerialConnectionAPI.has_available_data_serial_connection(connection) : 0;
	}

	public function writeBytes(data:Bytes):Int
	{
		if (data == null || data.length <= 0)
			return -1;

		final bytesData:BytesData = data.getData();

		if (bytesData == null || bytesData.length <= 0)
			return -1;

		return connection != null ? SerialConnectionAPI.write_bytes_serial_connection(connection, cpp.Pointer.ofArray(bytesData).constRaw,
			bytesData.length) : -1;
	}

	public function writeByte(data:UInt):Int
	{
		return connection != null ? SerialConnectionAPI.write_byte_serial_connection(connection, data) : -1;
	}

	public function writeString(data:String):Int
	{
		return connection != null ? SerialConnectionAPI.write_string_serial_connection(connection, data) : -1;
	}

	public function readByte():Int
	{
		final data:cpp.UInt8 = 0;

		if (connection != null)
			SerialConnectionAPI.read_serial_connection(connection, cpp.RawPointer.addressOf(data), 1);

		return data;
	}

	@:noCompletion
	private function get_connected():Bool
	{
		return connection != null;
	}

	@:noCompletion
	private function set_baud(value:BaudRate):BaudRate
	{
		if (connection != null && SerialConnectionAPI.set_serial_connection_baud(connection, value))
			return baud = value;

		return baud;
	}

	@:noCompletion
	private function set_charSize(value:CharSize):CharSize
	{
		if (connection != null && SerialConnectionAPI.set_serial_connection_char_size(connection, value))
			return charSize = value;

		return charSize;
	}

	@:noCompletion
	private function set_parity(value:Parity):Parity
	{
		if (connection != null && SerialConnectionAPI.set_serial_connection_parity(connection, value))
			return parity = value;

		return parity;
	}

	@:noCompletion
	private function set_stopBits(value:StopBits):StopBits
	{
		if (connection != null && SerialConnectionAPI.set_serial_connection_stop_bits(connection, value))
			return stopBits = value;

		return stopBits;
	}

	#if windows
	@:noCompletion
	private function set_dataBits(value:DataBits):DataBits
	{
		if (connection != null && SerialConnectionAPI.set_serial_connection_data_bits(connection, value))
			return dataBits = value;

		return dataBits;
	}
	#end

	@:noCompletion
	private function set_flowControl(value:FlowControl):FlowControl
	{
		if (connection != null && SerialConnectionAPI.set_serial_connection_flow_control(connection, value))
			return flowControl = value;

		return flowControl;
	}

	@:noCompletion
	private function set_timeout(value:Timeout):Timeout
	{
		if (connection != null && SerialConnectionAPI.set_serial_connection_timeout(connection, value))
			return timeout = value;

		return timeout;
	}
}
