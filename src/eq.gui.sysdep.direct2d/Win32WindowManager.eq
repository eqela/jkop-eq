
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

public class Win32WindowManager : WindowManager
{
	embed {{{
		#include <windows.h>
	}}}

	Array screens;

	public Win32WindowManager() {
		screens = Array.create();
	}

	public WindowManagerScreen get_default_screen() {
		var ss = get_screens();
		if(ss != null) {
			return(ss.get(0) as WindowManagerScreen);
		}
		return(null);
	}

	public void clear() {
		screens = Array.create();
	}

	public void add_screen_monitor(ptr hmonitor) {
		screens.add(new Win32WindowManagerScreen().set_monitor(hmonitor));
	}

	embed {{{
		BOOL CALLBACK MyMonitorInfoCallback(HMONITOR hMonitor, HDC hdcMonitor, LPRECT lprcMonitor, LPARAM self) {
			eq_gui_sysdep_direct2d_Win32WindowManager_add_screen_monitor(self, (void*)hMonitor);
			return(TRUE);
		}
	}}}

	public Collection get_screens() {
		clear();
		embed {{{
			EnumDisplayMonitors(NULL, NULL, MyMonitorInfoCallback, self);
		}}}
		return(screens);
	}

	public Frame create_frame(FrameController fc, CreateFrameOptions opts) {
		var v = new Direct2DWindowFrame();
		v.initialize(fc, opts);
		return(v);
	}
}
