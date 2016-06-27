
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

public class AndroidNativeWidget : Widget
{
	embed "java" {{{
		protected android.view.View androidview;
	}}}

	public bool is_surface_container() {
		return(true);
	}

	embed "java" {{{
		protected android.view.View create_android_view(android.content.Context context) {
			return(null);
		}
	}}}

	public Collection render() {
		return(LinkedList.create());
	}

	/* NOTE: There is a minor weirdness here: We create the surface here in initialize(), wherease
	 * surfaces are normally created afterwards, usually during on_resize(). This means that this surfae
	 * here is create BEFORE any other surfaces in the hierarchy, specifically before any surface that
	 * is below it. What this means is that if the surface below this one is created after this, it may
	 * get placed on top if it is the first one in the subcontainer (which is the case when placed inside
	 * a scroller). We have worked around this by making add_surface_inside to add to the BOTTOM, and not
	 * to the top, so that the one after will be placed under, and not below. This is consistent with the
	 * behavior of the Widget class which also adds to the bottom, not to the top. However, I am not sure
	 * if this will prove to be the best behavior in ALL cases. The alternative here would be to defer the
	 * creation of the surface to on_resize -> update_view, and likewise defer the addition of the Android
	 * widget, thus making the behavior of this widget consistent with other widgets in this regard. However,
	 * this would require us to call the measurement function of the Android widget before it is added, and
	 * while this can be done, I am not sure if this would work with all Android views. And as we have seen,
	 * they are quite fragile in terms of where they are added (read: EditText) and may end up behaving
	 * in funny ways, so it is better not to take the risk. But this note has been placed here in case we will
	 * have future odd behavior, and we can consider readjusting.
	 */

	public void on_surface_created(Surface surface) {
		base.on_surface_created(surface);
		if(surface != null) {
			embed "java" {{{
				if(surface instanceof android.view.ViewGroup) {
					android.view.ViewGroup vg = (android.view.ViewGroup)surface;
					vg.setFocusable(true);
					vg.setFocusableInTouchMode(true);
					androidview = create_android_view(vg.getContext());
					if(androidview != null) {
						vg.addView(androidview);
					}
				}
			}}}
			update_size_request();
		}
	}

	public void on_surface_removed() {
		embed "java" {{{
			androidview = null;
		}}}
	}

	public void initialize() {
		base.initialize();
		set_surface_content(render());
		start_timer(0, new MeasureTimer().set_widget(this), null);
	}

	class MeasureTimer : TimerHandler {
		property AndroidNativeWidget widget;
		public bool on_timer(Object arg) {
			widget.update_size_request();
			return(false);
		}
	}

	public virtual Size get_desired_size() {
		int wr = 0, hr = 0;
		embed {{{
			if(androidview != null) {
				androidview.measure(
					android.view.View.MeasureSpec.makeMeasureSpec(0, android.view.View.MeasureSpec.UNSPECIFIED),
					android.view.View.MeasureSpec.makeMeasureSpec(0, android.view.View.MeasureSpec.UNSPECIFIED)
				);
				wr = androidview.getMeasuredWidth();
				hr = androidview.getMeasuredHeight();
			}
			else {
				return(null);
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
		embed "java" {{{
			if(androidview != null) {
				androidview.layout(0, 0, (int)w, (int)h);
				androidview.invalidate();
			}
		}}}
	}

	public void on_gain_focus() {
		base.on_gain_focus();
		embed {{{
			if(androidview != null) {
				androidview.requestFocus();
			}
		}}}
	}

	bool losingfocus = false;
	public void on_lose_focus() {
		base.on_lose_focus();
		if(losingfocus) {
			return;
		}
		losingfocus = true;
		android_clear_focus();
		losingfocus = false;
	}

	public virtual void android_clear_focus() {
		var surface = get_surface();
		embed "java" {{{
			if(surface != null) {
				android.view.ViewGroup sf = (android.view.ViewGroup)surface;
				sf.requestFocus();
			}
			else if(androidview != null) {
				androidview.clearFocus();
			}
		}}}
	}
}
