
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

public class WidgetEngine : FrameController, Scene
{
	public static WidgetEngine for_widget(Widget widget) {
		return(new WidgetEngine().set_main_widget(widget));
	}

	ContainerWidget rootwidget = null;
	Frame frame = null;
	bool pointer_pressed = false;
	bool pointer_pressed_moved = false;
	bool context_pressed = false;
	bool context_pressed_moved = false;
	int pointer_press_x = 0;
	int pointer_press_y = 0;
	int context_press_x = 0;
	int context_press_y = 0;
	Widget focus_widget = null;
	Widget defaultaction = null;
	int mywidth = 0;
	int myheight = 0;
	int dpi = 96;
	int jitter = 8;
	int hover_x = -1;
	int hover_y = -1;
	Widget hover_widget = null;
	property Widget main_widget;
	SceneController scene_controller;
	property bool disable_click_timer = false;

	public WidgetEngine() {
		Theme.initialize();
	}

	~WidgetEngine() {
		destroy();
	}

	public virtual Size get_widget_preferred_size() {
		if(rootwidget == null) {
			return(null);
		}
		return(Size.instance(rootwidget.get_width_request(), rootwidget.get_height_request()));
	}

	public Size get_preferred_size() {
		return(get_widget_preferred_size());
	}

	public CreateFrameOptions get_frame_options() {
		if(main_widget != null) {
			return(main_widget.get_frame_options());
		}
		return(null);
	}

	public virtual Widget create_background_widget() {
		return(null);
	}

	public virtual Widget create_main_widget() {
		return(null);
	}

	public virtual Widget create_splash_widget(Widget nextwidget) {
		return(null);
	}

	class SwitchSceneTimer : TimerHandler {
		property SceneController controller;
		property FrameController next;
		public bool on_timer(Object arg) {
			controller.switch_scene(next);
			return(false);
		}
	}

	public bool switch_scene(FrameController fc) {
		if(scene_controller != null) {
			Timer.start(GUI.engine.get_background_task_manager(), 0, new SwitchSceneTimer().set_controller(scene_controller).set_next(fc));
			return(true);
		}
		return(false);
	}

	public void set_scene_controller(SceneController sc) {
		scene_controller = sc;
	}

	public SceneController get_scene_controller() {
		return(scene_controller);
	}

	public void end_scene(SceneEndListener sel) {
		sel.on_scene_ended(this);
	}

	bool close_frame_flag = false;

	public void close_frame() {
		if(frame != null) {
			var frc = frame as ClosableFrame;
			if(frc != null) {
				frc.close();
			}
		}
		else {
			close_frame_flag = true;
		}
	}

	public void initialize_frame(Frame fr) {
		if(close_frame_flag) {
			close_frame_flag = false;
			var frc = fr as ClosableFrame;
			if(frc != null) {
				frc.close();
				return;
			}
		}
		frame = fr;
		if(frame != null) {
			dpi = frame.get_dpi();
		}
		Log.debug("Widget engine DPI set to %d".printf().add(Primitive.for_integer(dpi)).to_string());
		this.jitter = Length.to_pixels("3500um", dpi);
		rootwidget = LayerWidget.instance();
		rootwidget.set_parent(this);
		set_frame_title(Application.get_display_name());
		set_frame_icon(IconCache.get("appicon"));
		var bgw = create_background_widget();
		if(bgw != null) {
			rootwidget.add(bgw);
		}
		var main_widget = create_main_widget();
		if(main_widget == null) {
			main_widget = this.main_widget;
		}
		var sp = create_splash_widget(main_widget);
		if(sp != null) {
			main_widget = sp;
		}
		if(main_widget != null) {
			rootwidget.add(main_widget);
		}
		// do a pseudo-resize to trigger any size-related changes to the size request (= labels)
		var psz = get_widget_preferred_size();
		if(psz != null) {
			on_event(new FrameResizeEvent().set_width(psz.get_width()).set_height(psz.get_height()));
		}
		reset_focus();
	}

	public ContainerWidget get_root_widget() {
		return(rootwidget);
	}

	public virtual bool on_frame_close_request() {
		if(rootwidget == null) {
			return(true);
		}
		var c = rootwidget.get_child(0) as WidgetEngineCloseRequestHandler;
		if(c == null) {
			return(true);
		}
		return(c.on_widget_engine_close_request());
	}

	public Widget get_default_action() {
		return(defaultaction);
	}

	public void set_default_action(Widget da) {
		defaultaction = da;
	}

	public Widget get_focus_widget() {
		return(focus_widget);
	}

	public void reset_focus(bool explicit = false) {
		set_focus_widget(null, explicit);
	}

	public void set_focus_widget(Widget ww, bool explicit = false) {
		var w = ww;
		if(w == null && explicit == false) {
			w = rootwidget.get_default_focus_widget();
		}
		if(focus_widget == w) {
			if(w != null) {
				w.on_update_focus();
			}
			else {
				var ff = get_frame() as FocusAwareFrame;
				if(ff != null) {
					ff.on_focus_reset();
				}
			}
			return;
		}
		var ofw = focus_widget;
		var nfw = w;
		focus_widget = w;
		if(ofw != null) {
			ofw.on_lose_focus();
		}
		var ff = get_frame() as FocusAwareFrame;
		if(ff != null) {
			ff.on_focus_reset();
		}
		if(nfw != null && focus_widget == nfw) {
			nfw.on_gain_focus();
		}
	}

	public void destroy() {
		stop();
		focus_widget = null;
		if(rootwidget != null) {
			rootwidget.set_parent(null);
			rootwidget = null;
		}
		frame = null;
	}

	public virtual int get_dpi() {
		return(dpi);
	}

	public virtual Frame get_frame() {
		return(frame);
	}

	public int get_width() {
		return(mywidth);
	}

	public int get_height() {
		return(myheight);
	}

	public virtual void on_resize(int w, int h) {
		mywidth = w;
		myheight = h;
		if(rootwidget != null) {
			rootwidget.move_resize(0, 0, w, h);
		}
		if(focus_widget != null) {
			var ff = FocusFrameWidget.find(focus_widget);
			if(ff != null) {
				ff.scroll_to_widget();
			}
			else {
				focus_widget.scroll_to_widget();
			}
		}
	}

	public void focus_previous() {
		if(focus_widget == null) {
			// there is no sense in going backwards from nothing ..
			// but from nothing, one can always go FORWARD!
			focus_next();
		}
		Widget v = null;
		var stack = Stack.create();
		Widget c = rootwidget;
		foreach(Widget cw in rootwidget.iterate_children()) {
			c = cw;
		}
		Widget prev = null;
		while(c != null && v == null) {
			if(c == focus_widget) {
				v = prev;
				if(v != null) {
					break;
				}
			}
			else if(c.is_focusable() && c.is_enabled()) {
				prev = c;
			}
			if(c is ContainerWidget && c.is_enabled()) {
				stack.push(((ContainerWidget)c).iterate_children());
			}
			c = null;
			while(c == null) {
				var cont = stack.peek() as Iterator;
				if(cont == null) {
					break;
				}
				c = cont.next() as Widget;
				if(c == null) {
					stack.pop();
				}
			}
		}
		if(v == null && prev != null) {
			v = prev;
		}
		if(v != null) {
			set_focus_widget(v);
		}
	}

	public void focus_next() {
		Widget v = null;
		var stack = Stack.create();
		Widget c = rootwidget;
		foreach(Widget cw in rootwidget.iterate_children()) {
			c = cw;
		}
		Widget first = null;
		bool flag = false;
		if(focus_widget == null) {
			flag = true;
		}
		while(c != null && v == null) {
			if(c == focus_widget) {
				flag = true;
			}
			else if(c.is_focusable() && c.is_enabled()) {
				if(flag) {
					v = c;
					break;
				}
				if(first == null) {
					first = c;
				}
			}
			if(c is ContainerWidget && c.is_enabled()) {
				stack.push(((ContainerWidget)c).iterate_children());
			}
			c = null;
			while(c == null) {
				var cont = stack.peek() as Iterator;
				if(cont == null) {
					break;
				}
				c = cont.next() as Widget;
				if(c == null) {
					stack.pop();
				}
			}
		}
		if(v == null && first != null && first != focus_widget) {
			v = first;
		}
		if(v != null) {
			set_focus_widget(v);
		}
	}

	BackgroundTask click_timer;

	class ClickTimer : TimerHandler {
		WidgetEngine we;
		PointerPressEvent ev;
		public static ClickTimer create(WidgetEngine e, PointerPressEvent ev) {
			var v = new ClickTimer();
			v.we = e;
			v.ev = ev;
			return(v);
		}
		public bool on_timer(Object arg) {
			if(we != null && ev != null) {
				we.on_click_timer(ev);
			}
			return(false);
		}
	}

	public void on_click_timer(PointerPressEvent ev) {
		click_timer = null;
		if(rootwidget == null || pointer_pressed == false) {
			return;
		}
		var ce = new PointerCancelEvent();
		ce.set_id(ev.get_id());
		ce.set_x(ev.get_x());
		ce.set_y(ev.get_y());
		ce.set_button(ev.get_button());
		on_event(ce);
		context_pressed = true;
		pointer_pressed = false;
		var rw = rootwidget;
		if(rw.on_context(ev.get_x(), ev.get_y()) == false) {
			rw.on_pointer_press(ev.get_x(), ev.get_y(), 2, ev.get_id());
		}
	}

	private void start_click_timer(PointerPressEvent e) {
		if(click_timer != null) {
			stop_click_timer();
		}
		if(disable_click_timer) {
			return;
		}
		click_timer = Timer.start(GUI.engine.get_background_task_manager(), 500000, ClickTimer.create(this, e));
	}

	private void stop_click_timer() {
		if(click_timer != null) {
			click_timer.abort();
		}
		click_timer = null;
	}

	public virtual void set_frame_icon(Image icon) {
		var ff = get_frame() as TitledFrame;
		if(ff != null) {
			ff.set_icon(icon);
		}
	}

	public virtual void set_frame_title(String title) {
		var ff = get_frame() as TitledFrame;
		if(ff != null) {
			ff.set_title(title);
		}
	}

	public bool on_event(Object o) {
		if(o is PointerEvent) {
			return(on_pointer_event((PointerEvent)o));
		}
		if(o is ScrollEvent) {
			var se = (ScrollEvent)o;
			return(rootwidget.on_scroll(se.get_x(), se.get_y(), se.get_dx(), se.get_dy()));
		}
		if(o is ZoomEvent) {
			var ze = (ZoomEvent)o;
			return(rootwidget.on_zoom(ze.get_x(), ze.get_y(), ze.get_dz()));
		}
		if(o is KeyEvent) {
			return(on_key_event((KeyEvent)o));
		}
		if(o is FrameCloseRequestEvent) {
			if(on_frame_close_request()) {
				((FrameCloseRequestEvent)o).accept();
			}
			else {
				((FrameCloseRequestEvent)o).reject();
			}
			return(true);
		}
		if(o is FrameResizeEvent) {
			var fre = (FrameResizeEvent)o;
			on_resize(fre.get_width(), fre.get_height());
			return(true);
		}
		return(false);
	}

	public bool on_pointer_event(PointerEvent pe) {
		if(pe is PointerMoveEvent) {
			bool f = false;
			if(pointer_pressed) {
				// minor resistance: just a few pixels of jitter is not yet considered dragging
				if(pointer_pressed_moved == true || Math.abs(pe.get_x() - pointer_press_x) >= jitter ||
					Math.abs(pe.get_y() - pointer_press_y) >= jitter)
				{
					stop_click_timer();
					pointer_pressed_moved = true;
					var px = pe.get_x();
					var py = pe.get_y();
					var rw = rootwidget;
					if(rw != null) {
						f = rw.on_pointer_drag(px, py, px - pointer_press_x, py - pointer_press_y, 0, false, pe.get_id());
					}
				}
			}
			if(context_pressed) {
				// minor resistance: just a few pixels of jitter is not yet considered dragging
				if(context_pressed_moved == true || Math.abs(pe.get_x() - context_press_x) >= jitter ||
					Math.abs(pe.get_y() - context_press_y) >= jitter)
				{
					context_pressed_moved = true;
					var px = pe.get_x();
					var py = pe.get_y();
					var rw = rootwidget;
					if(rw != null) {
						f = rw.on_context_drag(px, py, px - context_press_x, py - context_press_y, false, pe.get_id());
					}
				}
			}
			update_hover_widget((PointerMoveEvent)pe, f);
			if(f == false) {
				var rw = rootwidget;
				if(rw != null) {
					rw.on_pointer_move(pe.get_x(), pe.get_y(), pe.get_id());
				}
			}
			return(true);
		}
		if(pe is PointerPressEvent) {
			bool r = true;
			int button = ((PointerPressEvent)pe).get_button();
			if(button == 1) { // left button
				start_click_timer((PointerPressEvent)pe); // FIXME: This should be done separately for each pointer
				pointer_pressed = true;
				pointer_pressed_moved = false;
				pointer_press_x = pe.get_x();
				pointer_press_y = pe.get_y();
				var rw = rootwidget;
				if(rw != null) {
					r = rw.on_pointer_press(pe.get_x(), pe.get_y(), 0, pe.get_id());
				}
			}
			else if(button == 2) { // middle button
				var rw = rootwidget;
				if(rw != null) {
					r = rw.on_pointer_press(pe.get_x(), pe.get_y(), 1, pe.get_id());
				}
			}
			else if(button == 3) { // right button
				context_pressed = true;
				context_pressed_moved = false;
				context_press_x = pe.get_x();
				context_press_y = pe.get_y();
				var rw = rootwidget;
				if(rw != null && rw.on_context(pe.get_x(), pe.get_y()) == false) {
					r = rw.on_pointer_press(pe.get_x(), pe.get_y(), 2, pe.get_id());
				}
			}
			if(r == false) {
				reset_focus(true);
			}
			return(true);
		}
		if(pe is PointerReleaseEvent) {
			if(pointer_pressed) {
				stop_click_timer();
				var rw = rootwidget;
				if(rw != null) {
					rw.on_pointer_release(pe.get_x(), pe.get_y(), 0, pe.get_id());
					rw.on_pointer_drag(
						pointer_press_x,
						pointer_press_y,
						pe.get_x() - pointer_press_x,
						pe.get_y() - pointer_press_y,
						0, true, pe.get_id());
				}
				pointer_pressed = false;
			}
			if(context_pressed) {
				var rw = rootwidget;
				if(rw != null) {
					rw.on_pointer_release(pe.get_x(), pe.get_y(), 2, pe.get_id());
					rw.on_pointer_drag(
						context_press_x,
						context_press_y,
						pe.get_x() - context_press_x,
						pe.get_y() - context_press_y,
						2, true, pe.get_id());
				}
				context_pressed = false;
			}
			return(true);
		}
		if(pe is PointerCancelEvent) {
			var rw = rootwidget;
			if(rw != null) {
				rw.on_pointer_cancel(pe.get_x(), pe.get_y(),
					((PointerCancelEvent)pe).get_button() - 1, pe.get_id());
			}
			return(true);
		}
		if(pe is PointerLeaveEvent) {
			if(hover_widget != null) {
				var hw = hover_widget;
				hw.on_pointer_leave(pe.get_id());
				hover_widget = null;
			}
			var ww = rootwidget.get_child(0) as Widget;
			if(ww != null) {
				ww.on_pointer_leave_frame(pe.get_id());
			}
			return(true);
		}
		return(false);
	}

	public bool on_key_event(KeyEvent ke) {
		bool v = false;
		// primarily pass the key event to the focused widget
		if(focus_widget != null) {
			var fw = focus_widget;
			v = fw.on_key_event(ke);
		}
		// try to look for other widgets that may want the event
		if(v == false) {
			var c = rootwidget.get_last_child();
			if(c != null) {
				v = c.on_key_event(ke);
			}
		}
		if(v == false) {
			v = on_unhandled_key_event(ke);
		}
		return(v);
	}

	public virtual bool on_unhandled_key_event(KeyEvent e) {
		if(e is KeyPressEvent) {
			return(on_unhandled_key_press(e));
		}
		if(e is KeyReleaseEvent) {
			return(on_unhandled_key_release(e));
		}
		return(false);
	}

	public virtual bool on_unhandled_key_press(KeyEvent e) {
		bool v = false;
		if(e != null) {
			var keyname = e.get_name();
			if("tab".equals(keyname)) {
				if(e.get_shift()) {
					focus_previous();
					v = true;
				}
				else {
					focus_next();
					v = true;
				}
			}
			else if("focus_next".equals(keyname)) {
				focus_next();
				v = true;
			}
			else if("focus_previous".equals(keyname)) {
				focus_previous();
				v = true;
			}
		}
		return(v);
	}

	public virtual bool on_unhandled_key_release(KeyEvent e) {
		return(false);
	}

	private void update_hover_widget(PointerMoveEvent e, bool clearonly) {
		if(clearonly) {
			if(hover_widget != null) {
				hover_widget.on_pointer_leave(e.get_id());
				hover_widget = null;
			}
			return;
		}
		var currentx = e.get_x();
		var currenty = e.get_y();
		if(currentx != hover_x || currenty != hover_y) {
			hover_x = currentx;
			hover_y = currenty;
			Widget nw = null;
			if(currentx >= 0 && currenty >= 0) {
				if(rootwidget != null) {
					nw = rootwidget.get_hover_widget(hover_x, hover_y);
				}
				if(nw == null) {
					nw = rootwidget;
				}
			}
			if(nw != hover_widget) {
				if(hover_widget != null) {
					hover_widget.on_pointer_leave(e.get_id());
				}
				hover_widget = nw;
				if(hover_widget != null) {
					hover_widget.on_pointer_enter(e.get_id());
				}
			}
		}
	}

	Queue raised_events;
	Object raise_event_timer;

	class RaiseEventTimer : TimerHandler {
		WidgetEngine we;
		public static RaiseEventTimer create(WidgetEngine e) {
			var v = new RaiseEventTimer();
			v.we = e;
			return(v);
		}
		public bool on_timer(Object arg) {
			if(we != null) {
				we.handle_raised_events();
			}
			return(false);
		}
	}

	public void raise_event(Object e) {
		if(e == null) {
			return;
		}
		if(raised_events == null) {
			raised_events = Queue.create();
		}
		raised_events.push(e);
		if(raise_event_timer == null) {
			raise_event_timer = Timer.start(GUI.engine.get_background_task_manager(), 0, RaiseEventTimer.create(this));
		}
	}

	public void handle_raised_events() {
		raise_event_timer = null;
		PropertyObject o = null;
		while(raised_events != null && (o = raised_events.pop() as PropertyObject) != null) {
			on_event(o);
		}
		raised_events = null;
	}

	bool started = false;

	public bool is_started() {
		return(started);
	}

	public void start() {
		if(started == false) {
			if(rootwidget != null && rootwidget.is_started() == false) {
				rootwidget.start();
			}
			started = true;
		}
	}

	public void stop() {
		if(started == true) {
			if(rootwidget != null && rootwidget.is_started()) {
				rootwidget.stop();
			}
			started = false;
		}
	}

	public void on_new_child_size_params(Widget w) {
		var frame = this.frame;
		if(frame == null) {
			return;
		}
		bool change = false;
		var ww = frame.get_width(), wh = frame.get_height();
		var wr = w.get_width_request(), hr = w.get_height_request();
		if(wr != ww) {
			ww = wr;
			change = true;
		}
		if(hr != wh) {
			wh = hr;
			change = true;
		}
		if(change) {
			on_new_size_request(wr, hr);
		}
	}

	public virtual void on_new_size_request(int wr, int hr) {
	}

	public void on_create(String command, Collection args) {
	}
}
