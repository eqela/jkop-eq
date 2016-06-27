
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

public class Tmpdir : FileExtender
{
	public static Tmpdir create(File abasedir = null, String aid = null, bool transient = true, Logger logger = null) {
		var basedir = abasedir;
		if(basedir == null) {
			basedir = File.for_eqela_path("/tmp");
		}
		int n = 0;
		File dd;
		while(true) {
			var id = aid;
			if(String.is_empty(id)) {
				id = "%d_%d".printf().add((int)SystemClock.seconds()).add(Math.random(0, 1000000)).to_string();
			}
			if(n > 0) {
				id = "%s_%02d".printf().add(id).add(n).to_string();
			}
			dd = basedir.entry("_tmp_".append(id));
			if(dd.exists() == false) {
				break;
			}
			n++;
			if(n > 100) {
				Log.error("Tried a 100 times but failed to find a vacant temporary directory name. Giving up.");
				return(null);
			}
		}
		if(dd.is_directory() == false) {
			dd.mkdir_recursive();
		}
		if(dd.is_directory() == false) {
			Log.error("Failed to create temporary directory: `%s'".printf().add(dd), logger);
			dd = null;
		}
		if(dd == null) {
			return(null);
		}
		return((Tmpdir)new Tmpdir().set_logger(logger).set_transient(transient).set_file(dd));
	}

	property bool transient = true;
	property Logger logger;

	~Tmpdir() {
		release();
	}

	public void release() {
		var dir = get_file();
		if(dir != null && dir.exists() && transient) {
			Log.debug("Releasing tmpdir: `%s'".printf().add(this), logger);
			dir.delete_recursive();
		}
	}
}
