
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

public class XamlClipboard : Clipboard
{
	public XamlClipboard() {
	}

	public bool set_data(ClipboardData data) {
		var dt = data;
		if(dt == null) {
			dt = ClipboardData.for_string("");
		}
		embed {{{
			var data_package = new Windows.ApplicationModel.DataTransfer.DataPackage();
		}}}
		if("text/plain".equals(dt.get_mimetype())) {
			var str = dt.to_string();
			if(str != null) {
				embed {{{
					data_package.SetText(str.to_strptr());
				}}}
			}
		}
		else {
			Log.error("XamlClipboard.set_data: Mime type `%s' is not supported".printf().add(dt.get_mimetype()));
			return(false);
		}
		embed {{{
			Windows.ApplicationModel.DataTransfer.Clipboard.SetContent(data_package);
		}}}
		return(true);
	}

	public bool set_data_provider(ClipboardDataProvider dp) {
		//FIXME
		return(false);
	}

	public bool get_data(EventReceiver listener) {
		embed {{{
			var dp = Windows.ApplicationModel.DataTransfer.Clipboard.GetContent();
			if(dp.Contains(Windows.ApplicationModel.DataTransfer.StandardDataFormats.Text)) {
				var mutex = new System.Threading.ManualResetEvent(false);
				var ao = dp.GetTextAsync();
				ao.Completed = (sender, args) => {
					mutex.Set();
				};
				mutex.WaitOne();
				mutex.Reset();
				var txt = ao.GetResults();
				if(listener != null) {
					 listener.on_event((eq.api.Object)eq.gui.CClipboardData.for_string(eq.api.CString.for_strptr(txt)));
				}
			}
		}}}
		return(false);
	}
}