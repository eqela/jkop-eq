
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
	public static File for_path(String apath) {
		var path = apath;
		if(path != null && path.str("..") >= 0) {
			var pp = path;
			if(pp.has_prefix("/") == false) {
				pp = Path.from_native_notation(path);
			}
			if(pp!=null) {
				path = Path.normalize_path(pp);
			}
		}
		if(path != null && path.has_prefix("/")) {
			path = Path.to_native_notation(path);
		}
		return(new FileImpl().set_path(path));
	}

	public static File for_temporary_directory() {
	    String tmp_dir = null;
		strptr td;
		embed "c" {{{
			char path[MAX_PATH];
			if(GetTempPath(MAX_PATH, path) != 0) {
				td = path;
			}
		}}}
		if(td != null) {
			tmp_dir = String.for_strptr(td).dup();
		}
		else {
			tmp_dir = "c:\\windows\\temp";
		}
		return(for_path(tmp_dir));
	}

	public static File for_current_directory() {
		strptr dp = null;
		embed "c" {{{
			char t[4096];
			dp = getcwd(t, 4096);
		}}}
		if(dp == null) {
			return(new InvalidFile());
		}
		var cwd = String.for_strptr(dp).dup();
		if(cwd == null) {
			return(new InvalidFile());
		}
		return(for_path(cwd));
	}

	public static File for_home_directory() {
		strptr home;
		embed "c" {{{
			char path[MAX_PATH];
			if(SHGetFolderPath(NULL, CSIDL_PERSONAL, NULL, 0, path) == S_OK) {
				home = path;
			}
		}}}
		if(home == null) {
			return(new InvalidFile());
		}
		var hs = String.for_strptr(home).dup();
		if(hs == null) {
			return(new InvalidFile());
		}
		return(for_path(hs));
	}

	public static File for_app_directory() {
    	strptr p = null;
    	embed "c" {{{		    
    		char buffer[1024];
			if(GetModuleFileName(NULL, buffer, 1024) > 0) {	
				p = buffer;
			}
		}}}
		if(p == null) {
			return(null);
		}
		var ap = String.for_strptr(p).dup();
		if(ap == null) {
			return(null);
		}
		String dirname;
		if(ap != null) {
			var full = Path.from_native_notation(ap);
			dirname = Path.dirname(full);
		}
		return(for_path(dirname));
	}

	embed "c" {{{
		#include <shlobj.h>
		#include <stdlib.h>
		#include <errno.h>
		#include <utime.h>
		#include <unistd.h>
		#include <stdio.h>
		#include <sys/types.h>
		#include <sys/stat.h>
		#include <fcntl.h>
		#include <dirent.h>
		#include <direct.h>
		#include <string.h>
		#include <io.h>
	}}}

	property String path;
	String eqela_path;

	public String get_eqela_path() {
		if(path == null) {
			return(null);
		}
		if(eqela_path == null) {
			var native_eqela = Path.from_native_notation(path);
			if(native_eqela.has_prefix("/")) {
				eqela_path = "/native".append(native_eqela);
			}
			else {
				eqela_path = "/native/".append(native_eqela);
			}
		}
		return(eqela_path);
	}

	public File entry(String name) {
		if(name == null) {
			return(this);
		}
		var pe = "%s/%s".printf().add(path).add(name).to_string();
		pe = pe.replace_char('/', '\\');
		var pp = Path.from_native_notation(pe);
		if(pp != null) {
			pp = Path.normalize_path(pp);
		}
		return(FileImpl.for_path(pp));
	}

	public String to_string() {
		if(File.get_full_path_to_string() == false) {
			return(Path.basename(path));
		}
		return(path);
	}

	public File get_parent() {
		var pp = Path.from_native_notation(path);
		String np;
		if(pp != null) {
			np = Path.normalize_path(pp.append("/../"));
		}
		return(FileImpl.for_path(np));
	}

	class EntryIterator : Iterator
	{
		public static EntryIterator for_path(String path) {
			return(new EntryIterator().initialize(path));
		}

		private ptr dir = null;
		private String path = null;

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
			var apath = FileImpl.as_long_windows_filename(path);
			var pp = apath.to_strptr();
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
			if(sb.count() == 1 && "\\".equals(path)) {
			}
			else {
				sb.append_c('\\');
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
		var apath = FileImpl.as_long_windows_filename(path);
		var ps = apath.to_strptr();
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
			var anold = FileImpl.as_long_windows_filename(nold);
			var annew = FileImpl.as_long_windows_filename(nnew);
			var nolds = anold.to_strptr();
			var nnews = annew.to_strptr();
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
			v.filename = path;
			if(v.open() == false) {
				v = null;
			}
			return(v);
		}

		int fd = -1;
		int size = -1;
		String filename;

		~FileReader() {
			close();
		}

		public int get_size() {
			if(size < 0 && filename != null) {
				int sz = 0;
				var afilename = FileImpl.as_long_windows_filename(filename);
				var uuu = afilename.to_strptr();
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

		public bool open() {
			if(filename == null) {
				return(false);
			}
			bool v = false;
			int fd = 0;
			var afilename = FileImpl.as_long_windows_filename(filename);
			var uuu = afilename.to_strptr();
			embed "c" {{{
				fd = open(uuu, O_RDONLY | O_BINARY);
			}}}
			this.fd = fd;
			if(fd >= 0) {
				v = true;
			}
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
			var afilename = FileImpl.as_long_windows_filename(filename);
			var fn = afilename.to_strptr();
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

	public static String as_long_windows_filename(String fn) {
		if(fn == null) {
			return(null);
		}
		if(fn.chr('/') < 0) {
			return("\\\\?\\".append(fn));
		}
		var sb = StringBuffer.create();
		sb.append("\\\\?\\");
		var it = fn.iterate();
		int c;
		while((c = it.next_char()) > 0) {
			if(c == '/') {
				sb.append_c('\\');
			}
			else {
				sb.append_c(c);
			}
		}
		return(sb.to_string());
	}

	public FileInfo stat() {
		if(String.is_empty(path)) {
			return(new FileInfo());
		}
		int ftypefile = FileInfo.FILE_TYPE_FILE;
		int ftypedir = FileInfo.FILE_TYPE_DIR;
		var apath = FileImpl.as_long_windows_filename(path);
		var ps = apath.to_strptr();
		int r;
		var v = new FileInfo();
		int size;
		int atime;
		int mtime;
		int ftype = 0;
		embed "c" {{{
			HANDLE hfile = CreateFile((LPCTSTR)ps, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_FLAG_BACKUP_SEMANTICS, NULL);
			if(hfile != INVALID_HANDLE_VALUE) {
				FILETIME fctime, fatime, fmtime;
				LARGE_INTEGER fs;
				GetFileTime(hfile, &fctime, &fatime, &fmtime);
				atime = (int)(((((LONGLONG)(fatime.dwHighDateTime)) << 32) + fatime.dwLowDateTime - 116444736000000000) / 10000000);
				mtime = (int)(((((LONGLONG)(fmtime.dwHighDateTime)) << 32) + fmtime.dwLowDateTime - 116444736000000000) / 10000000);
				GetFileSizeEx(hfile, &fs);
				size = (int)fs.QuadPart;
				CloseHandle(hfile);
			}
			DWORD attributes = GetFileAttributes((LPCTSTR)ps);
			if(attributes == INVALID_FILE_ATTRIBUTES) {
				ftype = 0;
			}
			else if(attributes & FILE_ATTRIBUTE_DIRECTORY) {
				ftype = ftypedir;
			}
			else {
				ftype = ftypefile;
			}
		}}}
		if(path.has_suffix(".exe") || path.has_suffix(".bat") || path.has_suffix(".com")) {
			v.set_executable(true);
		}
		v.set_size(size);
		v.set_access_time(atime);
		v.set_modify_time(mtime);
		v.set_type(ftype);
		return(v);
	}

	public bool create_directory() {
		if(path == null) {
			return(false);
		}
		var apath = FileImpl.as_long_windows_filename(path);
		var ps = apath.to_strptr();
		if(ps == null) {
			return(false);
		}
		int r;
		embed "c" {{{
			r = mkdir(ps);
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
		var apath = FileImpl.as_long_windows_filename(path);
		var ps = apath.to_strptr();
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
		var apath = FileImpl.as_long_windows_filename(path);
		var ps = apath.to_strptr();
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
		var fpath = get_path();
		if(String.is_empty(fpath)) {
			return(this);
		}
		var exe = FileImpl.for_path(fpath.append(".exe"));
		if(exe.is_file()) {
			return(exe);
		}
		var com =  FileImpl.for_path(fpath.append(".com"));
		if(com.is_file()) {
			return(com);
		}
		var bat =  FileImpl.for_path(fpath.append(".bat"));
		if(bat.is_file()) {
			return(bat);
		}
		return(this);
	}

	public bool is_executable() {
		var v = stat();
		if(v != null) {
			return(v.get_executable());
		}
		return(false);
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
