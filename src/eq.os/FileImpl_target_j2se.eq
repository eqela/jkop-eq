
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
		java.io.File _file;
	}}}

	public static File for_current_directory() {
		var v = new FileImpl();
		embed {{{
			v._file = new java.io.File(System.getProperty("user.dir"));
		}}}
		return(v);
	}

	public static File for_path(String path) {
		if(String.is_empty(path)) {
			return(new InvalidFile());
		}
		var v = new FileImpl();
		embed {{{
			v._file = new java.io.File(path.to_strptr());
		}}}
		return(v);
	}

	public static File for_app_directory() {
		var v = new FileImpl();
		embed {{{
			v._file = new java.io.File(System.getProperty("java.class.path"));
		}}}
		return(v.get_parent());
	}

	public static File for_home_directory() {
		var v = new FileImpl();
		embed {{{
			v._file = new java.io.File(System.getProperty("user.home"));
		}}}
		return(v);
	}

	public static File for_temporary_directory() {
		var v = new FileImpl();
		embed {{{
			v._file = new java.io.File(System.getProperty("java.io.tmpdir"));
		}}}
		return(v);
	}

	public String get_native_path() {
		embed {{{
			if(_file != null) {
				return(_S(_file.getPath()));
			}
		}}}
		return(null);
	}

	public FileInfo stat() {
		var v = new FileInfo();
		v.set_file(this);
		embed {{{
			if(_file == null || _file.exists() == false) {
				return(v);
			}
			v.set_size((int)_file.length());
			v.set_modify_time((int)_file.lastModified());
			if(_file.isDirectory()) {
				}}}
				v.set_type(FileInfo.FILE_TYPE_DIR);
				embed {{{
			}
			else if(_file.isFile()) {
				}}}
				v.set_type(FileInfo.FILE_TYPE_FILE);
				embed {{{
			}
		}}}
		return(v);
	}

	public File entry(String path) {
		if(path != null) {
			var v = new FileImpl();
			embed {{{
				v._file = new java.io.File(_file, path.to_strptr());
			}}}
			return(v);
		}
		return(this);
	}

	public Iterator entries() {
		var v = Array.create();
		embed {{{
			if(_file != null) {
				String[] ent = _file.list();
				if(ent != null) {
					for(String path : ent) {
						FileImpl file = new FileImpl();
						file._file = new java.io.File(_file, path);
						((eq.api.Collection)v).append((eq.api.Object)file);
					}
				}
			}
		}}}
		return(v.iterate());
	}

	public bool touch() {
		bool v = false;
		embed {{{
			if(_file == null) {
				return(v);
			}
			try {
				v = _file.createNewFile();
			}
			catch(java.io.IOException e) {
				System.out.printf("[ERROR] File.touch: `%s' : `%s'\n", e.getMessage(), _file.getPath());	
			}
		}}}
		return(v);
	}

	public File get_parent() {
		FileImpl v = new FileImpl();
		embed {{{
			if(_file != null) {
				String pp = _file.getParent();
				if(pp != null) {
					v._file = new java.io.File(pp);
				}
			}
		}}}
		return(v);
	}

	public bool create_directory() {
		bool v;
		embed {{{
			if(_file != null) {
				v = _file.mkdir();
			}
		}}}
		return(v);
	}

	public bool mkdir_recursive() {
		bool v;
		embed {{{
			if(_file != null) {
				v = _file.mkdirs();
			}
		}}}
		return(v);
	}

	class MyFileReader : SizedReader, Reader
	{
		embed {{{
			java.io.FileInputStream stream;
		}}}
		embed {{{
			public boolean initialize(java.io.File file) {
				if(file == null) {
					return(false);
				}
				boolean v = true;
				try {
					stream = new java.io.FileInputStream(file);
				}
				catch(java.io.FileNotFoundException e) {
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
					v = stream.read(ptr, 0, sz);
				}
				catch(java.io.IOException e) {
					System.out.printf("[ERROR] MyFileReader.read: `%s'\n", e.getMessage());
				}
			}}}
			return(v);
		}

		public int get_size() {
			int v;
			embed {{{
				try {
					v = stream.available();
				}
				catch(java.io.IOException e) {
					System.out.printf("[ERROR] MyFileReader.get_size: `%s'\n", e.getMessage());
				}
			}}}
			return(v);
		}
	}

	public SizedReader read() {
		MyFileReader v = new MyFileReader();
		embed {{{
			if(v.initialize(_file) == false) {
				System.out.printf("[ERROR] File.read: `%s'\n",  _file.getPath());
				v = null;
			}
		}}}
		return(v);
	}

	class MyFileWriter : Writer
	{
		property bool append;
		embed {{{
			java.io.FileOutputStream stream;
		}}}

		embed {{{
			public boolean initialize(java.io.File file) {
				if(file == null) {
					return(false);
				}
				boolean v = true;
				try {
					stream = new java.io.FileOutputStream(file);
				}
				catch(java.io.IOException e) {
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
					stream.write(ptr, 0, sz);
				}
				catch(java.io.IOException e) {
					System.out.printf("[ERROR] MyFileWriter.write: `%s'\n", e.getMessage());
				}
			}}}
			return(sz);
		}
	}

	public Writer write() {
		var v = new MyFileWriter();
		embed {{{
			if(v.initialize(_file) == false) {
				System.out.printf("[ERROR] File.write: `%s'\n", _file.getPath());
				v = null;
			}
		}}}
		return(v);
	}

	public Writer append() {
		var v = new MyFileWriter().set_append(true);
		embed {{{
			if(v.initialize(_file) == false) {
				System.out.printf("[ERROR] File.append: `%s'\n", _file.getPath());
				v = null;
			}
		}}}
		return(v);
	}

	public bool remove() {
		bool v;
		embed {{{
			if(_file != null) {
				v = _file.delete();
			}
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
		var destf = dest as FileImpl;
		bool v;
		embed {{{
			if(_file != null && destf !=  null) {
				v = _file.renameTo(destf._file);
			}
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
