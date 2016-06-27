
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

public class DesktopApplicationWindowWidget : LayerWidget, ToolBarControlListener, WidgetEngineCloseRequestHandler
{
	class NewHandler : Executable
	{
		property DesktopApplicationWindowWidget widget;
		public void execute() {
			widget.on_new();
		}
	}

	class OpenHandler : Executable
	{
		property DesktopApplicationWindowWidget widget;
		public void execute() {
			widget.on_open();
		}
	}

	class SaveHandler : Executable
	{
		property DesktopApplicationWindowWidget widget;
		public void execute() {
			widget.on_save();
		}
	}

	class SaveAsHandler : Executable
	{
		property DesktopApplicationWindowWidget widget;
		public void execute() {
			widget.on_save_as();
		}
	}

	class CloseHandler : Executable
	{
		property DesktopApplicationWindowWidget widget;
		public void execute() {
			widget.on_close();
		}
	}

	class UndoHandler : Executable
	{
		property DesktopApplicationWindowWidget widget;
		public void execute() {
			widget.on_undo();
		}
	}

	class CutHandler : Executable
	{
		property DesktopApplicationWindowWidget widget;
		public void execute() {
			widget.on_cut();
		}
	}

	class CopyHandler : Executable
	{
		property DesktopApplicationWindowWidget widget;
		public void execute() {
			widget.on_copy();
		}
	}

	class PasteHandler : Executable
	{
		property DesktopApplicationWindowWidget widget;
		public void execute() {
			widget.on_paste();
		}
	}

	public static DesktopApplicationWindowWidget find(Widget widget) {
		var ww = widget;
		while(ww != null) {
			if(ww is DesktopApplicationWindowWidget) {
				return((DesktopApplicationWindowWidget)ww);
			}
			ww = ww.get_parent() as Widget;
		}
		return(null);
	}

	LayerWidget content_layer;
	ToolBarControl toolbar;
	MenuBarControl menubar;
	property bool is_main_window = false;
	property bool enable_preferences = true;
	property bool enable_new = false;
	property bool enable_open = false;
	property bool enable_about = true;
	property bool enable_quit = true;
	property bool enable_weblink = true;
	property bool enable_window_menu = true;
	property String help_url = null;
	property bool allow_native_toolbar = true;
	property bool allow_native_menubar = true;
	property bool enable_menubar = true;
	property bool enable_toolbar = true;
	property bool enable_save = false;
	property bool enable_save_as = false;
	property bool enable_close = true;
	property bool enable_undo = true;
	property bool enable_clipboard_actions = true;
	property Color background_color;

	public DesktopApplicationWindowWidget() {
		background_color = Color.instance("#CCCCCC");
		var dapp = DesktopApplication.instance();
		if(dapp != null) {
			set_enable_preferences(dapp.get_enable_preferences());
			set_enable_new(dapp.get_enable_new_file());
			set_enable_open(dapp.get_enable_open_file());
			set_enable_about(dapp.get_enable_about());
			set_enable_quit(dapp.get_enable_quit());
			set_enable_weblink(dapp.get_enable_weblink());
			set_enable_window_menu(dapp.get_enable_window_menu());
			set_help_url(dapp.get_help_url());
			set_allow_native_toolbar(dapp.get_allow_native_toolbar());
			set_allow_native_menubar(dapp.get_allow_native_menubar());
			set_enable_menubar(dapp.get_enable_menubar());
			set_enable_toolbar(dapp.get_enable_toolbar());
		}
	}

	public virtual void on_new() {
		var app = DesktopApplication.instance();
		if(app != null) {
			app.on_new_file();
		}
	}

	public virtual void on_open() {
		var app = DesktopApplication.instance();
		if(app != null) {
			app.on_open_file(this);
		}
	}

	public virtual void on_save() {
	}

	public virtual void on_save_as() {
	}

	public virtual void on_close() {
		desktop_window_close();
	}

	public virtual void on_undo() {
	}

	public virtual void on_cut() {
	}

	public virtual void on_copy() {
	}

	public virtual void on_paste() {
	}

	public virtual String get_initial_title() {
		return(Application.get_display_name());
	}

	public virtual Image get_initial_icon() {
		return(IconCache.get("appicon"));
	}

	public virtual DesktopWindowMenuBar create_menubar() {
		if(enable_menubar == false) {
			return(null);
		}
		return(new DesktopWindowMenuBar());
	}

	public virtual void populate_menubar(DesktopWindowMenuBar mb) {
		// about
		if(enable_about) {
			var about = ActionItem.for_text("About ".append(Application.get_display_name()));
			about.set_action(new AboutApplicationAction());
			mb.set_about_item(about);
		}

		// app menu actions
		if(enable_preferences || enable_quit) {
			var appmenu = mb.get_or_create_app_menu();
			if(enable_preferences) {
				appmenu.add(ActionItem.for_text("Preferences ..").set_action(new ApplicationPreferencesAction()));
				if(enable_quit) {
					appmenu.add_separator();
				}
			}
			if(enable_quit) {
				appmenu.add(ActionItem.for_text("Quit").set_action(new ExitApplicationAction().set_frame(get_frame())).set_shortcut("q"));
			}
		}

		// file menu actions
		if(enable_new || enable_open || enable_save || enable_save_as || enable_close) {
			var filemenu = mb.get_submenu("File");
			if(enable_new) {
				filemenu.append(ActionItem.for_text("New ..").set_shortcut("n").set_action(new NewHandler().set_widget(this)));
			}
			if(enable_open) {
				filemenu.append(ActionItem.for_text("Open ..").set_shortcut("o").set_action(new OpenHandler().set_widget(this)));
			}
			if(enable_save) {
				filemenu.append(ActionItem.for_text("Save").set_shortcut("s").set_action(new SaveHandler().set_widget(this)));
			}
			if(enable_save_as) {
				filemenu.append(ActionItem.for_text("Save As ..").set_shortcut("S").set_action(new SaveAsHandler().set_widget(this)));
			}
			filemenu.add_separator();
		}

		// edit menu actions
		if(enable_undo || enable_clipboard_actions) {
			var editmenu = mb.get_submenu("Edit");
			if(enable_undo) {
				editmenu.append(ActionItem.for_text("Undo").set_action(new UndoHandler().set_widget(this)));
			}
			if(enable_clipboard_actions) {
				if(editmenu.count() > 0) {
					editmenu.add_separator();
				}
				editmenu.append(ActionItem.for_text("Cut").set_shortcut("x").set_action(new CutHandler().set_widget(this)));
				editmenu.append(ActionItem.for_text("Copy").set_shortcut("c").set_action(new CopyHandler().set_widget(this)));
				editmenu.append(ActionItem.for_text("Paste").set_shortcut("v").set_action(new PasteHandler().set_widget(this)));
			}
			editmenu.add_separator();
		}

		// window menu actions
		if(enable_window_menu) {
			var windowmenu = mb.get_submenu("Window");
		}

		// help menu actions
		if(enable_weblink) {
			var url = Application.get_url();
			if(String.is_empty(url) == false) {
				var helpmenu = mb.get_submenu("Help");
				helpmenu.add(ActionItem.for_text("%s on the web ..".printf().add(Application.get_display_name()).to_string())
					.set_action(OpenURLAction.for_url(url)));
			}
		}
		if(String.is_empty(help_url) == false) {
			var helpmenu = mb.get_submenu("Help");
			helpmenu.add(ActionItem.for_text("%s Help ..".printf().add(Application.get_display_name()).to_string())
				.set_action(OpenURLAction.for_url(help_url)));
		}
	}

	public virtual void finalize_menubar(DesktopWindowMenuBar menubar) {
		if(enable_close) {
			var filemenu = menubar.get_submenu("File");
			if(filemenu.count() > 0) {
				filemenu.add_separator();
			}
			filemenu.append(ActionItem.for_text("Close").set_shortcut("w").set_action(new CloseHandler().set_widget(this)));
		}
	}

	public virtual ToolBar create_toolbar() {
		if(enable_toolbar == false) {
			return(null);
		}
		return(new ToolBar());
	}

	public virtual void populate_toolbar(ToolBar tb) {
		if(enable_new) {
			tb.add_entry(ActionItem.for_icon(IconCache.get("add")).set_text("New").set_action(new NewHandler().set_widget(this)));
		}
		if(enable_open) {
			tb.add_entry(ActionItem.for_icon(IconCache.get("open")).set_text("Open").set_action(new OpenHandler().set_widget(this)));
		}
		if(enable_save) {
			tb.add_entry(ActionItem.for_icon(IconCache.get("save")).set_text("Save")
				.set_action(new SaveHandler().set_widget(this)));
		}
		if(enable_save_as) {
			tb.add_entry(ActionItem.for_icon(IconCache.get("save")).set_text("Save As ..")
				.set_action(new SaveAsHandler().set_widget(this)));
		}
	}

	public virtual void finalize_toolbar(ToolBar tb) {
	}

	class MyCloseListener : CloseAwareWidgetListener, ModalDialogBooleanListener
	{
		property Widget widget;
		public void on_close_request_status(bool status) {
			if(status) {
				widget.close_frame();
			}
		}
		public void on_dialog_boolean_result(bool result) {
			if(result) {
				widget.close_frame();
			}
		}
	}

	public virtual String desktop_window_confirm_close() {
		return(null);
	}

	public void desktop_window_close() {
		if(is_main_window) {
			new ExitApplicationAction().set_frame(get_frame()).execute();
			return;
		}
		if(this is CloseAwareWidget) {
			((CloseAwareWidget)this).on_close_request(new MyCloseListener().set_widget(this));
			return;
		}
		var ccq = desktop_window_confirm_close();
		if(String.is_empty(ccq) == false) {
			ModalDialog.yesno(ccq, "Confirmation", new MyCloseListener().set_widget(this), get_frame());
			return;
		}
		close_frame();
	}

	public bool on_widget_engine_close_request() {
		desktop_window_close();
		return(false);
	}

	public Frame show() {
		return(Frame.open(WidgetEngine.for_widget(this)));
	}

	class MenuEventReceiver : EventReceiver
	{
		property Widget widget;
		public void on_event(Object o) {
			if(o != null && o is ActionItem) {
				if(((ActionItem)o).execute()) {
					return;
				}
			}
			if(widget != null) {
				widget.raise_event(o);
			}
		}
	}

	public virtual void update_menubar() {
		if(menubar != null) {
			var mb = create_menubar();
			if(mb == null) {
				menubar.initialize_menubar(null, null);
			}
			else {
				populate_menubar(mb);
				finalize_menubar(mb);
				menubar.initialize_menubar(mb, new MenuEventReceiver().set_widget(this));
			}
		}
	}

	public virtual void update_toolbar() {
		if(toolbar != null) {
			var tb = create_toolbar();
			if(tb == null) {
				toolbar.initialize_toolbar(null, null);
			}
			else {
				populate_toolbar(tb);
				finalize_toolbar(tb);
				toolbar.initialize_toolbar(tb, this);
			}
		}
	}

	public ContainerWidget add(Widget child) {
		if(content_layer == null) {
			return(base.add(child));
		}
		content_layer.add(child);
		return(this);
	}

	public void on_toolbar_entry_selected(ActionItem tbe) {
		if(tbe == null) {
			return;
		}
		if(tbe.execute()) {
			return;
		}
		raise_event(tbe.get_event());
	}

	public virtual void add_menubar(BoxWidget box) {
		if(allow_native_menubar) {
			IFDEF("target_osx") {
				menubar = OSXMenuBar.for_frame(get_frame());
			}
			IFDEF("target_win32") {
				menubar = WinMenuBar.for_frame(get_frame());
			}
			IFDEF("target_gtk") {
				menubar = GtkMenuBar.for_frame(get_frame());
			}
			IFDEF("target_uwpcs") {
				menubar = XamlMenuBar.for_frame(get_frame());
			}
			if(menubar != null) {
				return;
			}
		}
		var dmbw = DesktopMenuBarWidget.instance();
		menubar = dmbw;
		box.add(dmbw);
	}

	public virtual void add_toolbar(BoxWidget box) {
		if(allow_native_toolbar) {
			IFDEF("target_osx") {
				toolbar = OSXToolBar.for_frame(get_frame());
			}
			IFDEF("target_win32") {
				toolbar = WinToolBar.for_frame(get_frame());
			}
			IFDEF("target_gtk") {
				toolbar = GtkToolBar.for_frame(get_frame());
			}
			IFDEF("target_uwpcs") {
				toolbar = XamlToolBar.for_frame(get_frame());
			}
			if(toolbar != null) {
				return;
			}
		}
		var tb = ToolBarWidget.instance();
		toolbar = tb;
		box.add(tb);
	}

	public void initialize() {
		base.initialize();
		if(background_color != null) {
			add(CanvasWidget.for_color(background_color));
		}
		var box = BoxWidget.vertical();
		add_menubar(box);
		add_toolbar(box);
		var cl = LayerWidget.instance();
		box.add_box(1, cl);
		add(box);
		content_layer = cl;
		var tit = get_initial_title();
		if(tit != null) {
			set_frame_title(tit);
		}
		var ico = get_initial_icon();
		if(ico != null) {
			set_frame_icon(ico);
		}
	}

	public void on_initialized() {
		base.on_initialized();
		update_menubar();
		update_toolbar();
		var cm5 = px("50mm");
		if(get_width_request() < cm5 || get_height_request() < cm5) {
			set_size_request_override(px("130mm"), px("100mm"));
		}
	}

	public void cleanup() {
		base.cleanup();
		content_layer = null;
		if(toolbar != null) {
			toolbar.finalize();
			toolbar = null;
		}
		if(menubar != null) {
			menubar.finalize();
			menubar = null;
		}
	}

	public virtual bool open_file(File file) {
		return(false);
	}

	public bool open_files(Collection files) {
		foreach(File file in files) {
			if(open_file(file) == false) {
				return(false);
			}
		}
		return(true);
	}

	public void set_args(Collection args) {
		var files = LinkedList.create();
		foreach(String arg in args) {
			if(arg.has_prefix("-")) {
				continue;
			}
			files.add(File.for_native_path(arg));
		}
		if(Collection.is_empty(files) == false) {
			open_files(files);
		}
	}
}
