
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

public class FileListWidget : ListSelectorWidget
{
	public static FileListWidget for_directory(File dd) {
		return(new FileListWidget().set_directory(dd));
	}

	File directory;
	property FileIconProvider icon_provider;
	bool show_hidden_files = false;
	bool show_directories = false;
	bool show_parent_directory = false;
	Widget loading_widget;
	BackgroundTask loading_task;
	ItemReceiver handler;

	public FileListWidget() {
		set_show_desc(false);
		set_show_icon(true);
		icon_provider = new DefaultFileIconProvider();
	}

	public FileListWidget set_directory(File newdir, bool frefresh = false) {
		if((newdir == null && directory == null) || (newdir != null && newdir.is_same(directory))) {
			if(frefresh == false) {
				return(this);
			}
		}
		directory = newdir;
		if(is_initialized()) {
			refresh();
		}
		return(this);
	}

	public File get_directory() {
		return(directory);
	}

	public FileListWidget set_show_hidden_files(bool v) {
		if(v == show_hidden_files) {
			return(this);
		}
		show_hidden_files = v;
		if(is_initialized()) {
			refresh();
		}
		return(this);
	}

	public bool get_show_hidden_files() {
		return(show_hidden_files);
	}

	public FileListWidget set_show_directories(bool v) {
		if(v == show_directories) {
			return(this);
		}
		show_directories = v;
		if(is_initialized()) {
			refresh();
		}
		return(this);
	}

	public bool get_show_directories() {
		return(show_directories);
	}

	public FileListWidget set_show_parent_directory(bool v) {
		if(v == show_parent_directory) {
			return(this);
		}
		show_parent_directory = v;
		if(is_initialized()) {
			refresh();
		}
		return(this);
	}

	void stop_loading() {
		if(loading_widget != null) {
			remove(loading_widget);
			loading_widget = null;
		}
		if(loading_task != null) {
			loading_task.abort();
			loading_task = null;
		}
	}

	public void set_loading_status(bool status) {
		stop_loading();
		if(status) {
			add(loading_widget = AlignWidget.instance().add(new WaitAnimationWidget().set_size_request_override(px("40mm"), px("40mm"))));
		}
	}

	class ItemReceiver : EventReceiver
	{
		property bool start = false;
		property FileListWidget list;
		public void on_event(Object o) {
			list.set_loading_status(false);
			list.set_items(o as Collection);
			set_start(false);
		}
	}

	public virtual void refresh() {
		if(loading_task != null) {
			loading_task.abort();
			loading_task = null;
		}
		set_items(null);
		if(directory != null) {
			set_loading_status(true);
			loading_task = start_task(new SortedDirectoryDataProvider().set_directory(directory).set_show_directories(show_directories)
				.set_show_parent_directory(show_parent_directory).set_show_hidden_files(show_hidden_files)
				.set_icon_provider(icon_provider), handler.set_start(true));
		}
	}

	public void initialize() {
		base.initialize();
		handler = new ItemReceiver().set_list(this);
		refresh();
	}

	public void cleanup() {
		base.cleanup();
		if(loading_task != null) {
			loading_task.abort();
			loading_task = null;
		}
	}

	public void start() {
		base.start();
		if(handler.get_start()) {
			refresh();
		}
	}

	public void stop() {
		base.stop();
		stop_loading();
	}

	public virtual void on_file_selected(File file) {
		if(file == null) {
			return;
		}
		raise_event(file);
	}

	public virtual Widget get_context_widget_for_file(File file) {
		return(null);
	}

	public void on_action_item_context(ActionItem ai) {
		if(ai != null) {
			popup(get_context_widget_for_file(ai.get_data() as File));
		}
	}

	public void on_action_item_clicked(ActionItem ai) {
		if(ai != null) {
			on_file_selected(ai.get_data() as File);
		}
	}
}
