
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

public class CachedFile : Stringable
{
	property File file;
	int timestamp = -1;

	public bool set_contents_string(String str) {
		if(file != null) {
			var r = file.set_contents_string(str);
			if(r) {
				update_from_file(file);
			}
			return(r);
		}
		return(false);
	}

	public bool set_contents_buffer(Buffer buffer) {
		if(file != null) {
			var r = file.set_contents_buffer(buffer);
			if(r) {
				update_from_file(file);
			}
			return(r);
		}
		return(false);
	}

	public virtual void update_from_file(File file) {
	}

	void update() {
		timestamp = 0;
		if(file != null) {
			var fi = file.stat();
			if(fi != null) {
				timestamp = fi.get_modify_time();
			}
			update_from_file(file);
		}
	}

	public void on_get_contents() {
		if(file == null) {
			return;
		}
		if(timestamp < 0) {
			update();
		}
		else {
			var fi = file.stat();
			if(fi == null) {
				update();
			}
			else {
				if(fi.get_modify_time() > timestamp) {
					update();
				}
			}
		}
	}

	public String to_string() {
		if(file != null) {
			return(file.to_string());
		}
		return(null);
	}
}
