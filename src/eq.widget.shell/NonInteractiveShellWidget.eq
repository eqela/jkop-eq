
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

public class NonInteractiveShellWidget : ShellWidget
{
	public static NonInteractiveShellWidget for_command(ShellCommand command) {
		return(new NonInteractiveShellWidget().set_command(command));
	}

	public static NonInteractiveShellWidget for_command_sequence(Collection commands, ShellCommandListener ll = null) {
		return(new NonInteractiveShellWidget().set_command_sequence(commands)
			.set_command_sequence_listener(ll));
	}

	property ShellCommand command;
	property Collection command_sequence;
	property ShellCommandListener command_sequence_listener;

	public void initialize() {
		base.initialize();
	}

	public void cleanup() {
		base.cleanup();
	}

	public void initialize_box_top(BoxWidget box) {
	}

	public void first_start() {
		base.first_start();
		if(command != null) {
			execute_command(command);
		}
		else if(command_sequence != null) {
			execute_command_sequence(command_sequence, command_sequence_listener);
		}
		command = null;
		command_sequence = null;
		command_sequence_listener = null;
	}
}
