
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

public class FileInfo
{
	public static int FILE_TYPE_UNKNOWN = 0;
	public static int FILE_TYPE_FILE = 1;
	public static int FILE_TYPE_DIR = 2;

	public static FileInfo for_file(File file) {
		if(file == null) {
			return(new FileInfo());
		}
		return(file.stat());
	}

	public static FileInfo for_properties(PropertyObject o) {
		var v = new FileInfo();
		if(o != null) {
			v.set_size(o.get_int("size"));
			v.set_access_time(o.get_int("atime"));
			v.set_modify_time(o.get_int("mtime"));
			v.set_owner_user(o.get_int("uid"));
			v.set_owner_group(o.get_int("gid"));
			v.set_mode(o.get_int("mode"));
			v.set_executable(o.get_bool("exec"));
		}
		return(v);
	}

	File file;
	int size;
	int access_time;
	int modify_time;
	int owner_user;
	int owner_group;
	int mode;
	bool executable;
	int type;
	bool islink = false;

	public virtual FileInfo set_file(File v) {
		file = v;
		return(this);
	}

	public virtual File get_file() {
		return(file);
	}

	public virtual FileInfo set_size(int v) {
		size = v;
		return(this);
	}

	public virtual int get_size() {
		return(size);
	}

	public virtual FileInfo set_access_time(int v) {
		access_time = v;
		return(this);
	}

	public virtual int get_access_time() {
		return(access_time);
	}

	public virtual FileInfo set_modify_time(int v) {
		modify_time = v;
		return(this);
	}

	public virtual int get_modify_time() {
		return(modify_time);
	}

	public virtual FileInfo set_owner_user(int v) {
		owner_user = v;
		return(this);
	}

	public int get_owner_user() {
		return(owner_user);
	}

	public virtual FileInfo set_owner_group(int v) {
		owner_group = v;
		return(this);
	}

	public int get_owner_group() {
		return(owner_group);
	}

	public virtual FileInfo set_mode(int v) {
		mode = v;
		return(this);
	}

	public virtual int get_mode() {
		return(mode);
	}

	public virtual FileInfo set_executable(bool v) {
		executable = v;
		return(this);
	}

	public virtual bool get_executable() {
		return(executable);
	}

	public virtual FileInfo set_type(int v) {
		type = v;
		return(this);
	}

	public virtual int get_type() {
		return(type);
	}

	public virtual FileInfo set_islink(bool v) {
		islink = v;
		return(this);
	}

	public virtual bool get_islink() {
		return(islink);
	}

	public virtual bool is_file() {
		if(type == FILE_TYPE_FILE) {
			return(true);
		}
		return(false);
	}

	public virtual bool is_link() {
		return(islink);
	}

	public virtual bool is_directory() {
		if(type == FILE_TYPE_DIR) {
			return(true);
		}
		return(false);
	}

	public virtual bool exists() {
		return(is_file() || is_directory() || is_link());
	}
}

