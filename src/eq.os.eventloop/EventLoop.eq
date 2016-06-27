
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

public interface EventLoop : BackgroundTaskManager
{
	public static EventLoop for_network(Logger logger) {
		IFDEF("target_linux") {
			return(EventLoopEpoll.instance(logger));
		}
		ELSE IFDEF("target_win32") {
			return(Win32MainQueue.instance());
		}
		ELSE IFDEF("target_posix") {
			return(EventLoopSelect.instance(logger));
		}
		ELSE IFDEF("target_net4cs") {
			return(EventLoopDotNetSelect.instance(logger));
		}
		ELSE IFDEF("target_monocs") {
			return(EventLoopDotNetSelect.instance(logger));
		}
		ELSE {
			return(null);
		}
	}

	public static EventLoop for_gui(Logger logger) {
		IFDEF("target_apple") {
			return(EventLoopCocoa.instance());
		}
		ELSE IFDEF("target_win32") {
			return(Win32MainQueue.instance());
		}
		ELSE IFDEF("target_posix") {
			return(EventLoopSelect.instance(logger));
		}
		ELSE {
			return(null);
		}
	}

	public EventLoopEntry entry_for_object(Object o);
	public void execute();
	public void stop();
	public bool is_running();
}
