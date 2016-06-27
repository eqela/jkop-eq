
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

public class AndroidSSLSocket : LoggerObject, SSLSocket, Reader, Writer, ReaderWriter, ConnectedSocket, FileDescriptor, ConnectedSocketWrapper
{
	embed "java" {{{
		private javax.net.ssl.SSLSocket socket;
	}}}

	ConnectedSocket original = null;

	~AndroidSSLSocket() {
		close();
	}

	public ConnectedSocket get_original() {
		return(original);
	}

	public int get_fd() {
		var ofd = original as FileDescriptor;
		if(ofd == null) {
			return(-1);
		}
		return(ofd.get_fd());
	}

	public void close() {
		embed {{{
			try {
				socket.close();
			}
			catch(Exception e) {
			}
		}}}
	}

	public bool open(ConnectedSocket original, File certfile, File keyfile, bool server) {
		var ts = original as TCPSocketImpl;
		if(ts == null) {
			return(false);
		}
		var rm = ts.get_remote_address();
		int port = ts.get_remote_port();
		bool v = false;
		embed "java" {{{
			java.net.Socket jsocket = ts.get_native_socket();
			javax.net.ssl.SSLSocketFactory f = (javax.net.ssl.SSLSocketFactory) javax.net.ssl.SSLSocketFactory.getDefault();
			try {
				socket = (javax.net.ssl.SSLSocket) f.createSocket(jsocket, rm.to_strptr(), port, false);
				socket.startHandshake();
				v = true;
			}
			catch(Exception e) {
			}
		}}}
		if(v == false) {
			close();
		}
		else {
			this.original = original;
		}
		return(v);
	}

	public int read(Buffer buf) {
		if(buf == null) {
			return(-1);
		}
		var ptr = buf.get_pointer();
		if(ptr == null) {
			return(-1);
		}
		int v;
		var np = ptr.get_native_pointer();
		embed "java" {{{
			try {
				java.io.InputStream ins = socket.getInputStream();
				v = ins.read(np, 0, np.length);
			}
			catch(Exception e) {
			}
		}}}
		return(v);
	}

	public int write(Buffer buf, int asize) {
		var size = asize;
		if(buf == null) {
			return(-1);
		}
		var ptr = buf.get_pointer();
		if(ptr == null) {
			return(-1);
		}
		if(size < 0) {
			size = buf.get_size();
		}
		int v;
		var np = ptr.get_native_pointer();
		embed "java" {{{
			try {
				java.io.OutputStream ous = socket.getOutputStream();
				ous.write(np, 0, size);
				v = size;
			}
			catch(Exception e) {
			}
		}}}
		return(v);
	}
}
