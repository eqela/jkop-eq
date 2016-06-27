
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

public class TemporaryFile
{
	public static File create(String extension = null) {
		return(for_directory(null, extension));
	}

	public static File for_directory(File dir, String extension = null) {
		var tmpdir = dir;
		if(tmpdir == null) {
			tmpdir = File.for_temporary_directory();
		}
		if(tmpdir == null || tmpdir.is_directory() == false) {
			return(null);
		}
		File v;
		int n = 0;
		while(n < 100) {
			var id = "_tmp_%d_%d".printf().add((int)SystemClock.seconds()).add(Math.random(0, 1000000)).to_string();
			if(String.is_empty(extension) == false) {
				id = "%s%s".printf().add(id).add(extension).to_string();
			}
			v = tmpdir.entry(id);
			if(v.exists() == false) {
				v.touch();
				break;
			}
			n++;
		}
		if(v != null && v.is_file() == false) {
			v = null;
		}
		return(v);
	}
}
