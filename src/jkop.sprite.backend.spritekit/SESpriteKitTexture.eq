
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

public class SESpriteKitTexture
{
	embed {{{
		#import <SpriteKit/SpriteKit.h>
	}}}

	public static SESpriteKitTexture for_image(Image img) {
		return(new SESpriteKitTexture().set_image(img));
	}

	property ptr sktexture;

	public ~SESpriteKitTexture() {
		clear();
	}

	public void clear() {
		var skt = sktexture;
		if(skt == null) {
			return;
		}
		embed {{{
			(__bridge_transfer SKTexture*)skt;
		}}}
		sktexture = null;
	}

	public SESpriteKitTexture set_image(Image img) {
		if(sktexture != null) {
			clear();
		}
		var qi = img as QuartzBitmapImage;
		if(qi == null) {
			return(null);
		}
		IFDEF("target_osx") {
			var nsimg = qi.as_nsimage();
			if(nsimg == null) {
				return(null);
			}
			ptr skt;
			ptr ndp;
			embed {{{
				NSImage* nsimgx = (__bridge_transfer NSImage*)nsimg;
				SKTexture* texture = [SKTexture textureWithImage:nsimgx];
				skt = (__bridge_retained void*)texture;
			}}}
			sktexture = skt;
		}
		IFDEF("target_ios") {
			var uiimg = qi.as_uiimage();
			if(uiimg == null) {
				return(null);
			}
			ptr skt;
			ptr ndp;
			embed {{{
				UIImage* uiimgx = (__bridge_transfer UIImage*)uiimg;
				SKTexture* texture = [SKTexture textureWithImage:uiimgx];
				skt = (__bridge_retained void*)texture;
			}}}
			sktexture = skt;
		}
		return(this);
	}
}
