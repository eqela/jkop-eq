
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

public class SEWPCSLayer : SEWPCSElement, SELayer, SEElementContainer
{
	property bool force_clipped;

	public void cleanup() {
		embed "cs" {{{
			BackendCanvas.Children.Clear();
		}}}
	}

	public SESprite add_sprite() {
		var v = new SEWPCSSprite();
		embed "cs" {{{
			BackendCanvas.Children.Add(v.BackendCanvas);
		}}}
		v.set_rsc(get_rsc());
		return(v);
	}

	public SESprite add_sprite_for_image(SEImage image) {
		var v = add_sprite();
		v.set_image(image);
		return(v);
	}

	public SESprite add_sprite_for_text(String text, String fontid) {
		var v = add_sprite();
		if(v != null) {
			v.set_text(text, fontid);
		}
		return(v);
	}

	public SESprite add_sprite_for_color(Color color, double width, double height) {
		var v = add_sprite();
		if(v != null) {
			v.set_color(color, width, height);
		}
		return(v);
	}

	public SELayer add_layer(double x, double y, double width, double height, bool force_clipped = false) {
		var v = new SEWPCSLayer().set_force_clipped(force_clipped);
		embed "cs" {{{
			BackendCanvas.Children.Add(v.BackendCanvas);
		}}}
		v.move(x,y);
		v.resize(width, height);
		return(v);
	}

	public void resize(double width, double height) {
		resize_backend(width, height);
		if(force_clipped) {
			embed {{{
				BackendCanvas.Clip = new System.Windows.Media.RectangleGeometry() { Rect = new System.Windows.Rect(0, 0, width, height) };
			}}}
		}
	}
}
