
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

public class SEResourceCache
{
	public static SEResourceCache for_frame(Frame frame) {
		return(new SEResourceCache().set_frame(frame));
	}

	Frame frame;
	property int dpi = 96;
	HashTable images;
	HashTable fonts;
	HashTable sheets;

	~SEResourceCache() {
		cleanup();
	}

	public virtual void release_texture(Object o) {
		if(o == null) {
			return;
		}
		if(o is Image) {
			((Image)o).release();
		}
	}

	public virtual void cleanup() {
		Log.debug("SEResourceCache: Cleaning up cached resources ..");
		if(images != null) {
			foreach(SEImage img in images.iterate_values()) {
				var txt = img.get_texture();
				if(txt != null) {
					release_texture(txt);
				}
			}
			images = null;
		}
		fonts = null;
		if(sheets != null) {
			foreach(Collection sheet in sheets.iterate_values()) {
				foreach(var o in sheet) {
					release_texture(o);
				}
			}
			sheets = null;
		}
	}

	public Frame get_frame() {
		return(frame);
	}

	public SEResourceCache set_frame(Frame frame) {
		this.frame = frame;
		if(frame != null) {
			set_dpi(frame.get_dpi());
		}
		else {
			set_dpi(96);
		}
		return(this);
	}

	public virtual void on_font_prepared(String id) {
	}

	public bool prepare_font(String id, String details, double height) {
		if(String.is_empty(id)) {
			return(false);
		}
		var font = Font.instance(details);
		if(font == null) {
			return(false);
		}
		if(height > 0) {
			var sz = "%dpx".printf().add((int)Math.rint(height)).to_string();
			font.set_size(sz);
		}
		if(fonts == null) {
			fonts = HashTable.create();
		}
		Log.debug("SEResourceCache: Prepared font `%s': `%s' / %f".printf().add(id).add(details).add(height));
		fonts.set(id, font);
		on_font_prepared(id);
		return(true);
	}

	public Font get_font(String id) {
		Font v;
		if(fonts != null) {
			v = fonts.get(id) as Font;
		}
		if(v == null) {
			v = Font.instance("4mm");
		}
		return(v);
	}

	public virtual Object image_to_texture(Image img) {
		return(img);
	}

	public Image create_image_for_text(String text, String fontid) {
		var img = TextImage.for_properties(TextProperties.for_string(text).set_font(get_font(fontid)), get_frame(), get_dpi());
		return(img);
	}

	public Object create_texture_for_text(String text, String fontid) {
		return(image_to_texture(create_image_for_text(text, fontid)));
	}

	public Array get_image_sheet(String id) {
		if(sheets == null) {
			return(null);
		}
		return(sheets.get(id) as Array);
	}

	public bool prepare_image_sheet(String id, String resid, int cols, int rows, int max, double width, double height = -1.0) {
		if(id == null) {
			return(false);
		}
		if(sheets != null) {
			var v = sheets.get(id) as Array;
			if(v != null) {
				return(true);
			}
		}
		var ars = resid;
		if(ars == null) {
			ars = id;
		}
		Image img;
		IFDEF("target_html") {
			img = IconCache.get(ars);
		}
		ELSE {
			img = Image.for_resource(ars);
		}
		if(img == null) {
			Log.error("Failed to read image resource: `%s'".printf().add(ars));
			return(false);
		}
		var imgs = new ImageSheet().set_sheet(img).set_cols(cols).set_rows(rows).set_max_images(max).to_images((int)width, (int)height);
		if(imgs == null) {
			return(false);
		}
		if(sheets == null) {
			sheets = HashTable.create();
		}
		var nimgs = Array.create(imgs.count());
		int n;
		for(n=0; n<imgs.count(); n++) {
			nimgs.set(n, image_to_texture(imgs.get(n) as Image));
		}
		sheets.set(id, nimgs);
		return(true);
	}

	public SEImage prepare_image(String aid, String resid, double width, double height = -1.0) {
		if(String.is_empty(resid)) {
			return(null);
		}
		var id = aid;
		if(String.is_empty(id)) {
			id = "%s@%fx%f".printf().add(resid).add(width).add(height).to_string();
		}
		if(images == null) {
			images = HashTable.create();
		}
		var oo = images.get(id) as SEImage;
		if(oo != null) {
			return(oo);
		}
		var ars = resid;
		if(ars == null) {
			ars = id;
		}
		Image img;
		IFDEF("target_html") {
			img = IconCache.get(ars);
		}
		ELSE {
			img = Image.for_resource(ars);
		}
		if(img == null) {
			Log.error("Failed to read image resource: `%s'".printf().add(ars));
			return(null);
		}
		if(width > 0.0 || height > 0.0) {
			var nw = width, nh = height;
			if(nw == 0) {
				nw = img.get_width();
			}
			if(nh == 0) {
				nh = img.get_height();
			}
			if((nw > 0 && ((int)nw) != img.get_width()) || (nh > 0 && ((int)nh) != img.get_height())) {
				img = img.resize((int)nw, (int)nh);
			}
			if(img == null) {
				Log.error("Failed to scale image `%s' as %f x %f".printf().add(ars).add(nw).add(nh));
				return(null);
			}
		}
		var txt = image_to_texture(img);
		if(txt == null) {
			Log.error("Preparing image `%s': Failed to convert image to texture".printf().add(id));
			return(null);
		}
		var v = SEImage.for_texture(txt);
		images.set(id, v);
		Log.debug("SEResourceCache: Prepared image `%s' (%dx%dpx)".printf().add(id).add(img.get_width()).add(img.get_height()));
		return(v);
	}

	public Object get_texture(String id) {
		if(images != null) {
			var v = images.get(id) as SEImage;
			if(v != null) {
				return(v.as_texture(this));
			}
		}
		return(null);
	}

	IFDEF("enable_foreign_api")
	{
		public void releaseTexture(Object o) {
			release_texture(o);
		}
		public Frame getFrame() {
			return(frame);
		}
		public bool prepareFont(strptr id, strptr details, double height) {
			return(prepare_font(String.for_strptr(id), String.for_strptr(details), height));
		}
		public Object imageToTexture(Image img) {
			return(image_to_texture(img));
		}
		public Image createImageForText(strptr text, strptr fontid) {
			return(create_image_for_text(String.for_strptr(text), String.for_strptr(fontid)));
		}
		public Object createTextureForText(strptr text, strptr fontid) {
			return(create_texture_for_text(String.for_strptr(text), String.for_strptr(fontid)));
		}
		public Array getImageSheet(strptr id) {
			return(get_image_sheet(String.for_strptr(id)));
		}
		public bool prepareImageSheet(strptr id, strptr resid, int cols, int rows, int max, double width, double height) {
			return(prepare_image_sheet(
					String.for_strptr(id),
			String.for_strptr(resid),
				cols, rows, max, width, height));
		}
		public SEImage prepareImage(strptr id, double width) {
			return(prepareImageWithDetails(null, id, width, -1));
		}
		public SEImage prepareImageWithSize(strptr id, double width, double height) {
			return(prepareImageWithDetails(null, id, width, height));
		}
		public SEImage prepareImageWithDefaultSize(strptr id) {
			return(prepareImageWithDetails(null, id, -1, -1));
		}
		public SEImage prepareImageWithDetails(strptr id, strptr resid, double width, double height) {
			return(prepare_image(
				String.for_strptr(id),
				String.for_strptr(resid),
				width, height));
		}
		public Object getTexture(strptr id) {
			return(get_texture(String.for_strptr(id)));
		}
	}
}
