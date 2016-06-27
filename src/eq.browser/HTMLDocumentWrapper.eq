
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

public class HTMLDocumentWrapper : HTMLDocument
{
	public static ptr load_handler = null;
	public static ptr resize_handler = null;

	public static void set_handlers(ptr load, ptr resize) {
		load_handler = load;
		resize_handler = resize;
	}

	property ptr click_handler = null;

	public void on_load() {
		base.on_load();
		var lh = HTMLDocumentWrapper.load_handler;
		embed {{{
			if(lh != null) {
				lh();
			}
		}}}
	}

	public void on_click_id(String id) {
		base.on_click_id(id);
		strptr idp = null;
		if(id != null) {
			idp = id.to_strptr();
		}
		var ch = click_handler;
		embed {{{
			if(ch != null) {
				ch(idp);
			}
		}}}
	}

	public void on_resize(int w, int h) {
		base.on_resize(w, h);
		var rh = resize_handler;
		embed {{{
			if(rh != null) {
				rh(w, h);
			}
		}}}
	}
}
