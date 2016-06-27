
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
		if(file == null) {
			return(false);
		}
		var ext = file.extension();
		if("jpg".equals_ignore_case(ext) || "png".equals_ignore_case(ext) || "jpeg".equals_ignore_case(ext)) {
			return(true);
		}
		return(false);
	}

	public RenderableImage create_renderable_image(int w, int h) {
		return(GtkRenderableImage.create(w, h));
	}

	public Image create_image_for_buffer(ImageBuffer ib) {
		if(ib == null) {
			return(null);
		}
		return(ImageBufferHelper.buffer_to_image(ib.get_buffer(), ib.get_type()));
	}

	public Image create_image_for_file(File file, int w, int h) {
		var v = GtkFileImage.for_file(file);
		if(v == null) {
			return(null);
		}
		return(v.resize(w, h));
	}

	public static Image crop(Image orig, int x, int y, int w, int h) {
		if(orig == null) {
			return(null);
		}
		var bm = GtkRenderableImage.create(w, h) as VgRenderableImage;
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

	embed "c" {{{
		#include <gtk/gtk.h>
	}}}

	static File try_icon_path(String path) {
		var f = File.for_eqela_path(path);
		if(f.is_file()) {
			return(f);
		}
		return(null);
	}

	static File icon_file(String icon) {
		if(icon == null) {
			return(null);
		}
		File v;
		v = try_icon_path("/app/icons/%s.png".printf().add(icon).to_string());
		if(v != null) {
			return(v);
		}
		v = try_icon_path("/app/icons/%s.jpg".printf().add(icon).to_string());
		if(v != null) {
			return(v);
		}
		v = try_icon_path("/app/%s.png".printf().add(icon).to_string());
		if(v != null) {
			return(v);
		}
		v = try_icon_path("/app/%s.jpg".printf().add(icon).to_string());
		if(v != null) {
			return(v);
		}
		v = try_icon_path("/native/usr/share/pixmaps/%s.png".printf().add(icon).to_string());
		if(v != null) {
			return(v);
		}
		v = try_icon_path("/native/usr/share/pixmaps/%s.jpg".printf().add(icon).to_string());
		if(v != null) {
			return(v);
		}
		return(null);
	}

	public Image create_image_for_resource(String id, int w, int h) {
		var file = icon_file(id);
		if(file != null) {
			var v = GtkFileImage.for_file(file);
			if(v == null) {
				return(v);
			}
			return(v.resize(w, h));
		}
		else {
			Log.debug("No icon by id `%s' was found.".printf().add(id));
		}
		return(null);
	}

	public Clipboard get_default_clipboard() {
		return(new GtkClipboard());
	}

	public TextLayout layout_text(TextProperties props, Frame frame, int adpi) {
		if(props == null || frame == null) {
			return(null);
		}
		int dpi = 96;
		if(frame != null) {
			dpi = frame.get_dpi();
		}
		if(adpi > 0) {
			dpi = adpi;
		}
		var font = props.get_font();
		if(font == null) {
			return(null);
		}
		var font_name = font.get_name();
		if(font_name.has_suffix(".ttf")) {
			return(FreeTypeTextLayout.create(props, dpi, font_name));
		}
		return(PangoTextLayout.create(props, dpi));
	}

	public bool open_url(String url) {
		return(GtkUrlHandler.open(url));
	}

	public bool open_file(File file) {
		if(file != null) {
			var nautilus = SystemEnvironment.find_command("nautilus");
			if(nautilus!=null) {
				ProcessLauncher.for_file(nautilus).add_param_file(file).start();
				return(true);
			}
		}
		return(false);
	}

	public BackgroundTaskManager get_background_task_manager() {
		if(btm == null) {
			btm = new GtkEventLoop();
		}
		return(btm);
	}

	public bool execute(FrameController main, String argv0, Collection args) {
		var el = get_background_task_manager() as GtkEventLoop;
		var frame = new GtkWindowFrame();
		frame.initialize(main);
		frame.show();
		el.execute();
		return(true);
	}

	public WindowManager get_window_manager() {
		return(new GtkWindowManager());
	}
}
