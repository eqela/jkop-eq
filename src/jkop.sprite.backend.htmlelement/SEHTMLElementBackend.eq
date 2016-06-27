
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

public class SEHTMLElementBackend : SEBackend
{
	public static SEHTMLElementBackend instance(Frame fr, bool debug = false) {
		var v = new SEHTMLElementBackend();
		if(debug) {
			v.set_debug(debug);
		}
		v.set_frame(fr);
		return(v.initialize());
	}

	property bool debug;

	public SEResourceCache create_resource_cache() {
		return(new SEHTMLElementResourceCache());
	}

	public SEHTMLElementBackend initialize() {
		update_resource_cache();
		return(this);
	}

	public ptr get_document() {
		ptr v;
		var ff = get_frame() as HTML5Frame;
		if(ff != null) {
			v = ff.get_document();
		}
		if(v == null) {
			embed {{{
				v = document;
			}}}
		}
		return(v);
	}

	public ptr get_document_body() {
		var doc = get_document();
		ptr v;
		embed {{{
			v = doc.body;
		}}}
		return(v);
	}

	public void start(SEScene scene) {
		base.start(scene);
		var self = this;
		embed {{{
			var mainloop = function() {
				self.on_update();
			};
			var animframe = window.requestAnimationFrame ||
				window.webkitRequestAnimationFrame ||
				window.mozRequestAnimationFrame ||
				window.oRequestAnimationFrame ||
				window.msRequestAnimationFrame ||
				null;
			if(animframe != null) {
				var rr = function() {
					mainloop();
					animframe(rr);
				};
				animframe(rr);
			}
			else {
				setInterval(mainloop, 1000.0 / 60.0);
			}
		}}}
	}

	public void on_update() {
		var se = get_sescene();
		if(se != null) {
			se.tick();
		}
	}

	public void stop() {
		base.stop();
	}

	public void cleanup() {
		base.cleanup();
	}

	public SESprite add_sprite() {
		var v = new SEHTMLElementSprite();
		v.set_rsc(get_resource_cache());
		v.set_document(get_document());
		v.set_parent(get_document_body());
		return(v);
	}

	public SESprite add_sprite_for_image(SEImage image) {
		var v = new SEHTMLElementSprite();
		v.set_rsc(get_resource_cache());
		v.set_document(get_document());
		v.set_parent(get_document_body());
		v.set_image(image);
		return(v);
	}

	public SESprite add_sprite_for_text(String text, String fontid) {
		var v = new SEHTMLElementSprite();
		v.set_rsc(get_resource_cache());
		v.set_document(get_document());
		v.set_parent(get_document_body());
		v.set_text(text, fontid);
		return(v);
	}

	public SESprite add_sprite_for_color(Color color, double width, double height) {
		var v = new SEHTMLElementSprite();
		v.set_rsc(get_resource_cache());
		v.set_document(get_document());
		v.set_parent(get_document_body());
		v.set_color(color, width, height);
		return(v);
	}

	public SELayer add_layer(double x, double y, double width, double height, bool force_clipped = false) {
		var v = new SEHTMLElementLayer();
		v.set_force_clipping(force_clipped);
		v.set_rsc(get_resource_cache());
		v.set_document(get_document());
		v.set_parent(get_document_body());
		v.initialize();
		v.resize(width, height);
		v.move(x, y);
		return(v);
	}
}
