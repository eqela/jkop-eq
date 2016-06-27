
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

public class SESpriteKitElement : SEElement
{
	embed {{{
		#import <SpriteKit/SpriteKit.h>
	}}}

	property SEResourceCache rsc;
	property ptr parent;
	property ptr node;
	double x;
	double y;
	double angle;
	double scale_x = 1.0;
	double scale_y = 1.0;
	double alpha = 1.0;

	public ~SESpriteKitElement() {
		remove_node();
	}

	public void remove_node() {
		if(node == null) {
			return;
		}
		var ndp = node;
		embed {{{
			SKNode* nd = (__bridge_transfer SKNode*)ndp;
			[nd removeFromParent];
		}}}
		node = null;
	}
		
	public void move(double x, double y) {
		this.x = x;
		this.y = y;
		update_position();
	}

	public void update_position() {
		var ndp = get_node();
		if(ndp == null) {
			return;
		}
		var skc = get_parent();
		var x = get_x();
		var y = get_y();
		var sx = get_scale_x();
		var sy = get_scale_y();
		var w = get_width();
		var h = get_height();
		embed {{{
			SKNode* sknd = (__bridge SKNode*)ndp;
			CGSize sz, ndsz;
			sz = [(__bridge SKNode*)skc frame].size;
			if(sx != 1.0 || sy != 1.0) {
				sknd.xScale = sx;
				sknd.yScale = sy;
			}
			ndsz = [sknd frame].size;
			if(ndsz.width < 1 || ndsz.height < 1) {
				sknd.position = CGPointMake(x, sz.height - y);
			}
			else {
				sknd.position = CGPointMake(x + w / 2, sz.height - y - h / 2);
			}
		}}}
	}

	public double get_width() {
		return(0);
	}

	public double get_height() {
		return(0);
	}

	public void set_rotation(double angle) {
		this.angle = angle;
		if(node == null) {
			return;
		}
		var ndp = node;
		embed {{{
			SKNode* sknd = (__bridge SKNode*)ndp;
			sknd.zRotation = -angle;
		}}}
	}

	public void set_scale(double sx, double sy) {
		this.scale_x = sx;
		this.scale_y = sy;
		update_position();
	}

	public double get_scale_x() {
		return(scale_x);
	}

	public double get_scale_y() {
		return(scale_y);
	}

	public void set_alpha(double alpha) {
		this.alpha = alpha;
		if(node == null) {
			return;
		}
		var ndp = node;
		embed {{{
			SKNode* sknd = (__bridge SKNode*)ndp;
			sknd.alpha = alpha;
		}}}
	}

	public double get_x() {
		return(x);
	}

	public double get_y() {
		return(y);
	}

	public double get_rotation() {
		return(angle);
	}

	public double get_alpha() {
		return(alpha);
	}

	public void remove_from_container() {
		remove_node();
	}
}
