
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

public class FileExtender : File, Stringable
{
	property File file;

	public File realpath() {
		if(file != null) {
			file = file.realpath();
		}
		return(this);
	}

	public String get_eqela_path() {
		if(file == null) {
			return(null);
		}
		return(file.get_eqela_path());
	}

	public File entry(String name) {
		if(file == null) {
			return(null);
		}
		return(file.entry(name));
	}

	public File as_executable() {
		if(file == null) {
			return(null);
		}
		return(file.as_executable());
	}

	public File get_parent() {
		if(file == null) {
			return(null);
		}
		return(file.get_parent());
	}

	public File get_sibling(String name) {
		if(file == null) {
			return(null);
		}
		return(file.get_sibling(name));
	}

	public bool has_extension(String ext) {
		if(file == null) {
			return(false);
		}
		return(file.has_extension(ext));
	}

	public String extension() {
		if(file == null) {
			return(null);
		}
		return(file.extension());
	}

	public String strip_extension() {
		if(file == null) {
			return(null);
		}
		return(file.strip_extension());
	}

	public Iterator entries() {
		if(file == null) {
			return(null);
		}
		return(file.entries());
	}

	public bool remove() {
		if(file == null) {
			return(false);
		}
		return(file.remove());
	}

	public bool move(File dest, bool replace = true) {
		if(file == null) {
			return(false);
		}
		return(file.move(dest, replace));
	}

	public bool rename(String newname, bool replace = true) {
		if(file == null) {
			return(false);
		}
		return(file.rename(newname, replace));
	}

	public bool touch() {
		if(file == null) {
			return(false);
		}
		return(file.touch());
	}

	public SizedReader read() {
		if(file == null) {
			return(null);
		}
		return(file.read());
	}

	public Writer write() {
		if(file == null) {
			return(null);
		}
		return(file.write());
	}

	public Writer append() {
		if(file == null) {
			return(null);
		}
		return(file.append());
	}

	public bool set_mode(int mode) {
		if(file == null) {
			return(false);
		}
		return(file.set_mode(mode));
	}

	public bool set_owner_user(int uid) {
		if(file == null) {
			return(false);
		}
		return(file.set_owner_user(uid));
	}

	public bool set_owner_group(int gid) {
		if(file == null) {
			return(false);
		}
		return(file.set_owner_group(gid));
	}

	public FileInfo stat() {
		if(file == null) {
			return(null);
		}
		return(file.stat());
	}

	public int get_size() {
		if(file == null) {
			return(0);
		}
		return(file.get_size());
	}

	public bool exists() {
		if(file == null) {
			return(false);
		}
		return(file.exists());
	}

	public bool is_executable() {
		if(file == null) {
			return(false);
		}
		return(file.is_executable());
	}

	public bool is_file() {
		if(file == null) {
			return(false);
		}
		return(file.is_file());
	}

	public bool is_directory() {
		if(file == null) {
			return(false);
		}
		return(file.is_directory());
	}

	public bool is_link() {
		if(file == null) {
			return(false);
		}
		return(file.is_link());
	}

	public bool create_fifo() {
		if(file == null) {
			return(false);
		}
		return(file.create_fifo());
	}

	public bool create_directory() {
		if(file == null) {
			return(false);
		}
		return(file.create_directory());
	}

	public bool remove_directory() {
		if(file == null) {
			return(false);
		}
		return(file.remove_directory());
	}

	public String get_native_path() {
		if(file == null) {
			return(null);
		}
		return(file.get_native_path());
	}

	public bool is_same(File f) {
		if(file == null) {
			return(false);
		}
		return(file.is_same(f));
	}

	public bool delete_recursive() {
		if(file == null) {
			return(false);
		}
		return(file.delete_recursive());
	}

	public bool mkdir_recursive() {
		if(file == null) {
			return(false);
		}
		return(file.mkdir_recursive());
	}

	public bool write_from_reader(Reader reader, bool append) {
		if(file == null) {
			return(false);
		}
		return(file.write_from_reader(reader, append));
	}

	public bool match_pattern(Collection patterns) {
		if(file == null) {
			return(false);
		}
		return(file.match_pattern(patterns));
	}

	public bool copy_to(File dest, Collection excludes = null) {
		if(file == null) {
			return(false);
		}
		return(file.copy_to(dest, excludes));
	}

	public int compare_modification_time(File bf) {
		if(file == null) {
			return(0);
		}
		return(file.compare_modification_time(bf));
	}

	public bool is_newer_than(File bf) {
		if(file == null) {
			return(false);
		}
		return(file.is_newer_than(bf));
	}

	public bool is_older_than(File bf) {
		if(file == null) {
			return(false);
		}
		return(file.is_older_than(bf));
	}

	public String dirname() {
		if(file == null) {
			return(null);
		}
		return(file.dirname());
	}

	public String basename() {
		if(file == null) {
			return(null);
		}
		return(file.basename());
	}

	public String idname() {
		if(file == null) {
			return(null);
		}
		return(file.idname());
	}

	public bool is_identical(File f) {
		if(file == null) {
			return(false);
		}
		return(file.is_identical(f));
	}

	public Buffer get_contents_buffer() {
		if(file == null) {
			return(null);
		}
		return(file.get_contents_buffer());
	}

	public String get_contents_string() {
		if(file == null) {
			return(null);
		}
		return(file.get_contents_string());
	}

	public bool set_contents_buffer(Buffer buf) {
		if(file == null) {
			return(false);
		}
		return(file.set_contents_buffer(buf));
	}

	public bool set_contents_string(String str) {
		if(file == null) {
			return(false);
		}
		return(file.set_contents_string(str));
	}

	public Iterator lines() {
		if(file == null) {
			return(null);
		}
		return(file.lines());
	}

	public String to_string() {
		if(file == null) {
			return(null);
		}
		return(file.to_string());
	}
}
