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
	 * 230400 baud rate, only supported on linux and macos
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

	#if windows
	/**
	 * 16 bits per character, only supported on windows
	 */
	var CHAR_SIZE_16 = 16;
	#end
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
@:nullSafety
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
	@:nullSafety(Off)
	private var connection:cpp.RawPointer<SerialConnection>;

	/**
	 * Constructor for creating a new `Connection` instance. Optionally opens a connection
	 * to a specified serial `device`.
	 *
	 * @param device The serial device to connect to (optional).
	 */
	public function new(?device:Device, baud:BaudRate = BAUD_9600):Void
	{
		if (device != null)
			open(device, baud);
	}

	/**
	 * Opens a connection to the specified serial `device`.
	 *
	 * @param device The serial device to connect to.
	 */
	public function open(device:Device, baud:BaudRate = BAUD_9600):Void
	{
		if (connection != null)
			close();

		connection = untyped __cpp__('nullptr');

		final device:SerialDevice = device.device;

		if (!SerialConnectionAPI.open_serial_connection(cpp.RawPointer.addressOf(device), cpp.RawPointer.addressOf(connection), baud))
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

		// The .copy() is done so it doesn't break delete[].
		final readedData:BytesData = cpp.Pointer.fromRaw(data).toUnmanagedArray(size).copy();

		untyped __cpp__('delete[] {0}', data);

		return Bytes.ofData(readedData);
	}

	/**
	 * Reads a single byte from the serial connection.
	 *
	 * @return The read byte as an integer.
	 */
	public inline function readByte():Int
		return read(1).get(0);

	/**
	 * Reads a line of text from the serial connection.
	 *
	 * Precaution, the result doesn't contain the newline character.
	 * if you want to include it, then call readLine(true).
	 *
	 * @param includeNewline Whether to include the newline character in the result.
	 * @return The read line as a string.
	 */
	public function readLine(includeNewline:Bool = false):String
	{
		final buffer:StringBuf = new StringBuf();

		var c:Int = 0;

		// TODO: check if this ever returns -1
		while ((c = readByte()) != -1)
		{
			if (c == '\n'.code)
			{
				if (includeNewline)
					buffer.addChar(c);

				break;
			}

			if (c == '\r'.code)
			{
				c = readByte();

				if (c != '\n'.code || (c == '\n'.code && includeNewline))
				{
					buffer.addChar('\r'.code);

					if (c != '\n'.code || includeNewline)
						buffer.addChar(c);
				}

				if (c == -1 || c == '\n'.code)
					break;

				continue;
			}

			buffer.addChar(c);
		}

		return buffer.toString();
	}

	/**
	 * Reads a line of text from the serial connection until a specific byte is found.
	 *
	 * Precaution, the result doesn't contain the byte.
	 * if you want to include it, then call readUntilByte(byte, true).
	 *
	 * @param byte The byte to stop reading at.
	 * @return The read line as a string.
	 */
	public function readUntilByte(byte:Int, includeLast:Bool = false):String
	{
		final buffer:StringBuf = new StringBuf();

		var c:Int = 0;

		if (includeLast)
		{
			while ((c = readByte()) != -1)
			{
				if (c == byte)
					break;

				buffer.addChar(c);
			}
		}
		else
		{
			while ((c = readByte()) != -1)
			{
				buffer.addChar(c);

				if (c == byte)
					break;
			}
		}

		// not sure if we should use substr here, since it would be slower
		return buffer.toString();
	}

	/**
	 * Reads a line of text from the serial connection until a specific string is found.
	 *
	 * Precaution, the result doesn't contain the string that was searched for.
	 * if you want to include it, then call readUntilString(str, true).
	 *
	 * @param str The string to stop reading at.
	 * @return The read line as a string.
	 */
	public function readUntilString(str:String, includeLast:Bool = false):Null<String>
	{
		if (str == null || str.length == 0)
			return null;

		if (str != null && str.length == 1) // use readUntilByte if possible, since it's faster
		{
			final code:Null<Int> = str.charCodeAt(0);

			if (code != null)
				return readUntilByte(code);
			else
				return null;
		}

		final buffer:StringBuf = new StringBuf();
		final matchLength = str.length;

		var c:Int = 0;
		var matchIndex:Int = 0;

		while ((c = readByte()) != -1)
		{
			buffer.addChar(c);

			if (c == str.charCodeAt(matchIndex))
			{
				matchIndex++;

				if (matchIndex == matchLength)
					break;
			}
			else
				matchIndex = 0;
		}

		var res:String = buffer.toString();

		if (!includeLast)
			res = res.substr(0, res.length - matchLength);

		return res;
	}

	/**
	 * Checks if there is data available to read from the serial connection.
	 *
	 * @return The number of available bytes.
	 */
	public function hasAvailableData():Int
		return connection != null ? SerialConnectionAPI.has_available_data_serial_connection(connection) : 0;

	/**
	 * Writes a `Bytes` object to the serial connection.
	 *
	 * @param data The data to write.
	 * @return The number of bytes written.
	 */
	public function write(data:Bytes):Int
	{
		if (data == null || data.length <= 0)
			return -1;

		final bytesData:BytesData = data.getData();

		return connection != null ? SerialConnectionAPI.write_bytes_serial_connection(connection, cpp.Pointer.ofArray(bytesData).constRaw,
			bytesData.length) : -1;
	}

	/**
	 * Writes a single byte to the serial connection.
	 *
	 * @param data The byte to write.
	 * @return The result of the write operation.
	 */
	public inline function writeByte(data:Int):Int
	{
		final bytes:Bytes = Bytes.alloc(1);
		bytes.set(0, data);
		return write(bytes);
	}

	/**
	 * Writes a string to the serial connection.
	 *
	 * @param data The string to write.
	 * @return The result of the write operation.
	 */
	public inline function writeString(data:String):Int
		return write(Bytes.ofString(data));

	@:noCompletion
	private function get_connected():Bool
		return connection != null;

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
