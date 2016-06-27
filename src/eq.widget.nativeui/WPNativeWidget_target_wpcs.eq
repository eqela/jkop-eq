
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

public class WPNativeWidget : Widget
{
	embed "cs" {{{
		public System.Windows.Controls.Control wpcontrol;
		public System.Windows.Controls.Control focuscontrol;
	}}}

	public bool is_surface_container() {
		return(true);
	}

	embed "cs" {{{
		protected virtual System.Windows.Controls.Control create_wp_control() {
			return(null);
		}
	}}}

	public Collection render() {
		return(LinkedList.create());
	}

	public void on_surface_created(Surface surface) {
		base.on_surface_created(surface);
		if(surface != null) {
			embed "cs" {{{
				if(surface is System.Windows.Controls.Canvas) {
					var cc = (System.Windows.Controls.Canvas)surface;
					wpcontrol = create_wp_control();;
					if(wpcontrol != null) {
						cc.Children.Add(wpcontrol);
					}
				}
			}}}
		}
	}

	public void initialize() {
		base.initialize();
		set_surface_content(render());
		var surface = get_surface();
		update_size_request();
	}

	public virtual Size get_desired_size() {
		double wr = 0, hr = 0;
		embed {{{
			if(wpcontrol != null) {
				var sz = new System.Windows.Size() { Width = int.MaxValue, Height = int.MaxValue };
				wpcontrol.Measure(sz);
				wr = wpcontrol.DesiredSize.Width;
				hr = wpcontrol.DesiredSize.Height;
			}
		}}}
		return(Size.instance(wr, hr));
	}

	public void update_size_request() {
		var sz = get_desired_size();
		if(sz != null) {
			set_size_request((int)sz.get_width(), (int)sz.get_height());
		}
	}

	public void on_resize() {
		base.on_resize();
		var w = get_width(), h = get_height();
		embed "cs" {{{
			if(wpcontrol != null) {
				wpcontrol.Width = w;
				wpcontrol.Height = h;
			}
		}}}
	}

	public void set_native_focus(bool has_focus) {
		embed "cs" {{{
			if(has_focus) {
				if(wpcontrol!=null) {
					wpcontrol.Focus();
				}
			}
			else {
				wpcontrol.Visibility = System.Windows.Visibility.Collapsed;
				wpcontrol.Visibility = System.Windows.Visibility.Visible;
			}
		}}}
	}
}
