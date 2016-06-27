
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

public class ButtonFrameWidget : ClickWidget
{
	CanvasWidget wbg;
	CanvasWidget focuscanvas;
	String internal_margin;
	bool rounded = true;
	bool draw_frame = true;
	property bool draw_outline = true;
	property Color outline_color;
	property Color pressed_color;
	property Color hover_color;
	property String outline_width;
	Color color;
	LayerWidget internal_layer;
	property bool color_gradient = true;

	public ButtonFrameWidget() {
		color = Theme.color("eq.widget.common.ButtonFrameWidget.color", "#222222");
		pressed_color = Theme.color("eq.widget.common.ButtonFrameWidget.pressed_color", "none");
		outline_color = Theme.color("eq.widget.common.ButtonFrameWidget.outline_color", null);
		internal_margin = Theme.string("eq.widget.common.ButtonFrameWidget.internal_margin", "1500um");
		outline_width = Theme.string("eq.widget.common.ButtonFrameWidget.outline_width", "333um");
		hover_color = null;
	}

	public override bool get_always_has_surface() {
		return(true);
	}

	public bool is_surface_container() {
		return(true);
	}

	public LayerWidget get_internal_layer() {
		return(internal_layer);
	}

	public ButtonFrameWidget set_rounded(bool v) {
		rounded = v;
		if(wbg != null) {
			wbg.set_rounded(v);
		}
		if(focuscanvas != null) {
			focuscanvas.set_rounded(v);
		}
		return(this);
	}

	public bool get_rounded() {
		return(rounded);
	}

	public ButtonFrameWidget set_internal_margin(String mm) {
		internal_margin = mm;
		if(internal_layer != null) {
			internal_layer.set_margin(px(mm));
		}
		return(this);
	}

	public String get_internal_margin() {
		return(internal_margin);
	}

	public ButtonFrameWidget set_color(Color color) {
		this.color = color;
		on_changed();
		return(this);
	}

	public Color get_color() {
		return(color);
	}

	public ButtonFrameWidget set_draw_frame(bool f) {
		draw_frame = f;
		on_changed();
		return(this);
	}

	public bool get_draw_frame() {
		return(draw_frame);
	}

	public virtual void initialize_button(LayerWidget lw) {
	}

	public void initialize() {
		base.initialize();
		add(wbg = CanvasWidget.instance().set_rounded(rounded));
		internal_layer = LayerWidget.instance();
		internal_layer.set_margin(px(internal_margin));
		initialize_button(internal_layer);
		add(internal_layer);
		add(focuscanvas = CanvasWidget.instance().set_rounded(rounded));
		on_changed();
	}

	public void cleanup() {
		base.cleanup();
		wbg = null;
		focuscanvas = null;
		internal_layer = null;
	}

	public void on_changed() {
		if(wbg != null) {
			if(draw_frame || get_hover() || get_pressed()) {
				wbg.set_enabled(true);
				var cc = color;
				if(cc != null) {
					if(get_pressed()) {
						cc = pressed_color;
						if(cc == null) {
							var dc = get_draw_color();
							if(dc != null) {
								cc = dc.dup("50%");
							}
						}
						if(cc == null) {
							cc = color.dup("50%");
						}
					}
					else if(get_hover()) {
						if(hover_color != null) {
							cc = hover_color;
						}
						else {
							cc = color.dup().set_a(cc.get_a() * 0.65);
						}
					}
				}
				if(color_gradient) {
					wbg.set_color_gradient(cc);
				}
				else {
					wbg.set_color(cc);
				}
				if(draw_outline) {
					var oc = outline_color;
					if(oc == null) {
						oc = cc;
					}
					wbg.set_outline_width(outline_width);
					wbg.set_outline_color(oc);
				}
			}
			else {
				wbg.set_enabled(false);
			}
		}
		if(focuscanvas != null) {
			if(get_focus()) {
				focuscanvas.set_outline_color(Theme.get_highlight_color());
			}
			else {
				focuscanvas.set_outline_color(null);
			}
		}
	}
}
