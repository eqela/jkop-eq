
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

public class ActivityWidget : WindowFrameWidget, EventReceiver
{
	property String description;

	public static ActivityWidget find(Widget w) {
		return(WindowFrameWidget.find(w) as ActivityWidget);
	}

	ActivityManagerWidget get_activity_manager_widget() {
		var ww = get_parent() as Widget;
		while(ww != null) {
			if(ww is ActivityManagerWidget) {
				return((ActivityManagerWidget)ww);
			}
			ww = ww.get_parent() as Widget;
		}
		return(null);
	}

	public void on_icon_changed() {
		base.on_icon_changed();
		var dd = get_activity_manager_widget();
		if(dd != null) {
			dd.on_activity_title_changed(this);
		}
	}

	public void on_title_changed() {
		base.on_title_changed();
		var dd = get_activity_manager_widget();
		if(dd != null) {
			dd.on_activity_title_changed(this);
		}
	}

	public void close_activity() {
		var dw = get_activity_manager_widget();
		if(dw != null) {
			dw.close_activity(this);
		}
	}

	public void on_close_request() {
		var mw = get_main_widget() as WindowFrameCloseHandler;
		if(mw == null ||  mw.on_window_frame_close() == false) {
			close_activity();
		}
	}

	public bool on_key_press(KeyEvent e) {
		return(base.on_key_press(e));
	}

	public void on_event(Object o) {
		if(o != null && o is WindowFrameCloseEvent) {
			on_close_request();
			return;
		}
		forward_event(o);
	}
}
