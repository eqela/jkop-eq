
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

public class HTML5WindowManager : WindowManager
{
	public WindowManagerScreen get_default_screen() {
		return(null);
	}

	public Collection get_screens() {
		return(null);
	}

	public Frame create_frame(FrameController fc, CreateFrameOptions opts) {
		if(opts == null || fc == null) {
			return(null);
		}
		var pp = opts.get_parent() as HTML5Frame;
		if(pp != null) {
			var pd = pp.get_document();
			if(pd != null) {
				Log.debug("Creating an iframe frame ..");
				ptr iframe;
				embed {{{
					iframe = pd.createElement("iframe");
					document.defaultView.top.document.body.appendChild(iframe);
				}}}
				return(HTML5Frame.for_frame_controller(fc, iframe));
			}
		}
		Log.debug("Opening a new HTML document window ..");
		ptr ww;
		embed {{{
			ww = window.open('', '', 'toolbar=no,status=no,menubar=no,scrollbars=no,resizable=yes,width=1,height=1');
		}}}
		return(HTML5Frame.for_frame_controller(fc, null, ww));
	}
}
