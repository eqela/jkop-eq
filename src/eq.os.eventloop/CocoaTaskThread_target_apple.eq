
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

public class CocoaTaskThread : TaskThread
{
	class MyTaskThread {
		embed "objc" {{{
			#include <Foundation/Foundation.h>

			@interface MyTaskThread : NSObject
			{
				void * taskThread;
			}
			- (void)setTaskThread:(void*)tthread;
			- (void)add;
			@end

			@implementation MyTaskThread
			- (void) setTaskThread:(void*)tthread
			{
				taskThread = tthread;
			}
			- (void) main_thread_function
			{
				if(taskThread != nil) {
					eq_os_eventloop_TaskThread_handle_thread_signal_in_main_thread(taskThread);
					unref_eq_api_Object(taskThread);
				}
			}
			- (void) add
			{
				if(taskThread == nil) {
					return;
				}
				ref_eq_api_Object(taskThread);
				[self performSelectorOnMainThread:@selector(main_thread_function) withObject:self waitUntilDone:NO];
			}
			@end
		}}}
	}

	ptr thp;

	embed "c" {{{
		#include <sys/types.h>
		#include <sys/socket.h>
		#include <unistd.h>
		#include <fcntl.h>
	}}}

	public bool do_initialize() {
		var myself = this;
		ptr thpp;
		embed "objc" {{{
			MyTaskThread* thp = [[MyTaskThread alloc] init];
			[thp setTaskThread:myself];
			thpp = (__bridge_retained void*)thp;
		}}}
		this.thp = thpp;
		return(true);
	}

	public void do_shutdown() {
		if(thp != null) {
			var thpp = thp;
			embed "objc" {{{
				MyTaskThread* thp = (__bridge_transfer MyTaskThread*)thpp;
			}}}
			this.thp = null;
		}
	}

	public void send_thread_signal() {
		var thpp = thp;
		embed "objc" {{{
			if(thpp != nil) {
				MyTaskThread* tta = (__bridge MyTaskThread*)thpp;
				[tta add];
			}
		}}}
	}
}
