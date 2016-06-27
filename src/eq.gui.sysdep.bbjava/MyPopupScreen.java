
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

package eq.gui.sysdep.bbjava;

import eq.gui.*;
import net.rim.device.api.ui.*;
import net.rim.device.api.ui.container.*;
import net.rim.device.api.ui.decor.*;

class MyPopupScreen extends PopupScreen
{
	ScreenEventHelper helper;

	public MyPopupScreen(Manager manager) {
		super(manager);
		helper = new ScreenEventHelper((BBJavaManagerFrame)manager);
		setBackground(BackgroundFactory.createSolidTransparentBackground(net.rim.device.api.ui.Color.BLACK, 0));
		setBorder(BorderFactory.createSimpleBorder(new XYEdges(), Border.STYLE_TRANSPARENT));
	}

	protected boolean keyChar(char c, int status, int time) {
		helper.key_char(c, status, time);
		return(super.keyChar(c, status, time));		
	}

	protected boolean navigationClick(int s, int t) {
		helper.navigation_click(s, t);
		return(super.navigationClick(s, t));
	}

	protected boolean navigationUnclick(int s, int t) {
		helper.navigation_unclick(s, t);
		return(super.navigationUnclick(s, t));
	}

	protected boolean navigationMovement(int dx, int dy, int status, int time) {
		if(helper.navigation_movement(dx, dy, status, time)) {
			return(true);
		}
		return(super.navigationMovement(dx, dy, status, time));
	}

	protected boolean touchEvent(TouchEvent message) {
		if(helper.touch_event(message)) {
			return(true);
		}
		return(super.touchEvent(message));
	}

	public boolean onClose() {
		if(helper.on_close()) {
			return(false);
		}
		return(super.onClose());
	}
}
