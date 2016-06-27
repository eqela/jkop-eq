
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

public class J2MEWindowManager : WindowManager
{
	public WindowManagerScreen get_default_screen() {
		return(null);
	}

	public Collection get_screens() {
		return(null);
	}

	public Frame create_frame(FrameController controller, CreateFrameOptions opts) {
		embed "java" {{{
			if(opts != null && opts.get_parent() instanceof J2MECanvasFrame) {
				J2MECanvasFrame canvas = new J2MECanvasFrame();
				canvas.set_frame_controller(controller);
				canvas.set_parent_frame((J2MECanvasFrame)opts.get_parent());
				canvas.initialize_frame();
				javax.microedition.lcdui.Display display = J2MEDisplay.get_display();
				if(display!=null) {
					display.setCurrent(canvas);
				}
				canvas.start();
				return(canvas);
			}
		}}}
		return(null);
	}
}
