
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

class XamlSecondaryFrameManager : XamlFrame, Frame, Size, SurfaceContainer, ClosableFrame, TitledFrame, HidableFrame
{
	property XamlFrame origframe;

	public int get_frame_type() {
		if(origframe != null) {
			return(origframe.get_frame_type());
		}
		return(0);
	}

	public bool has_keyboard() {
		if(origframe != null) {
			return(origframe.has_keyboard());
		}
		return(false);
	}

	public FrameController get_controller() {
		if(origframe != null) {
			return(origframe.get_controller());
		}
		return(null);
	}

	public int get_dpi() {
		if(origframe != null) {
			return(origframe.get_dpi());
		}
		return(0);
	}

	public double get_width() {
		if(origframe != null) {
			return(origframe.get_width());
		}
		return(0);
	}

	public double get_height() {
		if(origframe != null) {
			return(origframe.get_height());
		}
		return(0);
	}

	public Surface add_surface(SurfaceOptions opts) {
		if(origframe != null) {
			return(origframe.add_surface(opts));
		}
		return(null);
	}

	public void remove_surface(Surface ss) {
		if(origframe != null) {
			origframe.remove_surface(ss);
		}
	}

	public void hide() {
		if(origframe != null) {
			origframe.hide();
		}
	}

	public void show() {
		if(origframe != null) {
			origframe.show();
		}
	}

	public void close() {
		if(origframe != null) {
			origframe.close();
		}
	}

	public void set_icon(Image icon) {
		if(origframe != null) {
			origframe.set_icon(icon);
		}
	}

	public void set_title(String title) {
		if(origframe != null) {
			origframe.set_title(title);
		}
	}
}