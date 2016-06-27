
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

public class SEWPCSBackend : SEBackend
{
	embed "cs" {{{
		System.Windows.Controls.Canvas gamecanvas;
		System.Windows.Controls.Canvas mycanvas;
	}}}

	public static SEWPCSBackend instance(Frame frame, bool debug) {
		embed "cs" {{{
			System.Windows.Application.Current.Host.Settings.EnableFrameRateCounter = debug;
		}}}
		var v = new SEWPCSBackend();
		v.set_frame(frame);
		v.initialize();
		return(v);
	}
	
	public void initialize() {
		update_resource_cache();
		var frame = get_frame();
		embed "cs" {{{
			var framecanvas = frame as System.Windows.Controls.Canvas;
			if(framecanvas != null) {
				mycanvas = framecanvas.Children[0] as System.Windows.Controls.Canvas;
				if(mycanvas!=null) {
					framecanvas.Children.Remove(mycanvas);
				}
				gamecanvas = new System.Windows.Controls.Canvas() { Width = ((com.eqela.libgui.Size)frame).get_width(), Height = ((com.eqela.libgui.Size)frame).get_height() };
				framecanvas.Children.Insert(0, gamecanvas);
			}
		}}}
	}

	SEGameLoop gameloop;

	public void start(SEScene scene) {
		if(gameloop != null) {
			gameloop.stop();
		}
		var prefs = scene.get_frame_preferences();
		if(prefs != null && prefs.get_fullscreen()) {
			embed {{{
				Microsoft.Phone.Shell.SystemTray.IsVisible = false;
			}}}
		}
		base.start(scene);
		gameloop = TimerGameLoop.for_scene(scene);
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
		var frame = get_frame();
		embed "cs" {{{
			if(mycanvas!=null) {
				var framecanvas = frame as System.Windows.Controls.Canvas;
				if(framecanvas != null) {
					if(gamecanvas!=null) {
						framecanvas.Children.Remove(gamecanvas);
					}
					framecanvas.Children.Insert(0, mycanvas);
				}
			}
		}}}
		base.cleanup();
	}

	public SESprite add_sprite() {
		var v = new SEWPCSSprite();
		embed "cs" {{{
			gamecanvas.Children.Add(v.BackendCanvas);
		}}}
		v.set_rsc(get_resource_cache());
		return(v);
	}

	public SESprite add_sprite_for_image(SEImage image) {
		var sprite = add_sprite();
		if(sprite != null ) {
			sprite.set_image(image);
		}
		return(sprite);
	}

	public SESprite add_sprite_for_text(String text, String fontid) {
		var sprite = add_sprite();
		if(sprite != null ) {
			sprite.set_text(text, fontid);
		}
		return(sprite);
	}

	public SESprite add_sprite_for_color(Color color, double width, double height) {
		var sprite = add_sprite();
		if(sprite != null ) {
			sprite.set_color(color, width, height);
		}
		return(sprite);
	}

	public SELayer add_layer(double x, double y, double width, double height, bool force_clipped = false) {
		var v = new SEWPCSLayer().set_force_clipped(force_clipped);
		v.set_rsc(get_resource_cache());
		embed "cs" {{{
			gamecanvas.Children.Add(v.BackendCanvas);
		}}}
		if(v != null) {
			v.move(x,y);
			v.resize(width, height);
		}
		return(v);
	}
}
