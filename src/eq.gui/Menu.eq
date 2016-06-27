
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

public class Menu
{
	property String title;
	LinkedList items;

	public Collection get_items() {
		if(items == null) {
			return(items);
		}
		var ll = items.get_last();
		var ff = items.get_first();
		if((ll != null && ll is SeparatorItem) || (ff != null && ff is SeparatorItem)) {
			var v = LinkedList.dup(items);
			while(v.get_first() is SeparatorItem) {
				v.remove_first();
			}
			while(v.get_last() is SeparatorItem) {
				v.remove_last();
			}
			return(v);
		}
		return(items);
	}

	public Menu set_items(Collection items) {
		if(items == null) {
			this.items = null;
		}
		else if(items is LinkedList) {
			this.items = (LinkedList)items;
		}
		else {
			this.items = LinkedList.dup(items);
		}
		return(this);
	}

	public Menu dup() {
		var v = new Menu();
		v.set_title(title);
		var vc = LinkedList.create();
		foreach(var o in items) {
			vc.add(o);
		}
		v.set_items(vc);
		return(v);
	}

	public int count() {
		if(items == null) {
			return(0);
		}
		return(items.count());
	}

	public Menu add_separator() {
		if(items == null) {
			items = LinkedList.create();
		}
		items.add(new SeparatorItem());
		return(this);
	}

	public ActionItem get_by_text(String text) {
		if(text == null) {
			return(null);
		}
		foreach(ActionItem ai in items) {
			if(text.equals(ai.get_text())) {
				return(ai);
			}
		}
		return(null);
	}

	public ActionItem add_action(String label, Executable action) {
		var ai = ActionItem.instance(null, label).set_action(action);
		add(ai);
		return(ai);
	}

	public Menu add(ActionItem item) {
		if(item == null) {
			return(this);
		}
		if(items == null) {
			items = LinkedList.create();
		}
		items.add(item);
		return(this);
	}

	public Menu append(ActionItem item) {
		return(add(item));
	}

	public Menu prepend(ActionItem item) {
		if(item == null) {
			return(this);
		}
		if(items == null) {
			items = LinkedList.create();
		}
		items.prepend(item);
		return(this);
	}

	public Menu prepend_separator() {
		if(items == null) {
			items = LinkedList.create();
		}
		items.prepend(new SeparatorItem());
		return(this);
	}

	public Menu add_menu(Menu menu) {
		if(menu == null) {
			return(this);
		}
		foreach(var o in menu.get_items()) {
			if(o is SeparatorItem) {
				add_separator();
			}
			else if(o is ActionItem) {
				add((ActionItem)o);
			}
		}
		return(this);
	}
}
