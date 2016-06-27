
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

class LocalSocketImpl : LocalSocket, ConnectedSocket, Reader, Writer, ReaderWriter
{
	public static LocalSocket create() {
		return(new LocalSocketImpl());
	}

	embed "java" {{{
		private android.net.LocalSocket socket = new android.net.LocalSocket();
		private android.net.LocalServerSocket lsocket = null;
	}}}

	~LocalSocketImpl() {
		close();
	}

	public int read(Buffer data) {
		int v = 0;
		if(data != null) {
			ptr jdata = data.get_pointer().get_native_pointer();
			embed "java" {{{
				try {
					java.io.InputStream ins = socket.getInputStream();
					v = ins.read(jdata, 0, jdata.length);
				}
				catch(Exception e) {
				}
			}}}
		}
		return(v);
	}

	public int write(Buffer data, int size) {
		int v = 0;
		if(data != null && size > 0) {
			ptr jdata = data.get_pointer().get_native_pointer();
			embed "java" {{{
				try {
					java.io.OutputStream ous = socket.getOutputStream();
					ous.write(jdata, 0, size);
					v = size;
				}
				catch(Exception e) {
				}
			}}}
		}
		return(v);
	}

	public void close() {
		embed "java" {{{
			try {
				socket.close();
				socket = null;
				lsocket = null;
			}
			catch(Exception e) {
			}
		}}}
	}

	public int get_remote_pid() {
		int v = 0;
		embed "java" {{{
			try {
				v = socket.getPeerCredentials().getPid();
			}
			catch(Exception e) {
			}
		}}}
		return(v);
	}

	public int get_remote_uid() {
		int v = 0;
		embed "java" {{{
			try {
				v = socket.getPeerCredentials().getUid();
			}
			catch(Exception e) {
			}
		}}}
		return(v);
	}

	public int get_remote_gid() {
		int v = 0;
		embed "java" {{{
			try {
				v = socket.getPeerCredentials().getGid();
			}
			catch(Exception e) {
			}
		}}}
		return(v);
	}

	public bool connect(String apath) {
		var path = apath;
		if(path == null) {
			return(false);
		}
		if(path.has_prefix("/") == false) {
			path = "/tmp/".append(apath);
		}
		strptr err = null;
		bool v = true;
		embed "java" {{{
			try {
				socket.close();
				socket = new android.net.LocalSocket();
				socket.connect(new android.net.LocalSocketAddress(path.to_strptr()));
			}
			catch(Exception e) {
				err = ""+e;
				v = false;
			}
		}}}
		if(err != null) {
			Log.error("Local socket connection to '%s' FAILED : %s".printf().add(path).add(String.for_strptr(err)));
		}
		return(v);
	}

	public bool listen(String apath) {
		if(apath == null) {
			return(false);
		}
		var path = apath;
		if(path.has_prefix("/") == false) {
			path = "/tmp/".append(apath);
		}
		bool v = true;
		strptr err = null;
		embed "java" {{{
			try {
				socket.close();
				socket = new android.net.LocalSocket();
				socket.bind(new android.net.LocalSocketAddress(path.to_strptr()));
			}
			catch(Exception e) {
				err = "\n\t"+e;
				v = false;
			}
			try {
				lsocket = new android.net.LocalServerSocket(socket.getFileDescriptor());
			}
			catch(Exception e) {
				err = err + "\n\t" +e;
				v = false;
			}
		}}}
		if(err != null) {
			Log.error("Failed to listen to local socket '%s': %s".printf().add(path).add(String.for_strptr(err)));
		}
		return(v);
	}

	public LocalSocket accept() {
		var v = new LocalSocketImpl();
		embed "java" {{{
			try {
				v.socket = lsocket.accept();
				if(v.socket == null) {
					return(null);
				}
			}
			catch(Exception e) {
				v = null;
			}
		}}}
		return(v);
	}
}

