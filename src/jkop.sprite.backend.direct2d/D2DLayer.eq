
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

class D2DLayer : D2DElement, D2DElementList, SELayer, SEElementContainer, Iterateable
{
	property bool clipped;
	Collection list;
	double width;
	double height;

	public D2DLayer() {
		list = LinkedList.create();
	}

	public double get_width() {
		return(width);
	}

	public double get_height() {
		return(height);
	}

	public void set_alpha(double alpha) {
		base.set_alpha(alpha);
	}

	public void resize(double width, double height) {
		this.width = width;
		this.height = height;
		update_children_layout();
	}

	public void move(double x, double y) {
		base.move(x, y);
		update_children_layout();
	}

	void update_children_layout() {
		if(this.width < 1 || this.height < 1) {
			return;
		}
		foreach(D2DElement e in list) {
			e.update_matrix();
		}
	}

	public void cleanup() {
		list.clear();
		list = null;
	}

	public SESprite add_sprite() {
		var sprite = new D2DSprite();
		sprite.set_mycontainer(this);
		add_element(sprite);
		sprite.set_rsc(get_rsc());
		return(sprite);
	}

	public void add_element(SEElement e) {
		list.append(e);
	}

	public void remove_element(SEElement e) {
		list.remove(e);
	}

	public Iterator iterate() {
		return(list.iterate());
	}

	public SESprite add_sprite_for_image(SEImage image) {
		var v = add_sprite();
		v.set_image(image);
		return(v);
	}

	public SESprite add_sprite_for_text(String text, String fontid) {
		var v = add_sprite();
		v.set_text(text, fontid);
		return(v);
	}

	public SESprite add_sprite_for_color(Color color, double width, double height) {
		var v = add_sprite();
		v.set_color(color, width, height);
		return(v);
	}

	public SELayer add_layer(double x, double y, double width, double height, bool force_clipped = false) {
		var v = new D2DLayer();
		v.set_mycontainer(this);
		add_element(v);
		v.set_rsc(get_rsc());
		v.move(x, y);
		v.resize(width, height);
		v.set_clipped(force_clipped);
		return(v);
	}
}
