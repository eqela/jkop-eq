
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

public class SocialShareDialog
{
	property String initial_text;
	property String initial_link;
	property Collection hashtags;

	public void add_hashtag(String hashtag) {
		if(String.is_empty(hashtag)) {
			return;
		}
		if(hashtags == null) {
			hashtags = LinkedList.create();
		}
		var sb = StringBuffer.create(" #");
		var it = hashtag.iterate();
		while(it != null) {
			var nc = it.next_char();
			if(nc < 1) {
				break;
			}
			if((nc >= 'a' && nc <= 'z') || (nc >= 'A' && nc <= 'Z')
				|| (nc >= '0' && nc <= '9')) {
				sb.append_c(nc);
			}
		}
		if(sb.count() < 1) {
			return;
		}
		hashtags.add(sb.to_string());
	}

	public void add_link(String link) {
		if(String.is_empty(link)) {
			return;
		}
		if(link.has_prefix("https://") || link.has_prefix("http://")) {
			set_initial_link(link);
			return;
		}
		set_initial_link("http://%s".printf().add(link).to_string());
	}

	public virtual void execute(Frame frame, SocialShareDialogListener listener = null) {
	}
}
