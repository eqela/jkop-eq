
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

public class ImageWidget : Widget
{
	public static ImageWidget instance() {
		return(new ImageWidget());
	}

	public static ImageWidget for_file(File file) {
		return(new ImageWidget().set_file(file));
	}

	public static ImageWidget for_resource(String rs) {
		return(new ImageWidget().set_icon(rs));
	}

	public static ImageWidget for_icon(String icon) {
		return(new ImageWidget().set_icon(icon));
	}

	public static ImageWidget for_image(Image img) {
		return(new ImageWidget().set_image(img));
	}

	Image orig = null;
	int set_w = -1;
	int set_h = -1;
	String mode = null;
	double zoom = 1.0;

	public ImageWidget set_mode(String m) {
		mode = m;
		update_size_request();
		update_view();
		return(this);
	}

	public String get_mode() {
		return(mode);
	}

	class LoadTimer : TimerHandler {
		property ImageWidget w;
		property AsyncImage i;
		public bool on_timer(Object arg) {
			if(i == null) {
				return(false);
			}
			if(i.is_loaded() == false) {
				return(true);
			}
			if(w != null) {
				w.on_image_loaded();
			}
			return(false);
		}
	}

	public void on_image_loaded() {
		update_size_request();
		update_view();
	}

	void set_orig(Image i) {
		orig = i;
		if(i != null && i is AsyncImage) {
			if(((AsyncImage)i).is_loaded() == false) {
				start_timer(100000, new LoadTimer().set_w(this).set_i((AsyncImage)i), null);
			}
		}
	}

	public ImageWidget set_file(File file) {
		if(file != null) {
			set_orig(Image.for_file(file));
		}
		update_size_request();
		update_view();
		return(this);
	}

	public ImageWidget set_icon(String icon) {
		if(icon != null) {
			set_orig(IconCache.get(icon));
		}
		update_size_request();
		update_view();
		return(this);
	}

	public ImageWidget set_image(Image image) {
		set_orig(image);
		update_size_request();
		update_view();
		return(this);
	}

	public Image get_image() {
		return(orig);
	}

	public ImageWidget set_image_width(int wd) {
		set_w = wd;
		update_size_request();
		update_view();
		return(this);
	}

	public ImageWidget set_image_height(int ht) {
		set_h = ht;
		update_size_request();
		update_view();
		return(this);
	}

	public ImageWidget set_image_size(int wd, int ht) {
		set_w = wd;
		set_h = ht;
		update_size_request();
		update_view();
		return(this);
	}

	public ImageWidget set_zoom(double z) {
		zoom = z;
		update_size_request();
		update_view();
		return(this);
	}

	public double get_zoom() {
		return(zoom);
	}

	public Collection render() {
		if(orig == null) {
			return(null);
		}
		Image img;
		Transform transform;
		if("fill".equals(mode)) {
			var ow = orig.get_width(), oh = orig.get_height();
			double wf = (double)get_width() / (double)ow, hf = (double)get_height() / (double)oh;
			double f = wf;
			if(hf > f) {
				f = hf;
			}
			img = orig;
			transform = new Transform().set_scale_x(zoom * f).set_scale_y(zoom * f);
		}
		else if("fit".equals(mode)) {
			var ow = orig.get_width(), oh = orig.get_height();
			double wf = (double)get_width() / (double)ow, hf = (double)get_height() / (double)oh;
			double f = wf;
			if(hf < f) {
				f = hf;
			}
			img = orig;
			transform = new Transform().set_scale_x(zoom * f).set_scale_y(zoom * f);
		}
		else if("tile".equals(mode)) {
			img = orig;
		}
		else {
			var ow = orig.get_width(), oh = orig.get_height();
			double wf = (double)get_width() / (double)ow, hf = (double)get_height() / (double)oh;
			img = orig;
			transform = new Transform().set_scale_x(zoom * wf).set_scale_y(zoom * hf);
		}
		var v = LinkedList.create();
		if("tile".equals(mode)) {
			int x, y, w = get_width(), h = get_height(),
				imgw = img.get_width(), imgh = img.get_height();
			if(imgw > 0 && imgh > 0) {
				for(y=0; y<h; y+=imgh) {
					for(x=0; x<w; x+=imgw) {
						v.add(new DrawObjectOperation().set_x(x).set_y(y).set_object(img));
					}
				}
			}
		}
		else {
			v.add(new DrawObjectOperation()
				.set_x((get_width() - img.get_width()) / 2)
				.set_y((get_height() - img.get_height()) / 2)
				.set_object(img)
				.set_transform(transform)
			);
		}
		return(v);
	}

	private void update_size_request() {
		if(orig == null || "tile".equals(mode)) {
			set_size_request(0, 0);
			return;
		}
		int rw = set_w;
		int rh = set_h;
		if(rw == 0 || rh == 0) {
			set_size_request(0, 0);
			return;
		}
		int w, h;
		if(orig != null && orig is AsyncImage && ((AsyncImage)orig).is_loaded() == false) {
			w = px("20mm");
			h = w;
		}
		else {
			w = orig.get_width();
			h = orig.get_height();
		}
		if(rw > 0 && rh < 1 && w > 0) {
			rh = rw * h / w;
		}
		if(rh > 0 && rw < 1 && h > 0) {
			rw = rh * w / h;
		}
		if(rw > 0 && rh > 0) {
			w = rw;
			h = rh;
		}
		set_size_request(zoom * w, zoom * h);
	}
}
