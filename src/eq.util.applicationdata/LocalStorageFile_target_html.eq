
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

public class LocalStorageFile : FileAdapter
{
	public static LocalStorageFile instance(String appname, LocalStorageFile parent, String name) {
		return(new LocalStorageFile().initialize(appname, parent, name));
	}

	property String appname;
	property String name;
	LocalStorageFile parent;

	public File get_parent() {
		return(parent);
	}

	public LocalStorageFile set_parent(LocalStorageFile pp) {
		parent = pp;
		return(this);
	}

	private bool has_localstorage() {
		bool v = false;
		embed "js" {{{
			try {
				v = ('localStorage' in window) && window['localStorage'] !== null;
			}
			catch(e) {
				v = false;
			}
		}}}
		return(v);
	}

	public LocalStorageFile initialize(String appname, LocalStorageFile parent, String name) {
		if(has_localstorage() == false) {
			Log.warning("This browser does not support local storage. Application data is not available.");
			return(null);
		}
		this.appname = appname;
		this.parent = parent;
		this.name = name;
		return(this);
	}

	public String get_complete_id() {
		if(parent == null) {
			return("%s/%s".printf().add(URLEncoder.encode(SystemEnvironment.get_current_url())).add(URLEncoder.encode(appname)).to_string());
		}
		if(String.is_empty(name)) {
			return(null);
		}
		var pid = parent.get_complete_id();
		if(pid == null) {
			pid = "";
		}
		return("%s/%s".printf().add(pid).add(URLEncoder.encode(name)).to_string());
	}

	public bool remove() {
		var id = get_complete_id();
		if(id == null) {
			return(false);
		}
		bool v = false;
		embed {{{
			try {
				localStorage.removeItem(id.to_strptr());
				v = true;
			}
			catch(e) {
				v = false;
			}
		}}}
		return(v);
	}

	public bool set_contents_string(String str) {
		var id = get_complete_id();
		if(id == null) {
			return(false);
		}
		var ss = str;
		if(str == null) {
			ss = "";
		}
		bool v = false;
		embed "js" {{{
			try {
				localStorage.setItem(id.to_strptr(), ss.to_strptr());
				v = true;
			}
			catch(e) {
				v = false;
			}
		}}}
		return(v);
	}

	public String get_contents_string() {
		var id = get_complete_id();
		if(id == null) {
			return(null);
		}
		strptr data;
		embed "js" {{{
			data = localStorage.getItem(id.to_strptr());
		}}}
		if(data == null) {
			return(null);
		}
		return(String.for_strptr(data));
	}

	public Buffer get_contents_buffer() {
		var ss = get_contents_string();
		if(ss == null) {
			return(null);
		}
		return(ss.to_utf8_buffer(false));
	}

	public File entry(String s) {
		return(LocalStorageFile.instance(appname, this, s));
	}

	public SizedReader read() {
		var str = get_contents_string();
		if(str == null) {
			return(null);
		}
		return(StringReader.for_string(str));
	}

	class MyWriter : Writer
	{
		property LocalStorageFile file;
		property String data;
		public int write(Buffer buf, int size) {
			var bb = buf;
			if(size > 0) {
				bb = SubBuffer.create(buf, 0, size);
			}
			var str = String.for_utf8_buffer(bb, false);
			if(String.is_empty(str)) {
				return(0);
			}
			var dd = data;
			if(dd == null) {
				dd = "";
			}
			dd = dd.append(str);
			if(file.set_contents_string(dd) == false) {
				return(-1);
			}
			data = dd;
			return(bb.get_size());
		}
	}

	public Writer write() {
		return(new MyWriter().set_file(this));
	}

	public Writer append() {
		return(new MyWriter().set_file(this).set_data(get_contents_string()));
	}

	public FileInfo stat() {
		var id = get_complete_id();
		if(id == null) {
			return(null);
		}
		var data = get_contents_string();
		if(data == null) {
			return(null);
		}
		var v = new FileInfo();
		v.set_file(this);
		v.set_size(data.get_length());
		if("___local_storage_directory___".equals(data)) {
			v.set_type(FileInfo.FILE_TYPE_DIR);
		}
		else {
			v.set_type(FileInfo.FILE_TYPE_FILE);
		}
		return(v);
	}

	public String to_string() {
		return(get_complete_id());
	}

	public bool create_directory() {
		return(set_contents_string("___local_storage_directory___"));
	}

	public bool remove_directory() {
		return(remove());
	}
}
