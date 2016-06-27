
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

public class PhotoSelectorOSX
{
	property EventReceiver listener;

	embed {{{
		#import <Quartz/Quartz.h>
	}}}

	public bool execute() {
		embed {{{
			IKPictureTaker* pt = [IKPictureTaker pictureTaker];
			[pt runModal];
		}}}
		var r = new PhotoSelectorResult();
		ptr nsimage;
		embed {{{
			NSImage* img = [pt outputImage];
			if(img != nil) {
				nsimage = (__bridge void*)img;
			}
		}}}
		if(nsimage != null) {
			var ee = (eq.gui.sysdep.osx.GuiEngine)GUI.engine;
			if(ee != null) {
				r.set_image(ee.create_image_for_nsimage(nsimage, -1, -1));
			}
		}
		EventReceiver.event(listener, r);
		return(true);
	}
}
