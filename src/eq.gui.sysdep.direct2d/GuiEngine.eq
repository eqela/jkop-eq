
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

public class GuiEngine : GUI
{
	public bool is_image_file(File file) {
		return(file != null && (file.has_extension("png") || file.has_extension("jpg") || file.has_extension("ico")));
	}

	public RenderableImage create_renderable_image(int w, int h) {
		return(Direct2DRenderableBitmap.create(w, h));
	}

	public Image create_image_for_buffer(ImageBuffer buffer) {
		return(Direct2DImage.for_buffer(buffer));
	}

	public Image create_image_for_file(File file, int w, int h) {
		if(file == null) {
			return(null);
		}
		var v = Direct2DImage.for_file(file);
		if(v == null) {
			return(null);
		}
		return(v.resize(w, h));
	}

	public Image create_image_for_resource(String res, int w, int h) {
		if(res == null) {
			return(null);
		}
		var ares = File.for_eqela_path("/app/%s.png".printf().add(res).to_string());
		if(ares != null && ares.is_file() == false) {
			ares = File.for_eqela_path("/app/%s.jpg".printf().add(res).to_string());
		}
		if(ares != null && ares.is_file() == false) {
			ares = File.for_eqela_path("/app/%s.ico".printf().add(res).to_string());
		}
		return(create_image_for_file(ares, w, h));
	}

	public static Image crop(Image orig, int x, int y, int w, int h) {
		if(orig == null) {
			return(null);
		}
		var bm = Direct2DRenderableBitmap.create(w, h) as VgRenderableImage;
		if(bm == null) {
			return(null);
		}
		var vg = bm.get_vg_context();
		if(vg == null) {
			return(null);
		}
		vg.draw_graphic(-x, -y, null, orig);
		return(bm);
	}

	public Clipboard get_default_clipboard() {
		return(new Win32Clipboard());
	}

	public TextLayout layout_text(TextProperties props, Frame frame, int dpi) {
		if(props == null || frame == null) {
			return(null);
		}
		var d = dpi;
		if(d < 0 && frame != null) {
			d = frame.get_dpi();
		}
		if(d < 0) {
			d = 96;
		}
		var font = props.get_font();
		if(font == null) {
			return(null);
		}
		var font_name = font.get_name();
		if(font_name.has_suffix(".ttf") || font_name.has_suffix(".otf")) {
			return(Direct2DCustomFontTextLayout.create(props, dpi, font_name));
		}
		return(Direct2DTextLayout.create(props, d));
	}

	public bool open_url(String url) {
		return(Win32URLHandler.open(url));
	}

	public bool open_file(File file) {
		return(Win32FileHandler.open(file));
	}

	public BackgroundTaskManager get_background_task_manager() {
		return(Win32MainQueue.instance());
	}

	embed {{{
		#include <objbase.h>
	}}}

	public bool execute(FrameController main, String argv0, Collection args) {
		Win32COM.initialize();
		var el = get_background_task_manager() as Win32MainQueue;
		var frame = new Direct2DWindowFrame();
		if(frame.initialize(main) == false) {
			Log.error("Frame initialization failed.");
			return(false);
		}
		frame.show();
		el.execute();
		Direct2DFactory.release();
		embed {{{
			CoUninitialize();
		}}}
		return(true);
	}

	public WindowManager get_window_manager() {
		return(new Win32WindowManager());
	}
}
