
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

public class ShellWidget : LayerWidget, Stringable
{
	property ShellEngine shell;
	ShellOutputWidget output;
	property Color background_color;
	property Color foreground_color;
	property TAParagraphWidgetCallback paragraph_callback;
	property Font font;

	public ShellWidget() {
		background_color = Theme.color("eq.widget.shell.background_color", "black");
		foreground_color = Theme.color("eq.widget.shell.foreground_color", "white");
		shell = new ShellEngine();
	}

	public void clear() {
		if(output != null) {
			output.clear();
		}
	}

	public ShellOutputWidget get_output() {
		return(output);
	}

	public ShellWidget set_working_directory(File wd) {
		if(shell != null) {
			shell.set_cwd(wd);
		}
		return(this);
	}

	public virtual void initialize_box_top(BoxWidget box) {
	}

	public virtual void initialize_box_bottom(BoxWidget box) {
	}

	public void initialize() {
		base.initialize();
		if(background_color != null) {
			add(CanvasWidget.for_color(background_color));
		}
		if(foreground_color != null) {
			set_draw_color(foreground_color);
		}
		var vb = VBoxWidget.instance();
		initialize_box_top(vb);
		output = new ShellOutputWidget();
		output.set_font(font);
		output.set_paragraph_callback(paragraph_callback);
		vb.add_vbox(1, output);
		initialize_box_bottom(vb);
		shell.set_output(output);
		shell.set_background_task_manager(this);
		add(vb);
	}

	public void cleanup() {
		base.cleanup();
		output = null;
		shell.kill_processes();
		shell.set_output(null);
		shell.set_background_task_manager(null);
	}

	public void terminate_processes() {
		if(shell != null) {
			shell.terminate_processes();
		}
	}

	public void println(String str) {
		if(shell != null) {
			shell.println(str);
		}
	}

	public void execute_command(ShellCommand command, ShellCommandListener listener = null) {
		if(command == null) {
			return;
		}
		if(output != null) {
			output.scroll_to_bottom();
		}
		shell.println("%s$ %s".printf().add(shell.get_cwd()).add(command.to_string()).to_string());
		shell.execute(command, listener);
	}

	public void execute_command_sequence(Collection commands, ShellCommandListener listener = null) {
		if(commands == null) {
			return;
		}
		if(output != null) {
			output.scroll_to_bottom();
		}
		shell.execute_sequence(commands, listener);
	}

	public String to_string() {
		if(output == null) {
			return(null);
		}
		return(output.to_string());
	}
}
