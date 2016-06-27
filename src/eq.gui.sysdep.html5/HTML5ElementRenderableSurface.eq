
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

public class HTML5ElementRenderableSurface : HTML5ElementSurface, Renderable
{
	public HTML5ElementRenderableSurface() {
		var element = HTMLElement.create("canvas");
		element.set_style("position", "absolute");
		element.set_style("left", "0");
		element.set_style("top", "0");
		element.set_style("width", "0px");
		element.set_style("height", "0px");
		element.set_style("margin", "0");
		element.set_style("padding", "0");
		element.set_style("-webkit-tap-highlight-color", "rgba(255, 255, 255, 0)");
		set_element(element);
	}

	public void resize(double w, double h) {
		base.resize(w, h);
		var rat = get_device_pixel_ratio();
		var element = get_element();
		element.set_style("width", "%dpx".printf().add(w).to_string());
		element.set_style("height", "%dpx".printf().add(h).to_string());
		element.set_attribute("width", "%dpx".printf().add(w*rat).to_string());
		element.set_attribute("height", "%dpx".printf().add(h*rat).to_string());
	}

	public void render(Collection ops) {
		var canvas = get_element();
		var ctx = HTML5CanvasVgContext.for_canvas_element(canvas.get_element(), get_device_pixel_ratio());
		ctx.clear(0, 0, VgPathRectangle.create(0, 0, get_width(), get_height()), null);
		if(Collection.is_empty(ops) == false) {
			VgRenderer.render_to_vg_context(ops, ctx);
		}
	}
}
