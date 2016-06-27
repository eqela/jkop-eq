
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

public class SEEntity : SEElementContainer, SEMessageListener
{
	property SEScene scene;
	property LinkedListNode mynode;
	property SEElementContainer container;

	public void on_message(Object o) {
	}

	public virtual void initialize(SEResourceCache rsc) {
	}

	public virtual void cleanup() {
	}

	public virtual void tick(TimeVal now, double delta) {
	}

	public int px(String s, int dpi = -1) {
		if(scene == null) {
			return(0);
		}
		return(scene.px(s,dpi));
	}

	public Iterator iterate_pointers() {
		if(scene == null) {
			return(null);
		}
		return(scene.iterate_pointers());
	}

	public void remove_entity() {
		if(scene != null) {
			scene.remove_entity(this);
		}
	}

	public virtual void on_entity_removed() {
	}

	public SEEntity add_entity(SEEntity entity) {
		if(scene == null || entity == null) {
			return(null);
		}
		entity.set_container(container);
		return(scene.add_entity(entity));
	}

	public int get_scene_width() {
		if(scene == null) {
			return(0);
		}
		return(scene.get_scene_width());
	}

	public int get_scene_height() {
		if(scene == null) {
			return(0);
		}
		return(scene.get_scene_height());
	}

	public bool is_key_pressed(String name) {
		if(scene == null) {
			return(false);
		}
		return(scene.is_key_pressed(name));
	}

	public SESprite add_sprite() {
		if(container != null) {
			return(container.add_sprite());
		}
		if(scene == null) {
			return(null);
		}
		return(scene.add_sprite());
	}

	public SESprite add_sprite_for_image(SEImage image) {
		if(container != null) {
			return(container.add_sprite_for_image(image));
		}
		if(scene == null) {
			return(null);
		}
		return(scene.add_sprite_for_image(image));
	}

	public SESprite add_sprite_for_text(String text, String fontid) {
		if(container != null) {
			return(container.add_sprite_for_text(text, fontid));
		}
		if(scene == null) {
			return(null);
		}
		return(scene.add_sprite_for_text(text, fontid));
	}

	public SESprite add_sprite_for_color(Color color, double width, double height) {
		if(container != null) {
			return(container.add_sprite_for_color(color, width, height));
		}
		if(scene == null) {
			return(null);
		}
		return(scene.add_sprite_for_color(color, width, height));
	}

	public SELayer add_layer(double x, double y, double width, double height, bool force_clipped = false) {
		if(container != null) {
			return(container.add_layer(x, y, width, height, force_clipped));
		}
		if(scene == null) {
			return(null);
		}
		return(scene.add_layer(x, y, width, height, force_clipped));
	}

	IFDEF("enable_foreign_api") {
		public SEScene getScene() {
			return(scene);
		}
		public SEElementContainer getContainer() {
			return(container);
		}
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
