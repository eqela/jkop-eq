
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

class FileImpl : FileAdapter
{
	public static File for_path(String path) {
		return(new FileImpl().set_path(Path.normalize_path(path)));
	}

	public static File for_temporary_directory() {
		return(for_path("/tmp"));
	}

	public static File for_current_directory() {
		strptr dp = null;
		embed "c" {{{
			char t[4096];
			dp = getcwd(t, 4096);
		}}}
		if(dp == null) {
			return(null);
		}
		var cwd = String.for_strptr(dp);
		if(cwd == null) {
			return(null);
		}
		if(cwd.has_prefix("/") == false) {
			return(null);
		}
		return(for_path(cwd));
	}

	public static File for_home_directory() {
		strptr home;
		embed "c" {{{
			home = getenv("HOME");
		}}}
		if(home == null) {
			return(null);
		}
		var hs = String.for_strptr(home);
		if(hs == null) {
			return(null);
		}
		if(hs.has_prefix("/") == false) {
			hs = "/";
		}
		return(for_path(hs));
	}

	static String get_app_directory_path() {
		IFDEF("target_darwin") {
			int r;
			embed "c" {{{
				char buffer[PATH_MAX];
				uint32_t bs = PATH_MAX;
				r = _NSGetExecutablePath(buffer, &bs);
			}}}
			if(r != 0) {
				Log.error("FAILED to _NSGetExecutablePath. Unable to find out the `/app' directory.");
				return(null);
			}
			strptr pp;
			embed "c" {{{
				char rp[PATH_MAX];
				pp = realpath(buffer, rp);
				if(pp == NULL) {
					pp = buffer;
				}
			}}}
			var path = String.for_strptr(pp).dup();
			var ss = path.rchr('/');
			if(ss >= 0) {
				path = path.substring(0, ss);
			}
			return(path);
		}
		ELSE IFDEF("target_linux") {
			strptr filepath;
			embed "c" {{{
				char file[4096];
				memset(file, 0, 4096);
				int rll = readlink("/proc/self/exe", file, 4095);
				if(rll > 0) {
					file[rll] = 0;
					filepath = file;
				}
			}}}
			if(filepath == null) {
				return(null);
			}
			var pp = String.for_strptr(filepath).dup();
			var ss = pp.rchr('/');
			if(ss >= 0) {
				pp = pp.substring(0, ss);
			}
			return(pp);
		}
		ELSE {
			var av0 = SystemEnvironment.get_env_var("_EQ_ARGV0");
			if(av0 != null && av0.get_length() > 0) {
				var dn = Path.dirname(Path.absolute_path(av0));
				if(dn != null && dn.has_prefix("/native")) {
					dn = dn.substring(7);
				}
				return(dn);
			}
			return(null);
		}
	}

	public static File for_app_directory() {
		var appp = get_app_directory_path();
		if(appp == null) {
			return(null);
		}
		return(for_path(appp));
	}

	embed "c" {{{
		#include <stdlib.h>
		#include <string.h>
		#include <errno.h>
		#include <unistd.h>
		#include <stdio.h>
		#include <sys/types.h>
		#include <sys/stat.h>
		#include <fcntl.h>
	}}}

	IFDEF("target_darwin") {
		embed "c" {{{
			#include <stdlib.h>
			#include <utime.h>
			#include <mach-o/dyld.h>
			#include <limits.h>
		}}}
	}

	property String path;
	String eqela_path;

	public File realpath() {
		var pp = path;
		if(pp == null) {
			return(this);
		}
		var pps = pp.to_strptr();
		if(pps == null) {
			return(this);
		}
		strptr r = null;
		embed {{{
			char tmp[PATH_MAX];
			r = realpath(pps, tmp);
		}}}
		if(r == null) {
			return(this);
		}
		return(File.for_native_path(String.for_strptr(r).dup()));
	}

	public String get_eqela_path() {
		if(path == null) {
			return(null);
		}
		if(eqela_path == null) {
			if(path.has_prefix("/")) {
				eqela_path = "/native".append(path);
			}
			else {
				eqela_path = "/native/".append(path);
			}
		}
		return(eqela_path);
	}

	public File entry(String name) {
		if(name == null) {
			return(this);
		}
		return(FileImpl.for_path("%s/%s".printf().add(path).add(name).to_string()));
	}

	public String to_string() {
		if(File.get_full_path_to_string() == false) {
			return(Path.basename(path));
		}
		return(path);
	}

	public File get_parent() {
		return(entry(".."));
	}

	class EntryIterator : Iterator
	{
		public static EntryIterator for_path(String path) {
			return(new EntryIterator().initialize(path));
		}

		private ptr dir = null;
		private String path = null;

		embed "c" {{{
			#include <sys/types.h>
			#include <dirent.h>
			#include <string.h>
		}}}

		~EntryIterator() {
			close();
		}

		void close() {
			if(dir == null) {
				return;
			}
			ptr dir = this.dir;
			embed "c" {{{
				closedir((DIR*)dir);
			}}}
			this.dir = null;
		}

		public EntryIterator initialize(String path) {
			if(path == null) {
				return(null);
			}
			var pp = path.to_strptr();
			if(pp == null) {
				return(null);
			}
			ptr dir;
			embed "c" {{{
				dir = (void*)opendir(pp);
			}}}
			if(dir == null) {
				return(null);
			}
			this.dir = dir;
			this.path = path;
			return(this);
		}

		public Object next() {
			if(dir == null) {
				return(null);
			}
			var dir = this.dir;
			strptr tptr = null;
			while(tptr == null) {
				embed "c" {{{
					struct dirent* ent = readdir((DIR*)dir);
					if(ent != (void*)0) {
						if(!strcmp(ent->d_name, ".") || !strcmp(ent->d_name, "..")) {
						}
						else {
							tptr = (char*)ent->d_name;
						}
					}
					else {
						break;
					}
				}}}
			}
			if(tptr == null) {
				return(null);
			}
			int tlen = 0;
			embed "c" {{{
				tlen = strlen(tptr);
				char* p = tptr;
			}}}
			var sb = StringBuffer.for_initial_size(path.get_length() + 1 + tlen + 1);
			sb.append(path);
			if(sb.count() == 1 && "/".equals(path)) {
			}
			else {
				sb.append_c('/');
			}
			int c;
			while(true) {
				embed "c" {{{
					c = *p;
					p++;
				}}}
				if(c < 1) {
					break;
				}
				sb.append_c(c);
			}
			return(FileImpl.for_path(sb.to_string()));
		}
	}

	public Iterator entries() {
		return(EntryIterator.for_path(path));
	}

	public bool remove() {
		if(path == null) {
			return(false);
		}
		bool v = false;
		var ps = path.to_strptr();
		int r = 0;
		embed "c" {{{
			r = unlink(ps);
		}}}
		if(r != 0) {
			return(false);
		}
		return(true);
	}

	public bool move(File dest, bool replace = true) {
		if(dest == null) {
			return(false);
		}
		if(dest.exists()) {
			if(replace == false) {
				return(false);
			}
			if(dest.delete_recursive() == false) {
				return(false);
			}
		}
		if(dest is FileImpl) {
			var nold = path;
			var nnew = ((FileImpl)dest).get_path();
			if(nold == null || nnew == null) {
				return(false);
			}
			if(nold.equals(nnew)) {
				return(false);
			}
			var nolds = nold.to_strptr();
			var nnews = nnew.to_strptr();
			if(nolds == null || nnews == null) {
				return(false);
			}
			int r;
			embed "c" {{{
				r = rename(nolds, nnews);
			}}}
			if(r != 0) {
				return(false);
			}
			return(true);
		}
		if(copy_to(dest) == false) {
			return(false);
		}
		if(delete_recursive() == false) {
			return(false);
		}
		return(true);
	}

	class FileReader : Reader, SizedReader, FileDescriptor, Seekable
	{
		public static FileReader for_path(String path) {
			var v = new FileReader();
			if(v.open(path) == false) {
				v = null;
			}
			return(v);
		}

		embed "c" {{{
			#include <unistd.h>
			#include <stdio.h>
			#include <sys/types.h>
			#include <sys/stat.h>
			#include <fcntl.h>
		}}}

		int fd = -1;
		int size = -1;
		String filename;

		~FileReader() {
			close();
		}

		public int get_size() {
			if(size < 0 && filename != null) {
				int sz = 0;
				var uuu = filename.to_strptr();
				embed "c" {{{
					struct stat st;
					int r = stat(uuu, &st);
					if(r == 0) {
						sz = (int)st.st_size;
					}
				}}}
				size = sz;
			}
			return(size);
		}

		public int get_fd() {
			return(fd);
		}

		public int read(Buffer buf) {
			if(buf == null) {
				return(0);
			}
			var ptr = buf.get_pointer();
			if(ptr == null) {
				return(0);
			}
			int v = 0;
			if(fd >= 0) {
				var np = ptr.get_native_pointer();
				var bs = buf.get_size();
				var fd = this.fd;
				embed "c" {{{
					v = read(fd, np, bs);
				}}}
			}
			return(v);
		}

		public void close(){
			if(fd >= 0) {
				var fd = this.fd;
				embed "c" {{{
					close(fd);
				}}}
			}
			fd = -1;
		}

		public bool open(String filename) {
			if(filename == null) {
				return(false);
			}
			bool v = false;
			int fd = 0;
			var uuu = filename.to_strptr();
			embed "c" {{{
				fd = open(uuu, O_RDONLY);
			}}}
			this.fd = fd;
			if(fd >= 0) {
				v = true;
			}
			this.filename = filename;
			return(v);
		}

		public bool seek_set(int n) {
			int fd = this.fd;
			int r;
			embed "c" {{{
				r = lseek(fd, n, SEEK_SET);
			}}}
			if(r < 0) {
				return(false);
			}
			return(true);
		}

		public int seek_current() {
			int v = 0;
			int fd = this.fd;
			embed "c" {{{
				v = (int)lseek(fd, 0, SEEK_CUR);
			}}}
			return(v);
		}
	}

	public SizedReader read() {
		return(FileReader.for_path(path));
	}

	class FileWriter : Writer, Seekable, FileDescriptor
	{
		public static FileWriter for_path(String path, bool append) {
			var v = new FileWriter();
			v.set_append(append);
			if(v.open(path) == false) {
				v = null;
			}
			return(v);
		}

		ptr fp = null;
		property bool append = false;

		embed "c" {{{
			#include <stdio.h>
		}}}

		~FileWriter() {
			var fp = this.fp;
			embed "c" {{{
				if(fp != ((void*)0)) {
					fclose((FILE*)fp);
				}
			}}}
			this.fp = null;
		}

		public int get_fd() {
			if(fp != null) {
				var fp = this.fp;
				embed "c" {{{
					return(fileno((FILE*)fp));
				}}}
			}
			return(-1);
		}

		public bool open(String filename) {
			if(filename == null) {
				return(false);
			}
			bool v = false;
			var fn = filename.to_strptr();
			if(fn == null) {
				return(false);
			}
			ptr fp = null;
			if(append) {
				embed "c" {{{
					fp = fopen(fn, "ab");
				}}}
			}
			else {
				embed "c" {{{
					fp = fopen(fn, "wb");
				}}}
			}
			this.fp = fp;
			if(fp != null) {
				v = true;
			}
			return(v);
		}

		public int write(Buffer buf, int size) {
			int v = 0;
			if(buf != null && fp != null) {
				var ptr = buf.get_pointer();
				if(ptr != null) {
					var fp = this.fp;
					var np = ptr.get_native_pointer();
					int sz;
					if(size < 0) {
						sz = buf.get_size();
					}
					else {
						sz = size;
					}
					embed "c" {{{
						v = write(fileno((FILE*)fp), np, sz);
					}}}
				}
			}
			return(v);
		}

		public bool seek_set(int n) {
			int r;
			var fp = this.fp;
			embed "c" {{{
				r = lseek(fileno((FILE*)fp), n, SEEK_SET);
			}}}
			if(r < 0) {
				return(false);
			}
			return(true);
		}

		public int seek_current() {
			int v = 0;
			var fp = this.fp;
			embed "c" {{{
				v = (int)lseek(fileno((FILE*)fp), 0, SEEK_CUR);
			}}}
			return(v);
		}
	}

	public Writer write() {
		return(FileWriter.for_path(path, false));
	}

	public Writer append() {
		return(FileWriter.for_path(path, true));
	}

	public bool set_mode(int mode) {
		if(path == null) {
			return(false);
		}
		var ps = path.to_strptr();
		if(ps == null) {
			return(false);
		}
		int r;
		embed "c" {{{
			r = chmod(ps, mode);
		}}}
		if(r != 0) {
			return(false);
		}
		return(true);
	}

	public bool set_owner_user(int uid) {
		if(path == null) {
			return(false);
		}
		var ps = path.to_strptr();
		if(ps == null) {
			return(false);
		}
		int r;
		embed "c" {{{
			r = chown(ps, uid, -1);
		}}}
		if(r != 0) {
			return(false);
		}
		return(true);
	}

	public bool set_owner_group(int gid) {
		if(path == null) {
			return(false);
		}
		var ps = path.to_strptr();
		if(ps == null) {
			return(false);
		}
		int r;
		embed "c" {{{
			r = chown(ps, -1, gid);
		}}}
		if(r != 0) {
			return(false);
		}
		return(true);
	}

	public FileInfo stat() {
		if(path == null) {
			return(new FileInfo());
		}
		var ps = path.to_strptr();
		if(ps == null) {
			return(new FileInfo());
		}
		int r;
		bool linkflag = false;
		embed "c" {{{
			struct stat st;
			r = lstat(ps, &st);
			int tt = (int)st.st_mode;
			if(r == 0 && (tt & S_IFMT) == S_IFLNK) {
				linkflag = 1;
				r = stat(ps, &st);
			}
		}}}
		if(r != 0) {
			return(new FileInfo());
		}
		var o = new FileInfo();
		o.set_islink(linkflag);
		int stmode;
		int stuid;
		int stgid;
		int stsize;
		int statime;
		int stmtime;
		bool exec = false;
		embed "c" {{{
			stmode = (int)st.st_mode;
			stuid = (int)st.st_uid;
			stgid = (int)st.st_gid;
			stsize = (int)st.st_size;
			statime = (int)st.st_atime;
			stmtime = (int)st.st_mtime;
		}}}
		embed "c" {{{
			if(stmode & S_IXUSR || stmode & S_IXGRP || stmode & S_IXOTH) {
				exec = 1;
			}
		}}}
		int tfile = FileInfo.FILE_TYPE_FILE;
		int tdir = FileInfo.FILE_TYPE_DIR;
		int type = 0;
		embed "c" {{{
			tt = stmode & S_IFMT;
			if(tt == S_IFREG) {
				type = tfile;
			}
			else if(tt == S_IFDIR) {
				type = tdir;
			}
			else {
				type = 3;
			}
		}}}
		o.set_type(type);
		o.set_mode(stmode);
		o.set_owner_user(stuid);
		o.set_owner_group(stgid);
		o.set_size(stsize);
		o.set_access_time(statime);
		o.set_modify_time(stmtime);
		o.set_executable(exec);
		return(o);
	}

	public bool create_fifo() {
		if(path == null) {
			return(false);
		}
		var ps = path.to_strptr();
		if(ps == null) {
			return(false);
		}
		int r = 1;
		IFNDEF("target_nacl") {
			embed "c" {{{
				r = mkfifo(ps, 0755);
			}}}
		}
		if(r != 0) {
			return(false);
		}
		return(true);
	}

	public bool create_directory() {
		if(path == null) {
			return(false);
		}
		var ps = path.to_strptr();
		if(ps == null) {
			return(false);
		}
		int r;
		embed "c" {{{
			r = mkdir(ps, 0755);
		}}}
		if(r != 0) {
			return(false);
		}
		return(true);
	}

	public bool remove_directory() {
		if(path == null) {
			return(false);
		}
		var ps = path.to_strptr();
		if(ps == null) {
			return(false);
		}
		int r;
		embed "c" {{{
			r = rmdir(ps);
		}}}
		if(r != 0) {
			return(false);
		}
		return(true);
	}

	public bool touch() {
		if(path == null) {
			return(false);
		}
		var ps = path.to_strptr();
		if(ps == null) {
			return(false);
		}
		if(is_file()) {
			int r = 0;
			embed "c" {{{
				r = utime(ps, NULL);
			}}}
			if(r != 0) {
				return(false);
			}
			return(true);
		}
		if(write() == null) {
			return(false);
		}
		return(true);
	}

	public File as_executable() {
		return(this);
	}

	public String get_native_path() {
		return(path);
	}

	public bool is_same(File af) {
		if(af == null || af is FileImpl == false) {
			return(false);
		}
		if(path == null) {
			if(((FileImpl)af).get_path() == null) {
				return(true);
			}
			return(false);
		}
		return(path.equals(((FileImpl)af).get_path()));
	}
}

