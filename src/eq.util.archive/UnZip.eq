
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

public class UnZip : ArchiveExtractorCommon
{
	public static UnZip instance() {
		return(new UnZip());
	}

	public static bool is_available() {
		return(true);
	}

	property File zipfile;

	public bool extract_to_dir(File destpath, Logger logger = null) {
		if(zipfile == null) {
			Log.error("No file to extract", logger);
			return(false);
		}
		if(destpath == null) {
			Log.error("No destination path given", logger);
			return(false);
		}
		var zr = ZipReader.for_file(zipfile);
		if(zr == null) {
			Log.error("Failed to open ZIP file: `%s'".printf().add(zipfile), logger);
			return(false);
		}
		destpath.mkdir_recursive();
		if(destpath.is_directory() == false) {
			Log.error("Failed to create directory: `%s'".printf().add(destpath), logger);
			return(false);
		}
		var e = new Error();
		foreach(ZipReaderEntry zre in zr.entries()) {
			if(zre.write_to_dir(destpath, true, true, e) == null) {
				Log.error(e, logger);
				return(false);
			}
		}
		return(true);
	}
}
