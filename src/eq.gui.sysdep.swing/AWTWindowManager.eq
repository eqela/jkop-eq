
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

public class AWTWindowManager : WindowManager
{
	embed {{{
		static java.awt.GraphicsDevice device = java.awt.GraphicsEnvironment
			.getLocalGraphicsEnvironment().getScreenDevices()[0];
	}}}

	public WindowManagerScreen get_default_screen() {
		var v = new AWTWindowManagerScreen();
		embed {{{
			v.device = java.awt.GraphicsEnvironment
				.getLocalGraphicsEnvironment().getScreenDevices()[0];
		}}}
		return(v);
	}

	public Collection get_screens() {
		var v = LinkedList.create();
		embed {{{
			java.awt.GraphicsDevice[] devs = java.awt.GraphicsEnvironment.getLocalGraphicsEnvironment().getScreenDevices();
			if(devs != null) {
				for(int n = 0; n<devs.length; n++) {
					AWTWindowManagerScreen wms = new AWTWindowManagerScreen();
					wms.device = devs[n];
					v.add(wms);
				}
			}
		}}}
		return(v);
	}

	public Frame create_frame(FrameController fc, CreateFrameOptions opts) {
		var frame = new SwingFrame();
		embed {{{
			final eq.gui.FrameController ffc = fc;
			final eq.gui.CreateFrameOptions fopts = opts;
			final SwingFrame ff = frame;
			try {
				javax.swing.SwingUtilities.invokeLater(new Runnable() {
					public void run() {
						if(ff.initialize(ffc, fopts)) {
							ff.show();
						}
					}
				});
			}
			catch(Exception e) {
				e.printStackTrace();
				frame = null;
			}
		}}}
		return(frame);
	}
}
