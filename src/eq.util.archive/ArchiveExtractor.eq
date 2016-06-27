
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

public interface ArchiveExtractor
{
	public static ArchiveExtractor for_file(File file, String type = null) {
		if(file == null) {
			return(null);
		}
		var tt = type;
		if(tt == null) {
			var bn = file.basename();
			if(bn == null) {
			}
			else if(bn.has_suffix(".zip")) {
				tt = "zip";
			}
			else if(bn.has_suffix(".tar.bz2") || bn.has_suffix(".tar.gz") || bn.has_suffix(".tgz") ||
				bn.has_suffix(".tbz2") || bn.has_suffix(".tar")) {
				tt = "tar";
			}
		}
		if("zip".equals(tt)) {
			var unzip = UnZip.instance();
			if(unzip == null) {
				return(null);
			}
			unzip.set_zipfile(file);
			return(unzip);
		}
		if("tar".equals(tt)) {
			var tar = Tar.instance();
			if(tar == null) {
				return(null);
			}
			tar.set_tarfile(file);
			return(tar);
		}
		return(null);
	}

	public bool extract_to_dir(File destdir, Logger logger = null);
	public bool extract_as_dir(File destdir, bool replace, Logger logger = null);
}
