
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

public class InteractiveShellWidget : ShellWidget, EventReceiver
{
	LabelWidget cwd;
	ShellInputWidget input;
	Array history;
	String editbuffer;
	int historyindex = -1;
	property bool single_process_mode = true;
	ChangerWidget input_changer;
	Widget input_editor;
	Widget input_hider;
	LabelWidget progress_label;
	property bool prompt_current_directory = false;
	ShellProcess current_process;

	public void initialize_box_bottom(BoxWidget vb) {
		input_changer = ChangerWidget.instance();
		input_changer.set_switch_duration(0);
		input_changer.add_changer(input_editor = HBoxWidget.instance().set_spacing(px("1mm"))
			.add_hbox(0, cwd = LabelWidget.for_string("$ ").set_font(Theme.font().modify("2500um monospace")))
			.add_hbox(1, input = (ShellInputWidget)new ShellInputWidget().set_shell_engine(get_shell()).set_listener(this)));
		input_changer.add_changer(input_hider = HBoxWidget.instance().set_spacing(px("1mm"))
			.add_hbox(0, WaitAnimationWidget.instance())
			.add_hbox(1, progress_label = LabelWidget.for_string("(executing command..)").set_text_align(LabelWidget.LEFT)
				.set_font(Theme.font().modify("color=#CCCCCC")))
			.add_hbox(0, ButtonWidget.for_icon(IconCache.get("arrowdown")).set_draw_frame(false).set_draw_outline(false)
				.set_rounded(false).set_internal_margin("0mm").set_popup(MenuWidget.instance()
				.add_entry(IconCache.get("close"), "Close / interrupt process", "Terminate the command gracefully", "interrupt-process")
				.add_entry(IconCache.get("close"), "Kill process", "Kill the command forcefully", "kill-process")
			))
		);
		input_changer.activate(input_editor);
		vb.add_vbox(0, LayerWidget.instance()
			.add(CanvasWidget.for_color(Color.instance("#FFFFFF40")))
			.add(input_changer)
		);
	}

	public void initialize() {
		base.initialize();
		var shell = get_shell();
		if(shell != null) {
			shell.set_listener(this);
		}
	}

	public void cleanup() {
		base.cleanup();
		input = null;
		cwd = null;
		input_changer = null;
		input_editor = null;
		input_hider = null;
		progress_label = null;
		current_process = null;
		var shell = get_shell();
		if(shell != null) {
			shell.set_listener(null);
		}
	}

	public bool on_key_press(KeyEvent e) {
		if(e != null && e.is_shortcut() && "c".equals(e.get_str())) {
			raise_event("interrupt-process");
			return(true);
		}
		return(base.on_key_press(e));
	}

	public void grab_focus() {
		if(input != null && input.is_enabled()) {
			input.grab_focus();
		}
	}

	public virtual bool on_command(String cmd, ShellCommandListener listener = null) {
		if(single_process_mode && current_process != null) {
			return(false);
		}
		if(String.is_empty(cmd)) {
			return(false);
		}
		if(history == null) {
			history = Array.create();
		}
		history.append(cmd);
		historyindex = -1;
		editbuffer = null;
		execute_command(ShellCommand.for_string(cmd), listener);
		return(true);
	}

	void history_move(int dx) {
		if(history == null || history.count() < 1 || input == null) {
			return;
		}
		if(dx < 0) {
			int hi;
			if(historyindex < 0) {
				hi = history.count() - 1;
			}
			else if(historyindex == 0) {
				return;
			}
			else {
				hi = historyindex - 1;
			}
			var current = input.get_text();
			if(historyindex < 0) {
				editbuffer = current;
			}
			else {
				history.set(historyindex, current);
			}
			historyindex = hi;
			input.set_text(String.as_string(history.get(historyindex)));
		}
		else if(dx > 0) {
			if(historyindex < 0) {
				return;
			}
			history.set(historyindex, input.get_text());
			if(historyindex+1 >= history.count()) {
				input.set_text(editbuffer);
				editbuffer = null;
				historyindex = -1;
				return;
			}
			historyindex ++;
			input.set_text(String.as_string(history.get(historyindex)));
		}
	}

	public void on_event(Object o) {
		if("interrupt-process".equals(o)) {
			if(current_process != null) {
				current_process.interrupt();
			}
			return;
		}
		if("kill-process".equals(o)) {
			if(current_process != null) {
				current_process.kill();
			}
			return;
		}
		if(o is KeyEvent) {
			if("up".equals(((KeyEvent)o).get_name())) {
				history_move(-1);
			}
			else if("down".equals(((KeyEvent)o).get_name())) {
				history_move(1);
			}
			else if("pageup".equals(((KeyEvent)o).get_name())) {
				var output = get_output();
				if(output != null) {
					output.scroll_page(-1);
				}
			}
			else if("pagedown".equals(((KeyEvent)o).get_name())) {
				var output = get_output();
				if(output != null) {
					output.scroll_page(1);
				}
			}
			return;
		}
		if(o is TextInputWidgetEvent && ((TextInputWidgetEvent)o).get_selected()) {
			var w = ((TextInputWidgetEvent)o).get_widget();
			if(w != null) {
				var tt = w.get_text();
				on_command(tt);
				w.set_text("");
			}
			return;
		}
		if(o is ShellEngineCwdChangedEvent) {
			on_cwd_changed(((ShellEngineCwdChangedEvent)o).get_cwd());
			return;
		}
		if(o is ShellProcessStartEvent) {
			if(single_process_mode) {
				current_process = ((ShellProcessStartEvent)o).get_process();
				var cmd = ((ShellProcessStartEvent)o).get_command();
				String txt;
				if(cmd != null) {
					txt = cmd.to_string();
				}
				if(String.is_empty(txt)) {
					txt = "(Executing command ..)";
				}
				else {
					txt = "(Executing: `%s' ..)".printf().add(txt).to_string();
				}
				progress_label.set_text(txt);
				input_changer.activate(input_hider);
			}
			return;
		}
		if(o is ShellProcessExitEvent) {
			if(single_process_mode) {
				current_process = null;
				input_changer.activate(input_editor);
				input.grab_focus();
			}
			return;
		}
	}

	public virtual void on_cwd_changed(File newcwd) {
		if(prompt_current_directory) {
			String bn;
			if(newcwd != null) {
				bn = newcwd.basename();
			}
			cwd.set_text("%s$ ".printf().add(bn).to_string());
		}
	}
}
