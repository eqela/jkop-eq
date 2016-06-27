
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
	IFDEF("target_bbjava") {
		String prefix = "file:///store";
	}
	ELSE {
		String prefix = "file://localhost/root1";
	}
	String path;
	String eqela_path;

	public static File for_path(String path) {
		var v = new FileImpl();
		var pp = path;
		if(pp != null) {
			IFDEF("target_bbjava") {
				if(pp.has_prefix("file:///store")) {
					pp = pp.substring(14);
				}
				else if(pp.has_prefix("file:///SDCard")) {
					pp = pp.substring(15);
					v.prefix = "file:///SDCard";
				}
			}
			ELSE IFDEF("target_j2me") {
				if(pp.has_prefix("file://localhost/root1")) {
					pp = pp.substring(22);
				}
			}
		}
		v.path = Path.normalize_path(pp);
		return(v);
	}

	public static File for_external_storage() {
		var v = new FileImpl();
		v.prefix = "file:///SDCard";
		return(v);
	}

	public static File for_current_directory() {
		return(new InvalidFile());
	}

	public static File for_app_directory() {
		return(new InvalidFile());
	}

	public static File for_home_directory() {
		var v = new FileImpl();
		v.path = "/home/user/";
		return(v);
	}

	public static File for_temporary_directory() {
		var v = new FileImpl();
		v.path = "/home/user/temp";
		if(v.is_directory() == false) {
			if(v.mkdir_recursive() == false) {
				Log.error("Failed to get temporary directory");
			}
		}
		return(v);
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

	public String get_native_path() {
		return(prefix.append(path));
	}

	public File get_parent() {
		return(entry(".."));
	}

	embed {{{
		javax.microedition.io.file.FileConnection open_file_connection(eq.api.String p) {
			eq.api.String path = p;
			if(path == null) {
				path = this.path;
			}
			if(path == null || prefix == null) {
				return(null);
			}
			java.lang.String pp = prefix.to_strptr() + path.to_strptr();
			if(pp == null) {
				return(null);
			}
			javax.microedition.io.file.FileConnection v = null;
			try {
				v = (javax.microedition.io.file.FileConnection)javax.microedition.io.Connector.open(pp, javax.microedition.io.Connector.READ_WRITE);
			}
			catch(java.lang.Exception e) {
				System.err.println("[ERROR] Opening file connection: " + e.getMessage());
				v = null;
			}
			return(v);
		}
	}}}

	public FileInfo stat() {
		var v = new FileInfo();
		embed {{{
			javax.microedition.io.file.FileConnection conn = open_file_connection(null);
			if(conn == null) {
				return(v);
			}
			try {
				if(conn.exists()) {
					if(conn.isDirectory()) {
						v.set_type(FileInfo.FILE_TYPE_DIR);
					}
					else {
						v.set_type(FileInfo.FILE_TYPE_FILE);
						v.set_size((int)conn.fileSize());
					}
					v.set_modify_time((int)conn.lastModified());
				}
				conn.close();
			}
			catch(java.lang.Exception e) {
				System.err.println("[ERROR] File stat: `" + conn.getURL() + "`: " + e.getMessage());
			}
		}}}
		return(v);
	}

	class EntryIterator : Iterator
	{
		embed {{{
			javax.microedition.io.file.FileConnection conn;
			java.util.Enumeration files;

			public EntryIterator(javax.microedition.io.file.FileConnection conn) {
				this.conn = conn;
			}
		}}}

		public EntryIterator initialize() {
			embed {{{
				if(conn == null) {
					return(null);
				}
				try {
					files = conn.list();
				}
				catch(java.lang.Exception e) {
					System.err.println("[ERROR] File entries: `" + conn.getURL() + "`: " + e.getMessage());
				}
				finally {
					try {
						conn.close();
					}
					catch(java.lang.Exception e) {
					}
				}
			}}}
			return(this);
		}

		public Object next() {
			strptr path;
			embed {{{
				java.lang.String entry = null;
				if(files != null && files.hasMoreElements()) {
					entry = (java.lang.String)files.nextElement();
				}
				if(entry == null) {
					return(null);
				}
				path = conn.getURL() + entry;
			}}}
			return(FileImpl.for_path(String.for_strptr(path)));
		}
	}

	public Iterator entries() {
		String pp = path;
		if(pp != null && pp.has_suffix("/") == false) {
			pp = pp.append("/");
		}
		EntryIterator v;
		embed {{{
			v = new EntryIterator(open_file_connection(pp));
		}}}
		return(v.initialize());
	}

	public bool touch() {
		bool v = true;
		embed {{{
			javax.microedition.io.file.FileConnection conn = open_file_connection(null);
			if(conn == null) {
				return(false);
			}
			try {
				conn.create();
				conn.close();
			}
			catch(java.lang.Exception e) {
				System.err.println("[ERROR] File touch: `" + conn.getURL() + "`: " + e.getMessage());
				v = false;
			}
		}}}
		return(v);
	}

	public bool create_directory() {
		String pp = path;
		if(pp != null && pp.has_suffix("/") == false) {
			pp = pp.append("/");
		}
		bool v = true;
		embed {{{
			javax.microedition.io.file.FileConnection conn = open_file_connection(pp);
			if(conn == null) {
				return(false);
			}
			try {
				conn.mkdir();
				conn.close();
			}
			catch(java.lang.Exception e) {
				System.err.println("[ERROR] File mkdir: `" + conn.getURL() + "`: " + e.getMessage());
				v = false;
			}
		}}}
		return(v);
	}

	class FileWriter : Writer
	{
		property bool append;
		embed {{{
			javax.microedition.io.file.FileConnection conn;
			java.io.OutputStream stream;

			public FileWriter(javax.microedition.io.file.FileConnection conn) {
				this.conn = conn;
			}
		}}}

		public Writer initialize() {
			embed {{{
				if(conn == null) {
					return(null);
				}
				long offset = 0;
				try {
					if(append) {
						offset = conn.fileSize();
					}
					if(conn.exists() == false) {
						conn.create();
					}
					stream = conn.openOutputStream();
					conn.close();
				}
				catch(java.lang.Exception e) {
					System.err.println("[ERROR] File write: `" + conn.getURL() + "`: " + e.getMessage());	
					return(null);
				}
			}}}
			return(this);
		}

		public int write(Buffer data, int size) {
			if(data == null) {
				return(0);
			}
			var ptr = data.get_pointer().get_native_pointer();
			int sz = size;
			if(sz < 0) {
				sz = data.get_size();
			}
			int v = sz;
			embed {{{
				try {
					stream.write(ptr, 0, sz);
				}
				catch(java.lang.Exception e) {
					System.err.println("[ERROR] FileWriter write: `" + conn.getURL() + "`: " + e.getMessage());
					e.printStackTrace();
					System.err.println("write: Exception Type: " + e);
					v = 0;
				}
				finally {
					try {
						stream.close();
					}
					catch(java.lang.Exception e) {
						System.err.println("[ERROR] FileWriter write (2): `" + conn.getURL() + "`: " + e.getMessage());
					}
				}
			}}}
			return(v);
		}
	}

	public Writer write() {
		FileWriter w;
		embed {{{
			w = new FileWriter(open_file_connection(null));
		}}}
		return(w.initialize());
	}

	public Writer append() {
		FileWriter w;
		embed {{{
			w = new FileWriter(open_file_connection(null));
		}}}
		w.set_append(true);
		return(w.initialize());
	}

	class FileReader : SizedReader, Reader
	{
		embed {{{
			javax.microedition.io.file.FileConnection conn;
			java.io.InputStream stream;

			public FileReader(javax.microedition.io.file.FileConnection conn) {
				this.conn = conn;
			}
		}}}

		public FileReader initialize() {
			embed {{{
				if(conn == null) {
					return(null);
				}
				try {
					stream = conn.openInputStream();
				}
				catch(java.lang.Exception e) {
					System.err.println("[ERROR] File read: `" + conn.getURL() + "`: " + e.getMessage());
					return(null);
				}
			}}}
			return(this);
		}

		int _size = -1;
		public int get_size() {
			if(_size < 0) {
				embed {{{
					if(conn != null) {
						try {
							_size = (int)conn.fileSize();
						}
						catch(java.lang.Exception e) {
						}
					}
					else {
						_size = 0;
					}
				}}}
			}
			return(_size);
		}

		public int read(Buffer buf) {
			if(buf == null) {
				return(0);
			}
			ptr data = buf.get_pointer().get_native_pointer();
			int size = buf.get_size();
			int v;
			embed {{{
				try {
					v = stream.read(data, 0, size);
				}
				catch(java.lang.Exception e) {
					System.err.println("[ERROR] FileReader read: `" + conn.getURL() + "`: " + e.getMessage());
					e.printStackTrace();
					v = -1;
				}
				if(v < 0) {
					try {
						stream.close();
						conn.close();
					}
					catch(java.lang.Exception e) {
						System.err.println("[ERROR] FileReader close: " + e.getMessage());
					}
				}
			}}}
			return(v);
		}
	}

	public SizedReader read() {
		FileReader v;
		embed {{{
			v = new FileReader(open_file_connection(null));
		}}}
		return(v.initialize());
	}

	public bool remove() {
		embed {{{
			javax.microedition.io.file.FileConnection conn = open_file_connection(null);
			if(conn != null) {
				boolean v = true;
				try {
					conn.delete();
					conn.close();
				}
				catch(java.lang.Exception e) {
					System.err.println("[ERROR] File remove: `" + conn.getURL() + "`: " + e.getMessage());
					v = false;
				}
				return(v);
			}
		}}}
		return(false);
	}

	public bool remove_directory() {
		if(is_directory() == false) {
			return(false);
		}
		return(remove());
	}

	public bool move(File dest, bool replace) {
		if(exists() == false) {
			return(false);
		}
		if(dest.exists()) {
			if(replace == false) {
				return(false);
			}
			dest.remove();
		}
		copy_to(dest);
		return(remove());
	}
}
