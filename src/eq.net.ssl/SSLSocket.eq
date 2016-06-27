
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

public interface SSLSocket : Reader, Writer, ReaderWriter, ConnectedSocket, ConnectedSocketWrapper
{
	static SSLSocket create_instance(ConnectedSocket ts, File certfile = null, File keyfile = null, Logger logger = null, bool server = false) {
		if(ts == null) {
			return(null);
		}
		SSLSocket v;
		IFDEF("target_apple") {
			var osl = new AppleSSLSocket();
			osl.set_logger(logger);
			if(osl.open(ts, certfile, keyfile, server)) {
				v = osl;
			}
		}
		ELSE IFDEF("target_android") {
			var osl = new AndroidSSLSocket();
			osl.set_logger(logger);
			if(osl.open(ts, certfile, keyfile, server)) {
				v = osl;
			}
		}
		ELSE IFDEF("target_linuxbuiltin") {
			var osl = new OpenSSLSocket();
			osl.set_logger(logger);
			if(osl.open(ts, certfile, keyfile, server)) {
				v = osl;
			}
		}
		return(v);
	}

	public static SSLSocket for_client(ConnectedSocket ts, File certfile = null, File keyfile = null, Logger logger = null) {
		return(create_instance(ts, certfile, keyfile, logger));
	}

	public static SSLSocket for_server(ConnectedSocket ts, File certfile, File keyfile, Logger logger = null) {
		return(create_instance(ts, certfile, keyfile, logger, true));
	}
}
