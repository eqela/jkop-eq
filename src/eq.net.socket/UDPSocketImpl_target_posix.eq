
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

class UDPSocketImpl : UDPSocket, FileDescriptor
{
	private int fd = -1;

	public static UDPSocketImpl create() {
		return(new UDPSocketImpl());
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
			#include <sys/types.h>
			#include <sys/socket.h>
			#include <netinet/in.h>
			#include <string.h>
			#include <errno.h>
		}}}
	}

	IFDEF("target_qnx") {
		embed "c" {{{	
			#include <sys/select.h>
		}}}
	}

	IFDEF("target_darwin") {
		embed "c" {{{
			#include <arpa/inet.h>
		}}}
	}

	IFDEF("target_pnacl") {
		embed "c" {{{
			#include <sys/time.h>
		}}}
	}

	public UDPSocketImpl() {
		int fd;
		IFDEF("target_win32") {
			embed "c" {{{
				fd = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
			}}}
		}
		ELSE {
			embed "c" {{{
				fd = socket(PF_INET, SOCK_DGRAM, 0);
			}}}
		}
		this.fd = fd;
	}

	~UDPSocketImpl() {
		close();
	}

	public int get_fd() {
		return(fd);
	}

	public void close(){
		if(fd >= 0) {
			int fd = this.fd;
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
	}

	public int send(eq.api.Buffer message, String address, int port) {
		if(address == null) {
			return(-1);
		}
		if(message == null) {
			return(0);
		}
		var ptr = message.get_pointer();
		if(ptr == null) {
			return(0);
		}
		int len = 0;
		if(fd >= 0) {
			var ap = address.to_strptr();
			var fd = this.fd;
			var np = ptr.get_native_pointer();
			var sz = message.get_size();
			embed "c" {{{
				struct sockaddr_in server_addr;
				memset(&server_addr, 0, sizeof(struct sockaddr_in));
				server_addr.sin_family = AF_INET;
				server_addr.sin_addr.s_addr = inet_addr(ap);
				server_addr.sin_port = htons(port);
				len = sendto(fd, np, sz, 0, (struct sockaddr*)(&server_addr), sizeof(struct sockaddr_in));
			}}}
		}
		return(len);
	}

	public int send_broadcast(Buffer message, String address, int port) {
		int v = 0;
		int fd = this.fd;
		embed "c" {{{
			int flag = 1;
			setsockopt(fd, SOL_SOCKET, SO_BROADCAST, (void*)&flag, sizeof(int));
		}}}
		v = send(message, address, port);
		embed "c" {{{
			flag = 0;
			setsockopt(fd, SOL_SOCKET, SO_BROADCAST, (void*)&flag, sizeof(int));
		}}}
		return(v);
	}

	private bool wait_for_data(int timeout) {
		bool v = false;
		int fd = get_fd();
		if(fd < 0) {
			return(false);
		}
		embed "c" {{{
			fd_set fdset;
			FD_ZERO(&fdset);
			FD_SET(fd, &fdset);
		}}}
		int r = -1;
		if(timeout < 0) {
			embed "c" {{{ r = select(fd+1, &fdset, (void*)0, (void*)0, (void*)0); }}}
		}
		else {
			embed "c" {{{
				struct timeval tv;
				tv.tv_sec = timeout / 1000000;
				tv.tv_usec = timeout % 1000000;
				r = select(fd+1, &fdset, (void*)0, (void*)0, &tv);
			}}}
		}
		if(r > 0) {
			embed "c" {{{
				if(FD_ISSET(fd, &fdset) != 0) {
					v = 1;
				}
			}}}
		}
		if(r < 0) {
			strptr err = null;
			IFDEF("target_win32") {
				embed "c" {{{
					#define EINTR WSAEINTR
				}}}
			}
			embed "c" {{{
				if(errno != EINTR) {
					err = strerror(errno);
				}
			}}}
			if(err != null) {
				Log.error("Call to 'select()' returned error status %d: '%s'".printf().add(Primitive.for_integer(r)).add(String.for_strptr(err)));
			}
		}
		return(v);
	}

	public int receive(eq.api.Buffer message, int timeout) {
		if(message == null) {
			return(0);
		}
		var ptr = message.get_pointer();
		if(ptr == null) {
			return(0);
		}
		int len = 0;
		int fd = this.fd;
		if(fd >= 0) {
			if(wait_for_data(timeout)) {
				var np = ptr.get_native_pointer();
				var sz = message.get_size();
				embed "c" {{{
					socklen_t l = (socklen_t)sizeof(struct sockaddr_in);
					struct sockaddr_in client_addr;
					len = recvfrom(fd, np, sz, 0, (struct sockaddr*)(&client_addr), &l);
				}}}
			}
		}
		return(len);
	}

	public bool bind(int port) {
		bool v = false;
		int fd = this.fd;
		if(fd >= 0) {
			embed "c" {{{
				struct sockaddr_in server_addr;
				memset(&server_addr, 0, sizeof(struct sockaddr_in));
				server_addr.sin_family = AF_INET;
				server_addr.sin_addr.s_addr = htonl(INADDR_ANY);
				server_addr.sin_port = htons(port);
				int error = bind(fd, (struct sockaddr*)(&server_addr), sizeof(struct sockaddr_in));
				if(error >= 0) {
					v = 1;
				}
			}}}
		}
		if(v == false) {
			close();
		}
		return(v);
	}
}

