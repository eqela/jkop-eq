
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

public class HTML5TextLayout : TextLayout, Size
{
	TextProperties props;
	Collection str_list;
	ptr canvas;
	int dpi;
	int th;

	public static HTML5TextLayout create(TextProperties props, int dpi) {
		var v = new HTML5TextLayout();
		if(v.initialize(props, dpi) == false) {
			v = null;
		}
		return(v);
	}

	private String get_font_name(Font font) {
		var n = font.get_name();
		if(n == null) {
			n = "Sans";
		}
		if("Sans".equals(n)) {
			n = "Arial";
		}
		if(n.has_suffix(".ttf") || n.has_suffix(".otf")) {
			n = n.substring(0, n.get_length()-4).replace_char('_', ' ');
		}
		return(n);
	}

	private String to_js_rgba_string(Color c) {
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

	int get_outline_width() {
		return(3);
	}

	public bool initialize(TextProperties props, int dpi) {
		this.props = props;
		this.dpi = dpi;
		if(props == null) {
			return(false);
		}
		var text = props.get_text();
		if(text == null) {
			return(false);
		}
		var str = text.to_strptr();
		if(str == null) {
			return(false);
		}
		String font;
		int font_height;
		var fontinfo = props.get_font();
		if(fontinfo != null) {
			var sb = StringBuffer.create();
			if(fontinfo.is_bold()) {
				sb.append("bold");
			}
			if(fontinfo.is_italic()) {
				if(sb.count() > 0) {
					sb.append_c(' ');
				}
				sb.append("italic");
			}
			if(sb.count() < 1) {
				sb.append("normal");
			}
			font = "%s %spx %s".printf().add(sb.to_string()).add(String.for_integer(Length.to_pixels(fontinfo.get_size(), dpi))).add(get_font_name(fontinfo)).to_string().strip();
			var fstyle = sb.to_string();
			var bstyle = "";
			if("bold".equals(fstyle)) {
				fstyle = "normal";
				bstyle = " font-weight: bold;";
			}
			var font_style = "padding: 0px; font-style: %s; font-size: %spx; font-family: %s;%s".printf().add(fstyle).add(String.for_integer(Length.to_pixels(fontinfo.get_size(), dpi))).add(get_font_name(fontinfo)).add(bstyle).to_string().strip();
			font_height = text_height(text, font_style);
		}
		if(font == null) {
			font = "12px Arial";
			font_height = text_height(text, "padding: 0px; font-size: 12px; font-family: Arial;");
		}
		ptr canvas;
		this.canvas = null;
		embed "js" {{{
			canvas = document.createElement('canvas');
			if(!canvas) {
				return(false);
			}
			var ctx = canvas.getContext('2d');
			if(!ctx) {
				return(false);
			}
			if(!ctx.measureText) {
				return(false);
			}
			ctx.font = font.to_strptr();
		}}}
		this.canvas = canvas;
		var outline = props.get_outline_color();
		if(outline != null) {
			var rgba = to_js_rgba_string(outline);
			embed "js" {{{
				ctx.strokeStyle = rgba.to_strptr();
				ctx.lineWidth = this.get_outline_width();
			}}}
		}
		int outlinewidth = get_outline_width();
		int wrap_width = props.get_wrap_width();
		bool wrap = false;
		var c_rgba = to_js_rgba_string(props.get_color());
		embed "js" {{{
			var metrics = ctx.measureText(str);
			canvas.width = Math.ceil(metrics.width);
			if(wrap_width > 0 && metrics.width > wrap_width) {
				wrap = true;
			}
			ctx.font = font.to_strptr();
			if(wrap == false) {
				canvas.height = font_height;
			}
			ctx.textBaseline = "bottom";
			ctx.fillStyle = c_rgba.to_strptr();
			ctx.font = font.to_strptr();
		}}}
		if(wrap) {
			var h = font_height;
			embed "js" {{{
				var words = str.split(" ");
				var line = "";
				var line_height = font_height;
				var x = 0;
				var y = 0;
				var n;
				for(n = 0; n < words.length; n++) {
					if(ctx.measureText(words[n]).width > wrap_width) {
						var index = n;
						var start = 0;
						var text = words[n];
						var pos;
						words.splice(index, 1);
						for(pos= 0; pos < text.length; pos++) {
							var s_text = text.substring(start, pos);
							if(ctx.measureText(s_text).width > wrap_width) {
								words.splice(index, 0, text.substring(start, pos-1));
								index++;
								start = pos - 1;
								pos--;
							}
						}
						words.splice(index, 0, text.substring(start, pos));		
					}
					var temp_line = line + words[n] + " ";
					var metrics = ctx.measureText(temp_line);
					var temp_width = metrics.width;
					if (temp_width > wrap_width) {
						h += line_height;
						this.add_string_line(line, x, y+font_height);
						line = words[n] + " ";
						y += line_height;
					}
					else {
						line = temp_line;
					}
					x = 0;
					if(props.get_alignment() === 1) {
						x = x + (canvas.width/2) - (ctx.measureText(line).width / 2);
						if(x < 0) {
							x = 0;
						}
					}
				}
				this.add_string_line(line, x, y+font_height);
				y += line_height;
				canvas.height = y;
			}}}
			if(str_list != null) {
				var ite = str_list.iterate();
				while(ite != null) {
					var po = ite.next() as PropertyObject;
					if(po == null) {
						break;
					}
					var temp_str = po.get_string("text");
					int x = po.get_int("x");
					int y = po.get_int("y");
					var rgba = to_js_rgba_string(props.get_color());
					embed "js" {{{
						ctx.textBaseline = "bottom";
						ctx.fillStyle = rgba.to_strptr();
						ctx.font = font.to_strptr();
					}}}
					if(outline != null) {
						rgba = to_js_rgba_string(outline);
						embed "js" {{{
							ctx.strokeStyle = rgba.to_strptr();
							ctx.lineWidth = this.get_outline_width();
							ctx.strokeText(temp_str.to_strptr(), x, y);
						}}}
					}
					embed "js" {{{
						ctx.fillText(temp_str.to_strptr(), x, y);
					}}}
				}
			}
		}
		else {
			if(outline != null) {
				var rgba = to_js_rgba_string(outline);
				embed "js" {{{
					ctx.strokeStyle = rgba.to_strptr();
					ctx.lineWidth = this.get_outline_width();
					ctx.strokeText(str, 0, font_height);
				}}}
			}
			embed "js" {{{
				ctx.fillText(str, 0, font_height);
			}}}
		}
		return(true);
	}

		private void add_string_line(strptr str, int x, int y) {
		if(str_list == null) {
			str_list = LinkedList.create();
		}
		str_list.add(new PropertyObject().set("text", String.for_strptr(str)).set_int("x", x).set_int("y", y));
	}

	private int text_height(String intext, String font_style) {
		int th = 0;
		embed "js" {{{
			var body = document.getElementsByTagName("body")[0];
			var dummy = document.createElement("div");
			var text = document.createTextNode(intext.to_strptr());
			dummy.appendChild(text);
			dummy.setAttribute("style", font_style.to_strptr());
			body.appendChild(dummy);
			th = dummy.offsetHeight;
			body.removeChild(dummy);
		}}}
		this.th = th;
		return(th);
	}

	public TextProperties get_text_properties() {
		return(props);
	}

	public Rectangle get_cursor_position(int index) {
		int x;
		int y;
		int w = 2;
		int h = th;
		var text = props.get_text();
		var str = text.substring(0, index);
		var canvas = this.canvas;
		embed "js" {{{
			var ctx = canvas.getContext('2d');
			x = ctx.measureText(str.to_strptr()).width;
		}}}
		return(Rectangle.instance(x, y, w, h));
	}

	public int xy_to_index(double x, double y) {
		var text = props.get_text();
		if(text == null || "".equals(text)) {
			return(0);
		}
		int tw;
		var canvas = this.canvas;
		embed "js" {{{
			var ctx = canvas.getContext('2d');
			tw = ctx.measureText(text.to_strptr()).width;
		}}}
		if(x >= tw) {
			return(text.get_length());
		}
		else {
			int c, t = 0;
			for(c = 0; c < text.get_length(); c++) {
				var str = String.for_character(text.get_char(c));
				embed "js" {{{
					 t += ctx.measureText(str.to_strptr()).width;
				}}}
				if(x < t) {
					return(c);
				}
			}
		}
		return(0);
	}

	public double get_width() {
		double v = 0;
		if(canvas != null) {
			var canvas = this.canvas;
			embed "js" {{{
				v = canvas.width;
			}}}
		}
		return(v);
	}

	public double get_height() {
		double v = 0;
		if(canvas != null) {
			var canvas = this.canvas;
			embed "js" {{{
				v = canvas.height;
			}}}
		}
		return(v);
	}

	public ptr get_canvas() {
		return(canvas);
	}
}
