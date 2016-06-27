
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

public class SEMainMenuScene : SEScene
{
	class FooterEntity : SEEntity, SEPointerListener
	{
		property String url;
		property String logoname;
		property String copyright;
		property String font_color;
		property String twitterid;
		property String facebookid;
		property Color background_color;
		SELayer layer;
		SESprite s_bg;
		SESprite s_logo;
		SESprite s_copyright;
		SESprite s_poweredby;
		SESprite s_twitter;
		SESprite s_facebook;
		int logox = 0;
		int logoy = 0;

		public double get_height() {
			if(layer == null) {
				return(0);
			}
			return(layer.get_height());
		}

		public SELayer get_layer() {
			return(layer);
		}

		public void initialize(SEResourceCache rsc) {
			base.initialize(rsc);
			var mm = px("500um");
			layer = add_layer(0, 0, get_scene_width(), px("5mm") + mm*2);
			if(background_color != null) {
				s_bg = layer.add_sprite_for_color(background_color, get_scene_width(), layer.get_height());
			}
			if(String.is_empty(logoname) == false) {
				rsc.prepare_image("footerlogo", logoname, -1, px("5mm"));
				s_logo = layer.add_sprite_for_image(SEImage.for_resource("footerlogo"));
				s_logo.move(mm, mm);
				logox = s_logo.get_x() + s_logo.get_width();
				logoy = s_logo.get_y() + s_logo.get_height();
			}
			if(String.is_empty(copyright) == false) {
				var fc = font_color;
				if(String.is_empty(fc)) {
					fc = "black";
				}
				rsc.prepare_font("copyrightfont", "color=".append(fc), px("2000um"));
				s_copyright = layer.add_sprite_for_text(copyright, "copyrightfont");
				int x;
				if(s_logo != null) {
					x = s_logo.get_width() + mm * 2;
				}
				else {
					x = mm;
				}
				s_copyright.move(x, (layer.get_height()-s_copyright.get_height())/2);
				logox = s_copyright.get_x() + s_copyright.get_width();
				logoy = s_copyright.get_y() + s_copyright.get_height();
			}
			var x = get_scene_width();
			rsc.prepare_image("poweredbyeqela_footer", "poweredbyeqela", -1, px("5mm"));
			s_poweredby = layer.add_sprite_for_image(SEImage.for_resource("poweredbyeqela_footer"));
			x -= mm;
			x -= s_poweredby.get_width();
			s_poweredby.move(x, mm);
			if(String.is_empty(twitterid) == false) {
				rsc.prepare_image("twitter_footer", "twitter_logo", -1, px("5mm"));
				s_twitter = layer.add_sprite_for_image(SEImage.for_resource("twitter_footer"));
				x -= mm;
				x -= s_twitter.get_width();
				s_twitter.move(x, mm);
			}
			if(String.is_empty(facebookid) == false) {
				rsc.prepare_image("facebook_footer", "facebook_logo", -1, px("5mm"));
				s_facebook = layer.add_sprite_for_image(SEImage.for_resource("facebook_footer"));
				x -= mm;
				x -= s_facebook.get_width();
				s_facebook.move(x, mm);
			}
		}

		public void cleanup() {
			base.cleanup();
			s_logo = SESprite.remove(s_logo);
			s_copyright = SESprite.remove(s_copyright);
			s_poweredby = SESprite.remove(s_poweredby);
			s_twitter = SESprite.remove(s_twitter);
			s_facebook = SESprite.remove(s_facebook);
			s_bg = SESprite.remove(s_bg);
			layer = SELayer.remove(layer);
		}

		public void on_pointer_move(SEPointerInfo pi) {
		}

		bool is_inside_element(SEPointerInfo pi, SEElement ee) {
			if(layer == null || pi == null || ee == null) {
				return(false);
			}
			if(pi.is_inside(layer.get_x()+ee.get_x(), layer.get_y()+ee.get_y(), ee.get_width(), ee.get_height())) {
				return(true);
			}
			return(false);
		}

		public void on_pointer_press(SEPointerInfo pi) {
			if(pi.get_x() < logox && pi.get_y() < logoy) {
				URLHandler.open(url);
			}
			else if(is_inside_element(pi, s_twitter)) {
				URLHandler.open("http://www.twitter.com/".append(twitterid));
			}
			else if(is_inside_element(pi, s_facebook)) {
				URLHandler.open("http://www.facebook.com/".append(facebookid));
			}
			else if(is_inside_element(pi, s_poweredby)) {
				URLHandler.open("http://www.eqela.com/applink");
			}
		}

		public void on_pointer_release(SEPointerInfo pi) {
		}
	}

	SESprite bg_sprite;
	SESprite logo_sprite;
	SESprite text_sprite;
	FooterEntity footer;
	bool first = true;
	property String background_image_resource;
	property String logo_image_resource;
	property String copyright;
	property String footerlogo_resource;
	property String url;
	property String twitterid;
	property String facebookid;
	property Color footer_background_color;
	property bool footer_is_on_top = false;
	property String text_font;

	public SEMainMenuScene() {
		text_font = "bold color=white outline-color=black";
	}

	public virtual void first_initialize() {
	}

	bool is_desktop() {
		var f = get_frame();
		if(f != null && f.get_frame_type() == Frame.TYPE_DESKTOP) {
			return(true);
		}
		return(false);
	}

	public void initialize(SEResourceCache rsc) {
		if(first) {
			first_initialize();
			first = false;
		}
		base.initialize(rsc);
		var width = get_scene_width();
		var height = get_scene_height();
		if(String.is_empty(background_image_resource) == false) {
			rsc.prepare_image("splash", background_image_resource, width, height);
		}
		if(String.is_empty(logo_image_resource) == false) {
			rsc.prepare_image("logo", logo_image_resource, width * 0.38);
		}
		bg_sprite = add_sprite_for_image(SEImage.for_resource("splash"));
		logo_sprite = add_sprite_for_image(SEImage.for_resource("logo"));
		rsc.prepare_font("textfont", text_font, height * 0.1);
		String text;
		if(is_desktop()) {
			text = "Click to start";
		}
		else {
			text = "Tap to start";
		}
		text_sprite = add_sprite_for_text(text, "textfont");
		var sp = px("2mm");
		var th = logo_sprite.get_height() + sp + text_sprite.get_height();
		logo_sprite.move(get_scene_width() / 2 - logo_sprite.get_width() / 2, get_scene_height() / 2 - th / 2);
		text_sprite.move(get_scene_width() / 2 - text_sprite.get_width() / 2, get_scene_height() / 2 + th / 2 - text_sprite.get_height());
		add_entity(footer = new FooterEntity()
			.set_background_color(footer_background_color)
			.set_copyright(copyright)
			.set_logoname(footerlogo_resource)
			.set_url(url)
			.set_twitterid(twitterid)
			.set_facebookid(facebookid)
		);
	}

	public void show_scene(SEAnimationListener listener) {
		var ame = new SEAnimationManagerEntity().set_listener(listener);
		ame.add_element(SEFaderAnimationElement.for_fadein(bg_sprite));
		ame.add_element(SEFaderAnimationElement.for_fadein(logo_sprite));
		ame.add_element(SEFaderAnimationElement.for_fadein(text_sprite));
		var layer = footer.get_layer();
		if(footer_is_on_top) {
			ame.add_element(SEMoverAnimationElement.for_element(layer, 0, -layer.get_height(), 0, 0, 1, false, true));
		}
		else {
			ame.add_element(SEMoverAnimationElement.for_element(layer, 0, get_scene_height(), 0, get_scene_height()-layer.get_height(), 1, false, true));
		}
		add_entity(ame);
	}

	public void hide_scene(SEAnimationListener listener) {
		var ame = new SEAnimationManagerEntity().set_listener(listener);
		ame.add_element(SEFaderAnimationElement.for_fadeout(bg_sprite));
		ame.add_element(SEFaderAnimationElement.for_fadeout(logo_sprite));
		ame.add_element(SEFaderAnimationElement.for_fadeout(text_sprite));
		var layer = footer.get_layer();
		if(footer_is_on_top) {
			ame.add_element(SEMoverAnimationElement.for_element(layer, 0, 0, 0, -layer.get_height(), 1, true, false));
		}
		else {
			ame.add_element(SEMoverAnimationElement.for_element(layer, 0, get_scene_height()-layer.get_height(), 0, get_scene_height(), 1, true, false));
		}
		add_entity(ame);
	}

	public void cleanup() {
		base.cleanup();
		bg_sprite = SESprite.remove(bg_sprite);
		logo_sprite = SESprite.remove(logo_sprite);
		text_sprite = SESprite.remove(text_sprite);
		footer = null;
	}

	public virtual SEScene create_next_scene() {
		return(null);
	}

	public virtual void on_next_scene() {
		var ss = create_next_scene();
		if(ss != null) {
			push_scene(ss);
		}
	}

	public void on_message(Object o) {
		if("play".equals(o)) {
			on_next_scene();
			return;
		}
		base.on_message(o);
	}

	public void on_escape_key_press() {
		pop_scene();
	}

	public void on_pointer_press(SEPointerInfo pi) {
		base.on_pointer_press(pi);
		if(footer != null) {
			if(footer_is_on_top) {
				if(pi.get_y() < footer.get_height()) {
					return;
				}
			}
			else {
				if(pi.get_y() >= get_scene_height() - footer.get_height()) {
					return;
				}
			}
		}
		on_next_scene();
	}

	public void update(TimeVal now, double delta) {
		base.update(now, delta);
		if(is_key_pressed("enter")) {
			on_next_scene();
		}
	}
}
