
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

public class ActivityListButtonWidget : FramelessButtonWidget
{
	property ActivityManagerWidget amgr;

	public ActivityListButtonWidget() {
		set_font(Theme.font("eq.widget.activitymanager.ActivityListButtonWidget.font", "3500um bold shadow-color=black color=white"));
		set_pressed_font(Theme.font("eq.widget.activitymanager.ActivityListButtonWidget.pressed_font", "3500um bold shadow-color=none outline-color=%s color=white"
			.printf().add(Theme.get_highlight_color()).to_string()));
		set_icon(IconCache.get("arrowdown"));
		set_text("(No current activity)");
		set_internal_margin("1mm");
		set_rounded(true);
	}

	public void on_active_activity(ActivityWidget aw) {
		Image icon;
		String text;
		if(aw != null) {
			icon = aw.get_icon();
			text = aw.get_title();
		}
		if(icon == null) {
			icon = IconCache.get("arrowdown");
		}
		if(String.is_empty(text)) {
			text = "(No current activity)";
		}
		set_icon(icon);
		set_text(text);
	}

	public Widget get_popup_widget() {
		var v = new MenuWidget();
		v.set_header_text("Current activities ..");
		foreach(ActivityWidget aw in amgr.get_activity_widgets()) {
			v.add_entry(aw.get_icon(), aw.get_title(), aw.get_description(), aw);
		}
		return(v);
	}
}
