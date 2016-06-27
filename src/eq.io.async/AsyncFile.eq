
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

public interface AsyncFile : Stringable
{
	public static AsyncFile for_file(File file, BackgroundTaskManager btm) {
		return(AsyncFileWrapper.for_file(file, btm));
	}

	public static File as_file(AsyncFile asf) {
		var wr = asf as AsyncFileWrapper;
		if(wr == null) {
			return(null);
		}
		return(wr.get_file());
	}

	public AsyncFile entry(String name);
	public String get_path();
	public String get_name();
	public String get_extension();
	public String get_name_without_extension();
	public bool is_same(AsyncFile af);
	public AsyncFile get_parent();
	public AsyncFile get_sibling(String name);
	public void get_entries(CollectionOperationListener rcv);
	public void remove(BooleanOperationListener rcv);
	public void rename(String newname, bool allow_replace, BooleanOperationListener rcv);
	public void touch(BooleanOperationListener rcv);
	public void get_contents_string(StringOperationListener rcv);
	public void get_contents_buffer(BufferOperationListener rcv);
	public void set_contents_string(String str, BooleanOperationListener rcv);
	public void set_contents_buffer(Buffer buf, BooleanOperationListener rcv);
	public void get_file_info(FileInfoOperationListener rcv);
	public void create_directory(BooleanOperationListener rcv);
	public void copy_to(AsyncFile dest, bool allow_replace, BooleanOperationListener rcv);
}
