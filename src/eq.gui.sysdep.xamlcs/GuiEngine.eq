
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
	WindowManager wmgr;

	embed {{{
		public static Windows.UI.Xaml.Controls.Panel root_panel;
	}}}

	public bool is_image_file(File file) {
		if(file == null) {
			return(false);
		}
		return(file.has_extension("jpg") ||
			file.has_extension("png") ||
			file.has_extension("jpeg") ||
			file.has_extension("gif") ||
			file.has_extension("bmp") ||
			file.has_extension("ico"));
	}

	public RenderableImage create_renderable_image(int w, int h) {
		return(XamlRenderableAsyncImage.create_renderable_image(w, h));
	}

	public Image create_image_for_buffer(ImageBuffer buf) {
		if(buf == null) {
			return(null);
		}
		if("image/x-rgba".equals(buf.get_type())) {
			return(XamlImage.create_image_from_pixels(buf.get_buffer(), buf.get_width(), buf.get_height()));
		}
		return(null);
	}

	public Image create_image_for_file(File file, int w, int h) {
		if(file == null || file.is_file() == false) {
			return(null);
		}
		return(XamlImage.create_image_from_file(file, w, h));
	}

	public Image create_image_for_resource(String res, int w, int h) {
		return(XamlImage.create_image_from_resource(res, w, h));
	}

	public Clipboard get_default_clipboard() {
		return(new XamlClipboard());
	}

	public TextLayout layout_text(TextProperties props, Frame frame, int adpi) {
		if(props == null) {
			return(null);
		}
		var dpi = adpi;
		if(dpi < 1 && frame != null) {
			dpi = frame.get_dpi();
		}
		if(dpi < 1) {
			dpi = 96;
		}
		return(XamlTextLayout.create(props, adpi));
	}

	public bool open_url(String url) {
		if(String.is_empty(url) || url.has_prefix("http") == false) {
			return(false);
		}
		strptr urlstr = url.to_strptr();
		if(urlstr != null) {
			embed {{{
				var uri = new System.Uri(urlstr);
				Windows.System.Launcher.LaunchUriAsync(uri);
				return(true);
			}}}
		}
		return(false);
	}

	public bool open_file(File file) {
		return(false); //FIXME
	}

	public BackgroundTaskManager get_background_task_manager() {
		if(btm == null) {
			btm = new XamlBackgroundTaskManager();
		}
		return(btm);
	}

	public bool execute(FrameController main, String argv0, Collection args) {
		return(false);
	}

	public WindowManager get_window_manager() {
		if(wmgr == null) {
			wmgr = new XamlWindowManager();
		}
		return(wmgr);
	}
}