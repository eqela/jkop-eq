
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

public class Theme
{
	static HashTable values;

	public static Color color(String id, String defval = null) {
		var v = string(id, defval);
		if(v == null) {
			return(null);
		}
		return(Color.instance(v));
	}

	public static Font font(String id = null, String defval = null) {
		var vs = string("eq.widget.default_font", null);
		if(vs == null) {
			vs = "";
		}
		var ff = Font.instance(vs);
		var v = string(id, defval);
		if(v != null) {
			ff.modify(v);
		}
		return(ff);
	}

	public static bool boolean(String id, String defval = null) {
		return(Boolean.as_boolean(string(id, defval)));
	}

	public static String string(String id, String defval = null) {
		initialize();
		if(values == null) {
			return(null);
		}
		String v;
		if(id != null) {
			v = values.get_string(id);
		}
		if(v == null) {
			if(defval != null && defval.has_prefix("$")) {
				v = string(defval.substring(1));
			}
			else {
				v = defval;
			}
		}
		return(v);
	}

	public static void set(String id, String value) {
		initialize();
		if(values != null && id != null) {
			values.set(id, value);
		}
	}

	public static String get_icon_size() {
		return(string("eq.widget.icon_size"));
	}

	public static Color get_highlight_color() {
		return(color("eq.widget.highlight_color"));
	}

	public static Color get_base_color() {
		return(color("eq.widget.base_color"));
	}

	public static Color get_base_draw_color() {
		return(color("eq.widget.base_draw_color"));
	}

	public static Color get_selected_color() {
		return(color("eq.widget.selected_color"));
	}

	public static Color get_hover_color() {
		return(color("eq.widget.hover_color"));
	}

	public static Color get_pressed_color() {
		return(color("eq.widget.pressed_color"));
	}

	static bool initialized = false;

	public static void initialize() {
		if(initialized) {
			return;
		}
		initialized = true;
		values = HashTable.create();
		values.set("eq.widget.highlight_color", "#FFA000");
		values.set("eq.widget.base_color", "#00383d");
		values.set("eq.widget.base_draw_color", "white");
		values.set("eq.widget.selected_color", "#ae6728aa");
		values.set("eq.widget.hover_color", "#00383d");
		values.set("eq.widget.pressed_color", "#ff902eaa");
		values.set("eq.widget.icon_size", "5mm");
		values.set("eq.widget.title_align", "center");
		values.set("eq.widget.outline_width", "300um");
		String fsz;
		/*
		IFDEF("target_osx") {
			fsz = "2250um";
		}
		ELSE IFDEF("target_win32") {
			fsz = "2750um";
		}
		ELSE IFDEF("target_linux") {
			fsz = "2750um";
		}
		ELSE {
			fsz = "2500um";
		}
		*/
		fsz = "2250um";
		values.set("eq.widget.default_font", "Sans %s".printf().add(fsz).to_string());
	}
}
