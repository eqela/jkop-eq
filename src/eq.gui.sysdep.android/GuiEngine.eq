
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
		if(file == null) {
			return(false);
		}
		return(file.has_extension("png") || file.has_extension("jpg") || file.has_extension("jpeg"));
	}

	public RenderableImage create_renderable_image(int w, int h) {
		return(AndroidBitmapImage.for_size(w, h) as RenderableImage);
	}

	public Image create_image_for_buffer(ImageBuffer ib) {
		if(ib == null) {
			return(null);
		}
		var buffer = ib.get_buffer();
		var type = ib.get_type();
		if(buffer == null) {
			return(null);
		}
		var ptr = buffer.get_pointer();
		if(ptr == null) {
			return(null);
		}
		var bytearray = ptr.get_native_pointer();
		Image v = null;
		embed "java" {{{
			android.graphics.BitmapFactory.Options opts = new android.graphics.BitmapFactory.Options();
			opts.inJustDecodeBounds = true;
		}}}
		embed "java" {{{
			v = AndroidBitmapImage.for_android_bitmap(android.graphics.BitmapFactory.decodeByteArray(bytearray, 0, bytearray.length, opts));
			if(opts.outHeight > 2000 || opts.outWidth > 2000) {
				opts.inSampleSize = 2;
			}
			try {
				opts.inJustDecodeBounds = false;
				v = AndroidBitmapImage.for_android_bitmap(android.graphics.BitmapFactory.decodeByteArray(bytearray, 0, bytearray.length, opts));
			}
			catch(Exception e) {
				eq.api.Log.Static.error((eq.api.Object)eq.api.String.Static.for_strptr("*** EXCEPTION CAUGHT WHEN DECODING A BITMAP ***"), null, null);
				e.printStackTrace();
				v = null;
			}
			catch(OutOfMemoryError e) {
				eq.api.Log.Static.error((eq.api.Object)eq.api.String.Static.for_strptr("*** OUT OF MEMORY ERROR WHEN DECODING A BITMAP ***"), null, null);
				e.printStackTrace();
				v = null;
			}
		}}}
		return(v);
	}

	public Image create_image_for_file(File file, int w, int h) {
		if(file == null) {
			return(null);
		}
		var filename = file.get_native_path();
		if(filename == null) {
			return(null);
		}
		embed "java" {{{
			android.graphics.BitmapFactory.Options opts = new android.graphics.BitmapFactory.Options();
			opts.inJustDecodeBounds = true;
		}}}
		Image v = null;
		embed "java" {{{
			v = AndroidBitmapImage.for_android_bitmap(android.graphics.BitmapFactory.decodeFile(filename.to_strptr(), opts));
			if(opts.outHeight > 2000 || opts.outWidth > 2000) {
				opts.inSampleSize = 2;
			}
		}}}
		embed "java" {{{
			try {
				opts.inJustDecodeBounds = false;
				v = AndroidBitmapImage.for_android_bitmap(android.graphics.BitmapFactory.decodeFile(filename.to_strptr(), opts));
			}
			catch(Exception e) {
				v = null;
			}
		}}}
		if(v == null) {
			Log.error("Failed to read bitmap image `%s'".printf().add(filename));
		}
		return(v);
	}

	String get_android_app_name() {
		var nn = eq.api.Application.get_name();
		if(nn == null) {
			nn = "app.android";
		}
		else if(nn.chr((int)'.') < 0) {
			nn = "app.".append(nn);
		}
		return(nn);
	}

	String sanitize_resource_name(String n) {
		if(n == null) {
			return(null);
		}
		var sb = StringBuffer.create();
		var it = n.iterate();
		int c;
		while((c = it.next_char()) > 0) {
			if(c >= 'A' && c <= 'Z') {
				sb.append_c((int)('a' + c - 'A'));
			}
			else if(c >= 'a' && c <= 'z') {
				sb.append_c(c);
			}
			else if(c >= '0' && c <= '9') {
				sb.append_c(c);
			}
			else {
				sb.append_c((int)'_');
			}
		}
		return(sb.to_string());
	}

	public Image create_image_for_resource(String id, int w, int h) {
		if(id == null) {
			return(null);
		}
		Image v = null;
		var rid = "%s:drawable/%s".printf().add(get_android_app_name()).add(sanitize_resource_name(id)).to_string();
		Log.debug("Trying to load drawable Android resource `%s' as image.".printf().add(rid));
		embed "java" {{{
			if(eq.api.Android.context == null) {
				System.out.println("ERROR: No Android context!");
				return(null);
			}
			android.content.res.Resources res = eq.api.Android.context.getResources();
			if(res != null) {
				int aid = res.getIdentifier(rid.to_strptr(), null, null);
				if(aid > 0) {
					android.graphics.drawable.Drawable d = res.getDrawable(aid);
					if(d != null && d instanceof android.graphics.drawable.BitmapDrawable) {
						v = AndroidBitmapImage.for_android_bitmap(((android.graphics.drawable.BitmapDrawable)d).getBitmap());
					}
				}
			}
		}}}
		if(v == null) {
			Log.error("Image `%s' not found as Android resource.".printf().add(id));
		}
		else if(w > 0 || h > 0) {
			return(v.resize(w, h));
		}
		return(v);
	}

	public Clipboard get_default_clipboard() {
		return(null); // FIXME
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
		TextLayout v = null;
		embed "java" {{{
			v = AndroidTextLayout.create(props, dpi);
		}}}
		return(v);
	}

	public bool open_url(String url) {
		if(url != null) {
			embed "java" {{{
				android.content.Intent intent = new android.content.Intent(android.content.Intent.ACTION_VIEW).setData(android.net.Uri.parse(url.to_strptr()));
				if(eq.api.Android.context != null) {
					eq.api.Android.context.startActivity(intent);
				}
			}}}
		}
		return(true);
	}

	public bool open_file(File file) {
		return(false); // FIXME
	}

	public BackgroundTaskManager get_background_task_manager() {
		return(new AndroidEventLoop());
	}

	public bool execute(FrameController main, String argv0, Collection args) {
		// this is not that kind of a backend
		return(false);
	}

	public WindowManager get_window_manager() {
		return(new AndroidWindowManager());
	}
}
