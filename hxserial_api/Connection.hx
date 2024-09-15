package hxserial_api;

import haxe.io.Bytes;
import haxe.io.BytesData;
import hxserial_api.externs.SerialConnectionAPI;
import hxserial_api.externs.Types;

/**
 * Enum abstract representing different baud rates used for serial communication.
 */
enum abstract BaudRate(Int) from Int to Int
{
	/**
	 * 1200 baud rate
	 */
	var BAUD_1200 = 1200;

	/**
	 * 1800 baud rate
	 */
	var BAUD_1800 = 1800;

	/**
	 * 2400 baud rate
	 */
	var BAUD_2400 = 2400;

	/**
	 * 4800 baud rate
	 */
	var BAUD_4800 = 4800;

	/**
	 * 9600 baud rate
	 */
	var BAUD_9600 = 9600;

	/**
	 * 19200 baud rate
	 */
	var BAUD_19200 = 19200;

	/**
	 * 38400 baud rate
	 */
	var BAUD_38400 = 38400;

	/**
	 * 57600 baud rate
	 */
	var BAUD_57600 = 57600;

	/**
	 * 115200 baud rate
	 */
	var BAUD_115200 = 115200;

	/**
	 * 230400 baud rate
	 */
	var BAUD_230400 = 230400;
}

/**
 * Enum abstract representing different character sizes for serial communication.
 */
enum abstract CharSize(Int) from Int to Int
{
	/**
	 * 5 bits per character
	 */
	var CHAR_SIZE_5 = 5;

	/**
	 * 6 bits per character
	 */
	var CHAR_SIZE_6 = 6;

	/**
	 * 7 bits per character
	 */
	var CHAR_SIZE_7 = 7;

	/**
	 * 8 bits per character
	 */
	var CHAR_SIZE_8 = 8;
}

/**
 * Enum abstract representing different parity settings for serial communication.
 */
enum abstract Parity(Int) from Int to Int
{
	/**
	 * No parity bit
	 */
	var NONE = 0;

	/**
	 * Odd parity bit
	 */
	var ODD = 1;

	/**
	 * Even parity bit
	 */
	var EVEN = 2;

	/**
	 * Mark parity bit
	 */
	var MARK = 3;

	/**
	 * Space parity bit
	 */
	var SPACE = 4;
}

/**
 * Enum abstract representing different stop bit configurations for serial communication.
 */
enum abstract StopBits(Int) from Int to Int
{
	/**
	 * 1 stop bit
	 */
	var STOP_BITS_1 = 1;

	/**
	 * 2 stop bits
	 */
	var STOP_BITS_2 = 2;
}

/**
 * Enum abstract representing different flow control settings for serial communication.
 */
enum abstract FlowControl(Int) from Int to Int
{
	/**
	 * No flow control
	 */
	var NONE = 0;

	/**
	 * RTS/CTS (Request to Send / Clear to Send) flow control
	 */
	var RTS_CTS = 1;

	/**
	 * DSR/DTR (Data Set Ready / Data Terminal Ready) flow control
	 */
	var DSR_DTR = 2;
}

/**
 * Enum abstract representing different timeout settings for serial communication.
 */
enum abstract Timeout(Int) from Int to Int
{
	/**
	 * No timeout
	 */
	var NONE = 0;

	/**
	 * Timeout for reading operations
	 */
	var READ = 1;

	/**
	 * Timeout for writing operations
	 */
	var WRITE = 2;

	/**
	 * Timeout for both reading and writing operations
	 */
	var READ_WRITE = 3;
}

/**
 * Class representing a serial connection that manages reading, writing, and configuring
 * serial communication settings such as baud rate, character size, parity, stop bits,
 * flow control, and timeouts.
 */
class Connection
{
	/**
	 * Indicates whether the connection is active.
	 */
	public var connected(get, never):Bool;

	/**
	 * The baud rate for the connection.
	 */
	public var baud(get, set):BaudRate;

	/**
	 * The character size for the connection.
	 */
	public var charSize(get, set):CharSize;

	/**
	 * The parity setting for the connection.
	 */
	public var parity(get, set):Parity;

	/**
	 * The stop bits setting for the connection.
	 */
	public var stopBits(get, set):StopBits;

	/**
	 * The flow control setting for the connection.
	 */
	public var flowControl(get, set):FlowControl;

	/**
	 * The timeout setting for the connection.
	 */
	public var timeout(get, set):Timeout;

	/**
	 * Internal pointer to the serial connection.
	 */
	@:noCompletion
	private var connection:cpp.RawPointer<SerialConnection>;

	/**
	 * Constructor for creating a new `Connection` instance. Optionally opens a connection
	 * to a specified serial `device`.
	 *
	 * @param device The serial device to connect to (optional).
	 */
	public function new(?device:Device):Void
	{
		if (device != null)
			open(device);
	}

	/**
	 * Opens a connection to the specified serial `device`.
	 *
	 * @param device The serial device to connect to.
	 */
	public function open(device:Device):Void
	{
		if (connection != null)
			close();

		connection = untyped __cpp__('nullptr');

		final device:SerialDevice = device.device;

		if (!SerialConnectionAPI.open_serial_connection(cpp.RawPointer.addressOf(device), cpp.RawPointer.addressOf(connection)))
			Sys.println('Failed to open connection.');
	}

	/**
	 * Closes the current serial connection.
	 */
	public function close():Void
	{
		SerialConnectionAPI.close_serial_connection(connection);
		SerialConnectionAPI.free_serial_connection(connection);
	}

	/**
	 * Reads a specified number of bytes from the serial connection.
	 *
	 * @param size The number of bytes to read.
	 * @return The read bytes as a `Bytes` object.
	 */
	public function read(size:Int):Bytes
	{
		final data:cpp.RawPointer<cpp.UInt8> = untyped __cpp__('new unsigned char[{0}]', size);

		if (connection != null)
			SerialConnectionAPI.read_serial_connection(connection, data, size);

		final readedData:BytesData = cpp.Pointer.fromRaw(data).toUnmanagedArray(size);

		untyped __cpp__('delete[] {0}', data);

		return Bytes.ofData(readedData);
	}

	/**
	 * Reads a single byte from the serial connection.
	 *
	 * @return The read byte as an unsigned integer.
	 */
	public function readByte():UInt
	{
		final data:cpp.UInt8 = 0;

		if (connection != null)
			SerialConnectionAPI.read_byte_serial_connection(connection, cpp.RawPointer.addressOf(data));

		return data;
	}

	/**
	 * Checks if there is data available to read from the serial connection.
	 *
	 * @return The number of available bytes.
	 */
	public function hasAvailableData():Int
	{
		return connection != null ? SerialConnectionAPI.has_available_data_serial_connection(connection) : 0;
	}

	/**
	 * Writes a `Bytes` object to the serial connection.
	 *
	 * @param data The data to write.
	 * @return The number of bytes written.
	 */
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

	/**
	 * Writes a single byte to the serial connection.
	 *
	 * @param data The byte to write.
	 * @return The result of the write operation.
	 */
	public function writeByte(data:UInt):Int
	{
		return connection != null ? SerialConnectionAPI.write_byte_serial_connection(connection, data) : -1;
	}

	/**
	 * Writes a string to the serial connection.
	 *
	 * @param data The string to write.
	 * @return The result of the write operation.
	 */
	public function writeString(data:String):Int
	{
		return connection != null ? SerialConnectionAPI.write_string_serial_connection(connection, data) : -1;
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
			return value;

		return baud;
	}

	@:noCompletion
	private function get_baud():BaudRate
	{
		if (connection != null)
			return connection[0].baud;

		return 0;
	}

	@:noCompletion
	private function set_charSize(value:CharSize):CharSize
	{
		if (connection != null && SerialConnectionAPI.set_serial_connection_char_size(connection, value))
			return value;

		return charSize;
	}

	@:noCompletion
	private function get_charSize():CharSize
	{
		if (connection != null)
			return connection[0].char_size;

		return 0;
	}

	@:noCompletion
	private function set_parity(value:Parity):Parity
	{
		if (connection != null && SerialConnectionAPI.set_serial_connection_parity(connection, value))
			return value;

		return parity;
	}

	@:noCompletion
	private function get_parity():Parity
	{
		if (connection != null)
			return connection[0].parity;

		return 0;
	}

	@:noCompletion
	private function set_stopBits(value:StopBits):StopBits
	{
		if (connection != null && SerialConnectionAPI.set_serial_connection_stop_bits(connection, value))
			return value;

		return stopBits;
	}

	@:noCompletion
	private function get_stopBits():StopBits
	{
		if (connection != null)
			return connection[0].stop_bits;

		return 0;
	}

	@:noCompletion
	private function set_flowControl(value:FlowControl):FlowControl
	{
		if (connection != null && SerialConnectionAPI.set_serial_connection_flow_control(connection, value))
			return value;

		return flowControl;
	}

	@:noCompletion
	private function get_flowControl():FlowControl
	{
		if (connection != null)
			return connection[0].flow_control;

		return 0;
	}

	@:noCompletion
	private function set_timeout(value:Timeout):Timeout
	{
		if (connection != null && SerialConnectionAPI.set_serial_connection_timeout(connection, value))
			return value;

		return timeout;
	}

	@:noCompletion
	private function get_timeout():Timeout
	{
		if (connection != null)
			return connection[0].timeout;

		return 0;
	}
}
