
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

public class ClipperContainerWidget : ContainerWidget, ClipperWidget
{
	public bool is_surface_container() {
		return(true);
	}

	public void on_widget_initialized() {
		base.on_widget_initialized();
		set_surface_content(LinkedList.create());
	}

	public Widget get_hover_widget(int x, int y) {
		return(base.get_hover_widget((int)(x - get_x()), (int)(y - get_y())));
	}

	public bool on_pointer_press(int x, int y, int button, int id) {
		return(base.on_pointer_press((int)(x - get_x()), (int)(y - get_y()), button, id));
	}

	public bool on_pointer_release(int x, int y, int button, int id) {
		return(base.on_pointer_release((int)(x - get_x()), (int)(y - get_y()), button, id));
	}

	public bool on_pointer_cancel(int x, int y, int button, int id) {
		return(base.on_pointer_cancel((int)(x - get_x()), (int)(y - get_y()), button, id));
	}

	public bool on_pointer_move(int x, int y, int id) {
		return(base.on_pointer_move((int)(x - get_x()), (int)(y - get_y()), id));
	}

	public bool on_context(int x, int y) {
		return(base.on_context((int)(x - get_x()), (int)(y - get_y())));
	}

	public bool on_context_drag(int x, int y, int dx, int dy, bool drop, int id) {
		return(base.on_context_drag((int)(x - get_x()), (int)(y - get_y()), dx, dy, drop, id));
	}

	public bool on_zoom(int x, int y, int dz) {
		return(base.on_zoom((int)(x - get_x()), (int)(y - get_y()), dz));
	}

	public void on_move_diff(double diffx, double diffy) {
	}

	public void do_update_view() {
	}

	public Collection render() {
		return(LinkedList.create());
	}
}
