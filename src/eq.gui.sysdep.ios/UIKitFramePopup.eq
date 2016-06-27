
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

public class UIKitFramePopup : UIKitFrame, ClosableFrame
{
	public static UIKitFramePopup create(FrameController fc) {
		var v = new UIKitFramePopup();
		if(v.do_create(fc) == false) {
			v = null;
		}
		return(v);
	}

	embed {{{
		#import <UIKit/UIKit.h>
	}}}

	public UIKitFramePopup() {
		set_is_popup(true);
	}

	bool closed = false;

	public void close() {
		if(closed) {
			return;
		}
		var vc = get_view_controller();
		if(vc == null) {
			return;
		}
		IOSPopupSynchronizer.pop_view_controller(vc);
		closed = true;
	}
}
