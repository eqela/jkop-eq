
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

class D2DSpriteRenderer : Direct2DCustomRenderer
{
	embed {{{
		#include <d2d1.h>
		#define MATRIX(x,y) ((jkop_sprite_backend_direct2d_D2DMatrix3x2F*)x)->y
	}}}

	property SEScene scene;
	property ptr d2dtarget;
	property bool stop = false;
	property SEDirect2DBackend backend;

	public void do_render_sprite(D2DSprite e, ptr t, double layer_alpha) {
		var mat = e.get_matrix();
		var tex = e.get_texture();
		var alpha = e.get_alpha() * layer_alpha;
		if(tex == null) {
			return;
		};
		ptr bitmap = tex.get_bitmap();
		var w = tex.get_width(), h = tex.get_height();
		embed {{{
			if(mat) {
				D2D1::Matrix3x2F m = D2D1::Matrix3x2F(
					MATRIX(mat, m11), MATRIX(mat, m12),
					MATRIX(mat, m21), MATRIX(mat, m22),
					MATRIX(mat, m31), MATRIX(mat, m32)
				); 
				((ID2D1RenderTarget*)t)->SetTransform(m);
			}
			((ID2D1RenderTarget*)t)->DrawBitmap(
				(ID2D1Bitmap*)bitmap,
				D2D1::RectF(0, 0, w, h),
				(float)alpha
			);
		}}}
	}

	void do_render_list(D2DElementList list, ptr target, double layer_alpha = 1.0) {
		bool clipped = false;
		if(list is D2DLayer) {
			var layer = (D2DLayer)list;
			clipped = layer.get_clipped();
			if(clipped) {
				double x = layer.get_x(), y = layer.get_y();
				double width = layer.get_width(), height = layer.get_height();
				embed {{{
					((ID2D1RenderTarget*)target)->SetTransform(D2D1::Matrix3x2F::Identity());
					((ID2D1RenderTarget*)target)->PushAxisAlignedClip(
						D2D1::RectF(x, y, x+width, y+height),
						D2D1_ANTIALIAS_MODE_PER_PRIMITIVE
					);
				}}}
			}
		}
		foreach(Object e in list) {
			if(e is D2DElementList) {
				double alpha = layer_alpha;
				if(e is D2DElement) {
					alpha *= ((D2DElement)e).get_alpha();
				}
				do_render_list((D2DElementList)e, target, alpha);
			}
			else if(e is D2DSprite) {
				do_render_sprite((D2DSprite)e, target, layer_alpha);
			}
		}
		if(clipped) {
			embed {{{
				((ID2D1RenderTarget*)target)->PopAxisAlignedClip();
			}}}
		}
	}

	public void render() {
		var t = d2dtarget;
		var scene = get_scene();
		if(t != null && scene != null) {
			if(stop == false) {
				scene.tick();
			}
			embed {{{
				((ID2D1RenderTarget*)t)->Clear(D2D1::ColorF(D2D1::ColorF(0, 0.0f)));
			}}}
			var list = backend as D2DElementList;
			if(list != null) {
				do_render_list(list, t);
			}
		}
	}
}
