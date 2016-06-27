
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
	embed {{{
		java.lang.String path;
	}}}

	public static File for_current_directory() {
		return(null);
	}

	public static File for_path(String path) {
		if(String.is_empty(path)) {
			return(null);
		}
		var v = new FileImpl();
		embed {{{
			v.path = path.to_strptr();
		}}}
		return(v);
	}

	public static File for_app_directory() {
		var v = new FileImpl();
		embed {{{
			android.content.Context ctx = eq.api.Android.context;
			android.content.pm.PackageManager pkm = ctx.getPackageManager();
			java.lang.String pkn = ctx.getPackageName();
			try {
				android.content.pm.PackageInfo pki = pkm.getPackageInfo(pkn, 0);
				v.path = pki.applicationInfo.dataDir;
			}
			catch(android.content.pm.PackageManager.NameNotFoundException e) {
				v = null;
			}
		}}}
		return(v);
	}

	public static File for_home_directory() {
		var v = new FileImpl();
		embed {{{
			v.path =  eq.api.Android.context.getFilesDir().getPath();
		}}}
		return(v);
	}

	public static File for_temporary_directory() {
		var v = new FileImpl();
		embed {{{
			v.path = eq.api.Android.context.getCacheDir().getPath();
			
		}}}
		return(v);
	}

	public String get_native_path() {
		embed {{{
			if(path != null) {
				return(eq.api.String.Static.for_strptr(path));
			}
		}}}
		return(null);
	}

	public String get_eqela_path() {
		return("/native".append(get_native_path()));
	}

	public String to_string() {
		return(get_native_path());
	}

	public FileInfo stat() {
		var v = new FileInfo();
		embed {{{
			java.io.File f = new java.io.File(path);
			if(f.exists() == false) {
				return(v);
			}
			v.set_size((int)f.length());
			v.set_modify_time((int)f.lastModified());
			if(f.isDirectory()) {
				v.set_type(FileInfo.Static.FILE_TYPE_DIR);
			}
			else if(f.isFile()) {
				v.set_type(FileInfo.Static.FILE_TYPE_FILE);
			}
		}}}
		return(v);
	}

	public File entry(String name) {
		if(String.is_empty(name)) {
			return(this);
		}
		var v = new FileImpl();
		embed {{{
			v.path = path + "/" + name.to_strptr();
		}}}
		return(v);
	}

	public Iterator entries() {
		var v = Array.create();
		embed {{{
			System.out.println("Entry: " + path);
			java.io.File f = new java.io.File(path);
			String[] str = f.list();
			if(str != null) {
				for(String path : str) {
					FileImpl file = new FileImpl();
					file.path = this.path + "/" + path;
					((eq.api.Collection)v).append((eq.api.Object)file);
				}
			}
		}}}
		return(v.iterate());
	}

	public bool touch() {
		bool v;
		embed {{{
			System.out.println("Touches: " + path);
			java.io.File f = new java.io.File(path);
			try {
				v = f.createNewFile();
			}
			catch(java.io.IOException e) {
				System.out.printf("Touch: `%s' : `%s'\n", e.getMessage(), path);	
			}
		}}}
		return( v);
	}

	public File get_parent() {
		embed {{{
			java.io.File f = new java.io.File(path);
			String ppath = f.getParent();
			if(ppath != null) {
				FileImpl v = new FileImpl();
				v.path = ppath;
				return(v);
			}
		}}}
		return(null);
	}

	public bool create_directory() {
		bool v;
		embed {{{
			java.io.File f = new java.io.File(path);
			v = f.mkdir();
		}}}
		return(v);
	}

	public bool mkdir_recursive() {
		bool v;
		embed {{{
			java.io.File f = new java.io.File(path);
			v = f.mkdirs();
		}}}
		return(v);
	}

	class MyFileReader : SizedReader, Reader
	{
		embed {{{
			java.io.FileInputStream stream;
			java.io.File file;
		}}}
		public MyFileReader initialize() {
			embed {{{
				if(file != null) {
					try {
						stream = new java.io.FileInputStream(file);
					}
					catch(java.io.FileNotFoundException e) {
						System.out.printf("File.read: `%s' : `%s'\n", e.getMessage(), file.getPath());
						return(null);
					}
					return(this);
				}
			}}}
			return(null);
		}

		public int read(Buffer buffer) {
			if(buffer == null) {
				return(0);
			}
			var ptr = buffer.get_pointer().get_native_pointer();
			int sz = buffer.get_size(), v;
			embed {{{
				try {
					v = stream.read(ptr, 0, sz);
				}
				catch(java.io.IOException e) {
					System.out.printf("Reader.read: `%s' : `%s'\n", e.getMessage(), file.getPath());
				}
			}}}
			Log.message("Read this value: %d, by this size: `%d`".printf().add(v).add(sz));
			return(v);
		}

		public int get_size() {
			int v;
			embed {{{
				try {
					v = stream.available();
				}
				catch(java.io.IOException e) {
					System.out.printf("Reader.get_size: `%s' : `%s'\n", e.getMessage(), file.getPath());
				}
			}}}
			return(v);
		}
	}

	public SizedReader read() {
		MyFileReader v = new MyFileReader();
		embed {{{
			v.file = new java.io.File(path);
		}}}
		return(v.initialize());
	}

	class MyFileWriter : Writer
	{
		property bool append;
		embed {{{
			java.io.FileOutputStream stream;
			java.io.File file;
		}}}

		public MyFileWriter initialize() {
			embed {{{
				if(file != null) {
					try {
						stream = new java.io.FileOutputStream(file);
					}
					catch(java.io.IOException e) {
						if(append) {
							System.out.printf("File." + (append ? "append " : "write ") + ": `%s' : `%s'\n", e.getMessage(), file.getPath());	
						}
					}
					return(this);
				}
			}}}
			return(null);
		}

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
					stream.write(ptr, 0, sz);
				}
				catch(java.io.IOException e) {
					System.out.printf("Writer.write: `%s' : `%s'\n", e.getMessage(), file.getPath());
				}
			}}}
			return(sz);
		}
	}

	public Writer write() {
		var v = new MyFileWriter();
		embed {{{
			v.file = new java.io.File(path);
		}}}
		return(v.initialize());
	}

	public Writer append() {
		var v = new MyFileWriter().set_append(true);
		embed {{{
			v.file = new java.io.File(path);
		}}}
		return(v.initialize());
	}

	public bool remove() {
		bool v;
		embed {{{
			java.io.File f = new java.io.File(path);
			v = f.delete();
		}}}
		return(v);
	}

	public bool move(File dest, bool replace) {
		if(dest.exists()) {
			if(replace == false) {
				return(false);
			}
			dest.remove();
		}
		strptr destpath;
		var dp = dest.get_native_path();
		if(dp == null) {
			return(false);
		}
		destpath = dp.to_strptr();
		bool v;
		embed {{{
			java.io.File src = new java.io.File(path);
			java.io.File dst = new java.io.File(destpath);
			v = src.renameTo(dst);
		}}}
		return(v);
	}

	public bool remove_directory() {
		if(is_directory()) {
			return(remove());
		}
		return(false);
	}
}
