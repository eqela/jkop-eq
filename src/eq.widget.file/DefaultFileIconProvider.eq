
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

public class DefaultFileIconProvider : FileIconProvider
{
	MimeTypeRegistry types;
	public Image get_icon_for_file(File file) {
		if(file == null) {
			return(null);
		}
		if(types == null) {
			types = MimeTypeRegistry.instance();
		}
		if(types == null) {
			return(null);
		}
		String icon;
		String mt;
		if(file.is_directory()) {
			icon = "fileicon_folder";
		}
		else if((mt = types.get_mimetype(file.basename())) == null) {
		}
		else if("text/x-eqela-src".equals(mt)) {
			icon = "fileicon_eqela";
		}
		else if("text/x-config".equals(mt)) {
			icon = "fileicon_eqela";
		}
		else if(mt.has_prefix("image/")) {
			icon = "fileicon_image";
		}
		else if(mt.has_prefix("archive/")) {
			icon = "fileicon_archive";
		}
		else if(mt.has_prefix("document/")) {
			icon = "fileicon_document";
		}
		else if("text/html".equals(mt)) {
			icon = "fileicon_html";
		}
		else if(mt.has_prefix("text/")) {
			icon = "fileicon_text";
		}
		else if("application/json".equals(mt)) {
			icon = "fileicon_text";
		}
		else if(mt.str("/pdf") >= 0) {
			icon = "fileicon_pdf";
		}
		else if(mt.str("sheet") >= 0) {
			icon = "fileicon_spreadsheet";
		}
		else if(mt.str("-diskimage") >= 0 || mt.str("-cd-image") >= 0) {
			icon = "fileicon_diskimage";
		}
		if(String.is_empty(icon)) {
			icon = "fileicon_generic";
		}
		return(IconCache.get(icon, -1, -1, true));
	}
}
