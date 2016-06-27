
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

public interface Frame : SurfaceContainer, Size
{
	public static Frame open(FrameController fc) {
		if(fc == null) {
			Log.error("Frame.open: No frame controller given.");
			return(null);
		}
		var wm = GUI.engine.get_window_manager();
		if(wm == null) {
			Log.error("Frame.open: No window manager. Cannot create a new frame");
			return(null);
		}
		var opts = fc.get_frame_options();
		if(opts == null) {
			opts = new CreateFrameOptions();
		}
		return(wm.create_frame(fc, opts));
	}

	public static Frame open_full_screen(FrameController fc) {
		if(fc == null) {
			Log.error("Frame.open_full_screen: No frame controller given.");
			return(null);
		}
		var wm = GUI.engine.get_window_manager();
		if(wm == null) {
			Log.error("Frame.open_full_screen: No window manager. Cannot create a new frame");
			return(null);
		}
		var opts = fc.get_frame_options();
		if(opts == null) {
			opts = new CreateFrameOptions();
		}
		opts.set_type(CreateFrameOptions.TYPE_FULLSCREEN);
		return(wm.create_frame(fc, opts));
	}

	public static Frame open_on_external_screen(FrameController fc, WindowManagerScreen screen = null) {
		if(fc == null) {
			Log.error("Frame.open_on_external_screen: No frame controller given.");
			return(null);
		}
		var wm = GUI.engine.get_window_manager();
		if(wm == null) {
			Log.error("Frame.open_on_external_screen: No window manager. Cannot create a new frame");
			return(null);
		}
		var opts = fc.get_frame_options();
		if(opts == null) {
			opts = new CreateFrameOptions();
		}
		var escreen = screen;
		if(escreen == null) {
			var screens = wm.get_screens();
			if(screens != null && screens.count() > 1) {
				escreen = screens.get(1) as WindowManagerScreen;
			}
		}
		if(escreen == null) {
			return(null);
		}
		opts.set_screen(escreen);
		opts.set_type(CreateFrameOptions.TYPE_FULLSCREEN);
		return(wm.create_frame(fc, opts));
	}

	public static Frame open_as_popup(FrameController fc, Frame parent) {
		if(fc == null) {
			Log.error("Frame.open_as_popup: No frame controller given.");
			return(null);
		}
		var wm = GUI.engine.get_window_manager();
		if(wm == null) {
			Log.error("Frame.open_as_popup: No window manager. Cannot create a new frame");
			return(null);
		}
		var opts = fc.get_frame_options();
		if(opts == null) {
			opts = new CreateFrameOptions();
		}
		opts.set_parent(parent);
		return(wm.create_frame(fc, opts));
	}

	public static Frame close(Frame frame) {
		var cf = frame as ClosableFrame;
		if(cf != null) {
			cf.close();
		}
		return(null);
	}

	public static int TYPE_DESKTOP = 0;
	public static int TYPE_TABLET = 1;
	public static int TYPE_PHONE = 2;
	public static int TYPE_TV = 3;
	public static int TYPE_WATCH = 4;
	public static int TYPE_OTHER = 5;

	public int get_frame_type();
	public bool has_keyboard();
	public FrameController get_controller();
	public int get_dpi();
}
