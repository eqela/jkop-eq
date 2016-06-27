
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

class LocalSocketImpl : Reader, Writer, ReaderWriter, ConnectedSocket, LocalSocket, FileDescriptor
{
	embed "c" {{{
		#include <unistd.h>
		#include <sys/types.h>
		#include <sys/socket.h>
		#include <string.h>
		#include <errno.h>
		#include <sys/un.h>
		#include <sys/stat.h>
		#if defined(LOCAL_PEERCRED) && !defined(SO_PEERCRED)
		#define SO_PEERCRED LOCAL_PEERCRED
		#endif
		#ifndef UNIX_PATH_MAX
		#ifdef __APPLE__
		#define UNIX_PATH_MAX 104
		#else
		#define UNIX_PATH_MAX 108
		#endif
		#endif
	}}}

	int fd = -1;
	String boundpath = null;

	public static LocalSocketImpl create() {
		return(new LocalSocketImpl());
	}

	public LocalSocketImpl() {
	}

	~LocalSocketImpl() {
		close();
	}

	public void close(){
		if(fd >= 0) {
			int fd = this.fd;
			embed "c" {{{
				close(fd);
			}}}
		}
		if(boundpath != null) {
			var bs = boundpath.to_strptr();
			embed "c" {{{
				unlink(bs);
			}}}
		}
		fd = -1;
		boundpath = null;
	}

	public int get_fd() {
		return(fd);
	}

	/* HACK: glibc requires -D_GNU_SOURCE for it to define struct ucred,
	   but that one will break many things in other ways. Thus there's no
	   way to glibc/uclibc -compatibly get that struct. We define it here
	   ourselves and hackery it to work with the getsockopts below.
	 */
	embed "c" {{{
		struct _my_ucred {
			int pid;
			int uid;
			int gid;
		};
	}}}

	public int get_remote_pid() {
		int v = -1;
		if(fd >= 0) {
			var fd = this.fd;
			IFDEF("target_qnx") {
				//FIXME
			}
			ELSE {
				embed "c" {{{
					struct _my_ucred ucred;
					socklen_t l = (socklen_t)sizeof(struct _my_ucred);
					if(getsockopt(fd, SOL_SOCKET, SO_PEERCRED, (void*)&ucred, &l) == 0) {
						v = ucred.pid;
					}
				}}}
			}
		}
		return(v);
	}

	public int get_remote_uid() {
		int v = -1;
		if(fd >= 0) {
			var fd = this.fd;
			IFDEF("target_qnx") {
				//FIXME
			}
			ELSE {
				embed "c" {{{
					struct _my_ucred ucred;
					socklen_t l = (socklen_t)sizeof(struct _my_ucred);
					if(getsockopt(fd, SOL_SOCKET, SO_PEERCRED, (void*)&ucred, &l) == 0) {
						v = ucred.uid;
					}
				}}}
			}
		}
		return(v);
	}

	public int get_remote_gid() {
		int v = -1;
		if(fd >= 0) {
			var fd = this.fd;
			IFDEF("target_qnx") {
				//FIXME
			}
			ELSE {
				embed "c" {{{
					struct _my_ucred ucred;
					socklen_t l = (socklen_t)sizeof(struct _my_ucred);
					if(getsockopt(fd, SOL_SOCKET, SO_PEERCRED, (void*)&ucred, &l) == 0) {
						v = ucred.gid;
					}
				}}}
			}
		}
		return(v);
	}

	public bool connect(String apath) {
		bool v = false;
		close();
		if(apath == null) {
			return(v);
		}
		var path = apath;
		if(path.has_prefix("/") == false) {
			path = "/tmp/".append(apath);
		}
		var fd = this.fd;
		int l = path.get_length();
		embed "c" {{{
			if(l > UNIX_PATH_MAX-1) {
				l = UNIX_PATH_MAX-1;
			}
		}}}
		var ps = path.to_strptr();
		strptr err = null;
		embed "c" {{{
			fd = socket(AF_UNIX, SOCK_STREAM, 0);
			if(fd >= 0) {
				int sai_size = sizeof(struct sockaddr_un);
				struct sockaddr_un svr_addr;
				memset(&svr_addr, 0, sai_size);
				svr_addr.sun_family = AF_UNIX;
				strncpy(svr_addr.sun_path, ps, l);
				svr_addr.sun_path[UNIX_PATH_MAX-1] = 0;
				if(connect(fd, (struct sockaddr*)(&svr_addr), sai_size) < 0) {
					err = strerror(errno);
				}
				else {
					v = 1;
				}
			}
		}}}
		this.fd = fd;
		if(err != null) {
			Log.debug("Local socket connection to '%s' FAILED: %s".printf().add(path).add(String.for_strptr(err)));
			close();
		}
		return(v);
	}

	public bool listen(String apath) {
		close();
		if(apath == null) {
			return(false);
		}
		var ff = File.for_native_path(apath, File.for_temporary_directory());
		if(ff == null) {
			return(false);
		}
		var npath = ff.get_native_path();
		if(npath == null) {
			return(false);
		}
		bool v = false;
		int l = (int)npath.get_length();
		embed "c" {{{
			if(l > UNIX_PATH_MAX-1) {
				l = UNIX_PATH_MAX-1;
			}
		}}}
		var ns = npath.to_strptr();
		if(ff.exists()) {
			Log.debug("Deleting existing local socket file '%s'".printf().add(ff).to_string());
			if(ff.remove() == false) {
				Log.error("Failed to remove file: `%s'".printf().add(ff));
			}
		}
		int fd;
		strptr err = null;
		embed "c" {{{
			fd = socket(AF_UNIX, SOCK_STREAM, 0);
			if(fd >= 0) {
				struct sockaddr_un addr;
				memset(&addr, 0, sizeof(struct sockaddr_un));
				addr.sun_family = AF_UNIX;
				strncpy(addr.sun_path, ns, l);
				addr.sun_path[UNIX_PATH_MAX-1] = 0;
				if(bind(fd, (struct sockaddr*)(&addr), sizeof(struct sockaddr_un)) != 0) {
					err = strerror(errno);
				}
				else if(listen(fd, 256) != 0) {
					err = strerror(errno);
				}
				else {
					v = 1;
				}
			}
		}}}
		this.fd = fd;
		if(err != null) {
			Log.debug("Failed to listen to local socket '%s': %s".printf().add(ff).add(String.for_strptr(err)));
		}
		if(v) {
			embed "c" {{{
				chmod(ns, S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH | S_IWOTH);
			}}}
			boundpath = npath;
		}
		if(v == false) {
			close();
		}
		return(v);
	}

	public LocalSocket accept() {
		LocalSocketImpl v = null;
		if(fd >= 0) {
			int newfd;
			var fd = this.fd;
			embed "c" {{{
				socklen_t s = (socklen_t)sizeof(struct sockaddr_un);
				struct sockaddr_un new_addr;
				newfd = accept(fd, (struct sockaddr*)(&new_addr), &s);
				if(newfd >= 0) {
					v = new_eq_net_localsocket_LocalSocketImpl();
				}
			}}}
			if(v != null) {
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
			return(0);
		}
		int r = 0;
		var np = ptr.get_native_pointer();
		var sz = buf.get_size();
		var fd = this.fd;
		embed "c" {{{
			r = read(fd, np, sz);
		}}}
		return(r);
	}

	public int write(eq.api.Buffer buf, int size) {
		if(buf == null) {
			return(0);
		}
		var ptr = buf.get_pointer();
		if(ptr == null) {
			return(0);
		}
		int v = 0;
		if(fd>=0 && buf != null) {
			int fd = this.fd;
			var np = ptr.get_native_pointer();
			embed "c" {{{
				v = write(fd, np, size);
			}}}
		}
		return(v);
	}
}

