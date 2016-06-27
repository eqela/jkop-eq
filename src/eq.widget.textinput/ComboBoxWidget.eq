
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

public class ComboBoxWidget : TextInputWidgetFrame, EventReceiver
{
	public static ComboBoxWidget instance() {
		return(new ComboBoxWidget());
	}

	class ComboMenuEvent
	{
	}

	property Collection entries;

	public Widget create_right_widget() {
		// FIXME: Instead of the triple dot, better have this be a down arrow
		return(HBoxWidget.instance().set_spacing(px("1mm"))
			.add(VSeparatorWidget.instance())
			.add(ButtonWidget.for_string("...").set_font(Theme.font().modify("color=black"))
				.set_draw_frame(false)
				.set_event(new ComboMenuEvent())
				.set_height_request_override(px(Theme.get_icon_size())))
		);
	}

	MenuWidget create_menu() {
		var v = MenuWidget.instance();
		foreach(var o in entries) {
			var ai = ActionItem.as_action_item(o);
			if(ai == null) {
				continue;
			}
			v.add_action_item(ai);
		}
		return(v);
	}

	public void on_event(Object o) {
		if(o is ComboMenuEvent) {
			var mm = create_menu();
			mm.set_event_handler(this);
			mm.popup(this, true);
			return;
		}
		var ss = String.as_string(o);
		if(ss == null) {
			return;
		}
		set_text(ss);
	}
}
