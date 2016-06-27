
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

public class ButtonSet : HBoxWidget
{
	class ButtonDesc
	{
		public Object event;
		public String text;
		public Image icon;
		public Color color;
		public static ButtonDesc create(Object event, String text, Image icon, Color color) {
			var v = new ButtonDesc();
			v.event = event;
			v.text = text;
			v.icon = icon;
			v.color = color;
			return(v);
		}
	}

	public static Color yescolor() {
		return(Theme.color("eq.widget.dialog.DialogWidget.yescolor", "lightgreen"));
	}

	public static Color nocolor() {
		return(Theme.color("eq.widget.dialog.DialogWidget.nocolor", "lightred"));
	}

	public static ButtonSet yesno(Object aayes = null, Object aano = null) {
		var ayes = aayes;
		var ano = aano;
		if(ayes == null) {
			ayes = "yes";
		}
		if(ano == null) {
			ano = "no";
		}
		return(ButtonSet.instance()
			.add_button(ayes, "Yes", null, ButtonSet.yescolor())
			.add_button(ano, "No", null, ButtonSet.nocolor()));
	}

	public static ButtonSet okcancel(Object aaok = null, Object aacancel = null) {
		var aok = aaok;
		var acancel = aacancel;
		if(aok == null) {
			aok = "ok";
		}
		if(acancel == null) {
			acancel = "cancel";
		}
		return(ButtonSet.instance()
			.add_button(aok, "OK", null, ButtonSet.yescolor())
			.add_button(acancel, "Cancel", null, ButtonSet.nocolor()));
	}

	public static ButtonSet ok(Object aaok = null) {
		var aok = aaok;
		if(aok == null) {
			aok = "ok";
		}
		return(ButtonSet.instance().add_button(aok, "OK", null, ButtonSet.yescolor()));
	}

	public static ButtonSet cancel(Object aacancel = null) {
		var acancel = aacancel;
		if(acancel == null) {
			acancel = "cancel";
		}
		return(ButtonSet.instance().add_button(acancel, "Cancel", null, ButtonSet.nocolor()));
	}

	Collection buttons;

	public static ButtonSet instance() {
		return(new ButtonSet());
	}

	public ButtonSet() {
		buttons = LinkedList.create();
	}

	public ButtonSet add_button(Object event, String text, Image icon = null, Color color = null) {
		buttons.add(ButtonDesc.create(event, text, icon, color));
		return(this);
	}

	public void initialize() {
		base.initialize();
		set_spacing(px("1mm"));
		foreach(ButtonDesc bd in buttons) {
			add_hbox(1, ButtonWidget.instance().set_text(bd.text).set_icon(bd.icon).set_color(bd.color).set_event(bd.event));
		}
	}
}
