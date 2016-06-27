
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

public class OpenFileDialogWidget : LayerWidget, EventReceiver
{
	class DefaultIconProvider : FileIconProvider
	{
		public Image get_icon_for_file(File file) {
			if(file != null && file.is_directory()) {
				return(IconCache.get("fileicon_folder"));
			}
			if(file != null && file.is_executable()) {
				return(IconCache.get("fileicon_application"));
			}
			return(IconCache.get("fileicon_generic"));
		}
	}

	property File directory;
	property FileIconProvider icon_provider;
	property OpenFileDialogListener open_listener;
	property String filter;
	property bool cancellable = true;
	LabelWidget title;
	File currentdir;
	ButtonWidget mbutton;
	property bool show_hidden_files = false;
	property bool choose_directories = false;
	property String view_type;
	LayerWidget selector_container;

	public OpenFileDialogWidget() {
		view_type = "list_view";
	}

	public void initialize() {
		base.initialize();
		if(icon_provider == null) {
			icon_provider = new DefaultIconProvider();
		}
		add(CanvasWidget.for_color(Theme.get_base_color().dup("50%")));
		set_draw_color(Color.instance("white"));
		set_size_request_override(px("150mm"), px("150mm"));
		var hdr = HBoxWidget.instance();
		hdr.set_draw_color(Color.instance("white"));
		hdr.add_hbox(1, AlignWidget.instance().set_margin(px("1mm"))
			.add_align(-1, 0, title = LabelWidget.instance().set_font(Theme.font().modify("shadow-color=#505050")))
		);
		title.set_height_request_override(px("5mm"));
		title.set_text("Open file ..");
		var mm7 = px("7mm");
		mbutton = ButtonWidget.instance().set_left_icon(IconCache.get("filewidget_view"))
			.set_draw_frame(false).set_margin(0).set_size_request_override(mm7,mm7) as ButtonWidget;
		update_menu();
		hdr.add_hbox(0, mbutton);
		if(cancellable) {
			var button = ButtonWidget.instance().set_left_icon(IconCache.get("filewidget_close"))
				.set_draw_frame(false).set_event("close").set_margin(0).set_size_request_override(mm7,mm7);
			hdr.add_hbox(0, button);
		}
		var hdrl = LayerWidget.instance()
			.add(CanvasWidget.for_color(Color.instance("#000000AA")))
			.add(hdr);
		var vb = VBoxWidget.instance();
		vb.add_vbox(0, hdr);
		vb.add_vbox(1, selector_container = new LayerWidget());
		if(choose_directories) {
			vb.add_vbox(0, AlignWidget.instance().add_align(1, 1,
				ButtonWidget.for_string("Choose current directory")
					.set_icon(IconCache.get("filewidget_accept"))
					.set_color(Color.instance("lightgreen"))
					.set_event("choose_directory")
				).set_margin(px("1mm"))
			);
		}
		add(vb);
		if(directory == null) {
			directory = File.for_eqela_path("/my");
		}
		directory = File.for_native_path(directory.get_native_path());
		go_to_dir(directory);
	}

	public void cleanup() {
		base.cleanup();
		title = null;
		mbutton = null;
	}

	void update_menu() {
		if(mbutton == null) {
			return;
		}
		var menu = MenuWidget.instance();
		if(show_hidden_files) {
			menu.add_entry(IconCache.get("filewidget_view_hidden"), "Hide hidden files", "Do not display hidden files", "toggle_hidden");
		}
		else {
			menu.add_entry(IconCache.get("filewidget_view_hidden"), "Show hidden files", "Include hidden files in the list", "toggle_hidden");
		}
		if("list_view".equals(view_type)) {
			menu.add_entry(IconCache.get("filewidget_view_grid"), "View as grid", "View files in a grid layout", "set_view_grid");
		}
		else {
			menu.add_entry(IconCache.get("filewidget_view_list"), "View as list", "View files as a list", "set_view_list");
		}
		mbutton.set_popup(menu);
	}

	public void go_to_dir(File dir) {
		bool root = false;
		if(title != null) {
			String nn;
			if(dir != null) {
				nn = dir.get_native_path();
			}
			if(String.is_empty(nn) || "/".equals(nn)) {
				root = true;
			}
			if(String.is_empty(nn)) {
				nn = "Open file ..";
			}
			title.set_text(nn);
		}
		var dp = new SortedDirectoryDataProvider();
		dp.set_show_parent_directory(!root);
		dp.set_show_hidden_files(show_hidden_files);
		dp.set_icon_provider(icon_provider);
		dp.set_choose_directories_only(choose_directories);
		dp.set_directory(dir);
		currentdir = dir;
		var bg_task_manager = GUI.engine.get_background_task_manager();
		if(bg_task_manager != null) {
			selector_container.remove_children();
			var task = bg_task_manager.start_task(dp, this);
			add(progress = AlignWidget.instance().add_align(0, 0, WaitAnimationWidget.instance().set_size_request_override(px("50mm"), px("50mm"))));
		}
	}

	AlignWidget progress;

	public bool on_key_press(KeyEvent e) {
		if(e == null) {
		}
		else if(("escape".equals(e.get_name()) || "back".equals(e.get_name())) && cancellable) {
			close();
			return(true);
		}
		return(base.on_key_press(e));
	}

	void close() {
		Popup.close(this);
	}

	public void on_event(Object o) {
		if(o is Collection) {
			if(progress != null) {
				progress.dismiss_widget();
				progress = null;
			}
			if("grid_view".equals(view_type)) {
				var grid_view = GridSelectorWidget.instance();
				grid_view.set_items((Collection)o);
				selector_container.add(grid_view);
			}
			else {
				var list_view = ListSelectorWidget.instance();
				list_view.set_items((Collection)o);
				selector_container.add(list_view);
			}
		}
		else if("choose_directory".equals(o)) {
			if(open_listener != null) {
				open_listener.on_open_file_dialog_ok(currentdir);
				close();
				return;
			}
		}
		else if("close".equals(o)) {
			close();
		}
		else if("toggle_hidden".equals(o)) {
			show_hidden_files = !show_hidden_files;
			update_menu();
			go_to_dir(currentdir);
		}
		else if("set_view_grid".equals(o)) {
			view_type = "grid_view";
			update_menu();
			go_to_dir(currentdir);
		}
		else if("set_view_list".equals(o)) {
			view_type = "list_view";
			update_menu();
			go_to_dir(currentdir);
		}
		else if(o is File) {
			var ff = (File)o;
			if(ff.is_directory()) {
				go_to_dir(ff);
			}
			else if(ff.is_file()) {
				if(open_listener != null) {
					open_listener.on_open_file_dialog_ok(ff);
					close();
					return;
				}
			}
		}
	}
}
