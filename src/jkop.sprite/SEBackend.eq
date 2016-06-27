
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

public class SEBackend : SEElementContainer
{
	property SEResourceCache resource_cache;
	property SEScene sescene;
	property Frame frame;

	public virtual SEResourceCache create_resource_cache() {
		return(SEResourceCache.for_frame(frame));
	}

	public void update_resource_cache() {
		if(resource_cache != null) {
			resource_cache.cleanup();
			resource_cache = null;
		}
		resource_cache = create_resource_cache();
		resource_cache.set_frame(get_frame());
	}

	public void on_scene_changed() {
		update_resource_cache();
	}

	public virtual void start(SEScene scene) {
		this.sescene = scene;
	}

	public virtual void stop() {
		this.sescene = null;
	}

	public virtual void cleanup() {
		if(resource_cache != null) {
			resource_cache.cleanup();
			resource_cache = null;
		}
		frame = null;
		sescene = null;
	}

	public virtual bool is_high_performance() {
		return(false);
	}

	public SESprite add_sprite() {
		return(null);
	}

	public SESprite add_sprite_for_image(SEImage image) {
		return(null);
	}

	public SESprite add_sprite_for_text(String text, String fontid) {
		return(null);
	}

	public SESprite add_sprite_for_color(Color color, double width, double height) {
		return(null);
	}

	public SELayer add_layer(double x, double y, double width, double height, bool force_clipped = false) {
		return(null);
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
