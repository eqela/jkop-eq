
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

public class DesktopApplication : WidgetApplicationMain, eq.os.FileOpener
{
	class SplashWidget : LayerWidget
	{
		property DesktopApplication app;
		property Widget content;
		property int timeout = 3000000;

		public CreateFrameOptions get_frame_options() {
			var v = new CreateFrameOptions();
			v.set_type(CreateFrameOptions.TYPE_SPLASH);
			return(v);
		}

		public void initialize() {
			base.initialize();
			add(CanvasWidget.for_color(Color.white()));
			add(content);
		}

		public void start() {
			base.start();
			start_delay_timer(timeout);
		}

		public void on_delay_timer(Object arg) {
			app.on_init_complete();
			close_frame();
		}
	}

	class DefaultWidget : DesktopApplicationWindowWidget
	{
		public DefaultWidget() {
			set_is_main_window(true);
			set_enable_save(false);
			set_enable_undo(false);
			set_enable_clipboard_actions(false);
		}

		public void initialize() {
			base.initialize();
			add(CanvasWidget.for_color(Color.instance("#CCCCCC")));
			var icon = IconCache.get("appicon");
			if(icon != null) {
				add(AlignWidget.for_widget(ImageWidget.for_image(icon).set_image_width(px("30mm"))));
			}
		}
	}

	public static DesktopApplication instance() {
		return(Application.get_main() as DesktopApplication);
	}

	property Collection files;
	property bool default_new_file = false;
	property bool always_open_default_widget = true;
	property bool enable_preferences = false;
	property bool enable_new_file = false;
	property bool enable_open_file = false;
	property bool enable_about = true;
	property bool enable_quit = true;
	property bool enable_weblink = true;
	property bool enable_window_menu = true;
	property String help_url = null;
	property bool allow_native_toolbar = true;
	property bool allow_native_menubar = true;
	property bool enable_menubar = true;
	property bool enable_toolbar = true;
	property Image splash_widget_image;
	bool init_complete = false;

	public DesktopApplication() {
		IFNDEF("target_osx") {
			enable_window_menu = false;
		}
		splash_widget_image = IconCache.get("splash");
		files = LinkedList.create();
	}

	void process_args() {
		if(enable_open_file == false) {
			return;
		}
		foreach(String arg in Application.get_instance_args()) {
			var ff = File.for_native_path(arg);
			if(ff != null) {
				open_file(ff);
			}
		}
	}

	public Widget create_main_widget() {
		process_args();
		var sw = new SplashWidget();
		sw.set_app(this);
		var sp = create_splash_widget();
		if(sp == null) {
			sp = new Widget();
			sw.set_timeout(0);
		}
		sw.set_content(sp);
		return(sw);
	}

	public void on_init_complete() {
		init_complete = true;
		var widgets = LinkedList.create();
		if(enable_open_file) {
			foreach(File file in files) {
				var ww = create_widget_for_file(file);
				if(ww != null) {
					widgets.add(ww);
				}
			}
			files.clear();
		}
		if(widgets.count() < 1 && default_new_file && enable_new_file) {
			var w = create_widget_for_new_file();
			if(w != null) {
				widgets.add(w);
			}
		}
		if(widgets.count() < 1 || always_open_default_widget) {
			var w = create_default_widget();
			if(w != null) {
				widgets.prepend(w);
			}
		}
		foreach(DesktopApplicationWindowWidget ww in widgets) {
			ww.show();
		}
	}

	public bool open_files(Collection files) {
		foreach(File file in files) {
			open_file(file);
		}
		return(true);
	}

	public virtual void on_new_file() {
		var ww = create_widget_for_new_file();
		if(ww != null) {
			ww.show();
		}
	}

	public virtual void open_file(File file) {
		if(file == null) {
			return;
		}
		if(init_complete == false) {
			foreach(File ef in files) {
				if(ef.is_same(file)) {
					return;
				}
			}
			files.append(file);
			return;
		}
		var ww = create_widget_for_file(file);
		if(ww != null) {
			ww.show();
		}
	}

	class MyOpenFileDialogListener: OpenFileDialogListener
	{
		property DesktopApplication app;
		public void on_open_file_dialog_ok(File file) {
			app.open_file(file);
		}
	}

	public void on_open_file(Widget widget) {
		File dir;
		if(widget != null && widget is FileAwareWidget) {
			dir = ((FileAwareWidget)widget).get_file();
			if(dir != null && dir.is_file()) {
				dir = dir.get_parent();
			}
		}
		if(dir == null || dir.is_directory() == false) {
			dir = SystemEnvironment.get_home_dir();
		}
		var dlg = OpenFileDialog.for_directory(dir);
		if(dlg != null) {
			if(widget != null) {
				dlg.set_parent_frame(widget.get_frame());
			}
			dlg.show(new MyOpenFileDialogListener().set_app(this));
		}
	}

	class MySplashWidget : AlignWidget
	{
		property Image image;
		public void initialize() {
			base.initialize();
			var iw = ImageWidget.for_image(image);
			iw.set_image_size(px("70mm"), -1);
			iw.set_mode("fit");
			add(iw);
		}
	}

	public virtual Widget create_splash_widget() {
		if(splash_widget_image == null) {
			return(null);
		}
		return(new MySplashWidget().set_image(splash_widget_image));
	}

	public virtual DesktopApplicationWindowWidget create_default_widget() {
		return(new DefaultWidget());
	}

	public virtual DesktopApplicationWindowWidget create_widget_for_new_file() {
		ModalDialog.error("New file: Not implemented.");
		return(null);
	}

	public virtual DesktopApplicationWindowWidget create_widget_for_file(File file) {
		ModalDialog.error("Unable to open file `%s': Not implemented.".printf().add(file).to_string());
		return(null);
	}
}
