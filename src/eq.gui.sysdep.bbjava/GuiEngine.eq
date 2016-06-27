
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
		String fn;
		if(file != null) {
			fn = file.basename();
		}
		String lc = fn.lowercase();
		return(lc.has_suffix(".png"));
	}

	public RenderableImage create_renderable_image(int w, int h) {
		RenderableImage v;
		embed "java" {{{
			v = BBJavaImage.create_bitmap_image(w, h, null, 0, 0);
		}}}
		return(v);
	}

	public Image create_image_for_buffer(ImageBuffer buffer) {
		if(buffer == null) {
			return(null);
		}
		return(ImageBufferHelper.buffer_to_image(buffer.get_buffer(), buffer.get_type()));
	}

	public Image create_image_for_file(File file, int w, int h) {
		if(file == null) {
			return(null);
		}
		Image v = null;
		var fn = file.to_string();
		var img_path = fn;
		if(fn.contains("file:///store/file:")) {
			img_path = fn.remove(8, 12);
		}
		embed "java" {{{
			try {
				String file_path = img_path.to_strptr();
				javax.microedition.io.file.FileConnection fc = (javax.microedition.io.file.FileConnection)javax.microedition.io.Connector.open(file_path);
				if(!fc.exists()) {
					throw new java.io.IOException("File does not exist");
				}
				java.io.DataInputStream input_stream = fc.openDataInputStream();
				byte[] data = new byte[(int)fc.fileSize()];
				data = net.rim.device.api.io.IOUtilities.streamToBytes(input_stream);
				input_stream.close();
				fc.close();
				v = BBJavaImage.create(net.rim.device.api.system.Bitmap.createBitmapFromBytes(data, 0, data.length, 1));
			}
			catch(Exception e) {
				e.printStackTrace();
				return(null);
			}
			if(v == null) {
				return(null);
			}
		}}}
		return(v.resize(w, h));
	}

	Image load_image_suffix(String name, String suf) {
		Image v;
		embed "Java" {{{
			try {
				v = BBJavaImage.create(net.rim.device.api.system.Bitmap.getBitmapResource(name.to_strptr() + suf.to_strptr()));
			}
			catch(Exception e) {
				return(null);
			}
		}}}
		return(v);
	}

	public Image create_image_for_resource(String res, int w, int h) {
		if(res == null) {
			return(null);
		}
		Image v = load_image_suffix(res, ".png");
		if(v == null) {
			v = load_image_suffix(res, ".jpg");
		}
		if(v == null) {
			return(null);
		}
		return(v.resize(w, h));
	}

	public Clipboard get_default_clipboard() {
		return(null);
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
		return(BBJavaTextLayout.create(props, dpi));
	}

	public bool open_url(String url) {
		if(url != null) {
			return(true);
		}
		return(false);
	}

	public bool open_file(File file) {
		return(false); // FIXME
	}

	public BackgroundTaskManager get_background_task_manager() {
		if(btm == null) {
			btm = new BBJavaBackgroundTaskManager();
		}
		return(btm);
	}

	public bool execute(FrameController main, String argv0, Collection args) {
		return(false);
	}

	public WindowManager get_window_manager() {
		return(new BBJavaWindowManager());
	}
}
