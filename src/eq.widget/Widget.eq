
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

public class Widget : BackgroundTaskManager, AnimationTarget
{
	class AnimationProperties
	{
		public Animation scale_animation;
		public Animation spin_animation;
		public Animation weight_animation;
		public Animation align_animation;
		public Animation move_animation;
		public Animation alpha_animation;
		public double anim_scale;
		public double anim_rotation;
		public double anim_alpha;
		public double anim_width;
		public double anim_height;
		public double anim_x;
		public double anim_y;

		public void stop_all_inactive() {
			if(scale_animation != null && scale_animation.is_active() == false) {
				scale_animation.stop();
				scale_animation = null;
			}
			if(spin_animation != null && spin_animation.is_active() == false) {
				spin_animation.stop();
				spin_animation = null;
			}
			if(weight_animation != null && weight_animation.is_active() == false) {
				weight_animation.stop();
				weight_animation = null;
			}
			if(align_animation != null && align_animation.is_active() == false) {
				align_animation.stop();
				align_animation = null;
			}
			if(move_animation != null && move_animation.is_active() == false) {
				move_animation.stop();
				move_animation = null;
			}
			if(alpha_animation != null && alpha_animation.is_active() == false) {
				alpha_animation.stop();
				alpha_animation = null;
			}
		}
	}

	class ExtraProperties
	{
		public int width_request_override = -1;
		public int height_request_override = -1;
		public int minimum_width_request = -1;
		public int minimum_height_request = -1;
		public int maximum_width_request = -1;
		public int maximum_height_request = -1;
		public bool resize_dirty = false;
	}

	public static Widget instance() {
		return(new Widget());
	}

	public static bool initialize_disabled_widgets = true;
	property bool initialize_if_disabled = true;

	property DoubleValue xvalue;
	property DoubleValue yvalue;
	property DoubleValue widthvalue;
	property DoubleValue heightvalue;
	property DoubleValue alphavalue;
	property DoubleValue rotationvalue;
	property DoubleValue scalevalue;
	property DoubleValue weightvalue;
	property DoubleValue align_x_value;
	property DoubleValue align_y_value;
	property Frame frame;
	property Surface surface;

	AnimationProperties animation;
	ExtraProperties _extra;
	double alpha_multiplier = 1.0;
	Object parent = null;
	int width_request = 0;
	int height_request = 0;
	Cursor _pointer_cursor;
	Cursor previous_cursor = null;
	bool enabled = true;
	Object event_handler;
	bool _initialized = false;
	bool _initializing = false;
	bool _reinit_flag = false;
	bool _first_init = true;
	bool _is_started = false;
	bool _first_start = true;
	bool willrender = false;
	bool has_focus_f = false;
	String widget_id;

	public Widget() {
		xvalue = new DoubleValue().set_value(0);
		yvalue = new DoubleValue().set_value(0);
		widthvalue = new DoubleValue().set_value(0);
		heightvalue = new DoubleValue().set_value(0);
		alphavalue = new DoubleValue().set_value(1);
		rotationvalue = new DoubleValue().set_value(0);
		scalevalue = new DoubleValue().set_value(1);
	}

	~Widget() {
		set_surface_content(null);
	}

	ExtraProperties extra() {
		if(_extra == null) {
			_extra = new ExtraProperties();
		}
		return(_extra);
	}

	public virtual bool get_always_has_surface() {
		return(false);
	}

	public virtual bool is_surface_container() {
		return(false);
	}

	public virtual CreateFrameOptions get_frame_options() {
		return(null);
	}

	public String get_widget_id() {
		return(widget_id);
	}

	public Widget set_widget_id(String id) {
		widget_id = id;
		update_surface_widget_id();
		return(this);
	}

	public virtual int get_dpi() {
		var pp = get_parent() as Widget;
		if(pp != null) {
			return(pp.get_dpi());
		}
		var frame = get_frame();
		if(frame != null) {
			return(frame.get_dpi());
		}
		return(96);
	}

	public int px(String s, int def = 0) {
		if(String.is_empty(s)) {
			return(def);
		}
		return(Length.to_pixels(s, get_dpi()));
	}

	public double get_x() {
		return(xvalue.value);
	}

	public double get_y() {
		return(yvalue.value);
	}

	public double get_width() {
		return(widthvalue.value);
	}

	public double get_height() {
		return(heightvalue.value);
	}

	public double get_alpha() {
		return(alphavalue.value);
	}

	public double get_alpha_multiplier() {
		return(alpha_multiplier);
	}

	public double get_rotation() {
		return(rotationvalue.value);
	}

	public double get_scale() {
		return(scalevalue.value);
	}

	public virtual Surface create_surface() {
		return(null);
	}

	class SurfaceFocusListener : FocusableSurfaceListener
	{
		property Widget widget;
		public void on_surface_gain_focus() {
			widget.grab_focus();
		}
		public void on_surface_lose_focus() {
		}
	}

	public virtual void configure_focusable_surface(FocusableSurface surface) {
		surface.set_focusable(is_focusable());
		surface.set_focusable_surface_listener(new SurfaceFocusListener().set_widget(this));
	}

	public virtual Surface create_add_surface() {
		var opts = find_surface_below_me();
		if(is_surface_container()) {
			opts.set_surface_type(SurfaceOptions.SURFACE_TYPE_CONTAINER);
		}
		opts.set_surface(create_surface());
		if(frame == null) {
			Log.error("create_add_surface: No frame");
			return(null);
		}
		var v = frame.add_surface(opts);
		if(v == null) {
			Log.error("Failed to create a surface");
		}
		else {
			if(v is FocusableSurface) {
				configure_focusable_surface((FocusableSurface)v);
			}
		}
		return(v);
	}

	public virtual bool remove_surface() {
		if(surface != null && frame != null) {
			frame.remove_surface(surface);
			surface = null;
			return(true);
		}
		return(false);
	}

	public void update_surface_widget_id() {
		var ss = surface as SurfaceWithId;
		if(ss == null) {
			return;
		}
		ss.set_surface_id(widget_id);
	}

	public virtual void on_surface_created(Surface surface) {
		update_surface_widget_id();
	}

	public virtual void on_surface_removed() {
	}

	public bool set_surface_content(Collection ops) {
		if(ops == null) {
			if(remove_surface()) {
				on_surface_removed();
			}
			return(true);
		}
		if(surface == null) {
			surface = create_add_surface();
			if(surface != null) {
				surface.set_alpha(alpha_multiplier * alphavalue.value);
				surface.move_resize(xvalue.value, yvalue.value, widthvalue.value, heightvalue.value);
				surface.set_rotation_angle(get_rotation());
				surface.set_scale(get_scale(), get_scale());
				on_surface_created(surface);
			}
		}
		if(surface != null && surface is Renderable) {
			((Renderable)surface).render(ops);
			return(true);
		}
		return(false);
	}

	public Position get_position() {
		return(Position.instance(xvalue.value, yvalue.value));
	}

	public Size get_size() {
		return(Size.instance(widthvalue.value, heightvalue.value));
	}

	public Rectangle get_rectangle() {
		return(Rectangle.instance(xvalue.value,yvalue.value,widthvalue.value,heightvalue.value));
	}

	public bool start_animation(Animation anim) {
		anim.set_active();
		TimerAnimation.start(anim);
		return(true);
	}

	public void move(double x, double y, int duration = 0, AnimationListener listener = null) {
		if(animation != null && animation.move_animation != null) {
			animation.move_animation.stop();
			animation.move_animation = null;
		}
		var oxv = xvalue.value;
		var oyv = yvalue.value;
		if(x == oxv && y == oyv) {
			return;
		}
		if(duration < 1) {
			var prevx = xvalue.get_value();
			var prevy = yvalue.get_value();
			xvalue.set_value(x);
			yvalue.set_value(y);
			if(surface != null) {
				surface.move(x, y);
			}
			on_move_diff(x-prevx, y-prevy);
			on_move();
			if(listener != null) {
				listener.on_animation_listener_end(false);
			}
			return;
		}
		if(animation == null) {
			animation = new AnimationProperties();
		}
		if(start_animation(animation.move_animation = new Animation()
			.set_duration(duration)
			.add_item(LinearAnimationItem.for_double(get_xvalue(), x))
			.add_item(LinearAnimationItem.for_double(get_yvalue(), y))
			.add_target(this).add_listener(listener)) == false) {
				move(x, y, 0);
		}
	}

	public virtual void on_move() {
	}

	public virtual void on_move_diff(double diffx, double diffy) {
	}

	public void set_resize_dirty(bool v) {
		extra().resize_dirty = v;
	}

	// FIXME: This should be animateable also
	public virtual void resize(double aw, double ah, int duration = 0, AnimationListener listener = null) {
		var w = aw;
		var h = ah;
		if(is_enabled() == false && (w > 0 || h > 0)) {
			return;
		}
		if(w < 0) {
			w = 0;
		}
		if(h < 0) {
			h = 0;
		}
		if(_extra != null && _extra.resize_dirty) {
			_extra.resize_dirty = false;
		}
		else if(w == widthvalue.value && h == heightvalue.value) {
			return;
		}
		widthvalue.set_value(w);
		heightvalue.set_value(h);
		on_resize();
	}

	public virtual void move_resize(double px, double py, double w, double h, int duration = 0, AnimationListener listener = null) {
		resize(w, h, duration, listener);
		move(px, py, duration);
	}

	public virtual void on_scale_change() {
		if(surface != null) {
			surface.set_scale(get_scale(), get_scale());
		}
	}

	public void scale(double da) {
		scalevalue.set_value(get_scale() + da);
		on_scale_change();
	}

	public void set_scale(double a, int duration = 0, AnimationListener listener = null) {
		if(animation != null && animation.scale_animation != null) {
			animation.scale_animation.stop();
			animation.scale_animation = null;
		}
		var dr = duration;
		if(dr > 0 && CapabilityFrame.check(get_frame(), "scale-surface") == false) {
			dr = 0;
		}
		if(dr < 1) {
			scalevalue.set_value(a);
			on_scale_change();
			if(listener != null) {
				listener.on_animation_listener_end(false);
			}
			return;
		}
		if(animation == null) {
			animation = new AnimationProperties();
		}
		if(start_animation(animation.scale_animation = new Animation()
			.set_duration(dr)
			.add_item(LinearAnimationItem.for_double(get_scalevalue(), a))
			.add_target(this).add_listener(listener)) == false) {
			set_scale(a, 0);
		}
	}

	public virtual void on_rotate() {
		if(surface != null) {
			surface.set_rotation_angle(get_rotation());
		}
	}

	public void rotate(double da) {
		rotationvalue.set_value(get_rotation() + da);
		on_rotate();
	}

	public void set_rotation(double da, int duration = 0, AnimationListener listener = null) {
		spin_stop();
		if(duration < 1) {
			rotationvalue.set_value(da);
			on_rotate();
			if(listener != null) {
				listener.on_animation_listener_end(false);
			}
			return;
		}
		if(animation == null) {
			animation = new AnimationProperties();
		}
		if(start_animation(animation.spin_animation = new Animation()
			.set_duration(duration)
			.add_item(LinearAnimationItem.for_double(get_rotationvalue(), da))
			.add_target(this).add_listener(listener)) == false) {
			set_rotation(da, 0);
		}
	}

	public void spin_start(int speed = 500000) {
		spin_stop();
		if(animation == null) {
			animation = new AnimationProperties();
		}
		if(start_animation(animation.spin_animation = new Animation()
			.set_duration(speed)
			.add_item(LinearAnimationItem.for_double(get_rotationvalue(), get_rotation() + MathConstant.M_PI * 2))
			.add_target(this)
			.set_repeat_infinitely(true)) == false) {
			; // Failed; nothing we can do about that ..
		}
	}

	public void spin_stop() {
		if(animation != null && animation.spin_animation != null) {
			animation.spin_animation.stop();
			animation.spin_animation = null;
		}
	}

	public virtual void on_alpha_change() {
		if(surface != null) {
			surface.set_alpha(alpha_multiplier * get_alpha());
		}
	}

	public void set_alpha(double a, int duration = 0, AnimationListener listener = null) {
		if(animation != null && animation.alpha_animation != null) {
			animation.alpha_animation.stop();
			animation.alpha_animation = null;
		}
		var dr = duration;
		if(dr > 0 && CapabilityFrame.check(get_frame(), "alpha") == false) {
			dr = 0;
		}
		if(dr < 1) {
			alphavalue.set_value(a);
			on_alpha_change();
			if(listener != null) {
				listener.on_animation_listener_end(false);
			}
			return;
		}
		if(animation == null) {
			animation = new AnimationProperties();
		}
		if(start_animation(animation.alpha_animation = new Animation()
			.set_duration(dr)
			.add_item(LinearAnimationItem.for_double(get_alphavalue(), a))
			.add_target(this).add_listener(listener)) == false) {
			set_alpha(a, 0);
		}
	}

	public void set_alpha_multiplier(double v) {
		alpha_multiplier = v;
		on_alpha_change();
	}

	public void on_animation_start() {
		if(animation == null) {
			return;
		}
		animation.anim_scale = get_scale();
		animation.anim_rotation = get_rotation();
		animation.anim_alpha = get_alpha();
		animation.anim_width = get_width();
		animation.anim_height = get_height();
		animation.anim_x = get_x();
		animation.anim_y = get_y();
	}

	public void on_animation_update() {
		if(animation == null) {
			return;
		}
		if(get_scale() != animation.anim_scale) {
			animation.anim_scale = get_scale();
			on_scale_change();
		}
		if(get_rotation() != animation.anim_rotation) {
			animation.anim_rotation = get_rotation();
			on_rotate();
		}
		if(get_alpha() != animation.anim_alpha) {
			animation.anim_alpha = get_alpha();
			on_alpha_change();
		}
		if(get_width() != animation.anim_width || get_height() != animation.anim_height) {
			animation.anim_width = get_width();
			animation.anim_height = get_height();
			on_resize();
		}
		if(get_x() != animation.anim_x || get_y() != animation.anim_y) {
			var prevx = animation.anim_x;
			var prevy = animation.anim_y;
			animation.anim_x = get_x();
			animation.anim_y = get_y();
			if(surface != null) {
				surface.move(animation.anim_x, animation.anim_y);
			}
			on_move_diff(animation.anim_x-prevx, animation.anim_y-prevy);
			on_move();
		}
	}

	public void on_animation_end() {
		if(animation != null) {
			animation.stop_all_inactive();
			animation = null;
		}
	}

	public double get_weight() {
		if(is_enabled() == false) {
			return(0.0);
		}
		if(weightvalue == null) {
			return(0.0);
		}
		return(weightvalue.value);
	}

	public double get_align_x() {
		if(align_x_value == null) {
			return(0.0);
		}
		return(align_x_value.value);
	}

	public double get_align_y() {
		if(align_y_value == null) {
			return(0.0);
		}
		return(align_y_value.value);
	}

	public void set_weight(double w, int duration = 0, AnimationListener listener = null) {
		if(animation != null && animation.weight_animation != null) {
			animation.weight_animation.stop();
			animation.weight_animation = null;
		}
		if(weightvalue == null) {
			weightvalue = new DoubleValue();
		}
		if(duration < 1) {
			weightvalue.set_value(w);
			var cp = get_parent() as ContainerWidget;
			if(cp != null) {
				cp.on_animation_update();
			}
			if(listener != null) {
				listener.on_animation_listener_end(false);
			}
			return;
		}
		var cp = get_parent() as ContainerWidget;
		if(cp == null) {
			return;
		}
		if(animation == null) {
			animation = new AnimationProperties();
		}
		start_animation(animation.weight_animation = new Animation()
			.set_duration(duration)
			.add_item(LinearAnimationItem.for_double(get_weightvalue(), w))
			.add_target(cp).add_listener(listener)
		);
	}

	public void set_align_x(double w, int duration = 0, AnimationListener listener = null) {
		set_align(w, get_align_y(), duration, listener);
	}

	public void set_align_y(double w, int duration = 0, AnimationListener listener = null) {
		set_align(get_align_x(), w, duration, listener);
	}

	public void set_align(double x, double y, int duration = 0, AnimationListener listener = null) {
		if(animation != null && animation.align_animation != null) {
			animation.align_animation.stop();
			animation.align_animation = null;
		}
		if(align_x_value == null) {
			align_x_value = new DoubleValue();
		}
		if(align_y_value == null) {
			align_y_value = new DoubleValue();
		}
		if(duration < 1) {
			align_x_value.set_value(x);
			align_y_value.set_value(y);
			var cp = get_parent() as ContainerWidget;
			if(cp != null) {
				cp.on_animation_update();
			}
			if(listener != null) {
				listener.on_animation_listener_end(false);
			}
			return;
		}
		var cp = get_parent() as ContainerWidget;
		if(cp == null) {
			return;
		}
		if(animation == null) {
			animation = new AnimationProperties();
		}
		start_animation(animation.align_animation = new Animation()
			.set_duration(duration)
			.add_item(LinearAnimationItem.for_double(get_align_x_value(), x))
			.add_item(LinearAnimationItem.for_double(get_align_y_value(), y))
			.add_target(cp).add_listener(listener)
		);
	}

	// FIXME: We would hope to make this faster (like not having to look for the current widget in the lists ...)
	Surface find_last_surface(ContainerWidget pp) {
		if(pp == null) {
			return(null);
		}
		foreach(Widget sw in pp.iterate_children_reverse()) {
			if(sw is ContainerWidget && sw is ClipperWidget == false) {
				var ss = find_last_surface((ContainerWidget)sw);
				if(ss != null) {
					return(ss);
				}
			}
			var ss = sw.get_surface();
			if(ss != null) {
				return(ss);
			}
		}
		return(null);
	}

	SurfaceOptions find_surface_below_me() {
		var wts = this;
		var pp = get_parent() as Widget;
		while(pp != null) {
			if(pp is ContainerWidget) {
				bool f = false;
				foreach(Widget sw in ((ContainerWidget)pp).iterate_children_reverse()) {
					if(f) {
						if(sw is ContainerWidget && sw is ClipperWidget == false) {
							var ss = find_last_surface((ContainerWidget)sw);
							if(ss != null) {
								return(SurfaceOptions.above(ss));
							}
						}
						var ss = sw.get_surface();
						if(ss != null) {
							return(SurfaceOptions.above(ss));
						}
					}
					else if(sw == wts) {
						f = true;
					}
				}
			}
			var ss = pp.get_surface();
			if(ss != null) {
				if(pp is ClipperWidget) {
					return(SurfaceOptions.inside(ss));
				}
				else {
					return(SurfaceOptions.above(ss));
				}
			}
			wts = pp;
			pp = pp.get_parent() as Widget;
		}
		return(SurfaceOptions.bottom());
	}

	public Object get_event_handler() {
		return(event_handler);
	}

	public Widget set_event_handler(Object er) {
		event_handler = er;
		return(this);
	}

	public virtual bool is_focusable() {
		return(false);
	}

	public virtual Widget set_enabled(bool v) {
		if(enabled == v) {
			return(this);
		}
		enabled = v;
		if(enabled) {
			if(is_initialized() == false) {
				if(parent != null && parent is WidgetEngine) {
					execute_initialize();
				}
				else if(parent != null && parent is Widget && ((Widget)parent).is_initialized()) {
					execute_initialize();
				}
			}
			if(parent != null && parent is WidgetEngine && ((WidgetEngine)parent).is_started()) {
				if(is_started() == false) {
					start();
				}
			}
			else if(parent != null && parent is Widget && ((Widget)parent).is_started()) {
				if(is_started() == false) {
					if(parent is ContainerWidget == false || ((ContainerWidget)parent).get_auto_start_children()) {
						start();
					}
				}
			}
			on_view_enabled();
		}
		else {
			release_focus();
			if(is_started()) {
				stop();
			}
			resize(0, 0);
		}
		on_new_size_request();
		return(this);
	}

	public bool is_enabled() {
		return(enabled);
	}

	public bool is_initialized() {
		return(_initialized);
	}

	public bool is_initializing() {
		return(_initializing);
	}

	public void set_parent(Object parent) {
		var wparent = parent as Widget;
		var was_initialized = is_initialized();
		var was_started = is_started();
		bool will_be_initialized = false;
		bool will_be_started = false;
		if(parent != null && parent is Widget && ((Widget)parent).is_initialized()) {
			will_be_initialized = true;
		}
		else if(parent != null && parent is WidgetEngine) {
			will_be_initialized = true;
		}
		if(parent != null && parent is Widget && ((Widget)parent).is_started()) {
			if(parent is ContainerWidget == false || ((ContainerWidget)parent).get_auto_start_children()) {
				will_be_started = true;
			}
		}
		else if(parent != null && parent is WidgetEngine && ((WidgetEngine)parent).is_started()) {
			will_be_started = true;
		}
		if(is_enabled() == false) {
			will_be_started = false;
			if(will_be_initialized) {
				will_be_initialized = Widget.initialize_disabled_widgets && initialize_if_disabled;
			}
		}
		if(was_started && will_be_started == false) {
			stop();
		}
		if(was_initialized && will_be_initialized == false) {
			cleanup();
		}
		this.parent = parent;
		if(parent != null) {
			if(will_be_initialized) {
				if(was_initialized == false) {
					execute_initialize();
				}
			}
			if(will_be_started) {
				if(was_started == false) {
					start();
				}
			}
		}
	}

	public virtual Widget get_default_focus_widget() {
		return(null);
	}

	public virtual void grab_focus() {
		var e = get_engine();
		if(e != null) {
			e.set_focus_widget(this);
		}
	}

	public virtual Color get_draw_color() {
		var p = this;
		while(true) {
			if(p == null) {
				break;
			}
			if(p is ContainerWidget) {
				var v = ((ContainerWidget)p).get_configured_draw_color();
				if(v != null) {
					return(v);
				}
			}
			p = p.get_parent() as Widget;
		}
		return(Color.black());
	}

	public WidgetEngine get_engine() {
		var p = get_parent();
		while(true) {
			if(p == null) {
				break;
			}
			else if(p is Widget) {
				p = ((Widget)p).get_parent();
			}
			else if(p is WidgetEngine) {
				return((WidgetEngine)p);
			}
		}
		return(null);
	}

	class CloseFrameTimer : TimerHandler {
		property WidgetEngine engine;
		public bool on_timer(Object arg) {
			engine.close_frame();
			return(false);
		}
	}

	public bool close_frame() {
		var eng = get_engine();
		if(eng != null) {
			start_timer(0, new CloseFrameTimer().set_engine(eng), null);
			return(true);
		}
		return(false);
	}

	public void set_frame_title(String title, bool recall = true) {
		Object p = this;
		if(recall == false) {
			p = get_parent();
		}
		while(p != null) {
			if(p is TitledFrame) {
				((TitledFrame)p).set_title(title);
				break;
			}
			else if(p is Widget) {
				p = ((Widget)p).get_parent();
			}
			else if(p is WidgetEngine) {
				((WidgetEngine)p).set_frame_title(title);
				break;
			}
			else {
				break;
			}
		}
	}

	public void set_frame_icon(Image icon, bool recall = true) {
		Object p = this;
		if(recall == false) {
			p = get_parent();
		}
		while(p != null) {
			if(p is TitledFrame) {
				((TitledFrame)p).set_icon(icon);
				break;
			}
			else if(p is Widget) {
				p = ((Widget)p).get_parent();
			}
			else if(p is WidgetEngine) {
				((WidgetEngine)p).set_frame_icon(icon);
				break;
			}
			else {
				break;
			}
		}
	}

	public Position get_absolute_position(int ax = 0, int ay = 0) {
		int x = get_x() + ax;
		int y = get_y() + ay;
		var p = get_parent() as Widget;
		while(p != null) {
			if(p is ClipperWidget) {
				x += p.get_x();
				y += p.get_y();
			}
			p = p.get_parent() as Widget;
		}
		return(Position.instance(x, y));
	}

	public Object get_parent() {
		return(parent);
	}

	public Widget set_width_request(int px) {
		set_size_request(px, -1);
		return(this);
	}

	public Widget set_height_request(int px) {
		set_size_request(-1, px);
		return(this);
	}

	public Widget set_minimum_width_request(int wr) {
		var owr = get_width_request();
		extra().minimum_width_request = wr;
		if(get_width_request() != owr) {
			on_new_size_request();
		}
		return(this);
	}

	public Widget set_minimum_height_request(int wr) {
		var owr = get_width_request();
		extra().minimum_height_request = wr;
		if(get_width_request() != owr) {
			on_new_size_request();
		}
		return(this);
	}

	public Widget set_maximum_width_request(int wr) {
		var owr = get_width_request();
		extra().maximum_width_request = wr;
		if(get_width_request() != owr) {
			on_new_size_request();
		}
		return(this);
	}

	public Widget set_maximum_height_request(int wr) {
		var owr = get_width_request();
		extra().maximum_height_request = wr;
		if(get_width_request() != owr) {
			on_new_size_request();
		}
		return(this);
	}

	public Widget set_width_request_override(int wr) {
		bool change = false;
		var xtr = extra();
		if(xtr.width_request_override != wr) {
			change = true;
		}
		xtr.width_request_override = wr;
		if(change) {
			on_new_size_request();
		}
		return(this);
	}

	public Widget set_height_request_override(int hr) {
		bool change = false;
		var xtr = extra();
		if(xtr.height_request_override != hr) {
			change = true;
		}
		xtr.height_request_override = hr;
		if(change) {
			on_new_size_request();
		}
		return(this);
	}

	public Widget set_size_request_override(int wr, int hr) {
		bool change = false;
		var xtr = extra();
		if(xtr.height_request_override != hr || xtr.width_request_override != wr) {
			change = true;
		}
		xtr.height_request_override = hr;
		xtr.width_request_override = wr;
		if(change) {
			on_new_size_request();
		}
		return(this);
	}

	public Widget set_size_request(int wr, int hr) {
		bool change = false;
		if(wr >= 0) {
			if(width_request != wr) {
				change = true;
			}
			width_request = wr;
		}
		if(hr >= 0) {
			if(height_request != hr) {
				change = true;
			}
			height_request = hr;
		}
		if(change) {
			on_new_size_request();
		}
		return(this);
	}

	public virtual void on_new_size_request() {
		if(parent is WidgetEngine) {
			((WidgetEngine)parent).on_new_child_size_params(this);
		}
		else if(parent is ContainerWidget) {
			((ContainerWidget)parent).on_new_child_size_params(this);
		}
	}

	public Widget set_cursor(Cursor _pointer_cursor) {
		this._pointer_cursor = _pointer_cursor;
		return(this);
	}

	public Cursor get_cursor() {
		return(_pointer_cursor);
	}

	public int get_width_request() {
		if(is_enabled() == false) {
			return(0);
		}
		var v = width_request;
		if(_extra != null) {
			if(_extra.width_request_override >= 0) {
				v = _extra.width_request_override;
			}
			if(v < _extra.minimum_width_request) {
				v = _extra.minimum_width_request;
			}
			else if(_extra.maximum_width_request > 0 && v > _extra.maximum_width_request) {
				v = _extra.maximum_width_request;
			}
		}
		return(v);
	}

	public int get_height_request() {
		if(is_enabled() == false) {
			return(0);
		}
		var v = height_request;
		if(_extra != null) {
			if(_extra.height_request_override >= 0) {
				v = _extra.height_request_override;
			}
			if(v < _extra.minimum_height_request) {
				v = _extra.minimum_height_request;
			}
			else if(_extra.maximum_height_request > 0 && v > _extra.maximum_height_request) {
				v = _extra.maximum_height_request;
			}
		}
		return(v);
	}

	public virtual void on_available_size(int w, int h) {
	}

	public BackgroundTask start_task(RunnableTask task, EventReceiver listener, BackgroundTaskListener tasklistener = null) {
		var el = GUI.engine.get_background_task_manager();
		if(el == null) {
			return(null);
		}
		return(el.start_task(task, listener, tasklistener));
	}

	public BackgroundTask start_timer(int usec, TimerHandler handler, Object arg) {
		var el = GUI.engine.get_background_task_manager();
		if(el == null) {
			return(null);
		}
		return(Timer.start(el, usec, handler, arg));
	}

	class DelayTimerHandler : TimerHandler {
		property Widget widget;
		public bool on_timer(Object arg) {
			bool v = false;
			if(widget != null) {
				widget.on_delay_timer(arg);
			}
			return(false);
		}
	}

	public BackgroundTask start_delay_timer(int usec, Object arg = null) {
		return(start_timer(usec, new DelayTimerHandler().set_widget(this), arg));
	}

	public virtual void on_delay_timer(Object arg) {
	}

	class RepeatTimerHandler : TimerHandler {
		property Widget widget;
		public bool on_timer(Object arg) {
			if(widget == null) {
				return(false);
			}
			return(widget.on_repeat_timer(arg));
		}
	}

	public BackgroundTask start_repeat_timer(int usec, Object arg = null) {
		return(start_timer(usec, new RepeatTimerHandler().set_widget(this), arg));
	}

	public virtual bool on_repeat_timer(Object arg) {
		return(false);
	}

	public virtual void on_initialized() {
	}

	public void execute_initialize() {
		_reinit_flag = false;
		_initializing = true;
		initialize();
		_initializing = false;
		if(_reinit_flag) {
			reinitialize();
		}
		on_initialized();
	}

	public virtual void configure() {
	}

	public virtual void on_widget_initialized() {
		if(get_always_has_surface()) {
			set_surface_content(render());
		}
	}

	public virtual void initialize() {
		var wep = get_parent() as WidgetEngine;
		if(wep != null) {
			set_frame(wep.get_frame());
		}
		else {
			var wp = get_parent() as Widget;
			if(wp != null) {
				set_frame(wp.get_frame());
			}
		}
		if(_first_init) {
			configure();
			_first_init = false;
		}
		_initialized = true;
		on_widget_initialized();
	}

	public virtual void release_focus() {
		if(has_focus_f) {
			var e = get_engine();
			if(e != null) {
				e.set_focus_widget(null, true);
			}
		}
	}

	public virtual void cleanup() {
		if(has_focus()) {
			var e = get_engine();
			if(e != null) {
				e.set_focus_widget(null, true);
			}
		}
		set_surface_content(null);
		_initialized = false;
		set_frame(null);
		animation = null;
	}

	public void reinitialize() {
		if(_initializing) {
			_reinit_flag = true;
			return;
		}
		bool fs = is_started();
		bool fi = is_initialized();
		if(fs) {
			stop();
		}
		if(fi) {
			Widget fw;
			var e = get_engine();
			if(e != null) {
				fw = e.get_focus_widget();
			}
			cleanup();
			execute_initialize();
			if(e != null && fw != null && fw.is_initialized() && fw.has_focus() == false && e.get_focus_widget() == null) {
				e.set_focus_widget(fw);
			}
		}
		if(fs) {
			if(is_started() == false) {
				start();
			}
		}
		if(fi) {
			on_resize();
		}
	}

	public virtual void first_start() {
	}

	public virtual void start() {
		_is_started = true;
		if(_first_start == true) {
			_first_start = false;
			first_start();
		}
	}

	public virtual void stop() {
		spin_stop();
		_is_started = false;
	}

	public bool is_started() {
		return(_is_started);
	}

	public void scroll_to_widget() {
		var p = get_parent() as Widget;
		while(p != null) {
			if(p is ScrollableWidget) {
				((ScrollableWidget)p).scroll_to(get_x(), get_y(), get_width(), get_height());
				break;
			}
			p = p.get_parent() as Widget;
		}
	}

	public virtual Collection render() {
		if(get_always_has_surface()) {
			return(LinkedList.create());
		}
		return(null);
	}

	class RenderTimer : TimerHandler {
		property Widget widget;
		public bool on_timer(Object arg) {
			if(widget != null) {
				widget.do_update_view();
			}
			return(false);
		}
	}

	public virtual void on_view_enabled() {
	}

	public virtual void on_view_disabled() {
		if(get_always_has_surface() == false) {
			set_surface_content(null);
		}
	}

	bool widget_shown = true;

	public Widget set_widget_shown(bool r, bool force = false) {
		if(r == widget_shown) {
			return(this);
		}
		widget_shown = r;
		if(force == false) {
			if(r) {
				on_widget_shown();
			}
			else {
				on_widget_hidden();
			}
		}
		return(this);
	}

	public bool get_widget_shown() {
		return(widget_shown);
	}

	public virtual void on_widget_shown() {
		set_render_content();
	}

	public virtual void on_widget_hidden() {
		set_surface_content(null);
	}

	public virtual void set_render_content() {
		if(widget_shown == false) {
			return;
		}
		set_surface_content(render());
	}

	public virtual void do_update_view() {
		willrender = false;
		if(get_width() < 1 || get_height() < 1 || is_enabled() == false || is_initialized() == false) {
			on_view_disabled();
			return;
		}
		set_render_content();
	}

	public void update_view() {
		if(willrender == false) {
			start_timer(0, new RenderTimer().set_widget(this), null);
			willrender = true;
		}
	}

	public virtual void on_resize() {
		int w = get_width();
		int h = get_height();
		if(w < 1 || h < 1 || is_enabled() == false || is_initialized() == false) {
			on_view_disabled();
		}
		else {
			if(surface != null) {
				surface.resize(w,h);
			}
			set_render_content();
		}
	}

	public virtual Widget get_hover_widget(int x, int y) {
		return(this);
	}

	public virtual void on_pointer_enter(int id) {
		if(_pointer_cursor != null && previous_cursor == null) {
			var cw = get_frame() as CursorFrame;
			if(cw != null) {
				previous_cursor = cw.get_current_cursor();
				cw.set_current_cursor(_pointer_cursor);
			}
		}
	}

	public virtual void on_pointer_leave(int id) {
		var cw = get_frame() as CursorFrame;
		if(cw != null) {
			cw.set_current_cursor(previous_cursor);
		}
		previous_cursor = null;
	}

	public virtual void on_pointer_leave_frame(int id) {
		on_pointer_leave(id);
	}

	public Position get_pointer_event_position(int x, int y) {
		return(Position.instance(x - get_x(), y - get_y()));
	}

	public virtual bool on_pointer_press(int x, int y, int button, int id) {
		return(false);
	}

	public virtual bool on_pointer_release(int x, int y, int button, int id) {
		return(false);
	}

	public virtual bool on_pointer_move(int x, int y, int id) {
		return(false);
	}

	public virtual bool on_pointer_cancel(int x, int y, int button, int id) {
		return(false);
	}

	public virtual bool on_pointer_drag(int x, int y, int dx, int dy, int button, bool drop, int id) {
		return(false);
	}

	public virtual bool on_context(int x, int y) {
		return(false);
	}

	public virtual bool on_context_drag(int x, int y, int dx, int dy, bool drop, int id) {
		return(false);
	}

	public virtual bool on_scroll(int x, int y, int dx, int dy) {
		return(false);
	}

	public virtual bool on_zoom(int x, int y, int dz) {
		return(false);
	}

	public virtual bool on_key_press(KeyEvent e) {
		return(false);
	}

	public virtual bool on_key_release(KeyEvent e) {
		return(false);
	}

	public virtual bool on_key_event(KeyEvent e) {
		if(e is KeyPressEvent) {
			return(on_key_press(e));
		}
		if(e is KeyReleaseEvent) {
			return(on_key_release(e));
		}
		return(false);
	}

	public virtual void on_update_focus() {
		if(has_focus() == false) {
			return;
		}
		scroll_to_widget();
	}

	public virtual void on_gain_focus() {
		if(has_focus()) {
			return;
		}
		if(surface != null && surface is FocusableSurface) {
			((FocusableSurface)surface).grab_focus();
		}
		has_focus_f = true;
		var ff = FocusFrameWidget.find(this);
		if(ff != null) {
			ff.update_focus_state(true);
			ff.scroll_to_widget();
		}
		else {
			scroll_to_widget();
		}
	}

	public virtual void on_lose_focus() {
		if(has_focus() == false) {
			return;
		}
		if(surface != null && surface is FocusableSurface) {
			((FocusableSurface)surface).release_focus();
		}
		has_focus_f = false;
		var ff = FocusFrameWidget.find(this);
		if(ff != null) {
			ff.update_focus_state(false);
		}
	}

	public bool has_focus() {
		return(has_focus_f);
	}

	public void forward_event(Object ee) {
		raise_event(ee, false);
	}

	public void raise_event(Object oo, bool include_self = true) {
		var o = oo;
		if(event_handler != null) {
			if(event_handler is EventReceiver) {
				((EventReceiver)event_handler).on_event(o);
			}
			else if(event_handler is Widget && event_handler != this) {
				((Widget)event_handler).raise_event(o);
			}
		}
		else {
			var p = this as Widget;
			if(include_self == false) {
				p = get_parent() as Widget;
			}
			while(p != null) {
				if(p is EventReceiver) {
					((EventReceiver)p).on_event(o);
					break;
				}
				var eh = p.get_event_handler();
				if(eh != null) {
					if(eh is EventReceiver) {
						((EventReceiver)eh).on_event(o);
						break;
					}
					else if(eh is Widget && eh != this) {
						((Widget)eh).raise_event(o);
						break;
					}
				}
				p = p.get_parent() as Widget;
			}
		}
	}

	public virtual void dismiss_widget() {
		var pp = get_parent() as ContainerWidget;
		if(pp != null) {
			pp.remove(this);
		}
	}

	public virtual void set_args(Collection args) {
	}

	public WidgetStack widget_stack_find() {
		var rr = this;
		while(rr != null) {
			if(rr is WidgetStack) {
				return((WidgetStack)rr);
			}
			rr = rr.get_parent() as Widget;
		}
		return(null);
	}

	public void widget_stack_push(Widget widget) {
		var ws = widget_stack_find();
		if(ws != null) {
			ws.push_widget(widget);
		}
	}

	public bool widget_stack_pop() {
		var ws = widget_stack_find();
		if(ws == null) {
			return(false);
		}
		return(ws.pop_widget());
	}
}
