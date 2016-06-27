
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

public interface TCPSocket : ConnectedSocket
{
	public static TCPSocket create(String address = null, int port = 0) {
		var v = TCPSocketImpl.create();
		if(String.is_empty(address) == false && port > 0) {
			if(v.connect(address, port) == false) {
				v = null;
			}
		}
		return(v);
	}

	public static TCPSocket for_address(String address, int port) {
		return(TCPSocket.create(address, port));
	}

	public static TCPSocket for_listen_port(int port) {
		var v = TCPSocket.create();
		if(v == null) {
			return(null);
		}
		if(v.listen(port) == false) {
			return(null);
		}
		return(v);
	}

	public String get_remote_address();
	public int get_remote_port();
	public String get_local_address();
	public int get_local_port();
	public bool connect(String address, int port);
	public bool listen(int port);
	public TCPSocket accept();
	public bool set_blocking(bool block);
}
