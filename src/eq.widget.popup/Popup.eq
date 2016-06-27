
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

public class Popup
{
	class PopupFrameLayerWidget : LayerWidget
	{
		public static PopupFrameLayerWidget for_widget(Widget widget) {
			return(new PopupFrameLayerWidget().set_widget(widget));
		}
		property Widget widget;
		public void initialize() {
			base.initialize();
			add(widget);
		}
	}

	class PopupCloseTimer : TimerHandler {
		Widget widget;
		public static PopupCloseTimer instance(Widget widget) {
			var v = new PopupCloseTimer();
			v.widget = widget;
			return(v);
		}
		public bool on_timer(Object arg) {
			if(widget != null) {
				Popup.close(widget);
			}
			return(false);
		}
	}

	public static bool is_popup(Widget widget) {
		if(widget == null) {
			return(false);
		}
		var p = widget.get_parent() as Widget;
		while(p != null) {
			if(p is PopupContainerWidget || p is PopupFrameLayerWidget) {
				return(true);
			}
			p = p.get_parent() as Widget;
		}
		return(false);
	}

	public static bool get_allow_native(WidgetEngine engine) {
		IFDEF("target_osx") {
			if(engine != null) {
				var prefs = engine.get_frame_options();
				if(prefs != null && prefs.get_type() == CreateFrameOptions.TYPE_FULLSCREEN) {
					return(false);
				}
			}
		}
		return(true);
	}

	public static void widget(WidgetEngine engine, Widget widget) {
		Popup.execute(engine, PopupSettings.instance().set_widget(widget));
	}

	public static bool execute_in_frame(Frame frame, PopupSettings pp) {
		if(frame == null || pp == null) {
			return(false);
		}
		if(pp.get_modal() == true && pp.get_master() == null && pp.get_fullscreen() == false) {
			if(GUI.engine != null && GUI.engine.get_window_manager() != null) {
				var fc = WidgetEngine.for_widget(PopupFrameLayerWidget.for_widget(pp.get_widget()));
				var ff = Frame.open_as_popup(fc, frame);
				if(ff != null) {
					return(true);
				}
			}
		}
		var ee = frame.get_controller() as WidgetEngine;
		if(ee == null) {
			Log.error("Popup.execute_in_frame: Can't do popups and frame controller is not a widget engine. Don't know what to do.");
			return(false);
		}
		return(execute_in_widget_engine(ee, pp));
	}

	public static bool execute(WidgetEngine engine, PopupSettings pp) {
		if(engine == null) {
			return(false);
		}
		var ff = engine.get_frame();
		if(ff != null) {
			return(execute_in_frame(ff, pp));
		}
		return(execute_in_widget_engine(engine, pp));
	}

	public static bool execute_in_widget_engine(WidgetEngine engine, PopupSettings pp) {
		if(pp == null || pp.get_widget() == null || engine == null) {
			return(false);
		}
		var rootwidget = engine.get_root_widget();
		if(rootwidget == null) {
			return(false);
		}
		var widget = pp.get_widget();
		if(widget == null) {
			return(false);
		}
		var timeout = pp.get_timeout();
		var modal = pp.get_modal();
		var master = pp.get_master();
		var x = pp.get_x();
		var y = pp.get_y();
		var fullscreen = pp.get_fullscreen();
		var toadd = widget;
		Widget ww;
		if(fullscreen) {
			ww = new PopupContainerWidget().set_modal(modal).add(toadd);
		}
		else if(master != null) {
			ww = new PopupContainerWidget().set_modal(modal).add(RelativeAlignWidget.for_widget(master, pp.get_force_same_width()).add(toadd));
		}
		else if(x >= 0 && y >= 0) {
			ww = new PopupContainerWidget().set_modal(modal).add(AbsoluteAlignWidget.for_location(x, y)
				.add(toadd));
		}
		else {
			ww = new PopupContainerWidget().set_modal(modal).add(AlignWidget.instance().set_margin(Length.to_pixels("500um", engine.get_dpi()))
				.add_align(0, 0, toadd));
		}
		((PopupContainerWidget)ww).set_next_to_focus(pp.get_focus());
		ww.set_alpha(0.0);
		rootwidget.add(ww);
		ww.set_alpha(1.0, 250000);
		engine.reset_focus();
		if(timeout > 0) {
			Timer.start(GUI.engine.get_background_task_manager(), timeout, PopupCloseTimer.instance(widget), null);
		}
		return(true);
	}

	public static void close(Widget widget) {
		if(widget == null) {
			return;
		}
		var engine = widget.get_engine();
		if(engine == null) {
			return;
		}
		var rootwidget = engine.get_root_widget();
		if(widget != null && rootwidget != null) {
			var p = widget;
			while(p != null && p is PopupContainerWidget == false) {
				p = p.get_parent() as Widget;
			}
			if(p == null) {
				if(rootwidget.get_child(0) as PopupFrameLayerWidget != null) {
					var frame = engine.get_frame() as ClosableFrame;
					if(frame != null) {
						frame.close();
						return;
					}
				}
			}
			if(engine.is_started() && widget.is_started()) {
				widget.stop();
			}
			Widget tofocus;
			if(p != null) {
				tofocus = ((PopupContainerWidget)p).get_next_to_focus();
				((PopupContainerWidget)p).set_next_to_focus(null);
				rootwidget.remove(p);
			}
			else {
				rootwidget.remove(widget);
			}
			var cc = rootwidget.count();
			if(cc > 0) {
				var top = rootwidget.get_child(cc-1);
				if(top != null) {
					engine.set_focus_widget(tofocus);
				}
			}
			else {
				var frame = rootwidget.get_frame() as ClosableFrame;
				if(frame != null) {
					frame.close();
				}
			}
		}
	}
}
