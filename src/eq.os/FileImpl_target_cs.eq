
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

IFDEF("target_winrtcs") {
}

ELSE {
class FileImpl : FileAdapter
{
	public static File for_path(String path) {
		strptr v;
		if(path != null) {
			v = path.to_strptr();
		}
		return(new FileImpl().set_complete_path(v));
	}

	public static File for_current_directory() {
		strptr v;
		embed {{{
			v = System.IO.Directory.GetCurrentDirectory();
		}}}
		return(new FileImpl().set_complete_path(v));
	}

	public static File for_app_directory() {
		strptr v;
		IFDEF("target_netcore") {
			; // FIXME?
		}
		ELSE {
			embed {{{
				v = System.AppDomain.CurrentDomain.BaseDirectory;
				// v = System.IO.Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase);
			}}}
		}
		return(new FileImpl().set_complete_path(v));
	}

	public static File for_home_directory() {
		strptr v = null;
		embed {{{
			var hd = System.Environment.GetEnvironmentVariable("HOMEDRIVE");
			if(hd != null) {
				var hp = System.Environment.GetEnvironmentVariable("HOMEPATH");
				if(hp != null) {
					v = hd + System.IO.Path.DirectorySeparatorChar + hp;
				}
			}
		}}}
		if(v == null) {
			embed {{{
				var h = System.Environment.GetEnvironmentVariable("HOME");
				if(h != null) {
					v = h;
				}
			}}}
		}
		IFNDEF("target_netcore") {
			if(v == null) {
				embed {{{
					v = System.Environment.GetFolderPath(System.Environment.SpecialFolder.UserProfile);
				}}}
			}
		}
		return(new FileImpl().set_complete_path(v));
	}

	public static File for_temporary_directory() {
		strptr v;
		embed {{{
			v = System.IO.Path.GetTempPath();
		}}}
		return(new FileImpl().set_complete_path(v));
	}

	strptr complete_path;

	public strptr get_complete_path() {
		return(complete_path);
	}

	public override File as_executable() {
		if(SystemEnvironment.is_os("windows")) {
			var fpath = get_native_path();
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
		}
		return(this);
	}

	public FileImpl set_complete_path(strptr cp) {
		var x = cp;
		embed {{{
			if(x == null || x.Length < 1) {
				complete_path = null;
			}
			else {
				string delim = new System.String(System.IO.Path.DirectorySeparatorChar, 1);
				while(x.EndsWith(delim) && x.Length > 1) {
					x = x.Substring(0, x.Length-1);
				}
				complete_path = System.IO.Path.GetFullPath(x);
			}
		}}}
		return(this);
	}

	public override String get_native_path() {
		if(complete_path == null) {
			return(null);
		}
		return(String.for_strptr(complete_path));
	}

	public override bool set_mode(int mode) {
		bool v = false;
		embed {{{
			if(complete_path != null && System.Type.GetType("Mono.Runtime") != null) {
				try {
					if(mode == 1) {
						System.IO.File.SetAttributes(complete_path, (System.IO.FileAttributes)((uint)System.IO.File.GetAttributes(complete_path) | 0x80000000));
					}
					else {
						System.IO.File.SetAttributes(complete_path, (System.IO.FileAttributes)((uint)System.IO.File.GetAttributes(complete_path) & ~0x80000000));
					}
					v = true;
				}
				catch(System.Exception e) {
				}
			}
		}}}
		return(v);
	}

	class MyFileInfo : FileInfo
	{
		public MyFileInfo() {
			set_mode(-1);
		}

		embed {{{
			bool isFileUnixExecutable(string filename) {
				if(filename == null || System.IO.File.Exists("/bin/sh") == false) {
					return(false);
				}
				bool v = false;
				try {
					var process = System.Diagnostics.Process.Start("/bin/sh", "-c 'if [ -x \"" + filename + "\" ]; then exit 0; else exit 1; fi'");
					if(process == null) {
						return(false);
					}
					process.WaitForExit();
					if(process.ExitCode == 0) {
						v = true;
					}
					process.Dispose();
					process = null;
				}
				catch(System.Exception e) {
					v = false;
				}
				return(v);
			}
		}}}

		public override int get_mode() {
			var v = base.get_mode();
			if(v >= 0) {
				return(v);
			}
			var file = get_file() as FileImpl;
			if(file == null) {
				return(0);
			}
			var fp = file.get_complete_path();
			if(fp == null) {
				return(0);
			}
			var r = 0;
			embed {{{
				if(isFileUnixExecutable(fp)) {
					r = 1;
				}
			}}}
			set_mode(r);
			return(r);
		}
	}

	public override FileInfo stat() {
		var v = new MyFileInfo();
		v.set_file(this);
		v.set_owner_user(0);
		v.set_owner_group(0);
		v.set_executable(true);
		v.set_islink(false);
		v.set_type(0); // unknown
		if(complete_path != null) {
			embed {{{
				try {
					var attrs = System.IO.File.GetAttributes(complete_path);
					if(attrs.HasFlag(System.IO.FileAttributes.Directory)) {
						v.set_type(2); // directory
					}
					else {
						v.set_type(1); // file
					}
				}
				catch(System.Exception e) {
				}
			}}}
			if(v.get_type() == 1) {
				embed {{{
					try {
						var dnfi = new System.IO.FileInfo(complete_path);
						v.set_size((int)dnfi.Length);
						v.set_access_time((int)dnfi.LastAccessTime.Subtract(new System.DateTime(1970, 1, 1)).TotalSeconds);
						v.set_modify_time((int)dnfi.LastWriteTime.Subtract(new System.DateTime(1970, 1, 1)).TotalSeconds);
					}
					catch(System.Exception e) {
					}
				}}}
			}
		}
		return(v);
	}

	public override File entry(String path) {
		if(path == null) {
			return(this);
		}
		var v = StringBuffer.create();
		v.append(String.for_strptr(complete_path));
		v.append_c(Path.get_path_delimiter());
		v.append(path);
		return(FileImpl.for_path(v.to_string()));
	}

	public override String determine_basename() {
		var path = get_native_path();
		if(path == null) {
			return(null);
		}
		var rs = path.rchr(Path.get_path_delimiter());
		if(rs < 0) {
			return(path);
		}
		return(path.substring(rs+1));
	}

	class MyIterator : Iterator
	{
		property strptr complete_path;

		embed {{{
			public System.Collections.IEnumerator it;
		}}}

		public Object next() {
			strptr str;
			embed {{{
				try {
					if(it == null) {
						return(null);
					}
					if(it.MoveNext() == false) {
						return(null);
					}
					str = it.Current as string;
					if(str == null) {
						return(null);
					}
					str = System.IO.Path.Combine(complete_path, str);
				}
				catch(System.Exception e) {
					return(null);
				}
			}}}
			return(new FileImpl().set_complete_path(str));
		}
	}

	public override Iterator entries() {
		if(complete_path == null) {
			return(null);
		}
		var v = new MyIterator();
		v.set_complete_path(complete_path);
		embed {{{
			try {
				System.Collections.IEnumerable cc = System.IO.Directory.EnumerateFileSystemEntries(
					complete_path);
				v.it = cc.GetEnumerator();
			}
			catch(System.Exception e) {
			}
		}}}
		return(v);
	}

	public override bool touch() {
		if(complete_path == null) {
			return(false);
		}
		bool v = true;
		embed {{{
			try {
				var fi = new System.IO.FileInfo(complete_path);
				if(fi.Exists) {
					System.IO.File.SetLastWriteTime(complete_path, System.DateTime.Now);
				}
				else {
					System.IO.File.Create(complete_path).Dispose();
				}
			}
			catch(System.Exception e) {
				// System.Console.WriteLine(e.ToString());
				v = false;
			}
		}}}
		return(v);
	}

	public override File get_parent() {
		strptr v;
		embed {{{
			if(complete_path != null) {
				var di = System.IO.Directory.GetParent(complete_path);
				if(di != null) {
					v = di.FullName;
				}
			}
			if(v == null) {
				v = complete_path;
			}
		}}}
		return(new FileImpl().set_complete_path(v));
	}

	public override bool create_directory() {
		bool v = false;
		embed {{{
			try {
				System.IO.Directory.CreateDirectory(complete_path);
				v = true;
			}
			catch(System.Exception e) {
				// System.Console.WriteLine(e.ToString());
				v = false;
			}
		}}}
		return(v);
	}

	public override bool mkdir_recursive() {
		return(create_directory());
	}

	class MyFileReader : SizedReader, Reader, ClosableReader
	{
		embed {{{
			System.IO.FileStream stream;
		}}}

		embed {{{
			public bool initialize(string file) {
				if(file == null) {
					return(false);
				}
				bool v = true;
				try {
					stream = System.IO.File.OpenRead(file);
				}
				catch(System.Exception e) {
					// System.Console.WriteLine(e.ToString());
					stream = null;
					v = false;
				}
				return(v);
			}
		}}}

		public int read(Buffer buffer) {
			if(buffer == null) {
				return(0);
			}
			var ptr = buffer.get_pointer().get_native_pointer();
			int sz = buffer.get_size(), v;
			embed {{{
				try {
					v = stream.Read(ptr, 0, sz);
				}
				catch(System.Exception e) {
					// System.Console.WriteLine(e.ToString());
					v = -1;
				}
			}}}
			return(v);
		}

		public int get_size() {
			int v;
			embed {{{
				v = (int)stream.Length;
			}}}
			return(v);
		}

		public void close() {
			embed {{{
				if(stream != null) {
					stream.Dispose();
					stream = null;
				}
			}}}
		}
	}

	public override SizedReader read() {
		MyFileReader v = new MyFileReader();
		embed {{{
			if(v.initialize(complete_path) == false) {
				v = null;
			}
		}}}
		return(v);
	}

	class MyFileWriter : Writer, ClosableWriter
	{
		property bool append;

		embed {{{
			System.IO.FileStream stream;
		}}}

		embed {{{
			public bool initialize(string file) {
				if(file == null) {
					return(false);
				}
				bool v = true;
				try {
					if(append) {
						stream = System.IO.File.Open(file, System.IO.FileMode.Append);
					}
					else {
						stream = System.IO.File.Open(file, System.IO.FileMode.Create);
					}
				}
				catch(System.Exception e) {
					// System.Console.WriteLine(e.ToString());
					stream = null;
					v = false;
				}
				return(v);
			}
		}}}

		public int write(Buffer buffer, int size) {
			if(buffer == null) {
				return(0);
			}
			var ptr = buffer.get_pointer().get_native_pointer();
			int sz = size;
			if(sz < 1) {
				sz = buffer.get_size();
			}
			embed {{{
				try {
					stream.Write(ptr, 0, sz);
					stream.Flush();
				}
				catch(System.Exception e) {
					// System.Console.WriteLine(e.ToString());
					sz = -1;
				}
			}}}
			return(sz);
		}

		public void close() {
			embed {{{
				if(stream != null) {
					stream.Dispose();
					stream = null;
				}
			}}}
		}
	}

	public override Writer write() {
		var v = new MyFileWriter();
		embed {{{
			if(v.initialize(complete_path) == false) {
				v = null;
			}
		}}}
		return(v);
	}

	public override Writer append() {
		var v = new MyFileWriter().set_append(true);
		embed {{{
			if(v.initialize(complete_path) == false) {
				v = null;
			}
		}}}
		return(v);
	}

	public override bool remove() {
		bool v = true;
		embed {{{
			try {
				System.IO.File.Delete(complete_path);
			}
			catch(System.IO.DirectoryNotFoundException e) {
				v = false;
			}
			catch(System.IO.FileNotFoundException e) {
				v = false;
			}
			catch(System.Exception e) {
				// System.Console.WriteLine(e.ToString());
				v = false;
			}
		}}}
		return(v);
	}

	public override bool remove_directory() {
		bool v = true;
		embed {{{
			try {
				System.IO.Directory.Delete(complete_path);
			}
			catch(System.IO.DirectoryNotFoundException e) {
				v = false;
			}
			catch(System.IO.FileNotFoundException e) {
				v = false;
			}
			catch(System.Exception e) {
				// System.Console.WriteLine(e.ToString());
				v = false;
			}
		}}}
		return(v);
	}

	public override bool move(File dest, bool replace) {
		if(dest == null) {
			return(false);
		}
		if(dest.exists()) {
			if(replace == false) {
				return(false);
			}
			dest.remove();
		}
		var destf = dest as FileImpl;
		if(destf == null) {
			return(false);
		}
		bool v = true;
		embed {{{
			try {
				System.IO.File.Move(get_complete_path(), destf.get_complete_path());
			}
			catch(System.Exception e) {
				// System.Console.WriteLine(e.ToString());
				v = false;
			}
		}}}
		return(v);
	}
}
}
