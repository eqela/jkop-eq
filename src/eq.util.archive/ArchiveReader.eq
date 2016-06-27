
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

public class ArchiveReader
{
	class FileEntryReader : Reader, SizedReader, Seekable
	{
		property Reader reader;
		property int offset;
		int size;
		int pos;

		public int get_size() {
			return(size);
		}

		public FileEntryReader set_size(int s) {
			size = s;
			return(this);
		}

		public bool seek_set(int n) {
			if(reader != null && reader is Seekable) {
				return(((Seekable)reader).seek_set(offset + n));
			}
			return(false);
		}

		public int seek_current() {
			if(reader == null || reader is Seekable == false) {
				return(0);
			}
			return(((Seekable)reader).seek_current() - offset);
		}

		public int read(Buffer buf) {
			if(buf == null || reader == null) {
				return(0);
			}
			if(pos >= size) {
				return(0);
			}
			if(pos + buf.get_size() > size) {
				int r = reader.read(SubBuffer.create(buf, 0, size - pos));
				if(r > 0) {
					pos += r;
				}
				return(r);
			}
			int r = reader.read(buf);
			if(r > 0) {
				pos += r;
			}
			return(r);
		}
	}

	class ArchiveReaderFileEntry
	{
		property File file;
		property int size;
		property int compressed_size;
		property int filepos;
		property String name;

		public SizedReader read() {
			if(file == null) {
				return(null);
			}
			var rd = file.read();
			if(rd == null) {
				return(null);
			}
			if(rd is Seekable == false || ((Seekable)rd).seek_set(filepos) == false) {
				// FIXME: Should create smaller buffers in case filepos is large
				var bb = DynamicBuffer.create(filepos);
				if(rd.read(bb) != filepos) {
					return(null);
				}
			}
			return(new FileEntryReader().set_offset(filepos).set_reader(rd).set_size(size));
		}
	}

	class ArchiveReaderDirectoryEntry
	{
		property String name;
	}

	public static ArchiveReader for_file(File file) {
		var v = new ArchiveReader();
		if(v.open_file(file) == false) {
			v = null;
		}
		return(v);
	}

	File archive_file;
	Collection errors;
	HashTable files;
	Collection filelist;
	int totalsize;

	public Collection get_errors() {
		return(errors);
	}

	public File get_archive_file() {
		return(archive_file);
	}

	public Collection get_files() {
		return(filelist);
	}

	public Object get_file(String name) {
		if(files == null) {
			return(null);
		}
		return(files.get(name));
	}

	public int get_total_size() {
		return(totalsize);
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

	bool do_open_file(File file) {
		var ins = InputStream.create(file.read());
		if(ins == null) {
			error("FAILED to read from file: `%s'".printf().add(file));
			return(false);
		}
		if(Integer.as_integer(ins.read_int8()) != 'E' ||
			Integer.as_integer(ins.read_int8()) != 'Q' ||
			Integer.as_integer(ins.read_int8()) != 'A' ||
			Integer.as_integer(ins.read_int8()) != '0') {
			error("File is not an archive: `%s'".printf().add(file));
			return(false);
		}
		files = HashTable.create();
		filelist = LinkedList.create();
		totalsize = 0;
		int offset = 0;
		int header = 4;
		while(true) {
			var i = ins.read_int8();
			if(i == null) {
				error("Unexpected end of file");
				return(false);
			}
			header ++;
			var ii = Integer.as_integer(i);
			if(ii == 0) {
				break; // end of header
			}
			else if(ii == 1) {
				error("Compressed files are not supported.");
				return(false);
			}
			else if(ii == 2) {
				String name;
				int sz = Integer.as_integer(ins.read_int32());
				int nsz = Integer.as_integer(ins.read_int32());
				header += 8;
				if(nsz > 0) {
					var bb = DynamicBuffer.create(nsz);
					if(ins.read(bb) != nsz) {
						error("Corrupt file data (1)");
						return(false);
					}
					header += nsz;
					name = String.for_utf8_buffer(bb, false);
				}
				if(String.is_empty(name)) {
					error("Corrupt file data (2)");
					return(false);
				}
				var ee = new ArchiveReaderFileEntry().set_file(file).set_size(sz).set_compressed_size(sz).set_filepos(offset).set_name(name);
				files.set(name, ee);
				filelist.add(ee);
				offset += sz;
				totalsize += sz;
			}
			else if(ii == 3) {
				String name;
				int nsz = Integer.as_integer(ins.read_int32());
				header += 4;
				if(nsz > 0) {
					var bb = DynamicBuffer.create(nsz);
					if(ins.read(bb) != nsz) {
						error("Corrupt file data (3)");
						return(false);
					}
					header += nsz;
					name = String.for_utf8_buffer(bb, false);
				}
				if(String.is_empty(name)) {
					error("Corrupt file data (4)");
					return(false);
				}
				var ee = new ArchiveReaderDirectoryEntry().set_name(name);
				files.set(name, ee);
				filelist.add(ee);
			}
			else {
				error("Unknown file entry type %d".printf().add(Primitive.for_integer(ii)));
				return(false);
			}
		}
		foreach(ArchiveReaderFileEntry fe in filelist) {
			fe.set_filepos(fe.get_filepos() + header);
		}
		return(true);
	}

	public bool open_file(File file) {
		errors = null;
		if(file == null) {
			return(false);
		}
		if(do_open_file(file) == false) {
			files = null;
			filelist = null;
			return(false);
		}
		archive_file = file;
		return(true);
	}

	public bool extract_to(File destdir, EventReceiver er = null) {
		if(destdir == null || filelist == null) {
			return(false);
		}
		if(destdir.is_directory() == false && destdir.mkdir_recursive() == false) {
			error("Unable to create directory: `%s'".printf().add(destdir));
			return(false);
		}
		foreach(Object entry in filelist) {
			String name;
			if(entry is ArchiveReaderFileEntry) {
				name = ((ArchiveReaderFileEntry)entry).get_name();
			}
			else if(entry is ArchiveReaderDirectoryEntry) {
				name = ((ArchiveReaderDirectoryEntry)entry).get_name();
			}
			if(er != null) {
				er.on_event(name);
			}
			var de = destdir.entry(name);
			if(entry is ArchiveReaderDirectoryEntry) {
				if(de.is_directory() == false && de.mkdir_recursive() == false) {
					error("Unable to create directory: `%s'".printf().add(de));
					return(false);
				}
			}
			else if(entry is ArchiveReaderFileEntry) {
				var rd = InputStream.create(((ArchiveReaderFileEntry)entry).read());
				if(rd == null) {
					error("Unable to extract archive file `%s'".printf().add(name));
					return(false);
				}
				var os = OutputStream.create(de.write());
				if(os == null) {
					error("Unable to write file: `%s'".printf().add(de));
					return(false);
				}
				if(os.write_from_reader(rd) < ((ArchiveReaderFileEntry)entry).get_size()) {
					error("Incomplete file data written for `%s'".printf().add(name));
					return(false);
				}
			}
		}
		return(true);
	}
}

