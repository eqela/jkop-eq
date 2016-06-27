
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

IFDEF("target_ios") {
}

ELSE IFDEF("target_android") {
}

ELSE IFDEF("target_osx") {
}

ELSE IFDEF("target_linuxbuiltin") {

class OpenSSL
{
	embed "c" {{{
		#include <openssl/ssl.h>
	}}}

	static bool initialized = false;
	static Mutex mutex;

	public static void initialize() {
		if(initialized) {
			return;
		}
		Log.debug("Initializing OpenSSL library");
		if(mutex == null) {
			mutex = Mutex.create();
		}
		mutex.lock();
		embed "c" {{{
			SSL_load_error_strings();
			SSL_library_init();
		}}}
		mutex.unlock();
		initialized = true;
	}
}

public class OpenSSLSocket : LoggerObject, SSLSocket, Reader, Writer, ReaderWriter, ConnectedSocket, FileDescriptor, ConnectedSocketWrapper
{
	ConnectedSocket original = null;
	ptr ctx = null;
	ptr ssl = null;

	embed "c" {{{
		#include <openssl/ssl.h>
	}}}

	public OpenSSLSocket() {
		OpenSSL.initialize();
	}

	~OpenSSLSocket() {
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
		ptr ssl = this.ssl;
		if(ssl != null) {
			embed "c" {{{
				SSL_shutdown(ssl);
				SSL_free(ssl);
			}}}
			this.ssl = null;
		}
		ptr ctx = this.ctx;
		if(ctx!=null) {
			embed "c" {{{
				SSL_CTX_free(ctx);
			}}}
			this.ctx = null;
		}
		if(original != null) {
			original.close();
			original = null;
		}
	}

	public bool open(ConnectedSocket original, File certfile, File keyfile, bool server) {
		if(original as FileDescriptor == null) {
			return(false);
		}
		bool v = false;
		ptr meth;
		if(server) {
			embed "c" {{{
				meth = (void*)SSLv23_server_method();
			}}}
		}
		else {
			embed "c" {{{
				meth = (void*)SSLv23_client_method();
			}}}
		}
		if(meth != null) {
			ptr ctx;
			embed "c" {{{
				ctx = SSL_CTX_new(meth);
			}}}
			this.ctx = ctx;
			if(ctx != null) {
				if(certfile != null) {
					var pf = certfile.get_native_path();
					if(pf != null) {
						var pp = pf.to_strptr();
						embed {{{
							SSL_CTX_use_certificate_file(ctx, pp, SSL_FILETYPE_PEM);
						}}}
					}
				}
				if(keyfile != null) {
					var pf = keyfile.get_native_path();
					bool cv = false;
					if(pf != null) {
						var pp = pf.to_strptr();
						embed {{{
							SSL_CTX_use_PrivateKey_file(ctx, pp, SSL_FILETYPE_PEM);
							if(SSL_CTX_check_private_key(ctx)) {
								cv = 1;
							}
						}}}
					}
					if(cv == false) {
						log_error("Private key verification failed.");
						return(false);
					}
				}
				ptr ssl;
				embed "c" {{{
					ssl = SSL_new(ctx);
				}}}
				this.ssl = ssl;
				if(ssl != null) {
					int fdid = ((FileDescriptor)original).get_fd();
					embed "c" {{{
						SSL_set_fd(ssl, fdid);
					}}}
					int err;
					if(server) {
						embed "c" {{{
							SSL_set_accept_state(ssl);
							err = 0;
						}}}
					}
					else {
						embed "c" {{{
							err = SSL_connect(ssl);
						}}}
					}
					if(err < 0) {
						log_error("Failed to perform SSL handshake");
					}
					else {
						v = true;
					}
				}
			}
		}
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
		var sz = buf.get_size();
		ptr ssl = this.ssl;
		embed "c" {{{
			v = SSL_read(ssl, np, sz);
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
		ptr ssl = this.ssl;
		embed "c" {{{
			v = SSL_write(ssl, np, size);
		}}}
		return(v);
	}
}

}
