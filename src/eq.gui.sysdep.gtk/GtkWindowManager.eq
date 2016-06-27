
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

public class GtkWindowManager : WindowManager
{
	embed "c" {{{
		#include <gdk/gdk.h>
	}}}

	public WindowManagerScreen get_default_screen() {
		var screens = get_screens();
		if(screens == null) {
			return(null);
		}
		return(screens.get_index(0) as GtkWindowManagerScreen);
	}

	public Collection get_screens() {
		int n = 0;
		embed "c" {{{
			GdkScreen *screen = gdk_display_get_default_screen(gdk_display_get_default());
			if(screen != NULL) {
				n = gdk_screen_get_n_monitors(screen);
			}
		}}}
		var v = LinkedList.create();
		int x;
		for(x = 0; x < n; x++) {
			v.add(new GtkWindowManagerScreen().set_index(x));
		}
		return(v);
	}

	public Frame create_frame(FrameController fc, CreateFrameOptions opts) {
		var v = new GtkWindowFrame();
		v.initialize(fc, opts);
		v.show();
		return(v);
	}
}
