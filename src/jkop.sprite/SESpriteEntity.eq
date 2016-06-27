
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

public class SESpriteEntity : SEEntity, SEElement, SESprite
{
	public static SESpriteEntity for_image(SEImage image) {
		return (new SESpriteEntity().set_initial_image(image));
	}

	public static SESpriteEntity for_text(String text, String fontid) {
		return (new SESpriteEntity().set_initial_text(text).set_initial_font(fontid));
	}

	public static SESpriteEntity for_color(Color color, double width, double height) {
		return (new SESpriteEntity().set_initial_color(color).set_initial_width(width).set_initial_height(height));
	}

	SESprite sprite;
	property Position initial_position;
	property SEImage initial_image;
	property String initial_text;
	property String initial_font;
	property Color initial_color;
	property double initial_width;
	property double initial_height;
	property double initial_rotation = 0.0;
	property double initial_alpha = 1.0;
	Array image_sheet;
	int current_frame = -1;

	public SESpriteEntity set_image_sheet(Array imgs) {
		image_sheet = imgs;
		current_frame = -1;
		next_frame();
		return(this);
	}

	public bool next_frame() {
		if(image_sheet == null || image_sheet.count() < 1) {
			set_image(null);
			return(false);
		}
		current_frame ++;
		if(current_frame >= image_sheet.count()) {
			current_frame = 0;
		}
		set_image(SEImage.for_texture(image_sheet.get(current_frame)));
		return(true);
	}

	public SESpriteEntity set_xy(double x, double y) {
		initial_position = Position.instance(x,y);
		move(x, y);
		return(this);
	}

	public virtual SESprite create_sprite() {
		var container = get_container();
		if(container != null) {
				return(container.add_sprite());
		}
		var scene = get_scene();
		if(scene == null) {
			return(null);
		}
		return(scene.add_sprite());
	}

	public void initialize(SEResourceCache rsc) {
		base.initialize(rsc);
		sprite = create_sprite();
		if(initial_image != null) {
			sprite.set_image(initial_image);
		}
		else if(initial_text != null) {
			sprite.set_text(initial_text, initial_font);
		}
		else if(initial_color != null) {
			sprite.set_color(initial_color, initial_width, initial_height);
		}
		if(initial_position != null) {
			move(initial_position.get_x(), initial_position.get_y());
		}
		set_rotation(initial_rotation);
		set_alpha(initial_alpha);
	}

	public void cleanup() {
		base.cleanup();
		if(sprite != null) {
			sprite = SESprite.remove(sprite);
		}
	}

	public bool is_inside(SEPointerInfo pi) {
		if(pi == null) {
			return(false);
		}
		var x = pi.get_x(), y = pi.get_y();
		if(x >= get_x() && x < get_x() + get_width() &&
			y >= get_y() && y < get_y() + get_height()) {
			return(true);
		}
		return(false);
	}
	
	public void set_image(SEImage image) {
		if(sprite == null) {
			return;
		}
		sprite.set_image(image);
	}

	public void set_text(String text, String fontid = null) {
		if(sprite == null) {
			return;
		}
		sprite.set_text(text, fontid);
	}

	public void set_color(Color color, double width, double height) {
		if(sprite == null) {
			return;
		}
		sprite.set_color(color, width, height);
	}

	public void move(double x, double y) {
		if(sprite == null) {
			return;
		}
		sprite.move(x, y);
	}

	public void set_rotation(double angle) {
		if(sprite == null) {
			return;
		}
		sprite.set_rotation(angle);
	}

	public void set_scale(double sx, double sy) {
		if(sprite == null) {
			return;
		}
		sprite.set_scale(sx, sy);
	}

	public void set_alpha(double alpha) {
		if(sprite == null) {
			return;
		}
		sprite.set_alpha(alpha);
	}

	public SESprite get_sprite() {
		return(sprite);
	}

	public double get_x() {
		if(sprite == null) {
			return(0);
		}
		return(sprite.get_x());
	}

	public double get_y() {
		if(sprite == null) {
			return(0);
		}
		return(sprite.get_y());
	}

	public double get_width() {
		if(sprite == null) {
			return(0);
		}
		return(sprite.get_width());
	}

	public double get_height() {
		if(sprite == null) {
			return(0);
		}
		return(sprite.get_height());
	}

	public double get_rotation() {
		if(sprite == null) {
			return(0);
		}
		return(sprite.get_rotation());
	}

	public double get_scale_x() {
		if(sprite == null) {
			return(0);
		}
		return(sprite.get_scale_x());
	}

	public double get_scale_y() {
		if(sprite == null) {
			return(0);
		}
		return(sprite.get_scale_y());
	}

	public double get_alpha() {
		if(sprite == null) {
			return(0);
		}
		return(sprite.get_alpha());
	}

	public void remove_from_container() {
		remove_entity();
	}

	IFDEF("enable_foreign_api") {
		public bool nextFrame() {
			return(next_frame());
		}
		public SESpriteEntity setXY(double x, double y) {
			return(set_xy(x, y));
		}
		public bool isInside(SEPointerInfo pi) {
			return(is_inside(pi));
		}
		public SESpriteEntity setImageSheet(Array imgs) {
			return(set_image_sheet(imgs));
		}
		public void setImage(strptr image) {
			set_image(SEImage.for_resource(String.for_strptr(image)));
		}
		public void setText(strptr text, strptr fontid) {
			set_text(String.for_strptr(text), String.for_strptr(fontid));
		}
		public void setColor(strptr color, double width, double height) {
			set_color(Color.instance(String.for_strptr(color)), width, height);
		}
		public void setRotation(double angle) {
			set_rotation(angle);
		}
		public void setAlpha(double alpha) {
			set_alpha(alpha);
		}
		public void setScale(double scalex, double scaley) {
			set_scale(scalex, scaley);
		}
		public double getX() {
			return(get_x());
		}
		public double getY() {
			return(get_y());
		}
		public double getWidth() {
			return(get_width());
		}
		public double getHeight() {
			return(get_height());
		}
		public double getRotation() {
			return(get_rotation());
		}
		public double getAlpha() {
			return(get_alpha());
		}
		public double getScaleX() {
			return(get_scale_x());
		}
		public double getScaleY() {
			return(get_scale_y());
		}
		public void removeFromContainer() {
			remove_from_container();
		}
	}
}
