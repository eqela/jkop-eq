
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

public class SESpriteKitLayer : SESpriteKitElement, SEElementContainer, SELayer
{
	embed {{{
		#import <SpriteKit/SpriteKit.h>
	}}}

	double width;
	double height;

	ptr get_container() {
		return(get_node());
	}

	public virtual void create_layer_node(double width, double height) {
		ptr ndp;
		var parent = get_parent();
		embed {{{
			SKNode* pnode = (__bridge SKNode*)parent;
			SKNode* nd = [SKNode node];
			ndp = (__bridge_retained void*)nd;
			[pnode addChild:nd];
		}}}
		set_node(ndp);
	}

	public void resize(double width, double height) {
		remove_node();
		if(width < 1 || height < 1) {
			return;
		}
		create_layer_node(width, height);
		this.width = width;
		this.height = height;
		update_position();
	}

	public void cleanup() {
		remove_node();
	}

	public double get_width() {
		return(width);
	}

	public double get_height() {
		return(height);
	}

	public SESprite add_sprite() {
		var v = new SESpriteKitSprite();
		v.set_rsc(get_rsc());
		v.set_parent(get_container());
		return(v);
	}

	public SESprite add_sprite_for_image(SEImage image) {
		var v = new SESpriteKitSprite();
		v.set_rsc(get_rsc());
		v.set_parent(get_container());
		v.set_image(image);
		return(v);
	}

	public SESprite add_sprite_for_text(String text, String fontid) {
		var v = new SESpriteKitSprite();
		v.set_rsc(get_rsc());
		v.set_parent(get_container());
		v.set_text(text, fontid);
		return(v);
	}

	public SESprite add_sprite_for_color(Color color, double width, double height) {
		var v = new SESpriteKitSprite();
		v.set_rsc(get_rsc());
		v.set_parent(get_container());
		v.set_color(color, width, height);
		return(v);
	}

	public SELayer add_layer(double x, double y, double width, double height, bool force_clipped) {
		SESpriteKitLayer v;
		if(force_clipped) {
			v = new SESpriteKitClippedLayer();
		}
		else {
			v = new SESpriteKitLayer();
		}
		v.set_rsc(get_rsc());
		v.set_parent(get_container());
		v.resize(width, height);
		v.move(x, y);
		return(v);
	}
}
