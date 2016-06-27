
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

public class AWTClipboard : Clipboard
{
	public bool set_data(ClipboardData data) {
		embed {{{
			java.awt.datatransfer.Clipboard clipboard = java.awt.Toolkit.getDefaultToolkit().getSystemClipboard();
			if(clipboard == null) {
				return(false);
			}
		}}}
		var mt = data.get_mimetype();
		if("text/plain".equals(mt)) {
			var text = data.to_string();
			if(text == null) {
				return(false);
			}
			embed {{{
				java.awt.datatransfer.StringSelection ss = new java.awt.datatransfer.StringSelection(text.to_strptr());
				clipboard.setContents(ss, ss);
			}}}
			return(true);
		}
		else {
			Log.debug("AWTClipboard.set_data: Implement for `%s'".printf().add(mt));
		}
		return(false);
	}

	public bool set_data_provider(ClipboardDataProvider dp) {
		//FIXME
		return(false);
	}

	void _event(Object listener, Object o) {
		EventReceiver.event(listener, o);
	}

	Object _cdata(String s) {
		return(ClipboardData.for_string(s));
	}

	public bool get_data(EventReceiver listener) {
		embed {{{
			java.awt.datatransfer.Clipboard clipboard = java.awt.Toolkit.getDefaultToolkit().getSystemClipboard();
			if(clipboard == null) {
				return(false);
			}
			java.awt.datatransfer.Transferable trans = clipboard.getContents(null);
			if(trans != null) {
				try {
					String s = (String)trans.getTransferData(java.awt.datatransfer.DataFlavor.stringFlavor);
					if(s != null) {
						_event((eq.api.Object)listener, _cdata(_S(s)));
						return(true);
					}
				}
				catch(Exception e) {
					e.printStackTrace();
				}
			}
		}}}
		return(false);
	}
}