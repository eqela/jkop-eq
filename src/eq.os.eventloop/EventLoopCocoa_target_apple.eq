
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

public class EventLoopCocoa : EventLoop, BackgroundTaskManager
{
	public static EventLoopCocoa instance() {
		return(new EventLoopCocoa());
	}

	bool should_stop = false;
	bool running = false;

	public bool is_running() {
		return(running);
	}

	public void execute() {
		Log.debug("Cocoa event loop starting.");
		should_stop = false;
		running = true;
		embed "objc" {{{
			NSRunLoop* rl = [NSRunLoop currentRunLoop];
			while([rl runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]) {
				}}}
				if(should_stop) {
					break;
				}
				embed "objc" {{{
			}
		}}}
		should_stop = false;
		running = false;
		Log.debug("Cocoa event loop exiting.");
	}

	public EventLoopEntry entry_for_object(Object o) {
		Log.error("EventLoopCocoa: entry_for_object is not implemented."); // FIXME
		return(null);
	}

	embed "objc" {{{
		#import <Foundation/Foundation.h>
		@interface WakeupClass : NSObject
		- (void) wakeup;
		@end
		@implementation WakeupClass
		- (void) wakeup
		{
		}
		@end
	}}}

	public void stop() {
		should_stop = true;
		embed "objc" {{{
			WakeupClass* wc = [[WakeupClass alloc] init];
			[wc performSelector:@selector(wakeup) onThread:[NSThread currentThread] withObject:nil waitUntilDone:NO];
		}}}
	}

	class TimerWrapper : BackgroundTask
	{
		TimerHandler o;
		Object arg;
		ptr timer;

		embed "objc" {{{
			#import <Foundation/Foundation.h>
			@interface TimerWrapperObjC : NSObject {
				void* wrapper;
				NSTimer* timer;
			}
			@end
			@implementation TimerWrapperObjC
			- (void) setWrapper:(void*)wr {
				wrapper = wr;
				ref_eq_api_Object(wrapper);
			}
			- (void) start:(int)ausec {
				int usec = ausec;
				if(usec < 1000) {
					usec = 1000;
				}
				timer = [NSTimer timerWithTimeInterval:((double)usec / 1000000.0) 
					target:self 
					selector:@selector(on_timer:) 
					userInfo:nil repeats:YES];
				[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
			}
			- (void) stop {
				if(timer != nil) {
					[timer invalidate];
					timer = nil;
				}
				if(wrapper != (void*)0) {
					void* pp = wrapper;
					wrapper = (void*)0;
					unref_eq_api_Object(pp);
				}
			}
			- (void) on_timer:(NSTimer*)timer {
				if(wrapper != (void*)0) {
					int r = eq_os_eventloop_EventLoopCocoa_TimerWrapper_on_timer(wrapper); 
					if(r == 0) {
						if(wrapper != (void*)0) {
							eq_os_eventloop_EventLoopCocoa_TimerWrapper_abort(wrapper);
						}
					}
				}
			}
			@end
		}}}

		public ~TimerWrapper() {
			abort();
		}

		public static TimerWrapper create(TimerHandler o, Object arg) {
			var v = new TimerWrapper();
			v.o = o;
			v.arg = arg;
			return(v);
		}

		public void start(int usec) {
			ptr tp;
			var myself = this;
			embed "objc" {{{
				TimerWrapperObjC* tw = [[TimerWrapperObjC alloc] init];
				[tw setWrapper:myself];
				[tw start:usec];
				tp = (__bridge_retained void*)tw;
			}}}
			this.timer = tp;
		}

		public bool abort() {
			var tp = timer;
			if(tp != null) {
				timer = null;
				embed "objc" {{{
					TimerWrapperObjC* tw = (__bridge_transfer TimerWrapperObjC*)tp;
					[tw stop];
				}}}
			}
			return(true);
		}

		public bool on_timer() {
			if(o != null) {
				return(o.on_timer(arg));
			}
			return(false);
		}
	}

	public BackgroundTask start_timer(int usec, TimerHandler o, Object arg) {
		var v = TimerWrapper.create(o, arg);
		v.start(usec);
		return(v);
	}

	public BackgroundTask start_task(RunnableTask task, EventReceiver listener, BackgroundTaskListener tasklistener) {
		if(task == null) {
			return(null);
		}
		var tt = new CocoaTaskThread();
		var v = new BackgroundTaskAdapter().set_task(task as BackgroundTask);
		tt.schedule(task, v.get_abortflag(), listener, tasklistener);
		return(v);
	}
}
