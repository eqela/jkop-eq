
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

public interface File : Stringable
{
	static bool full_path_to_string = true;

	public static bool get_full_path_to_string() {
		return(full_path_to_string);
	}

	public static void set_full_path_to_string(bool r) {
		full_path_to_string = r;
	}

	public static File for_eqela_path(String path, File relativeto = null) {
		if(String.is_empty(path)) {
			return(new InvalidFile());
		}
		if(path.has_prefix("/")) {
			if("/native".equals(path)) {
				return(File.for_native_path("/"));
			}
			else if(path.has_prefix("/native/")) {
				return(File.for_native_path(path.substring(7)));
			}
			else if("/tmp".equals(path)) {
				return(FileImpl.for_temporary_directory());
			}
			else if(path.has_prefix("/tmp/")) {
				return(for_native_path(path.substring(5), FileImpl.for_temporary_directory()));
			}
			else if("/my".equals(path)) {
				return(FileImpl.for_home_directory());
			}
			else if(path.has_prefix("/my/")) {
				return(for_native_path(path.substring(4), FileImpl.for_home_directory()));
			}
			else if("/app".equals(path)) {
				return(FileImpl.for_app_directory());
			}
			else if(path.has_prefix("/app/")) {
				return(for_native_path(path.substring(5), FileImpl.for_app_directory()));
			}
			else {
				// The path is not valid: Should be a file that cannot be operated on.
				return(new InvalidFile());
			}
		}
		else if(relativeto != null) {
			return(relativeto.entry(path));
		}
		else {
			var cwd = FileImpl.for_current_directory();
			if(cwd != null) {
				return(cwd.entry(path));
			}
		}
		return(new InvalidFile());
	}

	public static File for_temporary_directory(String path = null) {
		var v = for_eqela_path("/tmp");
		if(String.is_empty(path) == false) {
			v = v.entry(path);
		}
		return(v);
	}

	public static File for_home_directory(String path = null) {
		var v = for_eqela_path("/my");
		if(String.is_empty(path) == false) {
			v = v.entry(path);
		}
		return(v);
	}

	public static File for_app_directory(String path = null) {
		var v = for_eqela_path("/app");
		if(String.is_empty(path) == false) {
			v = v.entry(path);
		}
		return(v);
	}

	static bool has_native_prefix(String apath) {
		if(Path.get_path_delimiter() == '\\') {
			var path = apath;
			if(path.has_prefix("/")) {
				path = Path.to_native_notation(path);
			}
			return(Path.is_windows_absolute_path(path));
		}
		return(apath.has_prefix("/"));
	}

	public static File for_native_path(String path, File relativeto = null) {
		if(String.is_empty(path)) {
			return(new InvalidFile());
		}
		if(has_native_prefix(path)) {
			return(FileImpl.for_path(path));
		}
		var rt = relativeto;
		if(rt == null) {
			rt = FileImpl.for_current_directory();
		}
		if(rt == null) {
			return(new InvalidFile());
		}
		return(rt.entry(path));
	}

	public String get_eqela_path();
	public File entry(String name);
	public File as_executable();
	public File get_parent();
	public File get_sibling(String name);
	public bool has_extension(String ext);
	public String extension();
	public String strip_extension();
	public Iterator entries();
	public bool remove();
	public bool move(File dest, bool replace = true);
	public bool rename(String newname, bool replace = true);
	public bool touch();
	public SizedReader read();
	public Writer write();
	public Writer append();
	public bool set_mode(int mode);
	public bool set_owner_user(int uid);
	public bool set_owner_group(int gid);
	public FileInfo stat();
	public int get_size();
	public bool exists();
	public bool is_executable();
	public bool is_file();
	public bool is_directory();
	public bool is_link();
	public bool create_fifo();
	public bool create_directory();
	public bool remove_directory();
	public String get_native_path();
	public bool is_same(File f);
	public bool delete_recursive();
	public bool mkdir_recursive();
	public bool write_from_reader(Reader reader, bool append = false);
	public bool match_pattern(Collection patterns);
	public bool copy_to(File dest, Collection excludes = null);
	public int compare_modification_time(File bf);
	public bool is_newer_than(File bf);
	public bool is_older_than(File bf);
	public String dirname();
	public String basename();
	public String idname();
	public bool is_identical(File file);
	public Buffer get_contents_buffer();
	public String get_contents_string();
	public bool set_contents_buffer(Buffer buf);
	public bool set_contents_string(String str);
	public Iterator lines();
	public File realpath();
}
