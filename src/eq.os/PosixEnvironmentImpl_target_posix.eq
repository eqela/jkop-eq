
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

class PosixEnvironmentImpl : PosixEnvironment
{
	embed {{{
		#include <unistd.h>
		#include <sys/types.h>
		#include <pwd.h>
	}}}

	public PosixUser getpwnam(String username) {
		if(username == null) {
			return(null);
		}
		var sp = username.to_strptr();
		if(sp == null) {
			return(null);
		}
		strptr _name = null, _gecos = null, _dir = null, _shell = null;
		int _uid, _gid;
		embed {{{
			struct passwd pwd;
			struct passwd *result = NULL;
			char buffer[8192 * 4];
			getpwnam_r(sp, &pwd, buffer, 8192*4, &result);
			if(result != NULL) {
				_name = result->pw_name;
				_gecos = result->pw_gecos;
				_dir = result->pw_dir;
				_shell = result->pw_shell;
				_uid = result->pw_uid;
				_gid = result->pw_gid;
			}
		}}}
		if(_name == null) {
			return(null);
		}
		var v = new PosixUser();
		v.set_pw_name(String.for_strptr(_name).dup());
		v.set_pw_uid(_uid);
		v.set_pw_gid(_gid);
		v.set_pw_gecos(String.for_strptr(_gecos).dup());
		v.set_pw_dir(String.for_strptr(_dir).dup());
		v.set_pw_shell(String.for_strptr(_shell).dup());
		return(v);
	}

	public PosixUser getpwuid(int uid) {
		strptr _name = null, _gecos = null, _dir = null, _shell = null;
		int _uid, _gid;
		embed {{{
			struct passwd pwd;
			struct passwd *result = NULL;
			char buffer[8192 * 4];
			getpwuid_r(uid, &pwd, buffer, 8192*4, &result);
			if(result != NULL) {
				_name = result->pw_name;
				_gecos = result->pw_gecos;
				_dir = result->pw_dir;
				_shell = result->pw_shell;
				_uid = result->pw_uid;
				_gid = result->pw_gid;
			}
		}}}
		if(_name == null) {
			return(null);
		}
		var v = new PosixUser();
		v.set_pw_name(String.for_strptr(_name).dup());
		v.set_pw_uid(_uid);
		v.set_pw_gid(_gid);
		v.set_pw_gecos(String.for_strptr(_gecos).dup());
		v.set_pw_dir(String.for_strptr(_dir).dup());
		v.set_pw_shell(String.for_strptr(_shell).dup());
		return(v);
	}

	public bool setuid(int uid) {
		var v = false;
		embed {{{
			if(setuid(uid) == 0) {
				v = 1;
			}
		}}}
		return(v);
	}

	public bool setgid(int gid) {
		var v = false;
		embed {{{
			if(setgid(gid) == 0) {
				v = 1;
			}
		}}}
		return(v);
	}

	public bool seteuid(int uid) {
		var v = false;
		embed {{{
			if(seteuid(uid) == 0) {
				v = 1;
			}
		}}}
		return(v);
	}

	public bool setegid(int gid) {
		var v = false;
		embed {{{
			if(setegid(gid) == 0) {
				v = 1;
			}
		}}}
		return(v);
	}

	public int getuid() {
		int v;
		embed {{{
			v = getuid();
		}}}
		return(v);
	}

	public int geteuid() {
		int v;
		embed {{{
			v = geteuid();
		}}}
		return(v);
	}

	public int getgid() {
		int v;
		embed {{{
			v = getgid();
		}}}
		return(v);
	}

	public int getegid() {
		int v;
		embed {{{
			v = getegid();
		}}}
		return(v);
	}
}
