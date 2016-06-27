
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

class ImageResizer
{
	static int _li(double src1, double src2, double a) {
		return((a*src2) + (1-a)*src1);
	}

	static double bilinear_interpolation(int q11, int q21, int q12, int q22, double tx, double ty) {
		return(_li(
			_li(q11, q21, tx),
			_li(q12, q22, tx),
			ty)
		);
	}

	public static BitmapBuffer resize_bilinear(BitmapBuffer bmpbuf, int anw, int anh) {
		if(anw == 0 || anh == 0) {
			return(null);
		}
		if(anw < 0 && anh < 0) {
			return(bmpbuf);
		}
		Buffer src = bmpbuf.get_buffer();
		if(src == null) {
			return(null);
		}
		int sz = src.get_size();
		int ow = bmpbuf.get_width();
		int oh = bmpbuf.get_height();
		if(ow == anw && oh == anh) {
			return(bmpbuf);
		}
		if(sz != ow*oh*4) {
			Log.error("Image buffer has invalid dimensions.");
			return(null);
		}
		int nw = anw, nh = anh;
		double scaler = 1.0;
		if(nw < 0) {
			scaler = (double)nh/(double)oh;
		}
		else if(nh < 0) {
			scaler = (double)nw/(double)ow;
		}
		if(scaler != 1.0) {
			nw = (int)ow * scaler;
			nh = (int)oh * scaler;
		}
		var dest = DynamicBuffer.create(nw*nh*4);
		if(dest == null) {
			return(null);
		}
		var desp = dest.get_pointer();
		var srcp = src.get_pointer();
		int dx, dy;
		double stepx = (ow-1.0) / (nw-1.0);
		double stepy = (oh-1.0) / (nh-1.0);
		for(dy = 0; dy < nh; dy++) {
			for(dx = 0; dx < nw; dx++) {
				double ptx = dx * stepx;
				double pty = dy * stepy;
				int ix = (int)ptx;
				int iy = (int)pty;
				int q11i = (iy*ow+ix)*4, q21i = (iy*ow+(ix+1))*4, q12i = ((iy+1)*ow+ix)*4, q22i = ((iy+1)*ow+(ix+1))*4;
				int rq11 = ImageFilterUtil.get_safe_byte(srcp, sz, q11i+0);
				int gq11 = ImageFilterUtil.get_safe_byte(srcp, sz, q11i+1);
				int bq11 = ImageFilterUtil.get_safe_byte(srcp, sz, q11i+2);
				int aq11 = ImageFilterUtil.get_safe_byte(srcp, sz, q11i+3);
				int rq21 = ImageFilterUtil.get_safe_byte(srcp, sz, q21i+0);
				int gq21 = ImageFilterUtil.get_safe_byte(srcp, sz, q21i+1);
				int bq21 = ImageFilterUtil.get_safe_byte(srcp, sz, q21i+2);
				int aq21 = ImageFilterUtil.get_safe_byte(srcp, sz, q21i+3);
				int rq12 = ImageFilterUtil.get_safe_byte(srcp, sz, q12i+0);
				int gq12 = ImageFilterUtil.get_safe_byte(srcp, sz, q12i+1);
				int bq12 = ImageFilterUtil.get_safe_byte(srcp, sz, q12i+2);
				int aq12 = ImageFilterUtil.get_safe_byte(srcp, sz, q12i+3);
				int rq22 = ImageFilterUtil.get_safe_byte(srcp, sz, q22i+0);
				int gq22 = ImageFilterUtil.get_safe_byte(srcp, sz, q22i+1);
				int bq22 = ImageFilterUtil.get_safe_byte(srcp, sz, q22i+2);
				int aq22 = ImageFilterUtil.get_safe_byte(srcp, sz, q22i+3);
				int resr = (int)bilinear_interpolation(rq11, rq21, rq12, rq22, ptx-ix, pty-iy);
				int resg = (int)bilinear_interpolation(gq11, gq21, gq12, gq22, ptx-ix, pty-iy);
				int resb = (int)bilinear_interpolation(bq11, bq21, bq12, bq22, ptx-ix, pty-iy);
				int resa = (int)bilinear_interpolation(aq11, aq21, aq12, aq22, ptx-ix, pty-iy);
				desp.set_byte((dy*nw+dx)*4+0, resr);
				desp.set_byte((dy*nw+dx)*4+1, resg);
				desp.set_byte((dy*nw+dx)*4+2, resb);
				desp.set_byte((dy*nw+dx)*4+3, resa);
			}
		}
		return(BitmapBuffer.create(dest, nw, nh));
	}

	static void untransform_coords(Matrix33 m, int ix, int iy, DoubleBuffer tu, DoubleBuffer tv, DoubleBuffer tw) {
		double x = ix + 0.5;
		double y = iy + 0.5;
		tu.set_index(0, m.v1 * (x+0) + m.v4 * (y+0) + m.v7);
		tv.set_index(0, m.v2 * (x+0) + m.v5 * (y+0) + m.v8);
		tw.set_index(0, m.v3 * (x+0) + m.v6 * (y+0) + m.v9);
		tu.set_index(1, m.v1 * (x-1) + m.v4 * (y+0) + m.v7);
		tv.set_index(1, m.v2 * (x-1) + m.v5 * (y+0) + m.v8);
		tw.set_index(1, m.v3 * (x-1) + m.v6 * (y+0) + m.v9);
		tu.set_index(2, m.v1 * (x+0) + m.v4 * (y-1) + m.v7);
		tv.set_index(2, m.v2 * (x+0) + m.v5 * (y-1) + m.v8);
		tw.set_index(2, m.v3 * (x+0) + m.v6 * (y-1) + m.v9);
		tu.set_index(3, m.v1 * (x+1) + m.v4 * (y+0) + m.v7);
		tv.set_index(3, m.v2 * (x+1) + m.v5 * (y+0) + m.v8);
		tw.set_index(3, m.v3 * (x+1) + m.v6 * (y+0) + m.v9);
		tu.set_index(4, m.v1 * (x+0) + m.v4 * (y+1) + m.v7);
		tv.set_index(4, m.v2 * (x+0) + m.v5 * (y+1) + m.v8);
		tw.set_index(4, m.v3 * (x+0) + m.v6 * (y+1) + m.v9);
	}

	static void normalize_coords(int count, DoubleBuffer tu, DoubleBuffer tv, DoubleBuffer tw, DoubleBuffer su, DoubleBuffer sv) {
		int i;
		for(i = 0; i < count; i++) {
			if(tw.get_index(i) != 0.0) {
				su.set_index(i, tu.get_index(i) / tw.get_index(i) - 0.5);
				sv.set_index(i, tv.get_index(i) / tw.get_index(i) - 0.5);
			}
			else {
				su.set_index(i, tu.get_index(i));
				sv.set_index(i, tv.get_index(i));
			}
		}
	}

	static int FIXED_SHIFT = 10;
	static int FIXED_UNIT;

	static void init_fixed_unit() {
		FIXED_UNIT = 1 << FIXED_SHIFT;
	}

	static double double_2_fixed(double val) {
		init_fixed_unit();
		return(val * FIXED_UNIT);
	}

	static double fixed_2_double(double val) {
		init_fixed_unit();
		return(val / FIXED_UNIT);
	}

	static bool supersample_dtest(double x0, double y0, double x1, double y1, double x2, double y2, double x3, double y3) {
		return(Math.fabs(x0-x1) > MathConstant.M_SQRT2 ||
			Math.fabs(x1-x2) > MathConstant.M_SQRT2 ||
			Math.fabs(x2-x3) > MathConstant.M_SQRT2 ||
			Math.fabs(x3-x0) > MathConstant.M_SQRT2 ||

			Math.fabs(y0-y1) > MathConstant.M_SQRT2 ||
			Math.fabs(y1-y2) > MathConstant.M_SQRT2 ||
			Math.fabs(y2-y3) > MathConstant.M_SQRT2 ||
			Math.fabs(y3-y0) > MathConstant.M_SQRT2);
	}

	static bool supersample_test(int x0, int y0, int x1, int y1, int x2, int y2, int x3, int y3) {
		init_fixed_unit();
		return(
			Math.abs(x0-x1) > FIXED_UNIT ||
			Math.abs(x1-x2) > FIXED_UNIT ||
			Math.abs(x2-x3) > FIXED_UNIT ||
			Math.abs(x3-x0) > FIXED_UNIT ||

			Math.abs(y0-y1) > FIXED_UNIT ||
			Math.abs(y1-y2) > FIXED_UNIT ||
			Math.abs(y2-y3) > FIXED_UNIT ||
			Math.abs(y3-y0) > FIXED_UNIT);
	}

	static int lerp(int v1, int v2, int r) {
		init_fixed_unit();
		return((v1 * (FIXED_UNIT - r) + v2 * r) >> FIXED_SHIFT);
	}

	static void sample_bi(RGBAPixelIntegerBuffer pixels, int x, int y, IntegerBuffer color) {
		init_fixed_unit();
		int xscale = (x & (FIXED_UNIT-1));
		int yscale = (y & (FIXED_UNIT-1));
		int x0 = x >> FIXED_SHIFT;
		int y0 = y >> FIXED_SHIFT;
		int x1 = x0+1;
		int y1 = y0+1;
		int i;
		var C0=pixels.get_rgba_pixel(x0, y0, true);
		var C1=pixels.get_rgba_pixel(x1, y0, true);
		var C2=pixels.get_rgba_pixel(x0, y1, true);
		var C3=pixels.get_rgba_pixel(x1, y1, true);
		int res;
		color.set_index(3, res = lerp(
			lerp(C0.get_index(3), C1.get_index(3), yscale),
			lerp(C2.get_index(3), C3.get_index(3), yscale),
			xscale)
		);
		if(res != 0) {
			for(i = 0; i < 3; i++) {
				color.set_index(i, lerp(
					lerp(
						C0.get_index(i) * C0.get_index(3) / 255,
						C1.get_index(i) * C1.get_index(3) / 255, yscale),
					lerp(
						C2.get_index(i) * C2.get_index(3) / 255,
						C3.get_index(i) * C3.get_index(3) / 255, yscale),
					xscale
				));
			}
		}
		else {
			for(i = 0; i < 3; i++) {
				color.set_index(i, 0);
			}
		}
	}

	static void get_sample(RGBAPixelIntegerBuffer pixels, int xc, int yc, int x0, int y0, int x1, int y1, int x2, int y2, int x3, int y3, IntegerValue cciv, int level, IntegerBuffer color) {
		if(level == 0 || supersample_test(x0, y0, x1, y1, x2, y2, x3, y3) == false) {
			int i;
			var C = IntegerBuffer.create(4);
			sample_bi(pixels, xc, yc, C);
			for(i = 0; i < 4; i++) {
				color.set_index(i, color.get_index(i)+C.get_index(i));
			}
			cciv.set_value(cciv.get_value() + 1);
		}
		else {
			int tx, lx, rx, bx, tlx, trx, blx, brx;
			int ty, ly, ry, by, tly, try, bly, bry;
			tx  = (x0 + x1) / 2;
			tlx = (x0 + xc) / 2;
			trx = (x1 + xc) / 2;
			lx  = (x0 + x3) / 2;
			rx  = (x1 + x2) / 2;
			blx = (x2 + xc) / 2;
			brx = (x3 + xc) / 2;
			bx  = (x3 + x2) / 2;
			ty  = (y0 + y1) / 2;
			tly = (y0 + yc) / 2;
			try = (y1 + yc) / 2;
			ly  = (y0 + y3) / 2;
			ry  = (y1 + y2) / 2;
			bly = (y3 + yc) / 2;
			bry = (y2 + yc) / 2;
			by  = (y3 + y2) / 2;
			get_sample(pixels, tlx, tly,
				x0, y0, tx, ty, xc, yc, lx, ly,
				cciv, level-1, color);
			get_sample(pixels, trx, try,
				tx, ty, x1, y1, rx, ry, xc, yc,
				cciv, level-1, color);
			get_sample(pixels, brx, bry,
				xc, yc, rx, ry, x2, y2, bx, by,
				cciv, level-1, color);
			get_sample(pixels, blx, bly,
				lx, ly, xc, yc, bx, by, x3, y3,
				cciv, level-1, color);
		}
	}

	static void sample_adapt(RGBAPixelIntegerBuffer src, double xc, double yc, double x0, double y0, double x1,
		double y1, double x2, double y2, double x3, double y3, Pointer dest) {
		int cc, i;
		var C = IntegerBuffer.create(4);
		var cciv = new IntegerValue();
		get_sample(src,
			double_2_fixed(xc), double_2_fixed(yc),
			double_2_fixed(x0), double_2_fixed(y0),
			double_2_fixed(x1), double_2_fixed(y1),
			double_2_fixed(x2), double_2_fixed(y2),
			double_2_fixed(x3), double_2_fixed(y3),
			cciv, 3, C
		);
		cc = cciv.get_value();
		if(cc == 0) {
			cc = 1;
		}
		int aa = C.get_index(3)/cc;
		dest.set_byte(3, aa);
		if(aa != 0) {
			for(i = 0; i < 3; i++) {
				int tt;
				dest.set_byte(i, tt = ((C.get_index(i)/cc) * 255) / aa);
			}
		}
		else {
			for(i = 0; i < 3; i++) {
				dest.set_byte(i, 0);
			}
		}
	}

	static double drawable_transform_cubic(double x, int jm1, int j, int jp1, int jp2) {
		return(j + 0.5 * x*(jp1 - jm1 + x*(2.0*jm1 - 5.0*j + 4.0*jp1 - jp2 + x*(3.0*(j - jp1) + jp2 - jm1))));
	}

	static double cubic_row(double dx, Pointer row) {
		return(drawable_transform_cubic(
			dx, row.get_byte(0), row.get_byte(4), row.get_byte(8), row.get_byte(12)
		));
	}

	static double cubic_scaled_row(double dx, Pointer row, Pointer arow) {
		return(drawable_transform_cubic(
			dx,
			row.get_byte(0) * arow.get_byte(0),
			row.get_byte(4) * arow.get_byte(4),
			row.get_byte(8) * arow.get_byte(8),
			row.get_byte(12) * arow.get_byte(12)
		));
	}

	static void sample_cubic(PixelRegionBuffer src, double su, double sv, Pointer dest) {
		double aval, arecip;
		int i;
		int iu = Math.floor(su);
		int iv = Math.floor(sv);
		int stride = src.get_stride();
		double du, dv;
		var br = src.get_buffer_region(iu - 1, iv - 1);
		if(br == null) {
			return;
		}
		var data = br.get_pointer();
		du = su - iu;
		dv = sv - iv;
		aval = drawable_transform_cubic(dv,
			cubic_row(du, data.move(3 + stride * 0)),
			cubic_row(du, data.move(3 + stride * 1)),
			cubic_row(du, data.move(3 + stride * 2)),
			cubic_row(du, data.move(3 + stride * 3)));
		if(aval <= 0) {
			arecip = 0.0;
			dest.set_byte(3, 0);
		}
		else if(aval > 255.0) {
			arecip = 1.0/aval;
			dest.set_byte(3, 255);
		}
		else {
			arecip = 1.0/aval;
			dest.set_byte(3, Math.rint(aval));
		}
		for(i = 0; i < 3; i++) {
			int v = Math.rint((arecip *
				drawable_transform_cubic(dv,
					cubic_scaled_row(du, data.move(i + stride * 0), data.move(3 + stride * 0)),
					cubic_scaled_row(du, data.move(i + stride * 1), data.move(3 + stride * 1)),
					cubic_scaled_row(du, data.move(i + stride * 2), data.move(3 + stride * 2)),
					cubic_scaled_row(du, data.move(i + stride * 3), data.move(3 + stride * 3))))
			);
			dest.set_byte(i, ImageFilterUtil.clamp(v));
		}
	}

	public static BitmapBuffer resize_bicubic(BitmapBuffer bb, int anw, int anh) {
		if(anw == 0 || anh == 0) {
			return(null);
		}
		if(anw < 0 && anh < 0) {
			return(bb);
		}
		var sb = bb.get_buffer();
		if(sb == null) {
			return(null);
		}
		var srcp = sb.get_pointer();
		var sz = sb.get_size();
		var w = bb.get_width(), h = bb.get_height();
		double scaler = 1.0;
		int nw = anw, nh = anh;
		if(nw < 0) {
			scaler = (double)nh/(double)h;
		}
		else if(nh < 0) {
			scaler = (double)nw/(double)w;
		}
		if(scaler != 1.0) {
			nw = (int)w * scaler;
			nh = (int)h * scaler;
		}
		var v = DynamicBuffer.create(nw*nh*4);
		var vsz = v.get_size();
		var destp = v.get_pointer();
		int y;
		double sx = (double)nw/(double)w, sy = (double)nh/(double)h;
		var matrix = Matrix33.for_scale(sx, sy);
		matrix = Matrix33.invert_matrix(matrix);
		double uinc = matrix.v1, vinc = matrix.v2, winc = matrix.v3;
		var pixels = RGBAPixelIntegerBuffer.create(sb, w, h);
		var pixrgn = PixelRegionBuffer.for_rgba_pixels(pixels, 4, 4);
		var tu = DoubleBuffer.create(5);
		var tv = DoubleBuffer.create(5);
		var tw = DoubleBuffer.create(5);
		var su = DoubleBuffer.create(5);
		var sv = DoubleBuffer.create(5);
		for(y = 0; y < nh; y++) {
			untransform_coords(matrix, 0, y, tu, tv, tw);
			int width = nw;
			while(width-- > 0) {
				int i;
				normalize_coords(5, tu, tv, tw, su, sv);
				if(supersample_dtest(su.get_index(1), sv.get_index(1), su.get_index(2), sv.get_index(2),
					su.get_index(3), sv.get_index(3), su.get_index(4), sv.get_index(4))) {
					sample_adapt(pixels, su.get_index(0), sv.get_index(0), su.get_index(1), sv.get_index(1),
						su.get_index(2), sv.get_index(2), su.get_index(3), sv.get_index(3), su.get_index(4), sv.get_index(4), destp);
				}
				else {
					sample_cubic(pixrgn, su.get_index(0), sv.get_index(0), destp);
				}
				destp = destp.move(4);
				for(i = 0; i < 5; i++) {
					tu.set_index(i, tu.get_index(i)+uinc);
					tv.set_index(i, tv.get_index(i)+vinc);
					tw.set_index(i, tw.get_index(i)+winc);
				}
			}
		}
		return(BitmapBuffer.create(v, nw, nh));
	}
}