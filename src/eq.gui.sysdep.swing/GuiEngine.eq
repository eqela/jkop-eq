
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
	AWTBackgroundTaskManager btm;
	AWTWindowManager window_manager;

	public bool is_image_file(File file) {
		return(file != null && (file.has_extension("png") || file.has_extension("jpg")));
	}

	public RenderableImage create_renderable_image(int w, int h) {
		return(AWTImage.for_bitmap(w, h));
	}

	public Image create_image_for_buffer(ImageBuffer buf) {
		return(AWTImage.for_buffer(buf));
	}

	public Image create_image_for_file(File file, int w, int h) {
		var v = AWTImage.for_file(file);
		if(v == null) {
			return(null);
		}
		return(v.resize(w, h));
	}

	public Image create_image_for_resource(String res, int w, int h) {
		var v = AWTImage.for_resource(res);
		if(v == null) {
			return(null);
		}
		return(v.resize(w, h));
	}

	public Clipboard get_default_clipboard() {
		return(new AWTClipboard());
	}

	public TextLayout layout_text(TextProperties props, Frame frame, int dpi) {
		if(props == null) {
			return(null);
		}
		return(AWTTextLayout.create(props, frame, dpi));
	}

	public bool open_url(String url) {
		if(String.is_empty(url)) {
			return(false);
		}
		embed {{{
			java.net.URI uri = java.net.URI.create(url.to_strptr());
			java.awt.Desktop desktop = java.awt.Desktop.getDesktop();
			try {
				desktop.browse(uri);
			}
			catch(Exception e) {
				return(false);
			}
		}}}
		return(true);
	}

	public bool open_file(File file) {
		if(file == null) {
			return(false);
		}
		String path = file.get_native_path();
		if(String.is_empty(path)) {
			return(false);
		}
		embed {{{
			java.io.File f = new java.io.File(path.to_strptr());
			java.awt.Desktop desktop = java.awt.Desktop.getDesktop();
			try {
				desktop.open(f);
			}
			catch(Exception e) {
				return(false);
			}
		}}}
		return(true);
	}

	public BackgroundTaskManager get_background_task_manager() {
		if(btm == null) {
			btm = new AWTBackgroundTaskManager();
		}
		return(btm);
	}

	public WindowManager get_window_manager() {
		if(window_manager == null) {
			window_manager = new AWTWindowManager();
		}
		return(window_manager);
	}

	property bool exit_request = false;

	void _terminate(int rv) {
		SystemEnvironment.terminate(rv);
	}

	public bool execute(FrameController main, String argv0, Collection args) {
		embed {{{
			try {
				final eq.gui.FrameController fmain = main;
				javax.swing.SwingUtilities.invokeLater(new Runnable() {
					public void run() {
						SwingFrame frame = new SwingFrame();
						if(frame.initialize(fmain, null) == false) {
							_terminate(0);
						}
						else {
							frame.show();
						}
					}
				});
			}
			catch(Exception e) {
				e.printStackTrace();
			}
		}}}
		while(exit_request == false) {
			SystemEnvironment.sleep(60 * 60);
		}
		return(true);
	}
}
