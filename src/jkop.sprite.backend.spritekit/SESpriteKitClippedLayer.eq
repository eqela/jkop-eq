
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

public class SESpriteKitClippedLayer : SESpriteKitLayer
{
	embed {{{
		#import <SpriteKit/SpriteKit.h>
	}}}

	public void create_layer_node(double width, double height) {
		ptr ndp;
		var parent = get_parent();
		embed {{{
			SKNode* pnode = (__bridge SKNode*)parent;
			SKCropNode* nd = [[SKCropNode alloc] init];
			SKSpriteNode* mask = [SKSpriteNode spriteNodeWithColor:[SKColor blackColor] size:CGSizeMake(width, height)];
			// The anchor point is x=0, y=1 and this works on both iOS and OSX, but I really don't know why! Apple engineers are crazy.
			mask.anchorPoint = CGPointMake(0,1);
			nd.maskNode = mask;
			ndp = (__bridge_retained void*)nd;
			[pnode addChild:nd];
		}}}
		set_node(ndp);
	}
}
