package hxserial_api;

import haxe.io.Bytes;
import haxe.io.BytesData;
import hxserial_api.externs.SerialConnectionAPI;
import hxserial_api.externs.Types;

class Connection
{
	public var baud(default, set):Int = 0;
	public var char_size(default, set):Int = 0;
	public var parity(default, set):Int = 0;
	public var stop_bits(default, set):Int = 0;
	#if windows
	public var data_bits(default, set):Int = 0;
	#end
	public var flow_control(default, set):Int = 0;
	public var timeout(default, set):Int = 0;

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

		if (!SerialConnectionAPI.open_serial_connection(cpp.RawPointer.addressOf(device), cpp.RawPointer.addressOf(connection)))
			Sys.println('Failed to open connection.');
	}

	public function close():Void
	{
		SerialConnectionAPI.close_serial_connection(connection);
		SerialConnectionAPI.free_serial_connection(connection);
	}

	public function hasAvailableData():Int
	{
		return connection != null ? SerialConnectionAPI.has_available_data_serial_connection(connection) : -1;
	}

	public function writeBytes(data:Bytes):Int
	{
		if (data == null || data.length <= 0)
			return -1;

		final bytesData:BytesData = data.getData();

		if (bytesData == null || bytesData.length <= 0)
			return -1;

		return connection != null ? SerialConnectionAPI.write_bytes_serial_connection(connection, cpp.Pointer.ofArray(bytesData).constRaw, bytesData.length) : -1;
	}

	public function writeByte(data:UInt):Int
	{
		return connection != null ? SerialConnectionAPI.write_bytes_serial_connection(connection, data) : -1;
	}

	public function writeString(data:String):Int
	{
		return connection != null ? SerialConnectionAPI.write_bytes_serial_connection(connection, data) : -1;
	}

	@:noCompletion
	private function set_baud(value:Int):Int
	{
		if (connection != null && SerialConnectionAPI.set_serial_connection_baud(connection, value))
			return value;

		return baud;
	}

	@:noCompletion
	private function set_char_size(value:Int):Int
	{
		if (connection != null && SerialConnectionAPI.set_serial_connection_char_size(connection, value))
			return value;

		return char_size;
	}

	@:noCompletion
	private function set_parity(value:Int):Int
	{
		if (connection != null && SerialConnectionAPI.set_serial_connection_parity(connection, value))
			return value;

		return parity;
	}

	@:noCompletion
	private function set_stop_bits(value:Int):Int
	{
		if (connection != null && SerialConnectionAPI.set_serial_connection_stop_bits(connection, value))
			return value;

		return stop_bits;
	}

	#if windows
	@:noCompletion
	private function set_data_bits(value:Int):Int
	{
		if (connection != null && SerialConnectionAPI.set_serial_connection_data_bits(connection, value))
			return value;

		return data_bits;
	}
	#end

	@:noCompletion
	private function set_flow_control(value:Int):Int
	{
		if (connection != null && SerialConnectionAPI.set_serial_connection_flow_control(connection, value))
			return value;

		return flow_control;
	}

	@:noCompletion
	private function set_timeout(value:Int):Int
	{
		if (connection != null && SerialConnectionAPI.set_serial_connection_timeout(connection, value))
			return value;

		return timeout;
	}
}
