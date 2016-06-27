
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

public class SEHTMLElementLayer : SEHTMLElementElement, SEElementContainer, SELayer
{
	property bool force_clipping = false;
		
	public void resize(double width, double height) {
		var el = get_element();
		if(el == null) {
			return;
		}
		var iw = (int)width;
		var ih = (int)height;
		embed {{{
			el.style.width = iw;
			el.style.height = ih;
		}}}
		set_width(iw);
		set_height(ih);
	}

	public void initialize() {
		ptr el;
		var pp = get_parent();
		var mydoc = get_document();
		var force_clipping = this.force_clipping;
		embed {{{
			el = mydoc.createElement("div");
			el.style.position = "absolute";
			if(force_clipping) {
				el.style.overflow = "hidden";
			}
			pp.appendChild(el);
		}}}
		set_element(el);
	}

	public void cleanup() {
		remove_from_container();
		set_element(null);
	}

	public SESprite add_sprite() {
		var v = new SEHTMLElementSprite();
		v.set_rsc(get_rsc());
		v.set_document(get_document());
		v.set_parent(get_element());
		return(v);
	}

	public SESprite add_sprite_for_image(SEImage image) {
		var v = new SEHTMLElementSprite();
		v.set_rsc(get_rsc());
		v.set_document(get_document());
		v.set_parent(get_element());
		v.set_image(image);
		return(v);
	}

	public SESprite add_sprite_for_text(String text, String fontid) {
		var v = new SEHTMLElementSprite();
		v.set_rsc(get_rsc());
		v.set_document(get_document());
		v.set_parent(get_element());
		v.set_text(text, fontid);
		return(v);
	}

	public SESprite add_sprite_for_color(Color color, double width, double height) {
		var v = new SEHTMLElementSprite();
		v.set_rsc(get_rsc());
		v.set_document(get_document());
		v.set_parent(get_element());
		v.set_color(color, width, height);
		return(v);
	}

	public SELayer add_layer(double x, double y, double width, double height, bool force_clipped = false) {
		var v = new SEHTMLElementLayer();
		v.set_force_clipping(force_clipped);
		v.set_rsc(get_rsc());
		v.set_parent(get_element());
		v.initialize();
		v.resize(width, height);
		v.move(x, y);
		return(v);
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
