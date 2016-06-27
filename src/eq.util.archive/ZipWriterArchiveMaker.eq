
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

public class ZipWriterArchiveMaker : ArchiveMaker
{
	public static ZipWriterArchiveMaker for_output_file(File file) {
		var zw = ZipWriter.for_output_file(file);
		if(zw == null) {
			return(null);
		}
		return(new ZipWriterArchiveMaker().set_zipwriter(zw));
	}

	property ZipWriter zipwriter;
	bool failed = false;

	String get_relative_path(File file, File relative_to, String prefix) {
		var nn = String.as_string(relative_to);
		var filen = String.as_string(file);
		if(filen == null) {
			return(null);
		}
		if(filen.has_prefix(nn)) {
			filen = filen.substring(nn.get_length());
			while(filen.has_prefix("/") || filen.has_prefix("\\")) {
				filen = filen.substring(1);
			}
		}
		filen = filen.replace_char((int)'\\', (int)'/');
		if(String.is_empty(prefix) == false) {
			filen = prefix.append(filen);
		}
		return(filen);
	}

	public ArchiveMaker add(File ff, File relative_to, String prefix) {
		if(zipwriter == null || ff == null) {
			return(this);
		}
		var rt = relative_to;
		if(rt == null) {
			rt = ff;
			if(rt.is_file()) {
				rt = rt.get_parent();
			}
		}
		if(ff.is_file()) {
			if(zipwriter.add_file(ff, get_relative_path(ff, rt, prefix)) == false) {
				failed = true;
			}
			return(this);
		}
		if(ff.is_directory() == false) {
			return(this);
		}
		foreach(File file in FileFinder.for_root(ff)) {
			if(zipwriter.add_file(file, get_relative_path(file, rt, prefix)) == false) {
				failed = true;
			}
		}
		return(this);
	}

	public bool finalize_archive() {
		if(zipwriter == null) {
			return(false);
		}
		var v = zipwriter.close();
		zipwriter = null;
		if(failed) {
			return(false);
		}
		return(v);
	}
}
