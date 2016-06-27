
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

public class Direct2DRenderableBitmap : Direct2DBitmap, Image, Size, Renderable, RenderableImage, VgRenderable, VgRenderableImage
{
	public static Direct2DRenderableBitmap create(int w, int h) {
		var v = new Direct2DRenderableBitmap();
		v.w = w;
		v.h = h;
		return(v);
	}

	public static Direct2DRenderableBitmap create_scaled_image(Image img, double w, double h) {
		var v = create(w, h);
		double ow = (double)img.get_width(), oh = (double)img.get_height();
		double sw = (double)(w/ow), sh = ((double)(h/oh));
		var vt = VgTransform.for_scale(sw, sh);
		var vg = v.get_vg_context();
		if(vg != null) {
			vg.draw_graphic(w/2-ow/2, h/2-oh/2, vt, img);
		}
		return(v);
	}

	embed "c++" {{{
		#include <d2d1.h>
		#include <dxgiformat.h>
	}}}

	ptr d2dbitmap;
	int w;
	int h;
	VgContextDrawOperations vgcontext;

	~Direct2DRenderableBitmap() {
		release();
	}

	public void release() {
		var d2dbitmap = this.d2dbitmap;
		embed "c++" {{{
			if(d2dbitmap!=NULL) {
				((ID2D1Bitmap*)d2dbitmap)->Release();
			}
		}}}
		this.d2dbitmap = null;
	}

	public Image resize(int w, int h) {
		if(w < 0 && h < 0) {
			return(this);
		}
		int tw = w, th = h;
		if(tw < 0 && th >= 0) {
			tw = (int)((double)get_width() / ((double)get_height() / (double)th));
		}
		if(th < 0 && tw >= 0) {
			th = (int)((double)get_height() / ((double)get_width() / (double)tw));
		}
		if(get_width() == tw && get_height() == th) {
			return(this);
		}
		Image v;
		if(tw > 0 && th > 0) {
			v = Direct2DRenderableBitmap.create_scaled_image(this, tw, th);
		}
		return(v);
	}

	public double get_width() {
		return(w);
	}

	public double get_height() {
		return(h);
	}

	ptr _creator;

	private bool target_has_changed(ptr target) {
		if(target != _creator) {
			_creator = target;
			return(true);
		}
		return(false);
	}

	public ptr get_d2dbitmap(ptr target_param) {
		ptr v = this.d2dbitmap;
		if(v == null && target_param != null) {
			ptr target;
			bool success;
			int w = this.w, h = this.h;
			embed "c++" {{{
				D2D1_SIZE_F szf;
				szf.width = w;
				szf.height = h;
				D2D1_SIZE_U szu;
				szu.width = w;
				szu.height = h;
				D2D1_PIXEL_FORMAT pxf = D2D1::PixelFormat(DXGI_FORMAT_B8G8R8A8_UNORM, (D2D1_ALPHA_MODE)1);
				HRESULT r = ((ID2D1RenderTarget*)target_param)->CreateCompatibleRenderTarget(szf, szu, pxf, 
					D2D1_COMPATIBLE_RENDER_TARGET_OPTIONS_NONE, (ID2D1BitmapRenderTarget**)&target);
					success = SUCCEEDED(r);
			}}}
			if(success && target != null && vgcontext != null) {
				embed "c++" {{{
					((ID2D1RenderTarget*)target)->BeginDraw();
					((ID2D1RenderTarget*)target)->Clear(D2D1::ColorF(D2D1::ColorF(0, 0.0f)));
					((ID2D1RenderTarget*)target)->SetTransform(D2D1::Matrix3x2F::Identity());
				}}}
				var ops = vgcontext.get_operations();
				var vg = Direct2DVgContext.create(target, Direct2DFactory.instance());
				VgRenderer.render_to_vg_context(ops, vg);
				vg.clip_clear();
				int err;
				embed "c++" {{{
					r = ((ID2D1RenderTarget*)target)->EndDraw();
					if(SUCCEEDED(r)) {
						r = ((ID2D1BitmapRenderTarget*)target)->GetBitmap((ID2D1Bitmap**)&v);
					}
					success = SUCCEEDED(r);
					err = r;
				}}}
				if(success == false) {
					Log.debug("RenderableBitmap: unexpected error : %x".printf().add(err));
				}
			}
			if(target != null) {
				embed "c++" {{{
					((ID2D1RenderTarget*)target)->Release();
				}}}
			}
			this.d2dbitmap = v;
		}
		return(v);
	}

	public Buffer encode(String type) {
		return(null); // FIXME
	}

	public Image crop(int x, int y, int w, int h) {
		return(GuiEngine.crop(this, x, y, w, h));
	}

	public VgContext get_vg_context() {
		if(vgcontext != null) {
			release();
			vgcontext = null;
		}
		vgcontext = new VgContextDrawOperations();
		return(vgcontext);
	}

	public void render(Collection ops) {
		var ctx = get_vg_context();
		if(ctx == null) {
			return;
		}
		VgRenderer.render_to_vg_context(ops, ctx);
	}
}
