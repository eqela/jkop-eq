
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

public class WPCSFacebookShareDialog : FacebookShareDialog
{	
	public void execute(Frame frame, SocialShareDialogListener listener) {
		var text = get_initial_text();
		if(String.is_empty(text)) {
			 text = "";
		}
		var sb = StringBuffer.create(text);
		var h = get_hashtags();
		foreach(String s in h) {
			if(String.is_empty(s)) {
				continue;
			}
			sb.append(s);
		}
		var sbt = sb.to_string();
		var p = sbt.to_strptr();
		var link = get_initial_link();
		if(String.is_empty(link)) {
			link = "";
		}
		var l = link.to_strptr();
		embed "cs" {{{	
			Microsoft.Phone.Tasks.ShareLinkTask shareLinkTask = new Microsoft.Phone.Tasks.ShareLinkTask();
			shareLinkTask.LinkUri = new System.Uri(l, System.UriKind.Absolute);
			shareLinkTask.Message = p;
			shareLinkTask.Show();
		}}}
	}
}
