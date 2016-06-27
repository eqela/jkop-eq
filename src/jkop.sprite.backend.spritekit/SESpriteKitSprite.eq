
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

public class SESpriteKitSprite : SESpriteKitElement, SESprite
{
	embed {{{
		#import <SpriteKit/SpriteKit.h>
	}}}

	String last_font;
	double width;
	double height;

	void update_size() {
		double ww, hh;
		var ndp = get_node();
		embed {{{
			SKSpriteNode* nd = (__bridge SKSpriteNode*)ndp;
			ww = nd.size.width;
			hh = nd.size.height;
		}}}
		width = ww;
		height = hh;
	}

	public void set_image(SEImage image) {
		// remove_node();
		SESpriteKitTexture txt;
		var rsc = get_rsc();
		if(image != null) {
			txt = image.get_texture() as SESpriteKitTexture;
			if(txt == null && rsc != null) {
				var img = image.get_image();
				if(img != null) {
					txt = rsc.image_to_texture(img) as SESpriteKitTexture;
				}
				if(txt == null) {
					txt = rsc.get_texture(image.get_resource()) as SESpriteKitTexture;
				}
			}
		}
		if(txt == null) {
			Log.error("Failed to get texture when setting the image of a sprite");
			return;
		}
		var sktxt = txt.get_sktexture();
		ptr ndp = get_node();
		if(ndp != null) {
			embed {{{
				SKSpriteNode* nd = (__bridge SKSpriteNode*)ndp;
				[nd setScale:1.0];
				nd.anchorPoint = CGPointMake(0.5,0.5);
				nd.texture = (__bridge SKTexture*)sktxt;
				nd.size = [(__bridge SKTexture*)sktxt size];
			}}}
		}
		else {
			var parent = get_parent();
			embed {{{
				SKNode* pnode = (__bridge SKNode*)parent;
				SKTexture* texture = (__bridge SKTexture*)sktxt;
				SKSpriteNode* nd = [SKSpriteNode spriteNodeWithTexture:texture];
				nd.anchorPoint = CGPointMake(0.5,0.5);
				ndp = (__bridge_retained void*)nd;
				[pnode addChild:nd];
			}}}
			set_node(ndp);
		}
		update_size();
		update_position();
	}

	public void set_text(String text, String fontid = null) {
		Image img;
		var rsc = get_rsc();
		if(rsc != null) {
			var fid = fontid;
			if(fid == null) {
				fid = last_font;
			}
			img = rsc.create_image_for_text(text, fid);;
		}
		set_image(SEImage.for_image(img));
		if(fontid != null) {
			last_font = fontid;
		}
	}

	public void set_color(Color color, double width, double height) {
		remove_node();
		if(color == null || width < 1 || height < 1) {
			return;
		}
		var r = color.get_r(), g = color.get_g(), b = color.get_b(), a = color.get_a();
		ptr ndp;
		var parent = get_parent();
		embed {{{
			SKNode* pnode = (__bridge SKNode*)parent;
			SKColor* cc = [SKColor colorWithRed:r green:g blue:b alpha:a];
			SKSpriteNode* nd = [SKSpriteNode spriteNodeWithColor:cc size:CGSizeMake(width, height)];
			nd.anchorPoint = CGPointMake(0.5,0.5);
			ndp = (__bridge_retained void*)nd;
			[pnode addChild:nd];
		}}}
		set_node(ndp);
		update_size();
		update_position();
	}

	public double get_width() {
		return(width);
	}

	public double get_height() {
		return(height);
	}
}
