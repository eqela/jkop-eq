
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

public class ActionItem : Stringable
{
	public static ActionItem for_icon(Image icon) {
		return(new ActionItem().set_icon(icon));
	}

	public static ActionItem for_text(String text) {
		return(new ActionItem().set_text(text));
	}

	public static ActionItem for_string(String str) {
		return(new ActionItem().set_text(str));
	}

	public static ActionItem for_event(Object event) {
		return(new ActionItem().set_event(event));
	}

	public static ActionItem instance(Image icon = null, String text = null, String desc = null, Object event = null, Object data = null, bool selected = false) {
		return(new ActionItem().set_icon(icon).set_text(text).set_desc(desc).set_event(event).set_data(data).set_selected(selected));
	}

	public static ActionItem as_action_item(Object o) {
		if(o == null) {
			return(null);
		}
		if(o is ActionItem) {
			return((ActionItem)o);
		}
		if(o is Stringable) {
			var s = String.as_string(o);
			return(ActionItem.instance(null, s, null, o, o, false));
		}
		return(null);
	}

	property Image icon;
	property String text;
	property String desc;
	property Object data;
	property Object event;
	property Object context;
	property Menu menu;
	property String shortcut;
	property bool selected;
	property Executable action;
	property bool disabled = false;

	public bool execute() {
		if(action != null) {
			action.execute();
			return(true);
		}
		return(false);
	}

	public String to_string() {
		return(String.as_string(data));
	}
}
