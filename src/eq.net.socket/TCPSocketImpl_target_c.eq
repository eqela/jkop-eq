
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

class TCPSocketImpl : Reader, Writer, ReaderWriter, ConnectedSocket, TCPSocket, FileDescriptor, FileDescriptorSocket
{
	public static TCPSocket create() {
		return(new TCPSocketImpl());
	}

	IFDEF("target_win32") {
		embed "c" {{{
			#include <winsock2.h>
			#define socklen_t int
		}}}
	}
	ELSE {
		embed "c" {{{
			#include <unistd.h>
			#include <errno.h>
			#include <string.h>
			#include <sys/types.h>
			#include <sys/socket.h>
			#include <netinet/in.h>
			#include <arpa/inet.h>
			#include <errno.h>
			#include <fcntl.h>
		}}}
	}

	int fd = -1;
	bool blocking = true;

	~TCPSocketImpl() {
		close();
	}

	public void set_fd(int fd) {
		this.fd = fd;
	}

	public String get_remote_address() {
		int fd = this.fd;
		int r;
		embed "c" {{{
			socklen_t s = (socklen_t)sizeof(struct sockaddr_in);
			struct sockaddr_in new_addr;
			r = getpeername(fd, (struct sockaddr*)(&new_addr), &s);
		}}}
		if(r < 0) {
			return(null);
		}
		strptr adds = null;
		embed "c" {{{
			adds = (char*)inet_ntoa(new_addr.sin_addr);
		}}}
		return(String.for_strptr(adds).dup());
	}

	public int get_remote_port() {
		int fd = this.fd;
		int r;
		embed "c" {{{
			socklen_t s = (socklen_t)sizeof(struct sockaddr_in);
			struct sockaddr_in new_addr;
			r = getpeername(fd, (struct sockaddr*)(&new_addr), &s);
		}}}
		if(r < 0) {
			return(0);
		}
		int p;
		embed "c" {{{
			p = ntohs(new_addr.sin_port);
		}}}
		return(p);
	}

	public String get_local_address() {
		int fd = this.fd;
		int r;
		embed "c" {{{
			socklen_t s = (socklen_t)sizeof(struct sockaddr_in);
			struct sockaddr_in new_addr;
			r = getsockname(fd, (struct sockaddr*)(&new_addr), &s);
		}}}
		if(r < 0) {
			return(null);
		}
		strptr adds = null;
		embed "c" {{{
			adds = (char*)inet_ntoa(new_addr.sin_addr);
		}}}
		return(String.for_strptr(adds).dup());
	}

	public int get_local_port() {
		int fd = this.fd;
		int r;
		embed "c" {{{
			socklen_t s = (socklen_t)sizeof(struct sockaddr_in);
			struct sockaddr_in new_addr;
			r = getsockname(fd, (struct sockaddr*)(&new_addr), &s);
		}}}
		if(r < 0) {
			return(0);
		}
		int p;
		embed "c" {{{
			p = ntohs(new_addr.sin_port);
		}}}
		return(p);
	}

	public int get_fd() {
		return(fd);
	}

	public void close(){
		if(fd >= 0) {
			var fd = this.fd;
			IFDEF("target_win32") {
				embed "c" {{{
					closesocket(fd);
				}}}
				fd = -1;
			}
			ELSE {
				int r;
				embed "c" {{{
					r = close(fd);
				}}}
				if(r < 0) {
					strptr err;
					embed "c" {{{
						err = strerror(errno);
					}}}
					Log.error("FAILED to close socket fd %d: `%s'".printf().add(Primitive.for_integer(fd)).add(String.for_strptr(err)));
				}
				else {
					this.fd = -1;
				}
			}
		}
	}

	public bool set_blocking(bool block) {
		IFDEF("target_win32") {
			var fd1 = fd;
			embed {{{
				u_long mode = 1;
			}}}
			if(block) {
				embed {{{
					mode = 0;
				}}}
			}
			if(fd1 >= 0) {
				embed {{{
					ioctlsocket(fd1, FIONBIO, &mode);
				}}}
			}
			this.blocking = block;
			return(true);
		}
		ELSE {
			if(fd >= 0) {
				int fd1 = fd;
				if(block == false) {
					embed "c" {{{
						int f = fcntl(fd1, F_GETFL, 0);
						fcntl(fd1, F_SETFL, f | O_NONBLOCK);
					}}}
				}
				else {
					embed "c" {{{
						int f = fcntl(fd1, F_GETFL, 0);
						fcntl(fd1, F_SETFL, f & ~O_NONBLOCK);
					}}}
				}
			}
			this.blocking = block;
			return(true);
		}
	}

	public bool connect(String address, int port) {
		bool v = false;
		int fd;
		IFDEF("target_win32") {
			embed "c" {{{
				fd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
			}}}
		}
		ELSE {
			embed "c" {{{				
				fd = socket(AF_INET, SOCK_STREAM, 0);
			}}}
		}
		var aptr = address.to_strptr();
		strptr err = null;
		embed "c" {{{
			if(fd >= 0) {
				int sai_size = sizeof(struct sockaddr_in);
				struct sockaddr_in svr_addr;
				memset(&svr_addr, 0, sai_size);
				svr_addr.sin_family = AF_INET;
				svr_addr.sin_addr.s_addr = inet_addr(aptr);
				svr_addr.sin_port = htons(port);
				if(connect(fd, (struct sockaddr*)(&svr_addr), sai_size) != 0) {
					err = strerror(errno);
					if(err == NULL) {
						err = (char*)"Unknown error";
					}
				}
			}
		}}}
		if(err != null) {
			if(fd >= 0) {
				IFDEF("target_win32") {
					embed "c" {{{
						closesocket(fd);
					}}}
				}
				ELSE {
					embed "c" {{{
						close(fd);
					}}}
				}
			}
			fd = -1;
			Log.error("Socket connection to '%s:%d' FAILED: %s".printf()
				.add(address)
				.add(Primitive.for_integer(port))
				.add(String.for_strptr(err)));
		}
		else {
			this.fd = fd;
			v = true;
		}
		return(v);
	}

	public bool listen(int port) {
		bool v = false;
		int fd;
		IFDEF("target_win32") {
			embed "c" {{{
				fd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
			}}}
		}
		ELSE {
			embed "c" {{{		
				int reuseaddr = 1;	
				fd = socket(AF_INET, SOCK_STREAM, 0);
				setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, (const char*)&reuseaddr, sizeof(int));
			}}}
		}
		embed "c" {{{
			if(fd >= 0) {
				struct sockaddr_in addr;
				memset(&addr, 0, sizeof(struct sockaddr_in));
				addr.sin_family = AF_INET;
				addr.sin_port = htons(port);
				if(bind(fd, (struct sockaddr*)(&addr), sizeof(struct sockaddr_in)) >= 0) {
					if(listen(fd, 256) >= 0) {
						v = 1;
					}
				}
			}
		}}}
		if(v == false) {
			if(fd >= 0) {
				IFDEF("target_win32") {
					embed "c" {{{
						closesocket(fd);
					}}}
				}
				ELSE {
					embed "c" {{{
						close(fd);
					}}}
				}
				fd = -1;
			}
		}
		if(v) {
			this.fd = fd;
		}
		return(v);
	}

	public TCPSocket accept() {
		TCPSocketImpl v = null;
		if(fd >= 0) {
			var fd = this.fd;
			int newfd;
			embed "c" {{{
				newfd = accept(fd, NULL, NULL);
			}}}
			if(newfd >= 0) {
				v = new TCPSocketImpl();
				v.fd = newfd;
			}
		}
		return(v);
	}

	public int read(eq.api.Buffer buf) {
		if(buf == null) {
			return(0);
		}
		var ptr = buf.get_pointer();
		if(ptr == null) {
			return(0);
		}
		if(fd < 0) {
			return(-1);
		}
		int v;
		var fd = this.fd;
		var np = ptr.get_native_pointer();
		var sz = buf.get_size();
		IFDEF("target_win32") {
			embed "c" {{{
				v = recv(fd, (char*)np, sz, 0);
			}}}
		}
		ELSE {
			embed "c" {{{
				v = read(fd, np, sz);
			}}}
		}
		if(v == 0) {
			v = -1;
		}
		else if(v < 0 && blocking == false) {
			IFDEF("target_win32") {
				embed "c" {{{
					int err = WSAGetLastError();
					if(err == WSAEINTR || err == WSAEWOULDBLOCK) {
						v = 0;
					}
				}}}
			}
			ELSE {
				embed "c" {{{
					if(errno == EINTR || errno == EAGAIN || errno == EWOULDBLOCK) {
						v = 0;
					}
				}}}
			}
		}
		return(v);
	}

	public int write(eq.api.Buffer buf, int size) {
		if(buf == null) {
			return(0);
		}
		var ptr = buf.get_pointer();
		if(ptr == null) {
			return(0);
		}
		if(fd < 0) {
			return(-1);
		}
		int v = 0;
		int sz = size;
		if(sz < 0) {
			sz = buf.get_size();
		}
		if(fd>=0 && buf != null) {
			var np = ptr.get_native_pointer();
			var fd = this.fd;
			IFDEF("target_win32") {
				embed "c" {{{
					v = send(fd, (const char*)np, sz, 0);
				}}}
			}
			ELSE {
				embed "c" {{{
					v = write(fd, np, sz);
				}}}
			}
		}
		if(v < 0 && blocking == false) {
			IFDEF("target_win32") {
				embed "c" {{{
					int err = WSAGetLastError();
					if(err == WSAEINTR || err == WSAEWOULDBLOCK) {
						v = 0;
					}
				}}}
			}
			ELSE {
				embed "c" {{{
					if(errno == EINTR || errno == EAGAIN || errno == EWOULDBLOCK) {
						v = 0;
					}
				}}}
			}
		}
		return(v);
	}
}

