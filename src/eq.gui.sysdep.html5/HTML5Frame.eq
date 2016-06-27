
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

public class HTML5Frame : Frame, SurfaceContainer, Size, ClosableFrame, TitledFrame, ColoredFrame
{
	public static HTML5Frame for_frame_controller(FrameController fc, ptr iframe = null, ptr window = null) {
		var v = new HTML5Frame();
		if(iframe != null) {
			v.set_iframe(iframe);
		}
		if(window != null) {
			ptr mydoc;
			embed {{{
				mydoc = window.document;
			}}}
			v.set_document(mydoc);
			v.set_window(window);
		}
		if(v.initialize(fc) == false) {
			return(null);
		}
		return(v);
	}

	int ppi = 96;
	int mywidth = -1;
	int myheight = -1;
	FrameController controller;
	bool is_opera = false;
	bool is_webkit = false;
	int mouse_pos_x;
	int mouse_pos_y;
	property ptr iframe;
	property ptr window;
	ptr documentptr;
	int _ft = -1;

	int get_frame_type_internal() {
		if(_ft < 0) {
			embed {{{
				if(navigator.userAgent.match(/android/i) && navigator.userAgent.match(/mobile/i)) {
					}}}
					_ft = Frame.TYPE_PHONE;
					embed {{{
				}
				else if(navigator.userAgent.match(/iphone/i) ||
					navigator.userAgent.match(/blackberry/i) ||
					navigator.userAgent.match(/iemobile/i) ||
					navigator.userAgent.match(/phone/i) ||
					navigator.userAgent.match(/mobile/i) ||
					navigator.userAgent.match(/j2me/i) ||
					navigator.userAgent.match(/windows phone/i) ||
					navigator.userAgent.match(/bada/i)) {
					}}}
					_ft = Frame.TYPE_PHONE;
					embed {{{
				}
				else if(navigator.userAgent.match(/ipad/i) || navigator.userAgent.match(/android/i)) {
					}}}
					_ft = Frame.TYPE_TABLET;
					embed {{{
				}
			}}}
			if(_ft < 0) {
				_ft = Frame.TYPE_DESKTOP;
			}
		}
		return(_ft);
	}

	public int get_frame_type() {
		var f = get_frame_type_internal();
		if(f == Frame.TYPE_DESKTOP) {
			f = Frame.TYPE_TABLET;
		}
		return(f);
	}

	public bool has_keyboard() {
		if(get_frame_type_internal() == Frame.TYPE_DESKTOP) {
			return(true);
		}
		return(false);
	}

	private String to_js_rgba_string(Color c) {
		if(c == null) {
			return("");
		}
		var v = "rgba(%d,%d,%d,%f)".printf()
			.add(Primitive.for_integer((int)(c.get_r() * 255)))
			.add(Primitive.for_integer((int)(c.get_g() * 255)))
			.add(Primitive.for_integer((int)(c.get_b() * 255)))
			.add(Primitive.for_double(c.get_a()))
			.to_string();
		return(v);
	}

	public void set_frame_background_color(Color color) {
		var body = get_document_body();
		if(body == null || color == null) {
			return;
		}
		var cc = to_js_rgba_string(color);
		body.set_style("background-color", cc);
		body.set_style("backgroundColor", cc);
	}

	public void set_icon(Image icon) {
		String href;
		var img = icon as HTML5Image;
		if(img != null) {
			href = img.get_url();
		}
		if(href == null) {
			href = "";
		}
		var mydoc = get_document();
		embed {{{
			var oldlink = mydoc.getElementById('dynamic-favicon');
			var link = mydoc.createElement('link');
			link.id = 'dynamic-favicon';
			link.rel = 'shortcut icon';
			link.href = href.to_strptr();
			var hh = document.head || document.getElementsByTagName('head')[0];
			if(oldlink) {
				hh.removeChild(oldlink);
			}
			hh.appendChild(link);
		}}}
	}

	public void set_title(String title) {
		var doc = get_document();
		if(doc == null) {
			return;
		}
		var tt = title;
		if(tt == null) {
			tt = "";
		}
		embed {{{
			doc.title = tt.to_strptr();
		}}}
	}

	public void close() {
		if(iframe != null) {
			var ifr = iframe;
			embed {{{
				ifr.parentNode.removeChild(ifr);
			}}}
			iframe = null;
		}
		if(window != null) {
			var ww = window;
			embed {{{
				ww.close();
			}}}
			window = null;
		}
	}

	public void set_document(ptr p) {
		documentptr = p;
	}

	public ptr get_document() {
		var v = documentptr;
		if(v == null && iframe != null) {
			ptr mydoc;
			var ifr = iframe;
			embed {{{
				mydoc = (ifr.contentWindow.document) ? ifr.contentWindow.document : (ifr.contentDocument.document) ? ifr.contentDocument.document : ifr.contentDocument;
			}}}
			documentptr = mydoc;
			v = mydoc;
		}
		if(v == null) {
			embed {{{
				v = document;
			}}}
		}
		return(v);
	}

	public HTMLElement get_document_body() {
		var doc = get_document();
		ptr v;
		embed {{{
			v = doc.body;
		}}}
		return(HTMLElement.for_element(v));
	}

	public FrameController get_controller() {
		return(controller);
	}

	public void load_icon_js(strptr ss) {
		if(ss == null) {
			return;
		}
		IconCache.load(String.for_strptr(ss));
	}

	class WaitForIconsTimer : TimerHandler
	{
		property HTML5Frame frame;
		property FrameController fc;
		public bool on_timer(Object arg) {
			if(IconCache.is_loaded() == false) {
				return(true);
			}
			IconCache.remove_empty_images();
			Log.debug("Done waiting for icons. Starting the frame controller");
			if(frame != null) {
				frame.do_initialize(fc);
			}
			frame = null;
			fc = null;
			return(false);
		}
	}

	public bool initialize(FrameController fc) {
		var btm = GUI.engine.get_background_task_manager();
		if(btm == null) {
			Log.error("No background task manager (?). Unable to start icon wait timer.");
			return(do_initialize(fc));
		}
		Log.debug("Waiting for icons to load ..");
		btm.start_timer(10000, new WaitForIconsTimer().set_frame(this).set_fc(fc), null);
		return(true);
	}

	public bool do_initialize(FrameController fc) {
		if(fc == null) {
			return(false);
		}
		Log.debug("HTML5Frame: Initializing frame");
		controller = fc;
		ppi = determine_ppi();
		fc.initialize_frame(this);
		on_resize();
		var ifr = iframe;
		var wi = window;
		var mydoc = get_document();
		embed {{{
			mydoc.body.ondragstart = function() {
				return(false);
			};
			mydoc.body.ondrop = function() {
				return(false);
			};
			if(navigator.userAgent.indexOf("Opera") >= 0) {
				this.is_opera = true;
			}
			if(navigator.userAgent.indexOf("WebKit") >= 0) {
				this.is_webkit = true;
			}
			var self = this;
			if(ifr != null) {
				var wor = ifr.onresize;
				ifr.onresize = function() {
					self.on_resize();
					if(wor) {
						wor();
					}
				};
			}
			else if(wi != null) {
				var wor = wi.onresize;
				wi.onresize = function() {
					self.on_resize();
					if(wor) {
						wor();
					}
				};
			}
			else {
				var wor = window.onresize;
				window.onresize = function() {
					self.on_resize();
					if(wor) {
						wor();
					}
				};
			}
			self.on_js_mouse_move = function(e) {
				if(!('ontouchstart' in mydoc)) {
					var posx = 0;
					var posy = 0;
					if(!e) {
						e = window.event;
					}
					if(e.pageX || e.pageY) {
						posx = e.pageX;
						posy = e.pageY;
					}
					else if(e.clientX || e.clientY) {
						posx = e.clientX + mydoc.body.scrollLeft + mydoc.documentElement.scrollLeft;
						posy = e.clientY + mydoc.body.scrollTop + mydoc.documentElement.scrollTop;
					}
					self.move_x = posx;
					self.move_y = posy;
					if(!self.timeoutid) {
						self.timeoutid = setTimeout(self.on_js_event_timeout, 0);
					}
				}
				self.check_vk_is_enabled();
			};
			self.on_js_mouse_down = function(e) {
				if(!('ontouchstart' in mydoc)) {
					if(!e) {
						e = window.event;
					}
					self.on_mouse_down();
				}
				self.check_vk_is_enabled();
			};
			self.on_js_mouse_up = function(e) {
				if(!('ontouchstart' in mydoc)) {
					if(!e) {
						e = window.event;
					}
					self.on_mouse_up();
				}
				self.check_vk_is_enabled();
			};
			self.on_js_key_down = function(e) {
				if(self.on_key_down(e)) {
					return(true);
				}
				if(navigator.userAgent.indexOf("WebKit") >= 0) {
					if(e.keyCode == 9 || e.keyCode == 8) {
						if(e.preventDefault) {
							e.preventDefault();
						}
					}
					else if(e.ctrlKey) {
						self.on_key_press(e);
						if(e.preventDefault) {
							e.preventDefault();
						}
					}
				}
				else {
					if(e.preventDefault) {
						e.preventDefault();
					}
				}
				return(false);
			};
			self.on_js_key_press = function(e) {
				if(self.on_key_press(e)) {
					return(true);
				}
				if(e.preventDefault) {
					e.preventDefault();
				}
				return(false);
			};
			self.on_js_key_up = function(e) {
				if(self.on_key_up(e)) {
					return(true);
				}
				if(e.preventDefault) {
					e.preventDefault();
				}
				return(false);
			};
			self.on_js_touch_start = function(e) {
				for(i=0; i<e.touches.length; i++) {
					self.on_mouse_move(e.touches[i].pageX, e.touches[i].pageY);
				}
				self.on_mouse_down();
			};
			self.on_js_touch_move = function(e) {
				for(i=0; i<e.touches.length; i++) {
					self.move_x = e.touches[i].pageX;
					self.move_y = e.touches[i].pageY;
				}
				if(!self.timeoutid) {
					self.timeoutid = setTimeout(self.on_js_event_timeout, 0);
				}
				e.preventDefault();
			};
			self.on_js_event_timeout = function() {
				self.on_mouse_move(self.move_x, self.move_y);
				self.timeoutid = 0;
			};
			self.on_js_touch_end = function(e) {
				self.on_mouse_up();
			};
			self.on_js_mouse_wheel = function(e) {
				var delta = Math.max(-1, Math.min(1, (e.wheelDelta || -e.detail)));
				self.on_mouse_wheel(delta);
			};
			mydoc.addEventListener('touchstart', function(e) { if(self.on_js_touch_start) { self.on_js_touch_start(e) } }, false);
			mydoc.addEventListener('touchmove', function(e) { if(self.on_js_touch_move) { self.on_js_touch_move(e); } }, false);
			mydoc.addEventListener('touchend', function(e) { if(self.on_js_touch_end) { self.on_js_touch_end(e); } }, false);
			mydoc.addEventListener('mousemove', function(e) { if(self.on_js_mouse_move) { self.on_js_mouse_move(e); } }, false);
			mydoc.addEventListener('mousedown', function(e) { if(self.on_js_mouse_down) { self.on_js_mouse_down(e); } }, false);
			mydoc.addEventListener('mouseup', function(e) { if(self.on_js_mouse_up) { self.on_js_mouse_up(e); } }, false);
			mydoc.addEventListener('mousewheel', function(e) { if(self.on_js_mouse_wheel) { self.on_js_mouse_wheel(e); } }, false);
			mydoc.addEventListener('DOMMouseScroll', function(e) { if(self.on_js_mouse_wheel) { self.on_js_mouse_wheel(e); } }, false);
			mydoc.addEventListener('keydown', function(e) { if(self.on_js_key_down) { self.on_js_key_down(e); } }, false);
			mydoc.addEventListener('keypress', function(e) { if(self.on_js_key_press) { self.on_js_key_press(e); } }, false);
			mydoc.addEventListener('keyup', function(e) { if(self.on_js_key_up) { self.on_js_key_up(e); } }, false);
		}}}
		fc.start();
		if(iframe != null) {
			var psz = fc.get_preferred_size();
			if(psz != null) {
				var ifrm = iframe;
				embed {{{
					ifrm.frameBorder = 0;
					ifrm.width = psz.get_width();
					ifrm.height = psz.get_height();
					ifrm.style.position = "fixed";
					ifrm.style.left = window.innerWidth/2 - ifrm.width / 2;
					ifrm.style.top = window.innerHeight/2 - ifrm.height / 2;
					ifrm.focus();
				}}}
				on_resize();
			}
		}
		if(window != null) {
			var psz = fc.get_preferred_size();
			if(psz != null) {
				var ww = window;
				embed {{{
					ww.resizeTo(psz.get_width(), psz.get_height());
					ww.focus();
				}}}
				on_resize();
			}
		}
		Log.debug("HTML5Frame: Initial size determined as %dx%d".printf().add(mywidth).add(myheight));
		return(true);
	}

	bool vkb_on = false;

	public void virtual_keyboard(bool show) {
		if(show) {
			if(vkb_on) {
				embed "js" {{{
					this.textinput.focus();
				}}}
				return;
			}
			vkb_on = true;
			var mydoc = get_document();
			embed "js" {{{
				var bodys = mydoc.getElementsByTagName("body");
				this.textinput = mydoc.createElement("textarea");
				this.textinput.setAttribute("style", "-webkit-tap-highlight-color: rgba(255, 255, 255, 0);");
				this.textinput.style.color = "transparent";
				this.textinput.style.backgroundColor = "transparent";
				this.textinput.style.borderColor = "transparent";
				this.textinput.style.position = "absolute";
				this.textinput.style.left = 0;
				this.textinput.style.top = 0;
				this.textinput.style.width = 0;
				this.textinput.style.height = 0;
				bodys[0].appendChild(this.textinput);
				this.textinput.addEventListener('keydown', function(e) { if(this.on_js_key_down) { this.on_js_key_down(e); } }, false);
				this.textinput.addEventListener('keypress', function(e) { if(this.on_js_key_press) { this.on_js_key_press(e); } }, false);
				this.textinput.addEventListener('keyup', function(e) { if(this.on_js_key_up) { this.on_js_key_up(e); } }, false);
			}}}
		}
		else {
			vkb_on = false;
			var mydoc = get_document();
			embed "js" {{{
				this.textinput.setAttribute('style', 'display: none;');
				mydoc.body.removeChild(this.textinput);
			}}}
		}
	}

	public void check_vk_is_enabled() {
		if(vkb_on) {
			embed "js" {{{
				this.textinput.focus();
			}}}
		}
	}

	// The ultimate reference for all things related to keypresses on JavaScript: http://unixpapa.com/js/key.html

	private String keyname(int keycode) {
		String v = null;
		switch(keycode) {
			case 32: { v = "space"; }
			case 13: { v = "enter"; }
			case  9: { v = "tab"; }
			case 27: { v = "escape"; }
			case  8: { v = "backspace"; }
			case 16: { v = "shift"; }
			case 17: { v = "control"; }
			case 18: { v = "alt"; }
			case 20: { v = "capslock"; }
			case 144:{ v = "numlock"; }
			case 37: { v = "left"; }
			case 38: { v = "up"; }
			case 39: { v = "right"; }
			case 40: { v = "down"; }
			case 45: { v = "insert"; }
			case 46: { v = "delete"; }
			case 36: { v = "home"; }
			case 35: { v = "end"; }
			case 33: { v = "pageup"; }
			case 34: { v = "pagedown"; }
			case 112:{ v = "f1"; }
			case 113:{ v = "f2"; }
			case 114:{ v = "f3"; }
			case 115:{ v = "f4"; }
			case 116:{ v = "f5"; }
			case 117:{ v = "f6"; }
			case 118:{ v = "f7"; }
			case 119:{ v = "f8"; }
			case 120:{ v = "f9"; }
			case 121:{ v = "f10"; }
			case 122:{ v = "f11"; }
			case 123:{ v = "f12"; }
			// FIXME: Could somehow incorporate the keypad keys from http://unixpapa.com/js/key.html
			case 224:{ v = "super"; }
			case 91 :{ v = "super"; }
			case 92 :{ v = "super"; }
			case 93 :{ v = "super"; }
		}
		return(v);
	}

	property bool disable_key_capture = false;

	public bool on_key_down(ptr e) {
		int keycode;
		strptr keychar;
		bool shift = false;
		bool alt = false;
		bool ctrl = false;
		embed {{{
			keychar = e.key;
			keycode = e.keyCode;
			shift = e.shiftKey;
			alt = e.altKey;
			ctrl = e.ctrlKey;
		}}}
		var kn = keyname(keycode);
		if("tab".equals(kn) == false && disable_key_capture) {
			return(true);
		}
		var ev = new KeyPressEvent();
		if(kn == null) {
			ev.set_str(String.for_strptr(keychar));
		}
		ev.set_name(kn);
		ev.set_keycode(keycode);
		if("space".equals(kn)) {
			ev.set_str(" ");
		}
		else if("tab".equals(kn)) {
			ev.set_str("\t");
		}
		if(shift) {
			ev.set_shift(true);
		}
		if(alt) {
			ev.set_alt(true);
		}
		if(ctrl) {
			ev.set_ctrl(true);
		}
		event(ev);
		return(false);
	}

	public bool on_key_press(ptr e) {
		int keycode;
		int charcode;
		bool shift = false;
		bool alt = false;
		bool ctrl = false;
		embed {{{
			keycode = e.keyCode;
			if(this.is_opera) {
				charcode = e.which;
			}
			else if(this.is_webkit) {
				charcode = e.keyCode;
			}
			else {
				charcode = e.charCode;
			}
			shift = e.shiftKey;
			alt = e.altKey;
			ctrl = e.ctrlKey;
		}}}
		var kn = keyname(keycode);
		if("tab".equals(kn) == false && disable_key_capture) {
			return(true);
		}
		if(is_opera == false && is_webkit == false) {
			if(keycode > 0 && kn != null) {
				return(false);
			}
		}
		if(charcode == 32 || charcode == 9 || charcode == 8) {
			return(false);
		}
		if(charcode > 0) {
			var str = String.for_character(charcode);
			if(ctrl) {
				str = str.lowercase();
			}
			var en = new KeyPressEvent();
			en.set_name(str);
			en.set_str(str);
			en.set_keycode(keycode);
			if(shift) {
				en.set_shift(true);
			}
			if(alt) {
				en.set_alt(true);
			}
			if(ctrl) {
				en.set_ctrl(true);
			}
			event(en);
		}
		return(false);
	}

	public bool on_key_up(ptr e) {
		int keycode;
		strptr keychar;
		bool shift = false;
		bool alt = false;
		bool ctrl = false;
		embed {{{
			keychar = e.key;
			keycode = e.keyCode;
			shift = e.shiftKey;
			alt = e.altKey;
			ctrl = e.ctrlKey;
		}}}
		var kn = keyname(keycode);
		var ee = new KeyReleaseEvent();
		if(kn == null) {
			ee.set_str(String.for_strptr(keychar));
		}
		ee.set_name(kn);
		ee.set_keycode(keycode);
		if("space".equals(kn)) {
			ee.set_str(" ");
		}
		else if("tab".equals(kn)) {
			ee.set_str("\t");
		}
		if(shift) {
			ee.set_shift(true);
		}
		if(alt) {
			ee.set_alt(true);
		}
		if(ctrl) {
			ee.set_ctrl(true);
		}
		if("tab".equals(kn) == false && disable_key_capture) {
			return(true);
		}
		event(ee);
		return(false);
	}

	// FIXME: In the following: Not necessarily always mouse?
	public void on_mouse_move(int x, int y) {
		mouse_pos_x = x;
		mouse_pos_y = y;
		event(new PointerMoveEvent().set_x(x).set_y(y).set_pointer_type(PointerEvent.MOUSE).set_id(0));
	}

	public void on_mouse_down() {
		event(new PointerPressEvent().set_button(1).set_x(mouse_pos_x).set_y(mouse_pos_y).set_pointer_type(PointerEvent.MOUSE).set_id(0));
	}

	public void on_mouse_up() {
		event(new PointerReleaseEvent().set_button(1).set_x(mouse_pos_x).set_y(mouse_pos_y).set_pointer_type(PointerEvent.MOUSE).set_id(0));
	}

	public void on_mouse_wheel(int delta) {
		event(new ScrollEvent().set_x(mouse_pos_x).set_y(mouse_pos_y).set_dx(0).set_dy(delta * 32));
	}

	int determine_ppi() {
		int ppi;
		// HACK: Firefox (and likely others) stubbornly uses a DPI value of n*96, regardless of what it really is.
		// But in reality, most people wouldn't have 96 DPI anymore .. Thus we'll make a reasonable middle-ground guess
		// of 1.3x the DPI (thus 1.3in, not 1in)
		var mydoc = get_document();
		embed "js" {{{
			var div = mydoc.createElement("div");
			div.setAttribute("style", "width: 1.3in; padding: 0; visibility: hidden; position: absolute; left: 0; top: 0;");
			var bodys = mydoc.getElementsByTagName("body");
			bodys[0].appendChild(div);
			ppi = div.offsetWidth;
			if(ppi < 1) {
				ppi = 1;
			}
			bodys[0].removeChild(div);
		}}}
		Log.debug("DPI determined as %d".printf().add(ppi));
		var dpienv = SystemEnvironment.get_env_var("EQ_DPI");
		if(String.is_empty(dpienv) == false) {
			var dpienvi = dpienv.to_integer();
			if(dpienvi > 0) {
				ppi = dpienvi;
				Log.debug("DPI manually configured to %d via EQ_DPI".printf().add(Primitive.for_integer(ppi)));
			}
		}
		return(ppi);
	}

	void event(Object o) {
		if(controller != null) {
			controller.on_event(o);
		}
	}

	public void on_resize() {
		int nw, nh;
		if(iframe != null) {
			var ifr = iframe;
			embed {{{
				nw = ifr.width;
				nh = ifr.height;
				if(!nw) {
					nw = 0;
				}
				if(!nh) {
					nh = 0;
				}
			}}}
		}
		else if(window != null) {
			var ww = window;
			embed {{{
				nw = ww.innerWidth;
				nh = ww.innerHeight;
			}}}
		}
		else {
			embed "js" {{{
				nw = window.innerWidth;
				nh = window.innerHeight;
			}}}
		}
		if(mywidth != nw || myheight != nh) {
			mywidth = nw;
			myheight = nh;
			event(new FrameResizeEvent().set_width(mywidth).set_height(myheight));
		}
	}

	public int get_dpi() {
		return(ppi);
	}

	public Surface add_surface(SurfaceOptions opts) {
		if(opts == null) {
			return(null);
		}
		var v = opts.get_surface() as HTML5ElementSurface;
		if(v == null) {
			if(opts.get_surface_type() == SurfaceOptions.SURFACE_TYPE_CONTAINER) {
				v = new HTML5ElementContainerSurface();
			}
			else {
				v = new HTML5ElementRenderableSurface();
			}
		}
		if(opts.get_placement() == SurfaceOptions.TOP) {
			v.append_to(get_document_body());
		}
		else if(opts.get_placement() == SurfaceOptions.BOTTOM) {
			v.prepend_to(get_document_body());
		}
		else if(opts.get_placement() == SurfaceOptions.ABOVE) {
			HTMLElement refel;
			var rel = opts.get_relative() as HTML5ElementSurface;
			if(rel != null) {
				refel = rel.get_element();
			}
			if(refel == null) {
				v.append_to(get_document_body());
			}
			else {
				refel.add_sibling_after(v.get_element());
			}
		}
		else if(opts.get_placement() == SurfaceOptions.BELOW) {
			HTMLElement refel;
			var rel = opts.get_relative() as HTML5ElementSurface;
			if(rel != null) {
				refel = rel.get_element();
			}
			if(refel == null) {
				v.append_to(get_document_body());
			}
			else {
				refel.add_sibling_before(v.get_element());
			}
		}
		else if(opts.get_placement() == SurfaceOptions.INSIDE) {
			HTMLElement refel;
			var rel = opts.get_relative() as HTML5ElementSurface;
			if(rel != null) {
				refel = rel.get_element();
			}
			if(refel == null) {
				v.append_to(get_document_body());
			}
			else {
				v.append_to(refel);
			}
		}
		else {
			v = null;
		}
		return(v);
	}

	public void remove_surface(Surface ss) {
		var s = ss as HTML5ElementSurface;
		if(s == null) {
			return;
		}
		s.remove();
	}

	public double get_width() {
		return(mywidth);
	}

	public double get_height() {
		return(myheight);
	}
}
