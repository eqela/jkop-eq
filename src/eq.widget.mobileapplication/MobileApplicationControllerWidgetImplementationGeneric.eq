
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

public class MobileApplicationControllerWidgetImplementationGeneric : LayerWidget,
	EventReceiver, MobileApplicationControllerWidgetImplementation
{
	class MyMenuWidget : LayerWidget
	{
		property Color background_color;
		property Color foreground_color;
		property Image menu_image;
		BoxWidget box;
		Collection items;

		void add_item_button(ActionItem item) {
			if(box != null) {
				var font = Theme.font();
				var pc = foreground_color;
				if(pc != null) {
					pc = pc.dup("50%");
				}
				box.add(FramelessButtonWidget.for_action_item(item).set_font(font).set_pressed_font(font).set_internal_margin("2mm")
					.set_pressed_color(pc));
			}
		}

		public void add_item(ActionItem item) {
			if(item == null) {
				return;
			}
			if(items == null) {
				items = LinkedList.create();
			}
			items.add(item);
			add_item_button(item);
		}

		public void initialize() {
			base.initialize();
			add(CanvasWidget.for_color(background_color));
			set_draw_color(foreground_color);
			box = BoxWidget.vertical();
			if(menu_image != null) {
				box.add(AlignWidget.instance().set_margin(px("3mm")).add(ImageWidget.for_image(menu_image).set_image_height(px("10mm"))));
			}
			bool first = true;
			var hh = px("250um");
			foreach(ActionItem item in items) {
				if(first == false) {
					box.add(CanvasWidget.for_color(foreground_color).set_height_request_override(hh));
				}
				add_item_button(item);
				first = false;
			}
			box.add_box(1, new Widget());
			add(VScrollerWidget.instance().add_scroller(box));
		}

		public void cleanup() {
			base.cleanup();
			box = null;
		}
	}

	class BurgerIconWidget : Widget
	{
		public void initialize() {
			base.initialize();
			set_size_request(px("5mm"), px("5mm"));
		}

		public Collection render() {
			var cc = get_draw_color();
			if(cc == null) {
				cc = Color.instance("black");
			}
			var v = LinkedList.create();
			var h = get_height()/5;
			var ss = RoundedRectangleShape.create(0, 0, get_width(), h, px("500um"));
			v.add(new FillColorOperation().set_color(cc).set_shape(ss).set_y(0));
			v.add(new FillColorOperation().set_color(cc).set_shape(ss).set_y(h+h));
			v.add(new FillColorOperation().set_color(cc).set_shape(ss).set_y(h+h+h+h));
			return(v);
		}
	}

	class ArrowLeftWidget : Widget
	{
		public void initialize() {
			base.initialize();
			set_size_request(px("5mm"), px("5mm"));
		}

		public Collection render() {
			var cc = get_draw_color();
			if(cc == null) {
				cc = Color.instance("black");
			}
			var w4 = get_width() / 4;
			var h4 = get_height() / 4;
			var v = LinkedList.create();
			var ss = CustomShape.create(3*w4, 3*h4).line(w4, 2*h4).line(3*w4, h4);
			v.add(new StrokeOperation().set_color(cc).set_shape(ss).set_width(px("1mm")));
			return(v);
		}
	}

	Color background_color;
	Image background_image;
	String background_image_mode;
	ChangerWidget background_color_container;
	ChangerWidget background_image_container;
	StackChangerWidget main_changer;
	MenuLayerWidget overlay_menu;
	ChangerWidget title_changer;
	LayerWidget title_layer;

	public MobileApplicationControllerWidgetImplementationGeneric() {
		background_image_mode = "fill";
	}

	public void initialize() {
		base.initialize();
		var maw = MobileApplicationControllerWidget.find(this);
		if(maw == null) {
			return;
		}
		set_background_color(maw.get_frame_background_color());
		set_draw_color(maw.get_frame_foreground_color());
		add(background_image_container = ChangerWidget.instance());
		background_image_container.add_changer(ImageWidget.for_image(background_image).set_mode(background_image_mode), true, ChangerWidget.EFFECT_NONE);
		add(background_color_container = ChangerWidget.instance());
		background_color_container.add_changer(CanvasWidget.for_color(background_color), true, ChangerWidget.EFFECT_NONE);
		var vbox = BoxWidget.vertical();
		title_layer = LayerWidget.instance();
		vbox.add(title_layer
			.add(CanvasWidget.for_color(maw.get_title_background_color()))
			.add(title_changer = ChangerWidget.instance())
			.set_height_request_override(px("8mm"))
		);
		vbox.add_box(1, main_changer = StackChangerWidget.instance());
		add(vbox);
	}

	Widget create_title_widget(MobileApplicationScreenWidget asw) {
		Image img;
		String ts;
		Collection mis;
		if(asw != null) {
			var tt = asw.get_mobile_app_title();
			img = tt as Image;
			ts = String.as_string(tt);
			mis = asw.get_mobile_app_menu_items();
		}
		if(ts == null && img == null) {
			return(null);
		}
		var v = BoxWidget.horizontal();
		var bb = true;
		var maw = MobileApplicationControllerWidget.find(this);
		if(maw != null) {
			bb = maw.get_enable_back_button();
		}
		// back button
		var left_button = (FramelessButtonWidget)FramelessButtonWidget.instance().set_icon_size("5mm")
			.set_internal_margin("1500um");
		v.add_box(0, left_button);
		left_button.set_custom_display_widget(new ArrowLeftWidget());
		left_button.set_event("previous");
		if(bb == false || main_changer == null || main_changer.get_changer_widget_count() < 2) {
			left_button.set_alpha(0.0);
			left_button.set_click_widget_disabled(true);
		}
		// title image
		if(img != null) {
			v.add_box(1, AlignWidget.instance().set_margin(px("1mm"))
				.add_align(0, 0, ImageWidget.for_image(img).set_image_height(px("4mm"))));
		}
		// title label
		else {
			if(String.is_empty(ts)) {
				ts = Application.get_display_name();
			}
			Font tf;
			if(maw != null) {
				tf = maw.get_title_font();
			}
			else {
				tf = Theme.font();
			}
			v.add_box(1, LayerWidget.instance().set_margin(px("1mm"))
				.add(LabelWidget.for_string(ts).set_font(tf)
				.set_text_align(LabelWidget.CENTER)));
		}
		// menu button
		var menu_button = (FramelessButtonWidget)FramelessButtonWidget.instance()
			.set_custom_display_widget(new BurgerIconWidget())
			.set_icon_size("5mm").set_internal_margin("1500um")
			.set_event("show_menu");
		menu_button.set_widget_id("show_menu_button");
		v.add_box(0, menu_button);
		if(Collection.is_empty(mis)) {
			menu_button.set_alpha(0.0);
			menu_button.set_click_widget_disabled(true);
		}
		return(v);
	}

	public void cleanup() {
		base.cleanup();
		background_image_container = null;
		background_color_container = null;
		main_changer = null;
		title_changer = null;
		title_layer = null;
		close_overlay_menu(false);
	}

	class OverlayCloser : AnimationListener
	{
		property MobileApplicationControllerWidgetImplementationGeneric widget;
		public void on_animation_listener_end(bool aborted) {
			widget.remove_overlay_menu();
		}
	}

	public void close_overlay_menu(bool animate) {
		if(overlay_menu == null) {
			return;
		}
		var aw = overlay_menu.get_aligned_widget();
		if(aw == null || animate == false) {
			remove_overlay_menu();
			return;
		}
		aw.set_align_x(2.0, 300000, new OverlayCloser().set_widget(this));
	}

	public void remove_overlay_menu() {
		if(overlay_menu != null) {
			var pp = overlay_menu.get_parent() as ContainerWidget;
			if(pp != null) {
				pp.remove(overlay_menu);
			}
			overlay_menu = null;
		}
	}

	public void set_foreground_color(Color c) {
		set_draw_color(c);
	}

	public bool go_back() {
		if(main_changer.count() > 1) {
			return(pop_widget());
		}
		var pp = get_parent() as Widget;
		if(pp != null) {
			return(pp.widget_stack_pop());
		}
		return(false);
	}

	public bool on_key_press(KeyEvent e) {
		if("escape".equals(e.get_name()) || "back".equals(e.get_name())) {
			if(go_back()) {
				return(true);
			}
		}
		return(base.on_key_press(e));
	}

	class PopupEventForwarder : EventReceiver
	{
		property Widget target;
		public void on_event(Object o) {
			if(target != null) {
				target.raise_event(o);
			}
		}
	}

	public virtual Widget create_overlay_menu_widget(Collection items) {
		var maw = MobileApplicationControllerWidget.find(this);
		if(maw == null) {
			return(null);
		}
		var v = new MyMenuWidget();
		v.set_background_color(maw.get_overlay_menu_background_color());
		v.set_foreground_color(maw.get_overlay_menu_foreground_color());
		foreach(ActionItem item in items) {
			v.add_item(item);
		}
		return(v);
	}

	class MenuLayerWidget : EventConsumerLayerWidget, EventReceiver
	{
		property MobileApplicationControllerWidgetImplementationGeneric widget;
		property Widget aligned_widget;

		public MenuLayerWidget() {
			set_consume_tab_key_events(false);
			add(new KillerLayerWidget());
		}

		class KillerLayerWidget : LayerWidget
		{
			public bool on_pointer_press(int x, int y, int button, int id) {
				var pp = get_parent() as MenuLayerWidget;
				if(pp != null) {
					pp.on_close_layer();
				}
				return(true);
			}
		}

		public void cleanup() {
			base.cleanup();
			aligned_widget = null;
		}

		public void on_close_layer() {
			if(widget != null) {
				widget.close_overlay_menu(true);
			}
		}

		public void on_event(Object o) {
			var ss = widget.get_current_screen_widget() as Widget;
			if(ss == null) {
				ss = widget;
			}
			ss.raise_event(o);
			on_close_layer();
		}

		public bool on_key_press(KeyEvent e) {
			if("back".equals(e.get_name()) || "escape".equals(e.get_name())) {
				on_close_layer();
				return(true);
			}
			return(base.on_key_press(e));
		}
	}

	Widget find_menu_button() {
		if(title_changer == null) {
			return(null);
		}
		var aw = title_changer.get_active_widget() as ContainerWidget;
		if(aw == null) {
			return(null);
		}
		foreach(Widget w in aw.iterate_children()) {
			if("show_menu_button".equals(w.get_widget_id())) {
				return(w);
			}
		}
		return(null);
	}

	void show_menu() {
		var screen = get_current_screen_widget();
		if(screen == null) {
			return;
		}
		var items = screen.get_mobile_app_menu_items();
		if(Collection.is_empty(items)) {
			return;
		}
		var maw = MobileApplicationControllerWidget.find(this);
		if(maw == null) {
			return;
		}
		var mtp = maw.get_menu_type_preference();
		if(mtp == MobileApplicationControllerWidget.MENU_DROPDOWN) {
			var menu = MenuWidget.for_action_items(items);
			menu.set_event_handler(new PopupEventForwarder().set_target(screen));
			Popup.execute(get_engine(), PopupSettings.instance().set_widget(menu).set_modal(false).set_master(find_menu_button())
				.set_focus(this).set_force_same_width(false));
		}
		else if(mtp == MobileApplicationControllerWidget.MENU_POPUP) {
			var menu = MenuWidget.for_action_items(items);
			menu.set_event_handler(new PopupEventForwarder().set_target(screen));
			Popup.execute(get_engine(), PopupSettings.instance().set_widget(menu).set_modal(false).set_focus(this));
		}
		else { // overlay
			close_overlay_menu(false);
			var ee = get_engine();
			if(ee == null) {
				return;
			}
			var root = ee.get_root_widget();
			if(root == null) {
				return;
			}
			var menu = create_overlay_menu_widget(items);
			if(menu != null) {
				var mm = ShadowContainerWidget.for_widget(menu);
				mm.set_shadow_right(false);
				mm.set_shadow_top(false);
				mm.set_shadow_bottom(false);
				var om = AlignWidget.instance();
				om.set_maximize_height(true);
				om.add_align(2.0, 0, mm);
				mm.set_align_x(1.0, 300000);
				var mlw = new MenuLayerWidget();
				mlw.set_widget(this);
				mlw.set_aligned_widget(mm);
				mlw.add(om);
				root.add(mlw);
				mlw.grab_focus();
				overlay_menu = mlw;
			}
		}
	}

	public void on_event(Object o) {
		if("previous".equals(o)) {
			go_back();
			return;
		}
		if("show_menu".equals(o)) {
			show_menu();
			return;
		}
		forward_event(o);
	}

	public MobileApplicationScreenWidget get_current_screen_widget() {
		if(main_changer == null) {
			return(null);
		}
		return(main_changer.get_active_widget() as MobileApplicationScreenWidget);
	}

	void on_widget_changed() {
		Collection toolbar_items;
		var asw = get_current_screen_widget();
		var tw = create_title_widget(asw);
		if(title_layer != null) {
			if(tw == null) {
				title_layer.set_enabled(false);
			}
			else {
				title_layer.set_enabled(true);
			}
		}
		if(title_changer != null) {
			title_changer.replace_with(tw, ChangerWidget.EFFECT_CROSSFADE);
		}
	}

	public void push_widget(Widget widget) {
		if(main_changer != null) {
			var ef = ChangerWidget.EFFECT_SCROLL_LEFT;
			if(main_changer.count() < 1) {
				ef = ChangerWidget.EFFECT_NONE;
			}
			main_changer.push_widget(widget, ef);
			on_widget_changed();
		}
	}

	public bool pop_widget() {
		var v = false;
		if(main_changer != null && main_changer.count() > 1) {
			v = main_changer.pop_widget(ChangerWidget.EFFECT_SCROLL_RIGHT);
			on_widget_changed();
		}
		return(v);
	}

	public void set_background_color(Color color) {
		background_color = color;
		if(background_color_container != null) {
			background_color_container.replace_with(CanvasWidget.for_color(color), ChangerWidget.EFFECT_CROSSFADE);
		}
	}

	public void set_background_image(Image image, String mode = null) {
		background_image = image;
		if(mode != null) {
			background_image_mode = mode;
		}
		if(background_image_container != null) {
			background_image_container.replace_with(ImageWidget.for_image(background_image).set_mode(background_image_mode), ChangerWidget.EFFECT_CROSSFADE);
		}
	}

	public StackChangerWidget get_main_changer() {
		return(main_changer);
	}
}
