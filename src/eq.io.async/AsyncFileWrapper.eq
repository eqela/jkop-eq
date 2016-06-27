
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

public class AsyncFileWrapper : AsyncFile, Stringable
{
	public static AsyncFileWrapper for_file(File file, BackgroundTaskManager btm) {
		if(file == null || btm == null) {
			return(null);
		}
		return(new AsyncFileWrapper().set_file(file).set_btm(btm));
	}

	property File file;
	property BackgroundTaskManager btm;

	public bool is_same(AsyncFile aaf) {
		var af = aaf as AsyncFileWrapper;
		if(af == null) {
			return(false);
		}
		var aff = af.get_file();
		if(aff == null) {
			if(file == null) {
				return(true);
			}
			return(false);
		}
		return(aff.is_same(file));
	}

	public AsyncFile entry(String name) {
		if(file == null) {
			return(null);
		}
		return(AsyncFileWrapper.for_file(file.entry(name), btm));
	}

	public String get_path() {
		if(file == null) {
			return(null);
		}
		return(file.get_native_path());
	}

	public String get_name() {
		if(file == null) {
			return(null);
		}
		return(file.basename());
	}

	public String to_string() {
		return(get_path());
	}

	public String get_extension() {
		var name = get_name();
		if(name == null) {
			return(null);
		}
		var x = name.rchr((int)'.');
		if(x < 0) {
			return(null);
		}
		return(name.substring(x+1));
	}

	public String get_name_without_extension() {
		var name = get_name();
		if(name == null) {
			return(null);
		}
		var x = name.rchr((int)'.');
		if(x < 0) {
			return(null);
		}
		return(name.substring(0, x));
	}

	public AsyncFile get_parent() {
		return(AsyncFileWrapper.for_file(file.get_parent(), btm));
	}

	public AsyncFile get_sibling(String name) {
		return(AsyncFileWrapper.for_file(file.get_sibling(name), btm));
	}

	class GetEntriesTask : RunnableTask, EventReceiver
	{
		property CollectionOperationListener listener;
		property File file;
		public void run(EventReceiver listener, BooleanValue abortflag) {
			var ii = file.entries();
			if(ii == null) {
				listener.on_event(Error.instance("failed_to_read_directory", "Failed to read directory"));
				return;
			}
			listener.on_event(LinkedList.for_iterator(ii));
		}
		public void on_event(Object o) {
			if(listener == null) {
				return;
			}
			var cc = o as Collection;
			if(cc != null) {
				listener.on_collection(cc, null);
				return;
			}
			var ee = o as Error;
			if(ee == null) {
				ee = Error.instance("unknown_error", "Unknown error");
			}
			listener.on_collection(null, ee);
		}
	}

	public void get_entries(CollectionOperationListener rcv) {
		var gcst = new GetEntriesTask().set_file(file);
		gcst.set_listener(rcv);
		btm.start_task(gcst, gcst);
	}

	public void remove(BooleanOperationListener rcv) {
		bool v;
		if(file.is_directory()) {
			v = file.remove_directory();
		}
		else {
			v = file.remove();
		}
		Error ee;
		if(v == false) {
			ee = Error.instance("operation_failed", "Failed to remove");
		}
		if(rcv != null) {
			rcv.on_boolean(v, ee);
		}
	}

	public void rename(String newname, bool allow_replace, BooleanOperationListener rcv) {
		var v = file.rename(newname, allow_replace);
		Error ee;
		if(v == false) {
			ee = Error.instance("operation_failed", "Failed to rename");
		}
		if(rcv != null) {
			rcv.on_boolean(v, ee);
		}
	}

	public void touch(BooleanOperationListener rcv) {
		var v = file.touch();
		Error ee;
		if(v == false) {
			ee = Error.instance("operation_failed", "Failed to touch");
		}
		if(rcv != null) {
			rcv.on_boolean(v, ee);
		}
	}

	class GetContentsStringTask : RunnableTask, EventReceiver
	{
		property StringOperationListener listener;
		property File file;
		public void run(EventReceiver listener, BooleanValue abortflag) {
			listener.on_event(file.get_contents_string());
		}
		public void on_event(Object o) {
			if(listener == null) {
				return;
			}
			var sr = o as String;
			if(sr != null) {
				listener.on_string(sr, null);
			}
			else {
				listener.on_string(null, Error.instance("failed_to_read_file", "Failed to read file"));
			}
		}
	}

	public void get_contents_string(StringOperationListener rcv) {
		var gcst = new GetContentsStringTask().set_file(file);
		gcst.set_listener(rcv);
		btm.start_task(gcst, gcst);
	}

	class GetContentsBufferTask : RunnableTask, EventReceiver
	{
		property BufferOperationListener listener;
		property File file;
		public void run(EventReceiver listener, BooleanValue abortflag) {
			listener.on_event(file.get_contents_buffer());
		}
		public void on_event(Object o) {
			if(listener == null) {
				return;
			}
			var sr = o as Buffer;
			if(sr != null) {
				listener.on_buffer(sr, null);
			}
			else {
				listener.on_buffer(null, Error.instance("failed_to_read_file", "Failed to read file"));
			}
		}
	}

	public void get_contents_buffer(BufferOperationListener rcv) {
		var gcst = new GetContentsBufferTask().set_file(file);
		gcst.set_listener(rcv);
		btm.start_task(gcst, gcst);
	}

	class SetContentsStringTask : RunnableTask, EventReceiver
	{
		property BooleanOperationListener listener;
		property File file;
		property String content;
		public void run(EventReceiver listener, BooleanValue abortflag) {
			listener.on_event(Primitive.for_boolean(file.set_contents_string(content)));
		}
		public void on_event(Object o) {
			if(listener == null) {
				return;
			}
			bool v = false;
			var sr = o as Boolean;
			if(sr != null) {
				v = sr.to_boolean();
			}
			Error ee;
			if(v == false) {
				ee = Error.instance("operation_failed", "Failed to write file");
			}
			listener.on_boolean(v, ee);
		}
	}

	public void set_contents_string(String str, BooleanOperationListener rcv) {
		var gcst = new SetContentsStringTask().set_file(file).set_content(str);
		gcst.set_listener(rcv);
		btm.start_task(gcst, gcst);
	}

	class SetContentsBufferTask : RunnableTask, EventReceiver
	{
		property BooleanOperationListener listener;
		property File file;
		property Buffer content;
		public void run(EventReceiver listener, BooleanValue abortflag) {
			listener.on_event(Primitive.for_boolean(file.set_contents_buffer(content)));
		}
		public void on_event(Object o) {
			if(listener == null) {
				return;
			}
			bool v = false;
			var sr = o as Boolean;
			if(sr != null) {
				v = sr.to_boolean();
			}
			Error ee;
			if(v == false) {
				ee = Error.instance("operation_failed", "Failed to write file");
			}
			listener.on_boolean(v, ee);
		}
	}

	public void set_contents_buffer(Buffer buf, BooleanOperationListener rcv) {
		var gcst = new SetContentsBufferTask().set_file(file).set_content(buf);
		gcst.set_listener(rcv);
		btm.start_task(gcst, gcst);
	}

	public void get_file_info(FileInfoOperationListener rcv) {
		if(rcv != null) {
			var st = file.stat();
			if(st == null) {
				rcv.on_file_info(null, Error.instance("operation_failed", "Failed to retrieve file information"));
			}
			else {
				rcv.on_file_info(st, null);
			}
		}
	}

	public void create_directory(BooleanOperationListener rcv) {
		var r = file.mkdir_recursive();
		if(rcv == null) {
			return;
		}
		if(r == false) {
			rcv.on_boolean(false, Error.instance("operation_failed", "Failed to create directory"));
		}
		else {
			rcv.on_boolean(true, null);
		}
	}

	class CopyFileFileTask : RunnableTask, EventReceiver
	{
		property BooleanOperationListener listener;
		property File srcfile;
		property File dstfile;
		property bool allow_replace;
		Error ee;
		public void run(EventReceiver listener, BooleanValue abortflag) {
			if(dstfile.exists() && allow_replace == false) {
				ee = Error.instance("file_already_exists", "Destination file already exists");
				listener.on_event(Primitive.for_boolean(false));
				return;
			}
			listener.on_event(Primitive.for_boolean(srcfile.copy_to(dstfile)));
		}
		public void on_event(Object o) {
			if(listener == null) {
				return;
			}
			bool v = false;
			var sr = o as Boolean;
			if(sr != null) {
				v = sr.to_boolean();
			}
			if(v == false && ee == null) {
				ee = Error.instance("operation_failed", "Failed to write file");
			}
			listener.on_boolean(v, ee);
		}
	}

	public void copy_to(AsyncFile dest, bool allow_replace, BooleanOperationListener rcv) {
		if(dest == null) {
			if(rcv != null) {
				rcv.on_boolean(false, Error.instance("no_destination_file", "No destination file"));
			}
			return;
		}
		if(dest is AsyncFileWrapper) {
			var srcf = file;
			var dstf = ((AsyncFileWrapper)dest).get_file();
			var gcst = new CopyFileFileTask().set_srcfile(srcf).set_dstfile(dstf).set_allow_replace(allow_replace);
			gcst.set_listener(rcv);
			btm.start_task(gcst, gcst);
			return;
		}
		Log.error("FIXME: Implement copying to non-AsyncFileWrapper AsyncFile implementations");
		if(rcv != null) {
			rcv.on_boolean(false, Error.instance("not_implemented", "Not implemented"));
		}
	}
}
