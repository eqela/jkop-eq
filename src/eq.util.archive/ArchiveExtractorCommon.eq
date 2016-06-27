
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

public class ArchiveExtractorCommon : ArchiveExtractor
{
	public bool extract_to_dir(File destdir, Logger logger = null) {
		Log.error("Archive extractor: extract_to_dir not implemented.", logger);
		return(false);
	}

	public bool extract_as_dir(File destdir, bool replace, Logger logger) {
		if(destdir == null) {
			return(false);
		}
		var destdirparent = destdir.get_parent();
		if(destdirparent == null) {
			Log.error("Archive extractor: Destdir `%s' has no parent!".printf().add(destdir), logger);
			return(false);
		}
		var tmpdest = destdirparent.entry("_tmp_".append(destdir.basename()));
		Log.debug("Deleting temporary directory `%s' ..".printf().add(tmpdest), logger);
		tmpdest.delete_recursive();
		tmpdest.mkdir_recursive();
		if(extract_to_dir(tmpdest, logger) == false) {
			Log.debug("Failed to extract. Cleaning up temporary dir `%s' ..".printf().add(tmpdest), logger);
			tmpdest.delete_recursive();
			return(false);
		}
		if(destdir.exists()) {
			if(replace) {
				if(destdir.delete_recursive() == false) {
					Log.error("Archive extractor: Failed to delete: `%s'".printf().add(destdir), logger);
					tmpdest.delete_recursive();
					return(false);
				}
			}
			else {
				Log.error("Archive extractor: Already exists: `%s'".printf().add(destdir), logger);
				tmpdest.delete_recursive();
				return(false);
			}
		}
		bool v = false;
		int cc = 0;
		File tmpdestentry;
		foreach(File ff in tmpdest.entries()) {
			cc ++;
			if(ff.is_directory()) {
				tmpdestentry = ff;
			}
		}
		if(cc != 1 || tmpdestentry == null) {
			if(tmpdest.move(destdir) == false) {
				Log.error("FAILED to move: `%s' -> `%s'".printf().add(tmpdest).add(destdir), logger);
				tmpdest.delete_recursive();
				v = false;
			}
			else {
				v = true;
			}
		}
		else {
			if(tmpdestentry.move(destdir) == false) {
				Log.error("FAILED to move: `%s' -> `%s'".printf().add(tmpdestentry).add(destdir), logger);
				v = false;
			}
			else {
				v = true;
			}
			if(tmpdest.delete_recursive() == false) {
				Log.error("FAILED to delete temporary directory: `%s'".printf().add(tmpdest), logger);
			}
		}
		return(v);
	}
}
