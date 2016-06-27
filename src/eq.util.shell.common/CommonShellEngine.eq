
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

public class CommonShellEngine : ShellEngine
{
	public ShellExecutable get_internal_executable(String cmdname) {
		if("break".equals(cmdname)) {
			return(new ShellCommandBreak());
		}
		if("test".equals(cmdname)) {
			return(new ShellCommandTest());
		}
		if("pwd".equals(cmdname)) {
			return(new ShellCommandPwd());
		}
		if("ls".equals(cmdname) || "dir".equals(cmdname)) {
			return(new ShellCommandDir());
		}
		if("cat".equals(cmdname) || "type".equals(cmdname)) {
			return(new ShellCommandCat());
		}
		if("cp".equals(cmdname) || "copy".equals(cmdname)) {
			return(new ShellCommandCopy());
		}
		if("rm".equals(cmdname) || "del".equals(cmdname)) {
			return(new ShellCommandDelete());
		}
		if("mkdir".equals(cmdname)) {
			return(new ShellCommandMkdir());
		}
		if("rename".equals(cmdname) || "ren".equals(cmdname)) {
			return(new ShellCommandRename());
		}
		if("move".equals(cmdname) || "mv".equals(cmdname)) {
			return(new ShellCommandMove());
		}
		if("echo".equals(cmdname)) {
			return(new ShellCommandEcho());
		}
		if("set".equals(cmdname)) {
			return(new ShellCommandSet());
		}
		return(null);
	}
}
