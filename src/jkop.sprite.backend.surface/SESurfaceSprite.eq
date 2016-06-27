
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

public class SESurfaceSprite : SESurfaceElement, SESprite, Renderable
{
	public static SESurfaceSprite create(SurfaceContainer container, SESurfaceLayer parent, SEResourceCache rsc) {
		if(container == null) {
			return(null);
		}
		SurfaceOptions opts;
		if(parent != null) {
			opts = SurfaceOptions.below(parent.get_helper_surface());
		}
		else {
			opts = SurfaceOptions.top();
		}
		var surf = container.add_surface(opts);
		if(surf == null) {
			return(null);
		}
		var v = new SESurfaceSprite();
		v.set_rsc(rsc);
		v.set_surface(surf);
		v.set_surface_container(container);
		return(v);
	}

	Image image;
	String resource;
	String text;
	String fontid;
	Color color;
	double color_width;
	double color_height;

	public void set_color(Color color, double width, double height) {
		this.color = color;
		this.color_width = width;
		this.color_height = height;
		update_sprite_surface();
	}

	public void set_image(SEImage img) {
		if(img != null) {
			image = img.get_texture() as Image;
			if(image == null) {
				image = img.get_image();
			}
			resource = img.get_resource();
		}
		else {
			image = null;
			resource = null;
		}
		update_sprite_surface();
	}

	public void set_text(String text, String fontid) {
		this.text = text;
		if(fontid != null) {
			this.fontid = fontid;
		}
		update_sprite_surface();
	}

	public void update_sprite_surface() {
		var rsc = get_rsc();
		if(rsc == null) {
			return;
		}
		var img = this.image;
		if(String.is_empty(resource) == false) {
			img = rsc.get_texture(resource) as Image;
		}
		else if(String.is_empty(text) == false) {
			img = rsc.create_image_for_text(text, fontid);
		}
		var surface = get_surface();
		if(surface != null && surface is Renderable) {
			if(img == null) {
				if(color != null) {
					surface.resize(color_width, color_height);
					((Renderable)surface).render(LinkedList.create().add(
						new FillColorOperation().set_color(color).set_shape(RectangleShape.create(0,0,color_width,color_height))
					));
				}
				else {
					((Renderable)surface).render(null);
					surface.resize(0, 0);
				}
			}
			else {
				if(img.get_width() != get_width() || img.get_height() != get_height()) {
					surface.resize(img.get_width(), img.get_height());
				}
				((Renderable)surface).render(LinkedList.create().add(new DrawObjectOperation().set_object(img)));
			}
		}
	}

	public void render(Collection ops) {
		var surface = get_surface();
		if(surface != null && surface is Renderable) {
			((Renderable)surface).render(ops);
		}
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
