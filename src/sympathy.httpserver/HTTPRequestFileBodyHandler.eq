
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

public class HTTPRequestFileBodyHandler : HTTPRequestBodyHandler, Reader
{
	public static HTTPRequestFileBodyHandler for_file(File file, int maximum_size = -1, bool temporary = true) {
		return(new HTTPRequestFileBodyHandler().set_file(file).set_temporary(temporary).set_maximum_size(maximum_size));
	}

	public static HTTPRequestFileBodyHandler for_temporary_file(File tmpdir = null, int maximum_size = -1) {
		return(for_file(TemporaryFile.for_directory(tmpdir), maximum_size, true));
	}

	property File file;
	property bool temporary;
	property int maximum_size;
	Writer writer;
	Reader reader;
	int n;

	public ~HTTPRequestFileBodyHandler() {
		cleanup();
	}

	public bool copy_to_dir(File dir) {
		if(file == null || dir == null) {
			return(false);
		}
		return(file.copy_to(dir.entry(file.basename())));
	}

	public bool copy_to_file(File newfile) {
		if(file == null || newfile == null) {
			return(false);
		}
		return(file.copy_to(newfile));
	}

	public bool move_to_dir(File dir) {
		if(file == null || dir == null) {
			return(false);
		}
		return(file.move(dir.entry(file.basename()), true));
	}

	public bool move_to_file(File newfile) {
		if(file == null || newfile == null) {
			return(false);
		}
		return(file.move(newfile, true));
	}

	public void cleanup() {
		if(temporary && file != null && file.exists()) {
			file.remove();
		}
		file = null;
		writer = null;
		reader = null;
		n = 0;
	}

	public bool on_body_start(int length) {
		if(maximum_size >= 0 && length > maximum_size) {
			return(false);
		}
		if(file == null) {
			return(false);
		}
		writer = file.write();
		if(writer == null) {
			return(false);
		}
		n = 0;
		return(true);
	}

	public bool on_body_data(Buffer data) {
		if(writer != null && data != null) {
			if(n + data.get_size() > maximum_size) {
				return(false);
			}
			writer.write(data, -1);
			n += data.get_size();
		}
		return(true);
	}

	public bool on_body_end() {
		writer = null;
		if(file == null) {
			return(false);
		}
		reader = file.read();
		if(reader == null) {
			return(false);
		}
		return(true);
	}

	public int read(Buffer buf) {
		if(reader != null) {
			return(reader.read(buf));
		}
		return(0);
	}
}
