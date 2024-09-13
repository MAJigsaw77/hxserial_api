package hxserial_api.externs;

#if !cpp
#error 'Serial API supports only C++ target platforms.'
#end
import hxserial_api.externs.Types;

/**
 * API for managing serial connections.
 * This class provides functions for opening, closing, and configuring serial connections.
 * It also includes methods for reading from and writing to the serial connection.
 */
@:buildXml('<include name="${haxelib:hxserial_api}/project/Build.xml" />')
@:include('serial_connection.hpp')
@:unreflective
extern class SerialConnectionAPI
{
	/**
	 * Opens a serial connection to the specified device.
	 *
	 * @param device A pointer to the `SerialDevice` structure representing
	 *               the device to connect to.
	 * @param connection A pointer to a pointer where the serial connection
	 *                    object will be stored. This should be a pointer to
	 *                    a pointer to `SerialConnection`.
	 * @return true if the connection was successfully opened, false otherwise.
	 */
	@:native('open_serial_connection')
	static function open_serial_connection(device:cpp.RawPointer<SerialDevice>, connection:cpp.RawPointer<cpp.RawPointer<SerialConnection>>):Bool;

	/**
	 * Closes the specified serial connection.
	 *
	 * @param connection A pointer to the `SerialConnection` object to be closed.
	 */
	@:native('close_serial_connection')
	static function close_serial_connection(connection:cpp.RawPointer<SerialConnection>):Void;

	/**
	 * Frees the memory allocated for the serial connection object.
	 *
	 * @param connection A pointer to the `SerialConnection` object to be freed.
	 */
	@:native('free_serial_connection')
	static function free_serial_connection(connection:cpp.RawPointer<SerialConnection>):Void;

	/**
	 * Sets the baud rate for the serial connection.
	 *
	 * @param connection A pointer to the `SerialConnection` object to configure.
	 * @param baud The baud rate to set (e.g., 9600, 115200).
	 * @return true if the baud rate was successfully set, false otherwise.
	 */
	@:native('set_serial_connection_baud')
	static function set_serial_connection_baud(connection:cpp.RawPointer<SerialConnection>, baud:Int):Bool;

	/**
	 * Sets the character size for the serial connection.
	 *
	 * @param connection A pointer to the `SerialConnection` object to configure.
	 * @param char_size The number of data bits (e.g., 7 or 8).
	 * @return true if the character size was successfully set, false otherwise.
	 */
	@:native('set_serial_connection_char_size')
	static function set_serial_connection_char_size(connection:cpp.RawPointer<SerialConnection>, char_size:Int):Bool;

	/**
	 * Sets the parity for the serial connection.
	 *
	 * @param connection A pointer to the `SerialConnection` object to configure.
	 * @param parity The parity setting (e.g., 0 for none, 1 for odd, 2 for even).
	 * @return true if the parity was successfully set, false otherwise.
	 */
	@:native('set_serial_connection_parity')
	static function set_serial_connection_parity(connection:cpp.RawPointer<SerialConnection>, parity:Int):Bool;

	/**
	 * Sets the stop bits for the serial connection.
	 *
	 * @param connection A pointer to the `SerialConnection` object to configure.
	 * @param stop_bits The number of stop bits (e.g., 1 or 2).
	 * @return true if the stop bits were successfully set, false otherwise.
	 */
	@:native('set_serial_connection_stop_bits')
	static function set_serial_connection_stop_bits(connection:cpp.RawPointer<SerialConnection>, stop_bits:Int):Bool;

	#if windows
	/**
	 * Sets the data bits for the serial connection.
	 *
	 * @param connection A pointer to the `SerialConnection` object to configure.
	 * @param data_bits The number of data bits (typically 5, 6, 7, or 8).
	 * @return true if the data bits were successfully set, false otherwise.
	 */
	@:native('set_serial_connection_data_bits')
	static function set_serial_connection_data_bits(connection:cpp.RawPointer<SerialConnection>, data_bits:Int):Bool;
	#end

	/**
	 * Sets the flow control for the serial connection.
	 *
	 * @param connection A pointer to the `SerialConnection` object to configure.
	 * @param flow_control The flow control setting (e.g., 0 for none, 1 for XON/XOFF, 2 for RTS/CTS).
	 * @return true if the flow control was successfully set, false otherwise.
	 */
	@:native('set_serial_connection_flow_control')
	static function set_serial_connection_flow_control(connection:cpp.RawPointer<SerialConnection>, flow_control:Int):Bool;

	/**
	 * Sets the timeout for read operations on the serial connection.
	 *
	 * @param connection A pointer to the `SerialConnection` object to configure.
	 * @param timeout The timeout value in milliseconds.
	 * @return true if the timeout was successfully set, false otherwise.
	 */
	@:native('set_serial_connection_timeout')
	static function set_serial_connection_timeout(connection:cpp.RawPointer<SerialConnection>, timeout:Int):Bool;

	/**
	 * Reads data from the serial connection.
	 *
	 * @param connection A pointer to the `SerialConnection` object to read from.
	 * @param data A pointer to the buffer where the read data will be stored.
	 * @param size The number of bytes to read.
	 * @return The number of bytes read, or -1 if an error occurred.
	 */
	@:native('read_serial_connection')
	static function read_serial_connection(connection:cpp.RawPointer<SerialConnection>, data:cpp.RawPointer<cpp.UInt8>, size:cpp.SizeT):Int;

	/**
	 * Reads a single byte from the serial connection.
	 *
	 * @param connection A pointer to the `SerialConnection` object to read from.
	 * @param data A pointer to the buffer where the read byte will be stored.
	 * @return The number of bytes read (should be 1) or -1 if an error occurred.
	 */
	@:native('read_byte_serial_connection')
	static function read_byte_serial_connection(connection:cpp.RawPointer<SerialConnection>, data:cpp.RawPointer<cpp.UInt8>):Int;

	/**
	 * Reads data from the serial connection until a specific byte is encountered.
	 *
	 * @param connection A pointer to the `SerialConnection` object to read from.
	 * @param data A pointer to the buffer where the read data will be stored.
	 * @param until The byte value to read until (e.g., newline character).
	 * @return The number of bytes read, or -1 if an error occurred.
	 */
	@:native('read_until_byte_serial_connection')
	static function read_until_byte_serial_connection(connection:cpp.RawPointer<SerialConnection>, data:cpp.RawPointer<cpp.UInt8>, until:cpp.UInt8):Int;

	/**
	 * Reads data from the serial connection until a specific string is encountered.
	 *
	 * @param connection A pointer to the `SerialConnection` object to read from.
	 * @param data A pointer to the buffer where the read data will be stored.
	 * @param until The string value to read until (e.g., a specific terminator).
	 * @return The number of bytes read, or -1 if an error occurred.
	 */
	@:native('read_until_string_serial_connection')
	static function read_until_string_serial_connection(connection:cpp.RawPointer<SerialConnection>, data:cpp.RawPointer<cpp.UInt8>,
		until:cpp.ConstCharStar):Int;

	/**
	 * Reads data from the serial connection until a newline character is encountered.
	 *
	 * @param connection A pointer to the `SerialConnection` object to read from.
	 * @param data A pointer to the buffer where the read data will be stored.
	 * @return The number of bytes read, or -1 if an error occurred.
	 */
	@:native('read_until_line_serial_connection')
	static function read_until_line_serial_connection(connection:cpp.RawPointer<SerialConnection>, data:cpp.RawPointer<cpp.UInt8>):Int;

	/**
	 * Checks if there is data available to read from the serial connection.
	 *
	 * @param connection A pointer to the `SerialConnection` object to check.
	 * @return true if data is available, false otherwise.
	 */
	@:native('has_available_data_serial_connection')
	static function has_available_data_serial_connection(connection:cpp.RawPointer<SerialConnection>):Bool;

	/**
	 * Writes data to the serial connection.
	 *
	 * @param connection A pointer to the `SerialConnection` object to write to.
	 * @param data A pointer to the buffer containing the data to write.
	 * @param size The number of bytes to write.
	 * @return The number of bytes written, or -1 if an error occurred.
	 */
	@:native('write_bytes_serial_connection')
	static function write_bytes_serial_connection(connection:cpp.RawPointer<SerialConnection>, data:cpp.RawPointer<cpp.UInt8>, size:cpp.SizeT):Int;

	/**
	 * Writes a single byte to the serial connection.
	 *
	 * @param connection A pointer to the `SerialConnection` object to write to.
	 * @param data The byte to write.
	 * @return The number of bytes written (should be 1) or -1 if an error occurred.
	 */
	@:native('write_byte_serial_connection')
	static function write_byte_serial_connection(connection:cpp.RawPointer<SerialConnection>, data:cpp.UInt8):Int;

	/**
	 * Writes a string to the serial connection.
	 *
	 * @param connection A pointer to the `SerialConnection` object to write to.
	 * @param data A pointer to the null-terminated string to write.
	 * @return The number of bytes written, or -1 if an error occurred.
	 */
	@:native('write_string_serial_connection')
	static function write_string_serial_connection(connection:cpp.RawPointer<SerialConnection>, data:cpp.ConstCharStar):Int;
}
