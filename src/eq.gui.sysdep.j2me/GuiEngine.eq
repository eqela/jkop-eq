
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
	BackgroundTaskManager btm;

	public bool is_image_file(File file) {
		return(file != null && (file.has_extension("png") || file.has_extension("jpg")));
	}

	public RenderableImage create_renderable_image(int w, int h) {
		RenderableImage v;
		embed "java" {{{
			v = J2MEImage.create_bitmap_image(w, h, null, 32, 0);
		}}}
		return(v);
	}

	public Image create_image_for_buffer(ImageBuffer buf) {
		if(buf == null) {
			return(null);
		}
		if("image/x-rgba".equals(buf.get_type()) == false) {
			return(null);
		}
		Image v = null;
		embed "java" {{{
			v = J2MEImage.buffer_to_image(buf.get_buffer());
		}}}
		return(v);
	}

	public Image create_image_for_file(File file, int w, int h) {
		if(file == null) {
			return(null);
		}
		Image v = null;
		embed "java" {{{
			v = (eq.gui.Image)J2MEImage.read_image_file(((eq.api.Stringable)file).to_string());
		}}}
		if(v == null) {
			return(null);
		}
		return(v.resize(w, h));
	}

	public Image create_image_for_resource(String res, int w, int h) {
		if(res == null) {
			return(null);
		}
		Image v = null;
		var strres = "/%s.png".printf().add(res).to_string();
		embed "java" {{{
			v = (eq.gui.Image)J2MEImage.read_image_file(strres);
		}}}
		if(v == null) {
			return(null);
		}
		return(v.resize(w, h));
	}

	static Image crop(Image orig, int x, int y, int w, int h) {
		/*if(orig == null) {
			return(null);
		}
		var bm = J2MERenderableBitmap.create(w, h) as VgRenderableImage;
		if(bm == null) {
			return(null);
		}
		var vg = bm.get_vg_context();
		if(vg == null) {
			return(null);
		}
		vg.draw_graphic(-x, -y, null, orig);
		return(bm);	*/
		return(null);
	}

	public Clipboard get_default_clipboard() {
		return(null);
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
		return(J2METextLayout.create(props, dpi));
	}

	public bool open_url(String url) {
		// FIXME
		return(false);
	}

	public bool open_file(File file) {
		return(false); // FIXME
	}

	public BackgroundTaskManager get_background_task_manager() {
		if(btm == null) {
			btm = new J2MEBackgroundTaskManager();
		}
		return(btm);
	}

	public WindowManager get_window_manager() {
		return(new J2MEWindowManager());
	}

	public bool execute(FrameController main, String argv0, Collection args) {
		return(false);
	}
}
