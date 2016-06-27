
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

public class DesktopWindowMenuBar
{
	property Menu app_menu;
	property ActionItem about_item;
	property Collection submenus;

	public Menu get_or_create_app_menu() {
		if(app_menu == null) {
			app_menu = new Menu();
		}
		return(app_menu);
	}

	public Menu get_submenu(String title, bool create = true) {
		if(title == null) {
			return(null);
		}
		foreach(Menu menu in submenus) {
			if(title.equals(menu.get_title())) {
				return(menu);
			}
		}
		if(create) {
			var v = new Menu().set_title(title);
			if(submenus == null) {
				submenus = LinkedList.create();
			}
			if("File".equals(title)) {
				submenus.prepend(v);
			}
			else if("Edit".equals(title)) {
				var fm = submenus.get(0) as Menu;
				if(fm != null && "File".equals(fm.get_title())) {
					submenus.insert(v, 1);
				}
				else {
					submenus.prepend(v);
				}
			}
			else if("View".equals(title)) {
				var m0 = submenus.get(0) as Menu;
				var m1 = submenus.get(1) as Menu;
				if(m0 != null && "File".equals(m0.get_title())) {
					if(m1 != null && "Edit".equals(m1.get_title())) {
						submenus.insert(v, 2);
					}
					else {
						submenus.insert(v, 1);
					}
				}
				else if(m0 != null && "Edit".equals(m0.get_title())) {
					submenus.insert(v, 1);
				}
				else {
					submenus.prepend(v);
				}
			}
			else if("Window".equals(title)) {
				var lm = submenus.get(submenus.count() - 1) as Menu;
				if(lm != null && "Help".equals(lm.get_title())) {
					submenus.insert(v, submenus.count() - 1);
				}
				else {
					submenus.append(v);
				}
			}
			else if("Help".equals(title)) {
				submenus.append(v);
			}
			else {
				int n = 0;
				foreach(Menu menu in submenus) {
					if("Window".equals(menu.get_title()) || "Help".equals(menu.get_title())) {
						break;
					}
					n++;
				}
				if(n >= submenus.count()) {
					submenus.append(v);
				}
				else {
					submenus.insert(v, n);
				}
			}
			return(v);
		}
		return(null);
	}

	public DesktopWindowMenuBar add_submenu(Menu menu) {
		if(menu == null) {
			return(this);
		}
		if(submenus == null) {
			submenus = LinkedList.create();
		}
		submenus.add(menu);
		return(this);
	}

	public DesktopWindowMenuBar set_submenu(Menu menu) {
		if(menu == null) {
			return(this);
		}
		if(submenus == null) {
			submenus = LinkedList.create();
		}
		var tit = menu.get_title();
		if(tit == null) {
			Log.warning("Menu without a title. Ignoring.");
			return(this);
		}
		bool added = false;
		var nsm = LinkedList.create();
		foreach(Menu mm in submenus) {
			if(added == false && tit.equals(mm.get_title())) {
				nsm.append(menu);
				added = true;
			}
			else {
				nsm.append(mm);
			}
		}
		if(added == false) {
			nsm.append(menu);
		}
		submenus = nsm;
		return(this);
	}

	public Collection as_mac_menus() {
		var menus = LinkedList.create();
		var am = new Menu();
		var ab = get_about_item();
		if(ab != null) {
			am.add(ab);
		}
		if(app_menu != null && app_menu.count() > 0) {
			if(am.count() > 0) {
				am.add_separator();
			}
			foreach(var o in app_menu.get_items()) {
				if(o is SeparatorItem) {
					am.add_separator();
				}
				else if(o is ActionItem) {
					am.add((ActionItem)o);
				}
			}
		}
		menus.add(am);
		foreach(Menu mm in get_submenus()) {
			menus.add(mm);
		}
		return(menus);
	}

	public Collection as_non_mac_menus() {
		var menus = LinkedList.create();
		Menu file;
		Menu help;
		foreach(Menu mm in submenus) {
			if("File".equals(mm.get_title())) {
				file = mm.dup();
				menus.add(file);
			}
			else if("Help".equals(mm.get_title())) {
				help = mm.dup();
				menus.add(help);
			}
			else {
				menus.add(mm);
			}
		}
		if(app_menu != null && app_menu.count() > 0) {
			if(file == null) {
				file = new Menu().set_title("File");
				menus.prepend(file);
			}
			if(file.count() > 0) {
				file.add_separator();
			}
			file.add_menu(app_menu);
			// FIXME: Quit
		}
		if(about_item != null) {
			if(help == null) {
				help = new Menu().set_title("Help");
				menus.append(help);
			}
			if(help.count() > 0) {
				var ii = help.get_items();
				if(ii != null) {
					ii.prepend(about_item);
				}
			}
		}
		return(menus);
	}
}
