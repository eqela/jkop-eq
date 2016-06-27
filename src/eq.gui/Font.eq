
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

public class Font : Stringable
{
	public static Font instance(String desc = null) {
		return(new Font().modify(desc));
	}

	String name;
	bool bold;
	bool italic;
	bool underline;
	String configured_size;
	double scale_factor;
	String size;
	Color color;
	Color outline_color;
	Color shadow_color;
	property Object backend_data;

	public Font() {
		name = "Sans";
		configured_size = "2500um";
		bold = false;
		italic = false;
		underline = false;
		scale_factor = 1.0;
		update_size();
	}

	public void on_changed() {
		backend_data = null;
	}

	public Color get_color() {
		return(color);
	}

	public Color get_outline_color() {
		return(outline_color);
	}

	public Color get_shadow_color() {
		return(shadow_color);
	}

	public String get_name() {
		return(name);
	}

	public Font set_color(Color color) {
		this.color = color;
		return(this);
	}

	public Font set_outline_color(Color color) {
		this.outline_color = color;
		return(this);
	}

	public Font set_shadow_color(Color color) {
		this.shadow_color = color;
		return(this);
	}

	public Font set_size(String sz) {
		configured_size = sz;
		update_size();
		on_changed();
		return(this);
	}

	public String get_configured_size() {
		return(configured_size);
	}

	public Font set_scale_factor(double ff) {
		scale_factor = ff;
		update_size();
		on_changed();
		return(this);
	}

	public double get_scale_factor() {
		return(scale_factor);
	}

	public String get_size() {
		return(size);
	}

	void update_size() {
		if(scale_factor == 1.0) {
			size = configured_size;
			return;
		}
		var sz = configured_size;
		if(sz == null) {
			size = null;
			return;
		}
		if(sz.has_suffix("mm")) {
			sz = sz.substring(0,sz.get_length()-2).append("000").append("um");
		}
		String nsz;
		if(sz.has_suffix("px")) {
			var iii = sz.substring(0, sz.get_length()).to_integer();
			iii = (int)Math.rint((double)iii * scale_factor);
			nsz = "%dpx".printf().add(iii).to_string();
		}
		else if(sz.has_suffix("um")) {
			var iii = sz.substring(0, sz.get_length()).to_integer();
			iii = (int)Math.rint((double)iii * scale_factor);
			nsz = "%dum".printf().add(iii).to_string();
		}
		else {
			nsz = sz;
		}
		size = nsz;
	}

	public Font dup() {
		var v = new Font();
		v.name = name;
		v.size = size;
		v.configured_size = configured_size;
		v.bold = bold;
		v.italic = italic;
		v.underline = underline;
		v.scale_factor = scale_factor;
		v.color = color;
		v.outline_color = outline_color;
		v.shadow_color = shadow_color;
		v.backend_data = backend_data;
		return(v);
	}

	public Font modify(String desc) {
		if(desc == null) {
			return(this);
		}
		var dit = desc.split((int)' ');
		var nc = "";
		while(dit != null) {
			var comp = dit.next() as String;
			if(comp == null) {
				break;
			}
			var c0 = comp.get_char(0);
			if("bold".equals(comp)) {
				if(nc.get_length() > 0) { name = nc; nc = ""; }
				bold = true;
			}
			else if("italic".equals(comp)) {
				if(nc.get_length() > 0) { name = nc; nc = ""; }
				italic = true;
			}
			else if("underline".equals(comp)) {
				if(nc.get_length() > 0) { name = nc; nc = ""; }
				underline = true;
			}
			else if(comp.has_suffix("%")) {
				scale_factor = Double.as_double(comp.substring(0, comp.get_length()-1), 100.0) / 100.0;
			}
			else if(c0 >= '0' && c0 <= '9') {
				if(nc.get_length() > 0) { name = nc; nc = ""; }
				configured_size = comp;
			}
			else if(comp.has_prefix("color=")) {
				color = Color.instance(comp.substring(6));
			}
			else if(comp.has_prefix("outline-color=")) {
				outline_color = Color.instance(comp.substring(14));
			}
			else if(comp.has_prefix("shadow-color=")) {
				shadow_color = Color.instance(comp.substring(13));
			}
			else {
				if(nc.get_length() > 0) {
					nc = nc.append(" ");
				}
				nc = nc.append(comp);
			}
		}
		if(nc.get_length() > 0) {
			name = nc; nc = "";
		}
		update_size();
		on_changed();
		return(this);
	}

	public bool is_bold() {
		return(bold);
	}

	public bool is_italic() {
		return(italic);
	}

	public bool is_underline() {
		return(underline);
	}

	public String get_style() {
		var sb = StringBuffer.create();
		if(is_bold()) {
			sb.append("bold");
		}
		if(is_italic()) {
			if(sb.count() > 0) {
				sb.append_c((int)' ');
			}
			sb.append("italic");
		}
		if(is_underline()) {
			if(sb.count() > 0) {
				sb.append_c((int)' ');
			}
			sb.append("underline");
		}
		return(sb.to_string());
	}

	public String to_string() {
		return("%s %s %s %d%%".printf().add(get_name()).add(get_style()).add(get_size()).add((int)get_scale_factor() * 100.0).to_string());
	}
}
