
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
	embed {{{
		public static System.Windows.Controls.Panel rootframe;
	}}}

	public bool is_image_file(File file) {
		if(file == null) {
			return(false);
		}
		return(file.has_extension("png") || file.has_extension("jpg") || file.has_extension("jpeg"));
	}

	public RenderableImage create_renderable_image(int w, int h) {
		var v = new WPCSImage().set_ocwidth(w).set_ocheight(h).set_type(WPCSImage.RENDERABLE_IMAGE);
		return(v.initialize());
	}

	public Image create_image_for_buffer(ImageBuffer ib) {
		if(ib == null) {
			return(null);
		}
		return(new WPCSImage().set_type(WPCSImage.BUFFER_IMAGE).set_buffer(ib.get_buffer()).initialize());
	}

	public Image create_image_for_file(File file, int w, int h) {
		if(file == null) {
			return(null);
		}
		var v = new WPCSImage().set_file(file).set_type(WPCSImage.FILE_IMAGE).initialize();
		if(v != null && (w > 0 || h > 0)) {
			return(v.resize(w, h));
		}
		return(v);
	}

	public Image load_image_extension(String res, String ext) {
		String resfn = "Assets/%s.%s".printf().add(res).add(ext).to_string();
		Image v;
		embed "cs" {{{
			var uri = new System.Uri(resfn.to_strptr(), System.UriKind.RelativeOrAbsolute);
			System.Windows.Resources.StreamResourceInfo srinfo = System.Windows.Application.GetResourceStream(uri);
			if(srinfo == null) {
				return(null);
			}
			var bmp = new System.Windows.Media.Imaging.BitmapImage();
			bmp.SetSource(srinfo.Stream);
			v = WPCSImage.create_from_native_bitmap(bmp);
		}}}
		return(v);
	}

	public Image create_image_for_resource(String res, int w, int h) {
		if(res == null) {
			return(null);
		}
		var v = load_image_extension(res, "png");
		if(v == null) {
			v = load_image_extension(res, "jpg");
		}
		if(v != null && (w > 0 || h > 0)) {
			return(v.resize(w, h));
		}
		return(v);
	}

	public Clipboard get_default_clipboard() {
		return(null); //FIXME: implement
	}

	public TextLayout layout_text(TextProperties props, Frame frame, int adpi) {
		int dpi = -1;
		if(frame != null) {
			dpi = frame.get_dpi();
		}
		if(adpi > 0) {
			dpi = adpi;
		}
		if(dpi < 0) {
			dpi = 96;
		}
		return(WPCSTextLayout.create(props, dpi));
	}

	public bool open_url(String url) {
		if(String.is_empty(url) == false) {
			embed "cs" {{{
				var wbt = new Microsoft.Phone.Tasks.WebBrowserTask();
				wbt.Uri = new System.Uri(url.to_strptr());
				wbt.Show();
			}}}
			return(true);
		}
		return(false);
	}

	public bool open_file(File file) {
		return(false); // FIXME
	}

	public BackgroundTaskManager get_background_task_manager() {
		return(new WPCSEventLoop());
	}

	public bool execute(FrameController main, String argv0, Collection args) {
		return(false);
	}

	public WindowManager get_window_manager() {
		return(new WPCSWindowManager());
	}
}
