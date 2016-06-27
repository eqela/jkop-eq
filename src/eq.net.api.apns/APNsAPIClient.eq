
/*
 * This file is part of Jkop
 * Copyright (c) 2016 Job and Esther Technologies, Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

public class APNsAPIClient : LoggerObject
{
	public static APNsAPIClient for_certificate_and_key(File c, File k) {
		return(new APNsAPIClient().set_certificate(c).set_key(k));
	}

	property File certificate;
	property File key;
	String address;
	property int port = 2195;
	property bool production = false;
	ConnectedSocket socket;

	public APNsAPIClient set_address(String a) {
		address = a;
		return(this);
	}

	public String get_address() {
		if(String.is_empty(address) == false) {
			return(address);
		}
		if(production) {
			return("gateway.push.apple.com");
		}
		return("gateway.sandbox.push.apple.com");
	}

	bool connect() {
		if(socket != null) {
			socket.close();
			socket = null;
		}
		var address = get_address();
		if(String.is_empty(address)) {
			log_error("Empty address!");
			return(false);
		}
		var ip = DNSCache.resolve(address);
		if(String.is_empty(ip) == false) {
			address = ip;
		}
		log_debug("Connecting to `%s:%d'".printf().add(address).add(port));
		var tsocket = TCPSocket.for_address(address, port);
		if(tsocket == null) {
			log_error("Failed to connect to APNs");
			return(false);
		}
		var sslsocket = SSLSocket.for_client(tsocket, certificate, key, get_logger());
		if(sslsocket == null) {
			log_error("Failed to initiate SSL with APNs");
			return(false);
		}
		this.socket = sslsocket;
		log_debug("Successfully connected to APNs");
		return(true);
	}

	public bool send(APNsMessage message) {
		if(message == null) {
			return(false);
		}
		var buffer = message.to_buffer();
		if(buffer == null || buffer.get_size() < 1) {
			return(false);
		}
		if(socket == null) {
			connect();
		}
		if(socket == null) {
			log_debug("Cannot send APNsMessage: Failed to connect (1)");
			return(false);
		}
		var r = socket.write(buffer);
		if(r < buffer.get_size()) {
			log_debug("Failed to write APNsMessage to server, trying to reconnect ..");
			connect();
			if(socket == null) {
				log_debug("Cannot send APNsMessage: Failed to connect (2)");
				return(false);
			}
			r = socket.write(buffer);
			if(r < buffer.get_size()) {
				log_debug("Cannot send APNsMessage: Failed to send on second attempt.");
				return(false);
			}
		}
		return(true);
	}
}
