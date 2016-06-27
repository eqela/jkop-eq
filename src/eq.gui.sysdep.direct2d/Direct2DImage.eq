
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

public class Direct2DImage : Direct2DBitmap, Image, Size
{
	embed "c++" {{{
		#include <objbase.h>
		#include <wincodec.h>
		#include <d2d1.h>
	}}}

	ptr d2dbitmap;
	ptr bitmapsource;
	int width;
	int height;
	int status = 0;

	~Direct2DImage() {
		release();
	}

	public void release() {
		ptr bitmapsource = this.bitmapsource;
		destroy_safely();
		embed "c++" {{{
			if(bitmapsource != NULL) {	
				((IWICBitmapSource*)bitmapsource)->Release();
			}
		}}}
		this.bitmapsource = null;
	}

	public static Direct2DImage for_file(File file) {
		if(file == null) {
			return(null);
		}
		var v = new Direct2DImage();
		if(v.initialize_file(file.get_native_path()) == false) {
			Log.error("Failed to open image file: `%s'".printf().add(file));
			return(null);
		}
		return(v);
	}

	public static Direct2DImage for_buffer(ImageBuffer ib) {
		var data = ib.get_buffer();
		if(data == null) {
			return(null);
		}
		var pointer = data.get_pointer();
		if("image/png".equals(ib.get_type())) {
			if(pointer.get_byte(0) != 0x89 || pointer.get_byte(1) != 0x50 || pointer.get_byte(2) != 0x4e
				|| pointer.get_byte(3) != 0x47 || pointer.get_byte(4) != 0x0d || pointer.get_byte(5) != 0x0a
				|| pointer.get_byte(6) != 0x1a || pointer.get_byte(7) != 0x0a) {
				Log.error("Image not a PNG file.");
				return(null);
			}
		}
		if("image/jpg".equals(ib.get_type())) {
			if(pointer.get_byte(0) != 0xff || pointer.get_byte(1) != 0xd8) {
				Log.error("Image not a JPEG file.");
				return(null);
			}
		}
		if("image/x-rgba".equals(ib.get_type())) {
			var v = new Direct2DImage();
			if(v.initialize_rgba_buffer(data, ib.get_width(), ib.get_height()) == false) {
				Log.error("Failed to initialize rgba buffer.");
				return(null);
			}
			return(v);
		}
		var v = new Direct2DImage();
		if(v.initialize_buffer(data) == false) {
			Log.error("Failed to decode buffer of size `%d'".printf().add(data.get_size()));
			return(null);
		}
		return(v);
	}

	bool initialize_rgba_buffer(Buffer data, int w, int h) {
		ptr wmemory;
		ptr wicfactory = WICFactory.instance();
		if(wicfactory == null) {
			return(false);
		}
		bool success;
		// HACK: RGBA pixel format is not available. Manually
		// convert the input RGBA to BGRA
		ptr srcptr;
		int sz = data.get_size();
		var src = data.get_pointer();
		var bgra = DynamicBuffer.create(sz);
		if(bgra != null) {
			var dest = bgra.get_pointer();
			int i;
			for(i = 0; i < sz/4; i++) {
				var _r = src.get_byte(i*4+0);
				var _g = src.get_byte(i*4+1);
				var _b = src.get_byte(i*4+2);
				var _a = src.get_byte(i*4+3);
				dest.set_byte(i*4+0, _b);
				dest.set_byte(i*4+1, _g);
				dest.set_byte(i*4+2, _r);
				dest.set_byte(i*4+3, _a);
			}
			srcptr = bgra.get_pointer().get_native_pointer();
		}
		else {
			srcptr = src.get_native_pointer();
		}
		embed "c++" {{{
			HRESULT r = ((IWICImagingFactory*)wicfactory)->CreateBitmapFromMemory(
				w, h, GUID_WICPixelFormat32bppPBGRA, w*4, sz, (BYTE*)srcptr, (IWICBitmap**)&wmemory
			);
			success = SUCCEEDED(r);
		}}}
		if(success) {
			bitmapsource = wmemory;
			width = w;
			height = h;
		}
		return(success);
	}

	public bool initialize_buffer(Buffer data) {
		var ptr = data.get_pointer().get_native_pointer();
		int sz = data.get_size();
		ptr wdecoder;
		ptr wicfactory = WICFactory.instance();
		if(wicfactory == null) {
			return(false);
		}
		bool success;
		embed "c++" {{{
			IStream* istream = NULL;
			HRESULT hr = CreateStreamOnHGlobal(NULL, TRUE, &istream);
			if(SUCCEEDED(hr)) {
				int bs;
				hr = istream->Write(ptr, sz, &bs);
			}
			else {
			}}} Log.error("Direct2DImage: Failed to create memory stream."); embed "c++" {{{
			}
			if(SUCCEEDED(hr)) {
				LARGE_INTEGER li;
				li.QuadPart = 0;
				istream->Seek(li,0,NULL);
				HRESULT r = ((IWICImagingFactory*)wicfactory)->CreateDecoderFromStream(
					istream,
					NULL,
					WICDecodeMetadataCacheOnLoad,
					(IWICBitmapDecoder**)&wdecoder
				);
				istream->Release();
				success = SUCCEEDED(r);
			}
			else {
			}}} Log.error("Direct2DImage: Failed to write on memory stream."); embed "c++" {{{
			}
		}}}
		if(success) {
			success = initialize_bitmap(wdecoder);
		}
		embed "c++" {{{
			if(wdecoder!=NULL) {
				((IWICBitmapDecoder*)wdecoder)->Release();
			}
		}}}
		return(success);
	}

	private bool initialize_file(String url) {
		var w = WideString.for_string(url);
		if(w == null) {
			return(false);
		}
		var uri = w.get_buffer();
		ptr wicfactory = WICFactory.instance();
		if(wicfactory == null) {
			Log.error("No WICFactory was created");
			return(false);
		}
		ptr wdecoder;
		bool success;
		embed "c++" {{{
			HRESULT r = ((IWICImagingFactory*)wicfactory)->CreateDecoderFromFilename(
				(const WCHAR*)uri,
				NULL,
				GENERIC_READ,
				WICDecodeMetadataCacheOnLoad,
				(IWICBitmapDecoder**)&wdecoder
			);
			success = SUCCEEDED(r);
		}}}
		if(success) {
			success =  initialize_bitmap(wdecoder);
		}
		embed "c++" {{{
			if(wdecoder!= NULL) {
				((IWICBitmapDecoder*)wdecoder)->Release();
			}
		}}}
		return(success);
	}

	public Buffer encode(String type) {
		if(type == null) {
			return(null);
		}
		ptr encoder;
		ptr wicfactory = WICFactory.instance();
		if(type.equals("image/jpeg")) {
			embed "c++" {{{
				HRESULT r = ((IWICImagingFactory*)wicfactory)->CreateEncoder(GUID_ContainerFormatJpeg, NULL, (IWICBitmapEncoder**)&encoder);
				if(FAILED(r)) {
					encoder = NULL;
				}
			}}}
		}
		else if(type.equals("image/png")) {
			embed "c++" {{{
				HRESULT r = ((IWICImagingFactory*)wicfactory)->CreateEncoder(GUID_ContainerFormatPng, NULL, (IWICBitmapEncoder**)&encoder);
				if(FAILED(r)) {
					encoder = NULL;
				}
			}}}
		}
		else if(type.equals("image/x-rgba")) {
			ptr src = get_bitmapsource();
			int w = get_width();
			var size = w * get_height() * 4;
			if(src != null) {
				var buf = DynamicBuffer.create(size);
				if(buf == null) {
					Log.error("Failed to encode: %s: Unable to allocate".printf().add(type));
					return(null);
				}
				ptr bptr = buf.get_pointer().get_native_pointer();
				bool failed;
				int err;
				embed {{{
					err = (int)((IWICBitmapSource*)src)->CopyPixels(NULL, w*4, size, bptr);
					failed = FAILED(err);
					// HACK: Bitmap's pixel format is BGRA. Convert to RGBA manually.
					if(!failed) {
						BYTE* src = (BYTE*)bptr;
						BYTE* dest = (BYTE*)bptr;
						int i = 0;
						while(i < size/4) {
							BYTE b = *src; src++;
							BYTE g = *src; src++;
							BYTE r = *src; src++;
							BYTE a = *src; src++;
							*dest = r; dest++;
							*dest = g; dest++;
							*dest = b; dest++;
							*dest = a; dest++;
							i++; 
						}
					}
				}}}
				if(failed) {
					buf = null;
					Log.error("Failed to copy pixels: %x".printf().add(err));
				}
				return(buf);
			}
		}
		if(encoder == null) {
			Log.error("Encoder for image type not supported: '%s'".printf().add(type));
			return(null);
		}
		embed "c++" {{{
			IStream* istream = NULL;
			HRESULT hr = CreateStreamOnHGlobal(NULL, TRUE, &istream);
			if(FAILED(hr)) {
				}}} Log.error("Failed to create stream to contain the encoded bits."); embed {{{
			}
		}}}
		int sz;
		ptr source = get_bitmapsource();
		embed "c++" {{{
			IWICBitmapFrameEncode* frame = NULL; 
			if(SUCCEEDED(hr)) {
				hr = ((IWICBitmapEncoder*)encoder)->Initialize(istream, WICBitmapEncoderNoCache);
			}
			if(SUCCEEDED(hr)) {
				IPropertyBag2* props = NULL;
				hr = ((IWICBitmapEncoder*)encoder)->CreateNewFrame(&frame, &props);
				if(SUCCEEDED(hr)) {
					hr = frame->Initialize(props);
				}
				if(SUCCEEDED(hr)) {
					hr = frame->WriteSource((IWICBitmapSource*)source, NULL);
				}
				if(SUCCEEDED(hr)) {
					hr = frame->Commit();
				}
			}
			if(SUCCEEDED(hr)) {
				((IWICBitmapEncoder*)encoder)->Commit();
				STATSTG stat;
				istream->Stat(&stat, STATFLAG_NONAME);
				sz = (int)stat.cbSize.QuadPart;
			}
			if(frame != NULL) {
				frame->Release();
			}	
			if(encoder != NULL) {
				((IWICBitmapEncoder*)encoder)->Release();
			}
			if(istream!=NULL) {
				LARGE_INTEGER lint = {0};
				istream->Seek(lint, STREAM_SEEK_SET, NULL);
			}
		}}}
		Buffer v;
		if(sz > 0) {
			v = DynamicBuffer.create(sz);
			if(v != null) {
				var ptr = v.get_pointer().get_native_pointer();
				embed {{{
					istream->Read(ptr, sz, NULL);
				}}}
			}
		}
		embed "c++" {{{
			if(istream != NULL) {
				istream->Release();
			}
		}}}
		return(v);
	}

	public Image crop(int x, int y, int w, int h) {
		return(GuiEngine.crop(this, x, y, w, h));
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
		var v = new Direct2DImage();
		if(tw > 1 && th > 1) {
			if(v.do_resize(this, tw, th) == false) {
				v = null;
			}
		}
		return(v);
	}

	public bool do_resize(Direct2DImage oldi, int w, int h) {
		var source = oldi.get_bitmapsource();
		ptr scaler;
		ptr wicfactory = WICFactory.instance();
		bool v;
		embed "c++" {{{
			HRESULT r = ((IWICImagingFactory*)wicfactory)->CreateBitmapScaler((IWICBitmapScaler**)&scaler);
			if(SUCCEEDED(r)) {
				r = ((IWICBitmapScaler*)scaler)->Initialize((IWICBitmapSource*)source, w, h, WICBitmapInterpolationModeFant);
			}
			v = SUCCEEDED(r);
		}}}
		if(v) {
			this.bitmapsource = scaler;
			width = w;
			height = h;
		}
		return(v);
	}

	private bool initialize_bitmap(ptr decoder) {
		bool v;
		int width, height;
		ptr converter;
		ptr wicfactory = WICFactory.instance();
		embed "c++" {{{
			IWICBitmapFrameDecode* source;
			((IWICBitmapDecoder*)decoder)->GetFrame(0, &source);
			((IWICImagingFactory*)wicfactory)->CreateFormatConverter((IWICFormatConverter**)&converter);
			HRESULT r = ((IWICFormatConverter*)converter)->Initialize(source,
				GUID_WICPixelFormat32bppPBGRA,
				WICBitmapDitherTypeNone,
				NULL,
				0.0f,
				WICBitmapPaletteTypeMedianCut
			);
			if(SUCCEEDED(r)) {
				r = ((IWICFormatConverter*)converter)->GetSize((UINT*)&width, (UINT*)&height);
			}
			v = SUCCEEDED(r);
			source->Release();
		}}}
		if(v) {
			this.bitmapsource = converter;
			this.width = width;
			this.height = height;
		}
		return(v);
	}

	private void destroy_safely() {
		var d2dbitmap = this.d2dbitmap;
		embed "c++" {{{
			if(d2dbitmap!=NULL) {
				((ID2D1Bitmap*)d2dbitmap)->Release();
			}
		}}}
		this.d2dbitmap = null;
	}

	public ptr get_d2dbitmap(ptr target_param) {
		destroy_safely();
		ptr v = d2dbitmap;
		if(v == null && target_param != null && this.bitmapsource != null) {
			ptr bitmapsource = this.bitmapsource;
			embed "c++" {{{
				HRESULT hr = ((ID2D1RenderTarget*)target_param)->CreateBitmapFromWicBitmap((IWICBitmapSource*)bitmapsource, NULL, (ID2D1Bitmap**)&v);
				if(FAILED(hr)) {
					v = NULL;
				}
			}}}
			this.d2dbitmap = v;
		}
		return(v);
	}

	public ptr get_bitmapsource() {
		return(bitmapsource);
	}

	public double get_width() {
		return(width);
	}

	public double get_height() {
		return(height);
	}
}
