
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

public class ArchiveWriter
{
	class FileEntry
	{
		property File file;
		property String name;
	}

	Collection files;
	Collection errors;

	property bool compressed = false;

	public ArchiveWriter() {
		files = LinkedList.create();
	}

	void error(Object err) {
		var e = err as String;
		if(e == null && err is Stringable) {
			e = ((Stringable)err).to_string();
		}
		if(e != null) {
			if(errors == null) {
				errors = LinkedList.create();
			}
			errors.add(e);
		}
	}

	public Collection get_errors() {
		return(errors);
	}

	public ArchiveWriter add(File file) {
		if(file != null) {
			if(file.is_file()) {
				add_file(file);
			}
			else if(file.is_directory()) {
				add_directory(file);
			}
			else {
				Log.error("ArchiveWriter: Unknown file type: `%s'".printf().add(file));
			}
		}
		return(this);
	}

	public ArchiveWriter add_file(File file) {
		if(file != null) {
			files.add(new FileEntry().set_file(file).set_name(file.basename()));
			Log.debug("Archive writer: Add file `%s'".printf().add(file));
		}
		return(this);
	}

	public ArchiveWriter add_directory(File dir) {
		if(dir == null) {
			return(this);
		}
		Log.debug("ArchiveWriter: Adding directory `%s'".printf().add(dir));
		var dirname = Path.normalize_path(dir.get_eqela_path()).append("/");
		foreach(File file in new FileFinder().set_include_directories(true).set_root(dir)) {
			var filename = file.get_eqela_path();
			if(filename.has_prefix(dirname)) {
				filename = filename.substring(dirname.get_length());
			}
			files.add(new FileEntry().set_file(file).set_name(filename));
			Log.debug("Archive writer: Add file `%s'".printf().add(file));
		}
		return(this);
	}

	bool do_write(File file, EventReceiver er) {
		if(compressed) {
			error("Compression of archive files is not implemented.");
			return(false);
		}
		var os = OutputStream.create(file.write());
		if(os == null) {
			error("FAILED to write: `%s'".printf().add(file));
			return(false);
		}
		os.write_int8((int)'E');
		os.write_int8((int)'Q');
		os.write_int8((int)'A');
		os.write_int8((int)'0');
		var stats = LinkedList.create();
		foreach(FileEntry fe in files) {
			var ff = fe.get_file();
			var name = fe.get_name();
			var stat = ff.stat();
			if(stat == null) {
				continue;
			}
			stats.add(stat);
			var bb = name.to_utf8_buffer(false);
			if(ff.is_file()) {
				if(compressed) {
					int sz = stat.get_size();
					os.write_int8(1);
					os.write_int32(sz);
					os.write_int32(sz);
					os.write_int32(bb.get_size());
					os.write(bb);
				}
				else {
					int sz = stat.get_size();
					os.write_int8(2);
					os.write_int32(sz);
					os.write_int32(bb.get_size());
					os.write(bb);
				}
			}
			else if(ff.is_directory() && ff.is_link() == false) {
				os.write_int8(3);
				os.write_int32(bb.get_size());
				os.write(bb);
			}
			else {
				error("Not a file or a directory: `%s'".printf().add(ff));
				return(false);
			}
		}
		os.write_int8(0);
		foreach(FileInfo stat in stats) {
			var ff = stat.get_file();
			if(er != null) {
				er.on_event(ff);
			}
			if(ff.is_file()) {
				var ins = InputStream.create(ff.read());
				if(ins == null) {
					error("FAILED to read file: `%s'".printf().add(ff));
					return(false);
				}
				if(os.write_from_reader(ins) != stat.get_size()) {
					error("FAILED to dump file contents: `%s' (file changed during writing?)".printf().add(ff));
					return(false);
				}
			}
		}
		return(true);
	}

	public bool write(File file, EventReceiver er = null) {
		errors = null;
		if(file == null) {
			return(false);
		}
		if(do_write(file, er) == false) {
			file.remove();
			return(false);
		}
		return(true);
	}
}

