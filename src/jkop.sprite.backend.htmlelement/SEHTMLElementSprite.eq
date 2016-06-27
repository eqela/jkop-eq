
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

public class SEHTMLElementSprite : SEHTMLElementElement, SESprite
{
	property int element_type;
	String last_font;

	void on_created() {
		move(get_x(), get_y());
		set_rotation(get_rotation());
		set_alpha(get_alpha());
	}

	public void set_image(SEImage image) {
		if(image == null) {
			remove_from_container();
			return;
		}
		var txt = image.as_texture(get_rsc()) as Image;
		if(txt == null) {
			Log.error("Failed to get texture when setting the image of a sprite");
			return;
		}
		if(txt is HTML5RenderableImage) {
			remove_from_container();
			int width = txt.get_width(), height = txt.get_height();
			var pp = get_parent();
			var oo = ((HTML5RenderableImage)txt).get_element();
			ptr ee;
			embed {{{
				ee = document.createElement('canvas');
				var ctx = ee.getContext('2d');
				ee.width = width;
				ee.height = height;
				ctx.drawImage(oo, 0, 0, oo.width, oo.height, 0, 0, width, height);
				ee.style.position = "absolute";
				ee.style.MozUserSelect = "none";
				ee.style.mozUserSelect = "none";
				ee.style.webkitUserSelect = "none";
				ee.style.oUserSelect = "none";
				ee.style.userSelect = "none";
				ee.setAttribute("unselectable", "on");
				if(pp != null) {
					pp.appendChild(ee);
				}
			}}}
			set_element(ee);
			element_type = 0;
			set_width(width);
			set_height(height);
			on_created();
			return;
		}
		var element = get_element();
		if(element != null && element_type != 0) {
			remove_from_container();
		}
		if(element == null) {
			var pp = get_parent();
			var mydoc = get_document();
			embed {{{
				element = mydoc.createElement("img");
				element.style.position = "absolute";
				element.style.MozUserSelect = "none";
				element.style.mozUserSelect = "none";
				element.style.webkitUserSelect = "none";
				element.style.oUserSelect = "none";
				element.style.userSelect = "none";
				element.setAttribute("unselectable", "on");
				pp.appendChild(element);
			}}}
			set_element(element);
			element_type = 0;
		}
		String imgurl;
		if(txt is HTML5Image) {
			imgurl = ((HTML5Image)txt).get_url();
		}
		if(String.is_empty(imgurl)) {
			Log.error("No URL for texture");
			return;
		}
		var width = txt.get_width();
		var height = txt.get_height();
		embed {{{
			element.setAttribute("src", imgurl.to_strptr());
			element.setAttribute("width", "" + width);
			element.setAttribute("height" , "" + height);
		}}}
		set_width(width);
		set_height(height);
		on_created();
	}

	String get_font_name(Font font) {
		if(font == null) {
			return("Arial");
		}
		var n = font.get_name();
		if(String.is_empty(n)) {
			n = "Arial";
		}
		else if("Sans".equals(n)) {
			n = "Arial";
		}
		if(n.has_suffix(".ttf") || n.has_suffix(".otf")) {
			n = n.substring(0, n.get_length() - 4).replace_char('_', ' ');
		}
		return(n);
	}

	public void set_text(String text, String fontid = null) {
		var rsc = get_rsc();
		if(String.is_empty(text) || rsc == null) {
			remove_from_container();
			return;
		}
		var fid = fontid;
		if(fid == null) {
			fid = last_font;
		}
		else {
			last_font = fid;
		}
		var ff = rsc.get_font(fid);
		if(ff == null) {
			remove_from_container();
			return;
		}
		var element = get_element();
		if(element != null && element_type != 1) {
			remove_from_container();
		}
		if(element == null) {
			var pp = get_parent();
			var mydoc = get_document();
			embed {{{
				element = mydoc.createElement("div");
				element.style.position = "absolute";
				element.style.MozUserSelect = "none";
				element.style.mozUserSelect = "none";
				element.style.webkitUserSelect = "none";
				element.style.oUserSelect = "none";
				element.style.userSelect = "none";
				element.setAttribute("unselectable", "on");
				pp.appendChild(element);
			}}}
			set_element(element);
			element_type = 1;
		}
		int width, height;
		var fn = get_font_name(ff);
		var sb = StringBuffer.create();
		if(ff.is_bold()) {
			sb.append("bold");
		}
		if(ff.is_italic()) {
			if(sb.count() > 0) {
				sb.append_c(' ');
			}
			sb.append("italic");
		}
		if(sb.count() < 1) {
			sb.append("normal");
		}
		var fstyle = sb.to_string();
		var sz = ff.get_size();
		if(sz == null) {
			sz = "";
		}
		var cc = to_js_rgba_string(ff.get_color());
		embed {{{
			element.innerHTML = text.to_strptr();
			element.style.fontFamily = fn.to_strptr();
			element.style.fontSize = sz.to_strptr();
			element.style.fontStyle = fstyle.to_strptr();
			element.style.color = cc.to_strptr();
			width = element.offsetWidth;
			height = element.offsetHeight;
		}}}
		set_width(width);
		set_height(height);
		on_created();
	}

	String to_js_rgba_string(Color c) {
		if(c == null) {
			return("");
		}
		var v = "rgba(%d,%d,%d,%f)".printf()
			.add(Primitive.for_integer((int)(c.get_r() * 255)))
			.add(Primitive.for_integer((int)(c.get_g() * 255)))
			.add(Primitive.for_integer((int)(c.get_b() * 255)))
			.add(Primitive.for_double(c.get_a()))
			.to_string();
		return(v);
	}

	public void set_color(Color color, double width, double height) {
		if(color == null || width <= 1 || height <= 1) {
			remove_from_container();
			return;
		}
		var element = get_element();
		var element_type = get_element_type();
		if(element != null && element_type != 2) {
			remove_from_container();
		}
		if(element == null) {
			var pp = get_parent();
			var mydoc = get_document();
			embed {{{
				element = mydoc.createElement("div");
				element.style.position = "absolute";
				element.style.MozUserSelect = "none";
				element.style.mozUserSelect = "none";
				element.style.webkitUserSelect = "none";
				element.style.oUserSelect = "none";
				element.style.userSelect = "none";
				element.setAttribute("unselectable", "on");
				pp.appendChild(element);
			}}}
			set_element(element);
			element_type = 2;
		}
		var str = to_js_rgba_string(color);
		embed {{{
			element.style.width = "" + width;
			element.style.height = "" + height;
			element.style.backgroundColor = str.to_strptr();
			element.style.position = "absolute";
		}}}
		set_width(width);
		set_height(height);
		on_created();
	}

	IFDEF("enable_foreign_api") {
		public void setImage(strptr image) {
			set_image(SEImage.for_resource(String.for_strptr(image)));
		}
		public void setText(strptr text, strptr fontid) {
			set_text(String.for_strptr(text), String.for_strptr(fontid));
		}
		public void setColor(strptr color, double width, double height) {
			set_color(Color.instance(String.for_strptr(color)), width, height);
		}
	}
}
