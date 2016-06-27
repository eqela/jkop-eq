
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

public class MinizReader : ZipReader
{
	embed {{{
		#define MINIZ_HEADER_FILE_ONLY
		#include "miniz.c"
	}}}

	property File file;
	property ptr zip;

	~MinizReader() {
		close();
	}

	public MinizReader initialize() {
		if(file == null) {
			return(null);
		}
		var fp = file.get_native_path();
		if(String.is_empty(fp)) {
			return(null);
		}
		var fps = fp.to_strptr();
		if(fps == null) {
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
			if(mz_zip_reader_init_file(zipp, fps, 0) == MZ_FALSE) {
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

	public bool close() {
		var zp = zip;
		if(zp == null) {
			return(true);
		}
		this.zip = null;
		bool err = false;
		embed {{{
			if(mz_zip_reader_end((mz_zip_archive*)zp) == MZ_FALSE) {
				err = MZ_TRUE;
			}
			free(zp);
		}}}
		return(!err);
	}

	class MyZipReaderEntry : ZipReaderEntry
	{
		property MinizReader reader;
		property int index;

		public bool write_to_file(File file) {
			if(file == null) {
				return(false);
			}
			if(get_is_directory()) {
				return(file.mkdir_recursive());
			}
			if(reader == null) {
				return(false);
			}
			var zp = reader.get_zip();
			if(zp == null) {
				return(false);
			}
			var dstf = file.get_native_path();
			if(dstf == null) {
				return(false);
			}
			var dstfs = dstf.to_strptr();
			if(dstfs == null) {
				return(false);
			}
			bool v;
			var idx = index;
			embed {{{
				v = mz_zip_reader_extract_to_file((mz_zip_archive*)zp, idx, dstfs, 0);
			}}}
			return(v);
		}
	}

	public Iterator entries() {
		var zp = zip;
		if(zp == null) {
			return(null);
		}
		int c;
		embed {{{
			c = (int)mz_zip_reader_get_num_files((mz_zip_archive*)zp);
		}}}
		if(c < 1) {
			return(null);
		}
		var v = LinkedList.create();
		int n;
		embed {{{
			mz_zip_archive_file_stat stat;
		}}}
		for(n=0; n<c; n++) {
			ptr filename;
			int compsize;
			int uncompsize;
			embed {{{
				if(mz_zip_reader_file_stat((mz_zip_archive*)zp, n, &stat) == MZ_FALSE) {
					continue;
				}
				filename = stat.m_filename;
				compsize = stat.m_comp_size;
				uncompsize = stat.m_uncomp_size;
			}}}
			var e = new MyZipReaderEntry();
			e.set_reader(this);
			e.set_index(n);
			var nx = String.for_strptr(filename);
			nx = nx.replace_char('\\', '/'); // just in case
			if(nx.has_suffix("/")) {
				e.set_name(nx.substring(0, nx.get_length()-1));
				e.set_is_directory(true);
			}
			else {
				e.set_name(nx);
				e.set_is_directory(false);
			}
			e.set_compressed_size(compsize);
			e.set_uncompressed_size(uncompsize);
			v.add(e);
		}
		return(v.iterate());
	}
}
