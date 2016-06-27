
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

public class HTML5CanvasVgContext : VgContext
{
	public static HTML5CanvasVgContext for_canvas_element(ptr canvas, double rat = 1.0) {
		var v = new HTML5CanvasVgContext();
		v.set_canvas(canvas);
		ptr ctx;
		embed {{{
			ctx = canvas.getContext('2d');
		}}}
		if(ctx == null) {
			return(null);
		}
		embed {{{
			ctx.scale(rat, rat);
		}}}
		v.ctx = ctx;
		return(v);
	}

	bool saved = false;
	Rectangle current_clip;
	property ptr ctx;
	property ptr canvas;

	private bool apply_path(int x, int y, VgPath vp, VgTransform vt) {
		bool v = true;
		var ctx = this.ctx;
		if(vt != null) {
			int tx = x+vp.get_x()+(vp.get_w()/2);
			int ty = y+vp.get_y()+(vp.get_h()/2);
			if(vp is VgPathCustom) {
				tx = x+(vp as VgPathCustom).get_start_x()+(vp.get_w()/2);
				ty = y+(vp as VgPathCustom).get_start_y()+(vp.get_h()/2);
			}
			embed "js" {{{
				ctx.save();
				ctx.translate(tx, ty);
				ctx.rotate(vt.get_rotate_angle());
				ctx.scale(vt.get_scale_x(), vt.get_scale_y());
				ctx.translate(-tx, -ty);
			}}}
		}
		if(vp is VgPathRectangle) {
			embed "js" {{{
				ctx.beginPath();
				ctx.rect(x+vp.get_x(), y+vp.get_y(), vp.get_w(), vp.get_h());
			}}}
		}
		else if(vp is VgPathRoundedRectangle) {
			int x1 = x+vp.get_x(), y1 = y+vp.get_y(), w = vp.get_w(), h = vp.get_h(), r = (vp as VgPathRoundedRectangle).get_radius();
			embed "js" {{{
				ctx.beginPath();
				ctx.moveTo(x1 + r, y1);
				ctx.lineTo(x1 + w - r, y1);
				ctx.quadraticCurveTo(x1 + w, y1, x1 + w, y1+r);
				ctx.lineTo(x1+w, y1+h-r);
				ctx.quadraticCurveTo(x1 + w, y1 + h, x1 + w - r, y1 + h);
				ctx.lineTo(x1+r, y1+h);
				ctx.quadraticCurveTo(x1, y1+h, x1, y1+h-r);
				ctx.lineTo(x1, y1+r);
				ctx.quadraticCurveTo(x1, y1, x1+r, y1);
			}}}
		}
		else if(vp is VgPathCircle) {
			int xc = x+((VgPathCircle)vp).get_xc(), yc = y+((VgPathCircle)vp).get_yc(), radius = ((VgPathCircle)vp).get_radius();
			embed "js" {{{
				ctx.beginPath();
				ctx.arc(xc, yc, radius, 0, 2 * Math.PI, false);	
			}}}
		}
		else if(vp is VgPathCustom) {
			play_custom_path(x, y, (VgPathCustom)vp);
		}
		else {
			Log.warning("ERROR: VgPath(Other)"); // FIXME
			v = false;
		}
		return(v);
	}

	private void play_custom_path(int x, int y, VgPathCustom path) {
		var ctx = this.ctx;
		embed "js" {{{
			ctx.beginPath();
			ctx.moveTo(x+path.get_start_x(), y+path.get_start_y());
		}}}
		var it = path.iterate();
		while(it != null) {
			var e = it.next() as VgPathElement;
			if(e == null) {
				break;
			}
			int op = e.get_operation();
			switch(op) {
				case VgPathElement.OP_LINE: {
					embed "js" {{{
						ctx.lineTo(x+e.get_x1(), y+e.get_y1());
					}}}
				}
				case VgPathElement.OP_CURVE: {
					embed "js" {{{
						ctx.bezierCurveTo(x+e.get_x1(), y+e.get_y1(), x+e.get_x2(), y+e.get_y2(), x+e.get_x3(), y+e.get_y3());
					}}}
				}
				case VgPathElement.OP_ARC: {
					embed "js" {{{
						ctx.arc(x+e.get_x1(), y+e.get_y1(), e.get_radius(), e.get_angle1(), e.get_angle2(), false);
					}}}
				}
			}
		}
	}

	private String to_js_rgba_string(Color c) {
		if(c == null) {
			return("");
		}
		var v = "rgba(%d,%d,%d,%f)".printf()
			.add(Primitive.for_integer((int)(c.get_r() * 255)))
			.add(Primitive.for_integer((int)(c.get_g() * 255)))
			.add(Primitive.for_integer((int)(c.get_b() * 255)))
			.add(Primitive.for_double(c.get_a()))
			.to_string();
		return(v);
	}

	private void apply_alpha(VgTransform vt) {
		double a = 1.0;
		if(vt != null) {
			a = vt.get_alpha();
		}
		var ctx = this.ctx;
		embed "js" {{{
			ctx.globalAlpha = a;
		}}}
	}

	public bool stroke(int x, int y, VgPath vp, VgTransform vt, Color c, int linewidth, int style) {
		if(apply_path(x, y, vp, vt) == false) {
			return(false);
		}
		if(style != 0) {
			Log.warning("Stroke style not implemented."); // FIXME
		}
		apply_alpha(vt);
		var ctx = this.ctx;
		embed "js" {{{
			ctx.strokeStyle = this.to_js_rgba_string(c).to_strptr();
			ctx.lineWidth = linewidth;
			ctx.stroke();
			if(vt != null) {
				ctx.restore();
			}
		}}}
		return(true);
	}

	public bool clear(int x, int y, VgPath vp, VgTransform vt) {
		if(vp == null || vp is VgPathRectangle == false) {
			return(false);
		}
		var ctx = this.ctx;
		embed "js" {{{
			ctx.clearRect(vp.get_x(), vp.get_y(), vp.get_w(), vp.get_h());
		}}}
		return(true);
	}

	public bool fill_color(int x, int y, VgPath vp, VgTransform vt, Color c) {
		if(apply_path(x, y, vp, vt) == false) {
			return(false);
		}
		apply_alpha(vt);
		var ctx = this.ctx;
		embed "js" {{{
			ctx.fillStyle = this.to_js_rgba_string(c).to_strptr();
			ctx.fill();
			if(vt != null) {
				ctx.restore();
			}
		}}}
		return(true);
	}

	public bool fill_vertical_gradient(int x, int y, VgPath vp, VgTransform vt, Color a, Color b) {
		if(apply_path(x, y, vp, vt) == false) {
			return(false);
		}
		apply_alpha(vt);
		var ctx = this.ctx;
		embed "js" {{{
			var g = ctx.createLinearGradient(
				x+vp.get_x(),
				y+vp.get_y(),
				x+vp.get_x(),
				y+vp.get_y()+vp.get_h());
			g.addColorStop(0, this.to_js_rgba_string(a).to_strptr());
			g.addColorStop(1, this.to_js_rgba_string(b).to_strptr());
			ctx.fillStyle = g;
			ctx.fill();
			if(vt != null) {
				ctx.restore();
			}
		}}}
		return(true);
	}

	public bool fill_horizontal_gradient(int x, int y, VgPath vp, VgTransform vt, Color a, Color b) {
		if(apply_path(x, y, vp, vt) == false) {
			return(false);
		}
		apply_alpha(vt);
		var ctx = this.ctx;
		embed "js" {{{
			var g = ctx.createLinearGradient(
				x+vp.get_x(),
				y+vp.get_y(),
				x+vp.get_x()+vp.get_w(),
				y+vp.get_y());
			g.addColorStop(0, this.to_js_rgba_string(a).to_strptr());
			g.addColorStop(1, this.to_js_rgba_string(b).to_strptr());
			ctx.fillStyle = g;
			ctx.fill();
			if(vt != null) {
				ctx.restore();
			}
		}}}
		return(true);
	}

	public bool fill_radial_gradient(int x, int y, VgPath vp, VgTransform vt, int radius, Color a, Color b) {
		if(apply_path(x, y, vp, vt) == false) {
			return(false);
		}
		apply_alpha(vt);
		var ctx = this.ctx;
		embed "js" {{{
		 	var g = ctx.createRadialGradient(
				x+vp.get_x()+(vp.get_w()/2),
				y+vp.get_y()+(vp.get_h()/2),
				0,
				x+vp.get_x()+(vp.get_w()/2),
				y+vp.get_y()+(vp.get_h()/2),
				radius);
			g.addColorStop(0, this.to_js_rgba_string(a).to_strptr());
			g.addColorStop(1, this.to_js_rgba_string(b).to_strptr());
			ctx.fillStyle = g;
			ctx.fill();
			if(vt != null) {
				ctx.restore();
			}
		}}}
		return(true);
	}

	public bool fill_diagonal_gradient(int x, int y, VgPath vp, VgTransform vt, Color a, Color b, int direction) {
		if(apply_path(x, y, vp, vt) == false) {
			return(false);
		}
		apply_alpha(vt);
		int x1, y1, x2, y2;
		if(direction == 1) {
			x1 = x+vp.get_x()+vp.get_w();
			y1 = y+vp.get_y()+vp.get_h();
			x2 = x+vp.get_x();
			y2 = y+vp.get_y();
		}
		else {
			x1 = x+vp.get_x()+vp.get_w();
			y1 = y+vp.get_y();
			x2 = x+vp.get_x();
			y2 = y+vp.get_y()+vp.get_h();
		}
		var ctx = this.ctx;
		embed "js" {{{
		 	var g = ctx.createLinearGradient(x1, y1, x2, y2);
			g.addColorStop(0, this.to_js_rgba_string(a).to_strptr());
			g.addColorStop(1, this.to_js_rgba_string(b).to_strptr());
			ctx.fillStyle = g;
			ctx.fill();
			if(vt != null) {
				ctx.restore();
			}
		}}}
		return(true);
	}

	public bool draw_text(int ax, int ay, VgTransform vt, TextLayout text) {
		if(text == null) {
			return(false);
		}
		int x = ax;
		int y = ay;
		var props = text.get_text_properties();
		if(props == null) {
			return(false);
		}
		if(props.get_alignment() == 1) {
			x = x - (text.get_width() / 2);
		}
		ptr canvas;
		if(text is HTML5TextLayout) {
			canvas = ((HTML5TextLayout)text).get_canvas();
		}
		apply_alpha(vt);
		if(canvas != null) {
			var ctx = this.ctx;
			embed "js" {{{
				if(vt != null) {
					ctx.save();
					ctx.translate(x+(canvas.width/2), y+(canvas.height/2));
					ctx.rotate(vt.get_rotate_angle());
					ctx.scale(vt.get_scale_x(), vt.get_scale_y());
					ctx.translate(-x-(canvas.width/2), -y-(canvas.height/2));
				}
				if(canvas.width > 0 && canvas.height > 0) {
					ctx.drawImage(canvas, x, y);
				}
				if(vt != null) {
					ctx.restore();
				}
			}}}
		}
		return(true);
	}

	public bool draw_graphic(int x, int y, VgTransform vt, Image agraphic) {
		bool drawn = false;
		int w = 0;
		int h = 0;
		if(agraphic != null) {
			if(w < 1) {
				w = agraphic.get_width();
			}
			if(h < 1) {
				h = agraphic.get_height();
			}
		}
		apply_alpha(vt);
		if(agraphic is CodeImage) {
			((CodeImage)agraphic).render(this, x, y, vt);
			drawn = true;
		}
		else if(agraphic is HTML5RenderableImage) {
			var ctx = this.ctx;
			embed "js" {{{
				var img = agraphic.get_element();
				if(vt != null) {
					ctx.save();
					ctx.translate(x+(w/2), y+(h/2));
					ctx.rotate(vt.get_rotate_angle());
					ctx.scale(vt.get_scale_x(), vt.get_scale_y());
					ctx.translate(-x-(w/2), -y-(h/2));
					ctx.drawImage(img, x, y, w, h);
					ctx.restore();
				}
				else {
					ctx.drawImage(img, x, y, w, h);
				}
			}}}
			drawn = true;
		}
		else if(agraphic is HTML5Image) {
			var ctx = this.ctx;
			embed "js" {{{
				var img = agraphic.get_image();
				if(img) {
					var thecontext = this;
					if(typeof img.naturalWidth != "undefined" && img.naturalWidth > 0) {
						drawn = true;
						if(vt != null) {
							ctx.save();
							ctx.translate(x+(w/2), y+(h/2));
							ctx.rotate(vt.get_rotate_angle());
							ctx.scale(vt.get_scale_x(), vt.get_scale_y());
							ctx.translate(-x-(w/2), -y-(h/2));
							ctx.drawImage(img, x, y, w, h);
							ctx.restore();
						}
						else {
							ctx.drawImage(img, x, y, w, h);
						}
					}
					else {
						img.onload = function() {
							thecontext.draw_graphic(x, y, vt, agraphic);
						}
					}
				}
			}}}
		}
		if(drawn == false) {
			if(w < 1) {
				w = 32;
			}
			if(h < 1) {
				h = 32;
			}
			stroke(x, y, VgPathRectangle.create(0,0,w,h), null, Color.instance("#808080"), 2, 0);
		}
		return(true);
	}

	public bool clip(int x, int y, VgPath vp, VgTransform vt) {
		var ctx = this.ctx;
		if(saved == false) {
			embed "js" {{{
				ctx.save();
			}}}
			saved = true;
		}
		if(apply_path(x, y, vp, vt)) {
			embed "js" {{{
				ctx.clip();
			}}}
			if(current_clip == null) {
				current_clip = Rectangle.instance(x+vp.get_x(), y+vp.get_y(), vp.get_w(), vp.get_h());
			}
			else {
				int cx1 = current_clip.get_x(), cy1 = current_clip.get_y(),
					cx2 = cx1 + current_clip.get_width(), cy2 = cy1 + current_clip.get_height();
				int nx = x + vp.get_x(), ny = y + vp.get_y(), nw = vp.get_w(), nh = vp.get_h();
				if(nx > cx1) {
					cx1 = nx;
				}
				if(nx+nw < cx2) {
					cx2 = nx+nw;
				}
				if(ny > cy1) {
					cy1 = ny;
				}
				if(ny+nh < cy2) {
					cy2 = ny+nh;
				}
				int cw = cx2 - cx1;
				if(cw < 0) {
					cw = 0;
				}
				int ch = cy2 - cy1;
				if(ch < 0) {
					ch = 0;
				}
				current_clip = Rectangle.instance(cx1, cy1, cw, ch);
			}
			return(true);
		}
		return(false);
	}

	public bool clip_clear() {
		if(saved) {
			var ctx = this.ctx;
			embed "js" {{{
				ctx.restore();
			}}}
			saved = false;
			current_clip = null;
		}
		return(true);
	}

	public Rectangle get_clip() {
		if(current_clip != null) {
			return(current_clip);
		}
		int w = 0;
		int h = 0;
		var canvas = this.canvas;
		embed "js" {{{
			w = canvas.width;
			h = canvas.height;
		}}}
		return(Rectangle.instance(0, 0, w, h));
	}
}
