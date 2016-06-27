
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

public class ResponsiveWidget : LayerWidget
{
	int shrt = 0;
	int nrw = 0;
	int szt = 0;
	int orientation = -1;
	int sizeclass = 0;
	String narrow_threshold = null;
	String small_threshold = null;
	String short_threshold = null;
	bool _is_narrow = true;
	bool _is_short = true;

	public bool is_landscape() {
		return(orientation == 0);
	}

	public bool is_portrait() {
		return(orientation != 0);
	}

	public bool is_small() {
		return(sizeclass == 0);
	}

	public bool is_large() {
		return(sizeclass != 0);
	}

	public bool is_narrow() {
		return(_is_narrow);
	}

	public bool is_short() {
		return(_is_short);
	}

	public Widget set_narrow_threshold(String t) {
		narrow_threshold = t;
		nrw = 0;
		on_resize();
		return(this);
	}

	public String get_narrow_threshold() {
		return(narrow_threshold);
	}

	public Widget set_small_threshold(String t) {
		small_threshold = t;
		szt = 0;
		on_resize();
		return(this);
	}

	public String get_small_threshold() {
		return(small_threshold);
	}

	public Widget set_short_threshold(String t) {
		short_threshold = t;
		shrt = 0;
		on_resize();
		return(this);
	}

	public String get_short_threshold() {
		return(short_threshold);
	}

	public virtual void on_orientation_changed() {
	}

	public virtual void on_size_class_changed() {
	}

	public virtual void on_narrowness_changed() {
	}

	public virtual void on_shortness_changed() {
	}

	public void on_resize() {
		base.on_resize();
		int w = get_width();
		int h = get_height();
		if(w < 1 || h < 1) {
			return;
		}
		// check for orientation change
		{
			int no = 0;
			if(h > w) {
				no = 1;
			}
			if(no != orientation) {
				orientation = no;
				on_orientation_changed();
			}
		}
		// check for size class change
		var parent = get_parent();
		if(parent != null) {
			int sc = 0;
			if(szt < 1) {
				var t = small_threshold;
				if(t == null) {
					t = "6in";
				}
				int p = px(t);
				szt = p * p;
			}
			int ct = w * w + h * h;
			if(ct > szt) {
				sc = 1;
			}
			if(sc != sizeclass) {
				sizeclass = sc;
				on_size_class_changed();
			}
		}
		// check for narrowness change
		if(parent != null) {
			bool narrow = false;
			if(nrw < 1) {
				if(parent != null) {
					var t = narrow_threshold;
					if(t == null) {
						t = "120mm";
					}
					nrw = px(t);
				}
			}
			if(nrw > 0 && get_width() <= nrw) {
				narrow = true;
			}
			if(narrow != _is_narrow) {
				_is_narrow = narrow;
				on_narrowness_changed();
			}
		}
		// check for shortness change
		if(parent != null) {
			bool short = false;
			if(shrt < 1) {
				if(parent != null) {
					var t = short_threshold;
					if(t == null) {
						t = "80mm";
					}
					shrt = px(t);
				}
			}
			if(shrt > 0 && get_height() <= shrt) {
				short = true;
			}
			if(short != _is_short) {
				_is_short = short;
				on_shortness_changed();
			}
		}
	}
}
