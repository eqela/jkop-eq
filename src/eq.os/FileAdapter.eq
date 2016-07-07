
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

public class FileAdapter : File, Stringable
{
	public virtual File entry(String name) {
		return(null); // TBI
	}

	public virtual File get_parent() {
		return(null); // TBI
	}

	public virtual Iterator entries() {
		return(null); // TBI
	}

	public virtual bool remove() {
		return(false); // TBI
	}

	public virtual bool move(File dest, bool replace = true) {
		return(false); // TBI
	}

	public virtual SizedReader read() {
		return(null); // TBI
	}

	public virtual Writer write() {
		return(null); // TBI
	}

	public virtual Writer append() {
		return(null); // TBI
	}

	public virtual bool set_mode(int mode) {
		return(false); // TBI
	}

	public virtual bool set_owner_user(int uid) {
		return(false); // TBI
	}

	public virtual bool set_owner_group(int gid) {
		return(false); // TBI
	}

	public virtual FileInfo stat() {
		return(FileInfo.for_file(this)); // TBI
	}

	public virtual bool create_fifo() {
		return(false); // TBI
	}

	public virtual bool create_directory() {
		return(false); // TBI
	}

	public virtual bool remove_directory() {
		return(false); // TBI
	}

	public virtual bool touch() {
		return(false); // TBI // FIXME: There is probably a generic implementation using write()
	}

	public virtual File as_executable() {
		return(this); // TBI ?
	}

	public virtual String get_native_path() {
		return(null); // TBI
	}

	///

	public virtual String get_eqela_path() {
		return("/native".append(get_native_path()));
	}

	public virtual bool is_same(File f) {
		if(f == null) {
			return(false);
		}
		var path = get_native_path();
		if(path != null && path.equals(f.get_native_path())) {
			return(true);
		}
		return(false);
	}

	public virtual String to_string() {
		return(get_native_path());
	}

	public virtual File realpath() {
		return(this);
	}

	public virtual File get_sibling(String name) {
		var pp = get_parent();
		if(pp == null) {
			return(null);
		}
		return(pp.entry(name));
	}

	public virtual bool has_extension(String ext) {
		if(String.is_empty(ext)) {
			return(true);
		}
		return(ext.equals_ignore_case(extension()));
	}

	public virtual String extension() {
		return(Path.extension(basename()));
	}

	public virtual String strip_extension() {
		return(Path.strip_extension(basename()));
	}

	public virtual bool rename(String newname, bool replace = true) {
		if(newname == null || newname.chr((int)'/') >= 0) {
			return(false);
		}
		if(newname.equals(basename())) {
			return(false);
		}
		var pp = get_parent();
		if(pp == null) {
			return(false);
		}
		var dp = pp.entry(newname);
		return(move(dp, replace));
	}

	public virtual int get_size() {
		int v = 0;
		var st = stat();
		if(st != null) {
			v = st.get_size();
		}
		return(v);
	}

	public virtual bool exists() {
		var s = stat();
		if(s == null) {
			return(false);
		}
		if(s.is_file() || s.is_directory() || s.is_link()) {
			return(true);
		}
		return(false);
	}

	public virtual bool is_executable() {
		var st = stat();
		if(st == null) {
			return(false);
		}
		return(st.is_file() && st.get_executable());
	}

	public virtual bool is_file() {
		var st = stat();
		if(st == null) {
			return(false);
		}
		return(st.is_file());
	}

	public virtual bool is_directory() {
		var st = stat();
		if(st == null) {
			return(false);
		}
		return(st.is_directory());
	}

	public virtual bool is_link() {
		var st = stat();
		if(st == null) {
			return(false);
		}
		return(st.is_link());
	}

	public virtual bool delete_recursive() {
		var finfo = stat();
		if(finfo == null) {
			return(true);
		}
		if(finfo.is_directory() == false || finfo.is_link() == true) {
			return(remove());
		}
		foreach(File f in entries()) {
			if(f.delete_recursive() == false) {
				return(false);
			}
		}
		return(remove_directory());
	}

	public virtual bool mkdir_recursive() {
		if(is_directory() == false) {
			var pp = get_parent();
			if(pp != null && pp != this) {
				if(pp.mkdir_recursive() == false) {
					return(false);
				}
			}
			if(create_directory() == false) {
				return(false);
			}
		}
		return(true);
	}

	public virtual bool write_from_reader(Reader reader, bool append = false) {
		if(reader == null) {
			return(false);
		}
		bool v =  false;
		Writer writer;
		if(append) {
			writer = this.append();
		}
		else {
			writer = this.write();
		}
		if(writer != null) {
			var buf = DynamicBuffer.create(4096 * 4);
			if(buf != null) {
				v = true;
				int n = 0;
				while((n = reader.read(buf)) > 0) {
					if(writer.write(buf, n) != n) {
						v = false;
						break;
					}
				}
			}
		}
		if(v == false) {
			Log.error("Failed to write file: `%s'".printf().add(this.to_string()));
		}
		if(writer != null && writer is ClosableWriter) {
			((ClosableWriter)writer).close();
		}
		return(v);
	}

	public virtual bool match_pattern(Collection patterns) {
		if(patterns == null) {
			return(false);
		}
		var filename = basename();
		foreach(String pattern in patterns) {
			if(pattern.equals(filename)) {
				return(true);
			}
			if(pattern.has_prefix("*") && filename.has_suffix(pattern.substring(1))) {
				return(true);
			}
			if(pattern.has_suffix("*") && filename.has_prefix(pattern.substring(0,pattern.get_length()-1))) {
				return(true);
			}
		}
		return(false);
	}

	public virtual bool copy_to(File dest, Collection excludes = null) {
		if(this.is_file()) {
			return(copy_file_to(dest, excludes));
		}
		if(this.is_directory()) {
			return(copy_directory_to(dest, excludes));
		}
		return(false);
	}

	private bool copy_file_to(File dest, Collection excludes) {
		if(dest == null) {
			return(false);
		}
		if(match_pattern(excludes)) {
			return(true);
		}
		if(this.is_same(dest)) {
			return(true);
		}
		bool v = false;
		var reader = this.read();
		if(reader == null) {
			Log.error("Failed to read file for copying: `%s'".printf().add(this.to_string()));
		}
		var writer = dest.write();
		if(writer == null) {
			Log.error("Failed to write file for copying: `%s'".printf().add(dest.to_string()));
		}
		if(reader != null && writer != null) {
			var buf = DynamicBuffer.create(4096 * 4);
			if(buf != null) {
				v = true;
				int n = 0;
				while((n = reader.read(buf)) > 0) {
					var nr = writer.write(buf, n);
					if(nr != n) {
						Log.error("Failed to write to file: %d / %d bytes were written".printf().add(nr).add(n));
						v = false;
						break;
					}
				}
			}
		}
		if(v == false) {
			Log.error("Failed to copy: `%s' -> `%s'".printf().add(this.to_string()).add(dest.to_string()));
		}
		else {
			var fi = this.stat();
			if(fi != null && fi.get_mode() != 0) {
				if(dest.set_mode(fi.get_mode()) == false) {
					Log.error("FAILED to set file mode for `%s'".printf().add(dest.to_string()));
				}
			}
		}
		if(reader != null && reader is ClosableReader) {
			((ClosableReader)reader).close();
		}
		if(writer != null && writer is ClosableWriter) {
			((ClosableWriter)writer).close();
		}
		return(v);
	}

	private bool copy_directory_to(File dest, Collection excludes) {
		if(dest == null) {
			return(false);
		}
		if(dest.is_directory() == false && dest.mkdir_recursive() == false) {
			return(false);
		}
		bool v = true;
		foreach(File p in entries()) {
			if(p.match_pattern(excludes)) {
				continue;
			}
			if(p.copy_to(dest.entry(p.basename())) == false) {
				return(false);
			}
		}
		return(v);
	}

	public virtual int compare_modification_time(File bf) {
		if(bf == null) {
			return(1);
		}
		int v = 0;
		int ta = 0;
		int tb = 0;
		var sa = this.stat();
		var sb = bf.stat();
		if(sa != null) {
			ta = sa.get_modify_time();
		}
		if(sb != null) {
			tb = sb.get_modify_time();
		}
		if(ta == tb) {
			v = 0;
		}
		else if(ta < tb) {
			v = -1;
		}
		else if(ta > tb) {
			v = 1;
		}
		return(v);
	}

	public virtual bool is_newer_than(File bf) {
		if(compare_modification_time(bf) > 0) {
			return(true);
		}
		return(false);
	}

	public virtual bool is_older_than(File bf) {
		if(compare_modification_time(bf) < 0) {
			return(true);
		}
		return(false);
	}

	public virtual String dirname() {
		var pp = get_parent();
		if(pp != null) {
			return(pp.to_string());
		}
		return(null);
	}

	public virtual String determine_basename() {
		return(Path.basename(get_eqela_path()));
	}

	String _basename;
	public String basename() {
		if(_basename == null) {
			_basename = determine_basename();
		}
		return(_basename);
	}

	public virtual String idname() {
		return(Path.strip_extension(basename()));
	}

	public virtual bool is_identical(File file) {
		if(is_file() == false || file == null || file.is_file() == false) {
			return(false);
		}
		var myreader = read();
		var otreader = file.read();
		if(myreader == null || otreader == null) {
			return(false);
		}
		var mybb = DynamicBuffer.create(1024);
		var otbb = DynamicBuffer.create(1024);
		if(mybb == null || otbb == null) {
			return(false);
		}
		var myptr = mybb.get_pointer();
		var otptr = otbb.get_pointer();
		if(myptr == null || otbb == null) {
			return(false);
		}
		int myn, otn, x;
		while(true)
		{
			myn = myreader.read(mybb);
			otn = otreader.read(otbb);
			if(myn != otn) {
				return(false);
			}
			if(myn < 1) {
				break;
			}
			for(x=0 ;x<myn; x++) {
				if(myptr.get_byte(x) != otptr.get_byte(x)) {
					return(false);
				}
			}
		}
		return(true);
	}

	public virtual Buffer get_contents_buffer() {
		var st = stat();
		if(st == null || st.is_file() == false) {
			return(null);
		}
		var reader = read();
		if(reader == null) {
			return(null);
		}
		var sz = st.get_size();
		if(sz < 1) {
			return(DynamicBuffer.create(0));
		}
		var v = DynamicBuffer.create(sz);
		if(v == null) {
			return(null);
		}
		if(reader.read(v) < sz) {
			return(null);
		}
		return(v);
	}

	public virtual String get_contents_string() {
		var st = stat();
		if(st == null || st.is_file() == false) {
			return(null);
		}
		var reader = read();
		if(reader == null) {
			return(null);
		}
		var sz = st.get_size();
		if(sz < 1) {
			return("");
		}
		var v = DynamicBuffer.create(sz + 1);
		if(v == null) {
			return(null);
		}
		if(reader.read(v) < sz) {
			return(null);
		}
		var ptr = v.get_pointer();
		if(ptr == null) {
			return(null);
		}
		ptr.set_byte(sz, 0);
		return(String.for_utf8_buffer(v));
	}

	public virtual bool set_contents_buffer(Buffer buf) {
		var w = write();
		if(w == null) {
			return(false);
		}
		if(buf != null) {
			if(w.write(buf) != buf.get_size()) {
				if(w is ClosableWriter) {
					((ClosableWriter)w).close();
				}
				return(false);
			}
		}
		if(w is ClosableWriter) {
			((ClosableWriter)w).close();
		}
		return(true);
	}

	public virtual bool set_contents_string(String str) {
		if(str == null) {
			return(set_contents_buffer(null));
		}
		return(set_contents_buffer(str.to_utf8_buffer(false)));
	}

	class LineReaderIterator : Iterator
	{
		property InputStream inputstream;
		public Object next() {
			if(inputstream == null) {
				return(null);
			}
			var r = inputstream.readline();
			if(r == null) {
				inputstream = null;
			}
			return(r);
		}
	}

	public virtual Iterator lines() {
		var ins = InputStream.create(read());
		if(ins == null) {
			return(null);
		}
		return(new LineReaderIterator().set_inputstream(ins));
	}
}
