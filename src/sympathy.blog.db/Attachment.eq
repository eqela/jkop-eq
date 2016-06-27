
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

public class Attachment
{
	public static Attachment for_directory(File dir) {
		return(new Attachment().set_directory(dir));
	}

	public static String get_valid_string(String orig) {
		if(orig == null) {
			return(null);
		}
		var sb = StringBuffer.create();
		var it = orig.iterate();
		if(it == null) {
			return(null);
		}
		int c;
		while((c = it.next_char()) > 0) {
			if((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9')) {
				sb.append_c(c);
			}
			else if(c == '.' || c == '_' || c == '-' || c == ':') {
				sb.append_c(c);
			}
		}
		return(sb.to_string());
	}

	property File directory;
	property String reference;
	property String filename;

	public bool exists() {
		var f = get_file();
		if(f == null) {
			return(false);
		}
		return(f.exists());
	}

	public File get_file() {
		var reference = get_valid_string(this.reference);
		var filename = get_valid_string(this.filename);
		if(String.is_empty(reference) || String.is_empty(filename)) {
			return(null);
		}
		if(directory == null) {
			return(null);
		}
		return(directory.entry(reference).entry(filename));
	}

	public bool delete(Error error) {
		var file = get_file();
		if(file == null) {
			Error.set_error_message(error, "Failed to find the attachment file");
			return(false);
		}
		file.remove();
		if(file.exists()) {
			Error.set_error_message(error, "Failed to delete file");
			return(false);
		}
		return(true);
	}
}
