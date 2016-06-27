
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
	public static HashTable icon_ids;

	public GuiEngine() {
		if(icon_ids == null) {
			icon_ids = HashTable.create();
		}
	}

	public bool is_image_file(File file) {
		if(file == null) {
			return(false);
		}
		return(file.has_extension("png") || file.has_extension("jpg"));
	}

	public RenderableImage create_renderable_image(int w, int h) {
		return(HTML5RenderableImage.create(w, h));
	}

	public Image create_image_for_buffer(ImageBuffer buffer) {
		return(HTML5RealImage.for_data(buffer));
	}

	public Image create_image_for_file(File file, int w, int h) {
		return(null); // FIXME
	}

	public Image create_image_for_resource(String id, int w, int h) {
		var url = GuiEngine.icon_ids.get_string(id);
		if(url == null) {
			return(null);
		}
		var v = HTML5RealImage.for_url(url);
		if(v == null) {
			return(null);
		}
		return(v.resize(w, h));
	}

	public Clipboard get_default_clipboard() {
		return(null); // FIXME
	}

	public TextLayout layout_text(TextProperties props, Frame frame, int dpi) {
		var d = dpi;
		if(d < 0 && frame != null) {
			d = frame.get_dpi();
		}
		if(d < 0) {
			d = 96;
		}
		var fontinfo = props.get_font();
		if(fontinfo != null) {
			var fn = fontinfo.get_name();
			if(fn != null && (fn.has_suffix(".ttf") || fn.has_suffix(".otf"))) {
				HTML5FontFaceManager.add_font(frame, fn);
			}
		}
		return(HTML5TextLayout.create(props, d));
	}

	public bool open_url(String url) {
		if(url != null) {
			embed "js" {{{
				var win = window.open(url.to_strptr());
				if(win == null) {
					win = window.open(url.to_strptr(), '_parent','' ,false);
				}
			}}}
		}
		return(true);
	}

	public bool open_file(File file) {
		return(false); // FIXME
	}

	public BackgroundTaskManager get_background_task_manager() {
		return(new HTML5BackgroundTaskManager());
	}

	public bool execute(FrameController main, String argv0, Collection args) {
		return(false);
	}

	public WindowManager get_window_manager() {
		return(new HTML5WindowManager());
	}
}
