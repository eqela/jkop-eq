
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

public class MinizWriter : ZipWriter
{
	property File file;
	ptr zip;

	embed {{{
		#include <string.h>
		#define MINIZ_HEADER_FILE_ONLY
		#include "miniz.c"
	}}}

	~MinizWriter() {
		close();
	}

	public MinizWriter initialize() {
		if(file == null || file.exists()) {
			return(null);
		}
		var filename = file.get_native_path();
		if(filename == null) {
			return(null);
		}
		var fns = filename.to_strptr();
		if(fns == null) {
			return(null);
		}
		ptr zp;
		embed {{{
			mz_zip_archive* zipp = (mz_zip_archive*)malloc(sizeof(mz_zip_archive));
			zp = zipp;
		}}}
		if(zp == null) {
			return(null);
		}
		bool err = false;
		embed {{{
			memset(zipp, 0, sizeof(mz_zip_archive));
			if(mz_zip_writer_init_file(zipp, fns, 0) == MZ_FALSE) {
				err = MZ_TRUE;
			}
		}}}
		if(err) {
			embed {{{
				free(zipp);
			}}}
			return(null);
		}
		this.zip = zp;
		return(this);
	}

	public bool add_buffer(Buffer buffer, String filename) {
		return(false); // FIXME
	}

	public bool add_file(File file, String afilename) {
		if(zip == null || file == null || String.is_empty(afilename)) {
			return(false);
		}
		var fs = file.stat();
		if(fs.is_file() == false && fs.is_directory() == false) {
			return(false);
		}
		var filename = afilename.replace_char('\\', '/');
		var fn = file.get_native_path();
		if(fn == null) {
			return(false);
		}
		var fns = fn.to_strptr();
		if(fns == null) {
			return(false);
		}
		if(fs.is_directory() && filename.has_suffix("/") == false) {
			filename = filename.append("/");
		}
		var dns = filename.to_strptr();
		if(dns == null) {
			return(false);
		}
		var zp = zip;
		bool err = false;
		if(fs.is_file()) {
			embed {{{
				if(mz_zip_writer_add_file((mz_zip_archive*)zp, dns, fns, NULL, 0, MZ_DEFAULT_COMPRESSION) == MZ_FALSE) {
					err = MZ_TRUE;
				}
			}}}
		}
		else if(fs.is_directory()) {
			embed {{{
				if(mz_zip_writer_add_mem((mz_zip_archive*)zp, dns, NULL, 0, MZ_DEFAULT_COMPRESSION) == MZ_FALSE) {
					err = MZ_TRUE;
				}
			}}}
		}
		return(!err);
	}

	public bool close() {
		var zp = zip;
		if(zp == null) {
			return(true);
		}
		this.zip = null;
		bool err = false;
		embed {{{
			if(mz_zip_writer_finalize_archive((mz_zip_archive*)zp) == MZ_FALSE) {
				err = MZ_TRUE;
			}
			if(mz_zip_writer_end((mz_zip_archive*)zp) == MZ_FALSE) {
				err = MZ_TRUE;
			}
			free(zp);
		}}}
		return(!err);
	}
}
