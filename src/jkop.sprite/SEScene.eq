
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

public class SEScene : FrameController, Scene, TransferrableScene, SEElementContainer, SEMessageListener
{
	Frame frame;
	SceneController scene_controller;
	LinkedList pointers;
	HashTable keys_pressed;
	TimeVal last_tick;
	LinkedList entities;
	FrameController next_scene;
	int next_scene_action;
	bool do_switch_scene = false;
	bool stop_request = false;
	bool is_initialized = false;
	LinkedList pointer_listeners;
	SEResourceCache resource_cache;
	property SEBackend backend;
	bool started = false;
	SceneEndListener scene_end_listener;
	SESprite background_sprite;
	property bool debug = false;
	property bool do_cleanup_backend = true;
	property bool accept_volume_keys = false;
	property bool handle_escape_back = true;

	public SEScene() {
		entities = LinkedList.create();
		pointers = LinkedList.create();
		keys_pressed = HashTable.create();
		pointer_listeners = LinkedList.create();
		IFDEF("target_html") {
			handle_escape_back = false;
		}
	}

	public bool transfer_from(Scene scene) {
		var ss = scene as SEScene;
		if(ss == null) {
			return(false);
		}
		var be = ss.get_backend();
		if(be == null) {
			return(false);
		}
		set_backend(be);
		ss.set_do_cleanup_backend(false);
		be.on_scene_changed();
		return(true);
	}

	public void on_message(Object o) {
	}

	public Iterator iterate_entities() {
		if(entities == null) {
			return(null);
		}
		return(entities.iterate());
	}

	public Collection get_entities() {
		return(entities);
	}

	public Frame get_frame() {
		return(frame);
	}

	public int get_frame_type() {
		var f = get_frame();
		if(f == null) {
			return(Frame.TYPE_TABLET);
		}
		return(f.get_frame_type());
	}

	public bool has_keyboard() {
		var f = get_frame();
		if(f == null) {
			return(false);
		}
		return(f.has_keyboard());
	}

	public int get_dpi() {
		if(frame != null) {
			return(frame.get_dpi());
		}
		return(96);
	}

	public int px(String s, int dpi = -1) {
		var dd = dpi;
		if(dd < 0) {
			dd = get_dpi();
		}
		return(Length.to_pixels(s, dd));
	}

	public double get_scene_width() {
		if(frame == null) {
			return(0);
		}
		return(frame.get_width());
	}

	public double get_scene_height() {
		if(frame == null) {
			return(0);
		}
		return(frame.get_height());
	}

	public void set_scene_controller(SceneController sc) {
		scene_controller = sc;
	}

	public virtual void on_scene_shown() {
		IFDEF("enable_foreign_api") {
			onSceneShown();
		}
	}

	public virtual void on_scene_hidden() {
		do_switch_scene = true;
		IFDEF("enable_foreign_api") {
			onSceneHidden();
		}
	}

	class ShowSceneListener : SEAnimationListener
	{
		property SEScene scene;
		public void on_animation_ended() {
			if(scene != null) {
				scene.on_scene_shown();
			}
		}
	}

	class HideSceneListener : SEAnimationListener
	{
		property SEScene scene;
		public void on_animation_ended() {
			if(scene != null) {
				scene.on_scene_hidden();
			}
		}
	}

	public virtual void show_scene(SEAnimationListener listener) {
		listener.on_animation_ended();
	}

	public virtual void hide_scene(SEAnimationListener listener) {
		listener.on_animation_ended();
	}

	public void switch_scene(FrameController scene) {
		next_scene_action = 0;
		next_scene = scene;
		hide_scene(new HideSceneListener().set_scene(this));
	}

	public void push_scene(FrameController scene) {
		next_scene_action = 1;
		next_scene = scene;
		hide_scene(new HideSceneListener().set_scene(this));
	}

	public void pop_scene() {
		next_scene_action = 2;
		next_scene = null;
		hide_scene(new HideSceneListener().set_scene(this));
	}

	// NOTE: This is here for legacy support. The actual functionality
	// should be considered to be in SEApplication now.
	public CreateFrameOptions get_frame_options() {
		var v = new CreateFrameOptions();
		v.set_type(CreateFrameOptions.TYPE_FULLSCREEN);
		v.set_resizable(false);
		var wt = SystemEnvironment.get_env_var("EQ_SPRITEENGINE_FULLSCREEN");
		if("no".equals(wt)) {
			v.set_type(CreateFrameOptions.TYPE_NORMAL);
		}
		return(v);
	}

	public Size get_preferred_size() {
		return(Size.instance(1024, 768));
	}

	public virtual SEBackend create_backend() {
		var ei = SEEngine._instance;
		if(ei == null) {
			Log.error("No engine is configured. Cannot create a backend.");
			return(null);
		}
		return(ei.create_backend(get_frame(), get_debug()));
	}

	public void initialize_frame(Frame fr) {
		frame = fr;
		IFDEF("target_android") {
			embed {{{
				if(frame instanceof eq.gui.sysdep.android.FrameViewGroup) {
					((eq.gui.sysdep.android.FrameViewGroup)frame)
						.set_enable_android_measurements(false);
				}
			}}}
		}
		try_initialize();
	}

	void terminate(int v) {
		SystemEnvironment.terminate(v);
	}

	void try_initialize() {
		if(is_initialized == false && get_scene_width() > 0 && get_scene_height() > 0) {
			if(backend == null) {
				backend = create_backend();
				if(backend == null) {
					Log.error("Failed to create a backend. Exiting app.");
					terminate(1);
				}
			}
			if(backend != null) {
				is_initialized = true;
				if(started) {
					backend.start(this);
				}
				resource_cache = backend.get_resource_cache();
				initialize(resource_cache);
				show_scene(new ShowSceneListener().set_scene(this));
			}
		}
	}

	public virtual void initialize(SEResourceCache rsc) {
	}

	public virtual void cleanup() {
		background_sprite = SESprite.remove(background_sprite);
		if(backend != null) {
			if(do_cleanup_backend) {
				backend.cleanup();
			}
			backend = null;
		}
		resource_cache = null;
		is_initialized = false;
	}

	public void start() {
		if(started) {
			return;
		}
		started = true;
		last_tick = null;
		stop_request = false;
		if(backend != null) {
			backend.start(this);
		}
	}

	public void clear_entities() {
		foreach(SEEntity t in entities) {
			t.cleanup();
			t.set_mynode(null);
			t.set_scene(null);
		}
		entities = LinkedList.create();
	}

	public void stop() {
		if(started == false) {
			return;
		}
		if(backend != null && do_cleanup_backend) {
			backend.stop();
		}
		started = false;
		pointers = LinkedList.create();
		keys_pressed = HashTable.create();
		last_tick = null;
	}

	public void destroy() {
		stop();
		clear_entities();
		cleanup();
		frame = null;
		scene_controller = null;
	}

	public virtual void on_exit_scene_request() {
		terminate(0);
	}

	public virtual void on_escape_key_press() {
		on_exit_scene_request();
	}

	public virtual void on_key_press(String name, String str) {
		if(handle_escape_back) {
			if("escape".equals(name) || "back".equals(name)) {
				on_escape_key_press();
			}
		}
		IFDEF("enable_foreign_api") {
			strptr namep = null;
			strptr strp = null;
			if(name != null) {
				namep = name.to_strptr();
			}
			if(str != null) {
				strp = str.to_strptr();
			}
			onKeyPress(namep, strp);
		}
	}

	public virtual void on_key_release(String name, String str) {
		IFDEF("enable_foreign_api") {
			strptr namep = null;
			strptr strp = null;
			if(name != null) {
				namep = name.to_strptr();
			}
			if(str != null) {
				strp = str.to_strptr();
			}
			onKeyRelease(namep, strp);
		}
	}

	public virtual void on_pointer_leave(SEPointerInfo pi) {
		foreach(SEPointerListener pl in pointer_listeners.iterate_reverse()) {
			pl.on_pointer_move(pi);
		}
		IFDEF("enable_foreign_api") {
			onPointerLeave(pi);
		}
	}

	public virtual void on_pointer_press(SEPointerInfo pi) {
		foreach(SEPointerListener pl in pointer_listeners.iterate_reverse()) {
			pl.on_pointer_press(pi);
		}
		IFDEF("enable_foreign_api") {
			onPointerPress(pi);
		}
	}

	public virtual void on_pointer_release(SEPointerInfo pi) {
		foreach(SEPointerListener pl in pointer_listeners.iterate_reverse()) {
			pl.on_pointer_release(pi);
		}
		IFDEF("enable_foreign_api") {
			onPointerRelease(pi);
		}
	}

	public virtual void on_pointer_move(SEPointerInfo pi) {
		foreach(SEPointerListener pl in pointer_listeners.iterate_reverse()) {
			pl.on_pointer_move(pi);
		}
		IFDEF("enable_foreign_api") {
			onPointerMove(pi);
		}
	}

	IFDEF("target_osx") {
		class QuitListener : ModalDialogBooleanListener
		{
			public void on_dialog_boolean_result(bool result) {
				if(result) {
					SystemEnvironment.terminate(0);
				}
			}
		}
	}

	public bool on_event(Object e) {
		if(e is KeyPressEvent) {
			var ke = (KeyPressEvent)e;
			var nn = ke.get_name();
			if("volume-down".equals(nn) || "volume-up".equals(nn)) {
				if(get_accept_volume_keys() == false) {
					return(false);
				}
			}
			var ns = ke.get_str();
			if(String.is_empty(nn) == false) {
				keys_pressed.set_bool(nn, true);
			}
			if(String.is_empty(ns) == false) {
				keys_pressed.set_bool(ns, true);
			}
			IFDEF("target_osx") {
				if("q".equals(ns) && ke.get_command() == true) {
					ModalDialog.yesno("Do you really want to quit?", "Confirmation", new QuitListener());
				}
			}
			on_key_press(nn, ns);
			return(true);
		}
				
		if(e is KeyReleaseEvent) {
			var ke = (KeyReleaseEvent)e;
			var nn = ke.get_name();
			var ns = ke.get_str();
			if(String.is_empty(nn) == false) {
				keys_pressed.set_bool(nn, false);
			}
			if(String.is_empty(ns) == false) {
				keys_pressed.set_bool(ns, false);
			}
			on_key_release(nn, ns);
			return(true);
		}
		if(e is PointerLeaveEvent) {
			var pe = (PointerLeaveEvent)e;
			remove_pointer_info(pe.get_id());
			var pp = get_pointer_info(pe.get_id());
			if(pp != null) {
				pp.set_last_event(e as PointerEvent);
				pp.set_x(-1);
				pp.set_y(-1);
				on_pointer_leave(pp);
			}
			return(true);
		}
		if(e is PointerPressEvent) {
			var ppe = (PointerPressEvent)e;
			var pp = get_pointer_info(ppe.get_id());
			if(pp == null) {
				return(true);
			}
			pp.set_last_event(e as PointerEvent);
			if(ppe.get_button() == 1) {
				pp.set_pressed(true);
				pp.set_pressed_x(ppe.get_x());
				pp.set_pressed_y(ppe.get_y());
			}
			pp.set_x(ppe.get_x());
			pp.set_y(ppe.get_y());
			on_pointer_press(pp);
			return(true);
		}
		if(e is PointerReleaseEvent) {
			var pre = (PointerReleaseEvent)e;
			var pp = get_pointer_info(pre.get_id());
			if(pp == null) {
				return(true);
			}
			pp.set_last_event(e as PointerEvent);
			if(pre.get_button() == 1) {
				pp.set_pressed(false);
				pp.set_pressed_x(-1);
				pp.set_pressed_y(-1);
			}
			pp.set_x(pre.get_x());
			pp.set_y(pre.get_y());
			on_pointer_release(pp);
			return(true);
		}
		if(e is PointerMoveEvent) {
			var pe = (PointerMoveEvent)e;
			var pp = get_pointer_info(pe.get_id());
			if(pp == null) {
				return(true);
			}
			pp.set_last_event(e as PointerEvent);
			pp.set_x(pe.get_x());
			pp.set_y(pe.get_y());
			on_pointer_move(pp);
			return(true);
		}
		if(is_initialized == false && e is FrameResizeEvent) {
			try_initialize();
		}
		return(false);
	}

	public void end_scene(SceneEndListener sel) {
		stop_request = true;
		scene_end_listener = sel;
	}

	public SEEntity add_entity(SEEntity entity) {
		if(entity != null) {
			entity.set_scene(this);
			var nn = LinkedListNode.create(entity);
			entity.set_mynode(nn);
			entities.add_node(nn);
			entity.initialize(resource_cache);
			if(entity is SEPointerListener) {
				// FIXME: This is slow if there are lots of entries
				pointer_listeners.add(entity);
			}
		}
		return(entity);
	}

	public SEEntity remove_entity(SEEntity entity) {
		if(entity != null) {
			entity.cleanup();
			entities.remove_node(entity.get_mynode());
			entity.set_mynode(null);
			entity.set_scene(null);
			if(entity is SEPointerListener) {
				// FIXME: This is slow if there are lots of entries
				pointer_listeners.remove(entity);
			}
			entity.on_entity_removed();
		}
		return(null);
	}

	public void tick() {
		var now = SystemClock.timeval();
		double delta;
		if(last_tick == null) {
			delta = 0.0;
		}
		else {
			delta = (double)TimeVal.diff(now, last_tick) / 1000000.0;
		}
		if(is_initialized) {
			foreach(SEEntity t in entities) {
				t.tick(now, delta);
			}
			update(now, delta);
		}
		last_tick = now;
		if(do_switch_scene) {
			var ns = next_scene;
			do_switch_scene = false;
			next_scene = null;
			if(scene_controller != null) {
				if(next_scene_action == 0) {
					scene_controller.switch_scene(ns);
				}
				else if(next_scene_action == 1) {
					scene_controller.push_scene(ns);
				}
				else if(next_scene_action == 2) {
					scene_controller.pop_scene();
				}
			}
		}
		if(stop_request) {
			stop_request = false;
			//stop();
			if(scene_end_listener != null) {
				scene_end_listener.on_scene_ended(this);
				scene_end_listener = null;
			}
		}
	}

	public virtual void update(TimeVal now, double delta) {
	}

	public SEPointerInfo get_pointer_info(int id) {
		SEPointerInfo v = null;
		foreach(SEPointerInfo pi in pointers) {
			if(pi.get_id() == id) {
				v = pi;
				break;
			}
		}
		if(v == null) {
			v = new SEPointerInfo().set_id(id);
			pointers.append(v);
		}
		return(v);
	}

	void remove_pointer_info(int id) {
		var node = pointers.get_first_node();
		while(node != null) {
			var pi = node.value as SEPointerInfo;
			if(pi != null && pi.get_id() == id) {
				pointers.remove_node(node);
				break;
			}
			node = node.get_next_node();
		}
	}

	public Iterator iterate_pointers() {
		return(pointers.iterate());
	}

	public bool is_key_pressed(String name) {
		return(keys_pressed.get_bool(name, false));
	}

	public void on_create(String command, Collection args) {
	}
	
	public void set_background(Color color) {
		background_sprite = SESprite.remove(background_sprite);
		if(color != null) {
			background_sprite = add_sprite_for_color(color, get_scene_width(), get_scene_height());
		}
	}

	public SESprite add_sprite() {
		if(backend == null) {
			return(null);
		}
		return(backend.add_sprite());
	}

	public SESprite add_sprite_for_image(SEImage image) {
		if(backend == null) {
			return(null);
		}
		return(backend.add_sprite_for_image(image));
	}

	public SESprite add_sprite_for_text(String text, String fontid) {
		if(backend == null) {
			return(null);
		}
		return(backend.add_sprite_for_text(text, fontid));
	}

	public SESprite add_sprite_for_color(Color color, double width, double height) {
		if(backend == null) {
			return(null);
		}
		return(backend.add_sprite_for_color(color, width, height));
	}

	public SELayer add_layer(double x, double y, double width, double height, bool force_clipped = false) {
		if(backend == null) {
			return(null);
		}
		return(backend.add_layer(x, y, width, height, force_clipped));
	}

	// The "foreign API"

	IFDEF("enable_foreign_api")
	{
		public Size getPreferredSize() {
			return(get_preferred_size());
		}
		public bool transferFrom(Scene scene) {
			return(transfer_from(scene));
		}
		public Iterator iterateEntities() {
			return(iterate_entities());
		}
		public Collection getEntities() {
			return(entities);
		}
		public Frame getFrame() {
			return(frame);
		}
		public int getFrameType() {
			return(get_frame_type());
		}
		public bool hasKeyboard() {
			return(has_keyboard());
		}
		public int getDpi() {
			return(get_dpi());
		}
		public int toPx(strptr s, int dpi = -1) {
			return(px(String.for_strptr(s), dpi));
		}
		public double getSceneWidth() {
			return(get_scene_width());
		}
		public double getSceneHeight() {
			return(get_scene_height());
		}
		public virtual void onSceneShown() {
		}
		public virtual void onSceneHidden() {
		}
		public void switchScene(FrameController scene) {
			switch_scene(scene);
		}
		public void pushScene(FrameController scene) {
			push_scene(scene);
		}
		public void popScene() {
			pop_scene();
		}
		public void clearEntities() {
			clear_entities();
		}
		public virtual void onKeyPress(strptr name, strptr str) {
		}
		public virtual void onKeyRelease(strptr name, strptr str) {
		}
		public virtual void onPointerMove(SEPointerInfo pi) {
		}
		public virtual void onPointerLeave(SEPointerInfo pi) {
		}
		public virtual void onPointerPress(SEPointerInfo pi) {
		}
		public virtual void onPointerRelease(SEPointerInfo pi) {
		}
		public void endScene(SceneEndListener sel) {
			end_scene(sel);
		}
		public SEEntity addEntity(SEEntity entity) {
			return(add_entity(entity));
		}
		public SEEntity removeEntity(SEEntity entity) {
			return(remove_entity(entity));
		}
		public SEPointerInfo getPointerInfo(int id) {
			return(get_pointer_info(id));
		}
		public void removePointerInfo(int id) {
			remove_pointer_info(id);
		}
		public Iterator iteratePointers() {
			return(iterate_pointers());
		}
		public bool isKeyPressed(strptr name) {
			return(is_key_pressed(String.for_strptr(name)));
		}
		public void setBackground(strptr color) {
			set_background(Color.instance(String.for_strptr(color)));
		}
		public SESprite addSprite() {
			return(add_sprite());
		}
		public SESprite addSpriteForImage(SEImage image) {
			return(add_sprite_for_image(image));
		}
		public SESprite addSpriteForText(strptr text, strptr fontid) {
			return(add_sprite_for_text(String.for_strptr(text), String.for_strptr(fontid)));
		}
		public SESprite addSpriteForColor(strptr color, double width, double height) {
			return(add_sprite_for_color(
				Color.instance(String.for_strptr(color)), width, height));
		}
		public SELayer addLayer(double x, double y, double width, double height, bool force_clipped) {
			return(add_layer(x,y,width,height,force_clipped));
		}
	}
}
