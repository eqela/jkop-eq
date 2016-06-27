
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

public class SEDirect2DBackend : SEBackend, D2DElementList, Iterateable
{
	D2DSpriteRenderer renderer;
	Collection list;

	public static SEDirect2DBackend instance(Frame frame) {
		var f = frame as Direct2DWindowFrame;
		if(f == null) {
			return(null);
		}
		var v = new SEDirect2DBackend();
		v.set_frame(f);
		return(v.initialize());
	}

	SEDirect2DBackend initialize() {
		list = LinkedList.create();
		var winframe = get_frame() as Direct2DWindowFrame;
		var t = winframe.get_current_target();
		if(t != null) {
			update_resource_cache();
		}
		return(this);
	}

	public SEResourceCache create_resource_cache() {
		if(get_frame() != null) {
			var winframe = ((Direct2DWindowFrame)get_frame());
			return(D2DTargetResourceCache.for_d2dtarget(winframe.get_current_target()).set_frame(get_frame()));
		}
		return(base.create_resource_cache());
	}

	public void start(SEScene scene) {
		base.start(scene);
		if(renderer != null) {
			renderer.set_scene(scene);
			renderer.set_stop(false);
			return;
		}
		var winframe = (Direct2DWindowFrame)get_frame();
		var t = winframe.get_current_target();
		if(t != null) {
			renderer = new D2DSpriteRenderer();
			renderer.set_scene(scene);
			renderer.set_d2dtarget(t);
			renderer.set_backend(this);
			winframe.set_renderer(renderer);
		}
	}

	public void stop() {
		base.stop();
		if(renderer != null) {
			renderer.set_stop(true);
		}
	}

	public void cleanup() {
		base.cleanup();
		if(get_frame() != null) {
			var winframe = (Direct2DWindowFrame)get_frame();
			renderer = null;
			winframe.set_renderer(null);
		}
	}

	public void add_element(SEElement e) {
		list.append(e);
	}

	public void remove_element(SEElement e) {
		list.remove(e);
	}

	public Iterator iterate() {
		return(list.iterate());
	}

	public SESprite add_sprite() {
		var sprite = new D2DSprite();
		sprite.set_mycontainer(this);
		add_element(sprite);
		sprite.set_rsc(get_resource_cache());
		return(sprite);
	}

	public SESprite add_sprite_for_image(SEImage image) {
		var v = add_sprite();
		v.set_image(image);
		return(v);
	}

	public SESprite add_sprite_for_text(String text, String fontid) {
		var v = add_sprite();
		v.set_text(text, fontid);
		return(v);
	}

	public SESprite add_sprite_for_color(Color color, double width, double height) {
		var v = add_sprite();
		v.set_color(color, width, height);
		return(v);
	}

	public SELayer add_layer(double x, double y, double width, double height, bool force_clipped = false) {
		var v = new D2DLayer();
		v.set_mycontainer(this);
		add_element(v);
		v.set_rsc(get_resource_cache());
		v.move(x, y);
		v.resize(width, height);
		v.set_clipped(force_clipped);
		return(v);
	}
}
