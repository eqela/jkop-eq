
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

public class Color : Stringable
{
	static Color _black;
	public static Color black() {
		if(_black == null) {
			_black = Color.instance("black");
		}
		return(_black);
	}

	static Color _white;
	public static Color white() {
		if(_white == null) {
			_white = Color.instance("white");
		}
		return(_white);
	}

	public static Color as_color(Object o) {
		if(o == null) {
			return(null);
		}
		if(o is Color) {
			return((Color)o);
		}
		var ss = String.as_string(o);
		if(ss != null) {
			return(Color.instance(ss));
		}
		return(null);
	}

	public static Color instance(String str) {
		if("none".equals(str)) {
			return(null);
		}
		var v = new Color();
		if(str != null) {
			if(v.parse(str) == false) {
				v = null;
			}
		}
		return(v);
	}

	public static Color instance_double(double r, double g, double b, double a) {
		return(new Color().set_r(r).set_g(g).set_b(b).set_a(a));
	}

	property double r = 0.0;
	property double g = 0.0;
	property double b = 0.0;
	property double a = 0.0;

	public bool parse(String s) {
		if(s == null) {
			r = 0.0;
			g = 0.0;
			b = 0.0;
			a = 1.0;
			return(true);
		}
		bool v = true;
		a = 1.0;
		if(s.get_char(0) == '#') {
			int slength = s.get_length();
			if(slength == 7 || slength == 9) {
				r = s.substring(1,2).to_integer_base(16) / 255.0;
				g = s.substring(3,2).to_integer_base(16) / 255.0;
				b = s.substring(5,2).to_integer_base(16) / 255.0;
				if(slength == 9) {
					a = s.substring(7,2).to_integer_base(16) / 255.0;
				}
				v = true;
			}
			else {
				r = g = b = 0.0;
				v = false;
			}
		}
		else {
			if("black".equals(s)) {
				r = 0.0;
				g = 0.0;
				b = 0.0;
			}
			else if("white".equals(s)) {
				r = 1.0;
				g = 1.0;
				b = 1.0;
			}
			else if("red".equals(s)) {
				r = 1.0;
				g = 0.0;
				b = 0.0;
			}
			else if("green".equals(s)) {
				r = 0.0;
				g = 1.0;
				b = 0.0;
			}
			else if("blue".equals(s)) {
				r = 0.0;
				g = 0.0;
				b = 1.0;
			}
			else if("lightred".equals(s)) {
				r = 0.6;
				g = 0.4;
				b = 0.4;
			}
			else if("lightgreen".equals(s)) {
				r = 0.4;
				g = 0.6;
				b = 0.4;
			}
			else if("lightblue".equals(s)) {
				r = 0.4;
				g = 0.4;
				b = 0.6;
			}
			else if("yellow".equals(s)) {
				r = 1.0;
				g = 1.0;
				b = 0.0;
			}
			else if("cyan".equals(s)) {
				r = 0.0;
				g = 1.0;
				b = 1.0;
			}
			else if("orange".equals(s)) {
				r = 1.0;
				g = 0.5;
				b = 0.0;
			}
			else {
				v = false;
			}
		}
		return(v);
	}

	public Color dup(String arg = null) {
		double f = 1.0;
		if(arg != null) {
			if("light".equals(arg)) {
				f = 1.2;
			}
			else if("dark".equals(arg)) {
				f = 0.8;
			}
			else if(arg.has_suffix("%")) {
				f = ((double)arg.to_integer()) / 100.0;
			}
		}
		var v = new Color();
		if(f > 1.0) {
			v.set_r(r + (1.0-r) * (f - 1.0));
			v.set_g(g + (1.0-g) * (f - 1.0));
			v.set_b(b + (1.0-b) * (f - 1.0));
		}
		else if(f < 1.0) {
			v.set_r(r * f);
			v.set_g(g * f);
			v.set_b(b * f);
		}
		else {
			v.set_r(r);
			v.set_g(g);
			v.set_b(b);
		}
		v.set_a(a);
		return(v);
	}

	public String to_string() {
		return(to_rgba_string());
	}

	public String to_rgb_string() {
		return("#%02x%02x%02x".printf()
			.add(Primitive.for_integer((int)(r*255)))
			.add(Primitive.for_integer((int)(g*255)))
			.add(Primitive.for_integer((int)(b*255)))
			.to_string());
	}

	public String to_rgba_string() {
		return("#%02x%02x%02x%02x".printf()
			.add(Primitive.for_integer((int)(r*255)))
			.add(Primitive.for_integer((int)(g*255)))
			.add(Primitive.for_integer((int)(b*255)))
			.add(Primitive.for_integer((int)(a*255)))
			.to_string());
	}
}

