
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

public class SESurfaceBackend : SEBackend
{
	public static SESurfaceBackend instance(Frame frame) {
		var v = new SESurfaceBackend();
		v.set_frame(frame);
		return(v.initialize());
	}

	SEGameLoop gameloop;

	public SESurfaceBackend initialize() {
		update_resource_cache();
		return(this);
	}

	public virtual SEGameLoop create_game_loop() {
		var sescene = get_sescene();
		if(sescene == null) {
			return(null);
		}
		return(SEGenericGameLoop.for_scene(sescene));
	}

	public void start(SEScene scene) {
		if(gameloop != null) {
			stop();
		}
		base.start(scene);
		gameloop = create_game_loop();
	}

	public void stop() {
		if(gameloop != null) {
			gameloop.stop();
			gameloop = null;
		}
		base.stop();
	}

	public void cleanup() {
		stop();
		base.cleanup();
		// FIXME
	}

	public SESprite add_sprite() {
		return(SESurfaceSprite.create(get_frame(), null, get_resource_cache()));
	}

	public SESprite add_sprite_for_image(SEImage image) {
		var sprite = SESurfaceSprite.create(get_frame(), null, get_resource_cache());
		if(sprite != null ) {
			sprite.set_image(image);
		}
		return(sprite);
	}

	public SESprite add_sprite_for_text(String text, String fontid) {
		var sprite = SESurfaceSprite.create(get_frame(), null, get_resource_cache());
		if(sprite != null ) {
			sprite.set_text(text, fontid);
		}
		return(sprite);
	}

	public SESprite add_sprite_for_color(Color color, double width, double height) {
		var sprite = SESurfaceSprite.create(get_frame(), null, get_resource_cache());
		if(sprite != null ) {
			sprite.set_color(color, width, height);
		}
		return(sprite);
	}

	public SELayer add_layer(double x, double y, double width, double height, bool force_clipped) {
		// FIXME: Force the clipping (?)
		var layer = SESurfaceLayer.create(get_frame(), null, get_resource_cache());
		if(layer != null) {
			layer.move(x,y);
			layer.resize(width, height);
		}
		return(layer);
	}
}
