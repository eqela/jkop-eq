
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

public class SESurfaceLayer : SESurfaceElement, SELayer, SEElementContainer
{
	public static SESurfaceLayer create(SurfaceContainer container, SESurfaceLayer parent, SEResourceCache rsc) {
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
		opts.set_surface_type(SurfaceOptions.SURFACE_TYPE_CONTAINER);
		var surf = container.add_surface(opts);
		if(surf == null) {
			return(null);
		}
		var helper_surface = container.add_surface(SurfaceOptions.inside(surf));
		if(helper_surface == null) {
			container.remove_surface(surf);
			return(null);
		}
		var v = new SESurfaceLayer();
		v.set_rsc(rsc);
		v.set_surface(surf);
		v.set_helper_surface(helper_surface);
		v.set_surface_container(container);
		return(v);
	}

	property Surface helper_surface;

	public void cleanup() {
		// FIXME
	}

	public SESprite add_sprite() {
		return(SESurfaceSprite.create(get_surface_container(), this, get_rsc()));
	}

	public SESprite add_sprite_for_image(SEImage image) {
		var sprite = SESurfaceSprite.create(get_surface_container(), this, get_rsc());
		if(sprite != null) {
			sprite.set_image(image);
		}
		return(sprite);
	}

	public SESprite add_sprite_for_text(String text, String fontid) {
		var sprite = SESurfaceSprite.create(get_surface_container(), this, get_rsc());
		if(sprite != null) {
			sprite.set_text(text, fontid);
		}
		return(sprite);
	}

	public SESprite add_sprite_for_color(Color color, double width, double height) {
		var sprite = SESurfaceSprite.create(get_surface_container(), this, get_rsc());
		if(sprite != null) {
			sprite.set_color(color, width, height);
		}
		return(sprite);
	}

	public SELayer add_layer(double x, double y, double width, double height, bool force_clipped) {
		// FIXME: Force the clipping (?)
		var layer = SESurfaceLayer.create(get_surface_container(), this, get_rsc());
		if(layer != null) {
			layer.move(x,y);
			layer.resize(width, height);
		}
		return(layer);
	}

	public void resize(double width, double height) {
		var surface = get_surface();
		if(surface != null) {
			surface.resize(width, height);
		}
	}

	public void remove_from_container() {
		var surface_container = get_surface_container();
		if(helper_surface != null && surface_container != null) {
			surface_container.remove_surface(helper_surface);
			helper_surface = null;
		}
		base.remove_from_container();
	}

	IFDEF("enable_foreign_api") {
		public SESprite addSprite() {
			return(add_sprite());
		}
		public SESprite addSpriteForImage(SEImage image) {
			return(add_sprite_for_image(image));
		}
		public SESprite addSpriteForText(strptr text, strptr fontid) {
			return(add_sprite_for_text(String.for_strptr(text), String.for_strptr(fontid)));
		}
		public SESprite addSpriteForColor(strptr color, double width, double height) {
			return(add_sprite_for_color(
				Color.instance(String.for_strptr(color)), width, height));
		}
		public SELayer addLayer(double x, double y, double width, double height, bool force_clipped) {
			return(add_layer(x,y,width,height,force_clipped));
		}
	}
}
