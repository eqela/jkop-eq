
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

public class HTTPClientOperation
{
	embed "objc" {{{
		#import <Foundation/Foundation.h>

		@interface MyNSURLConnectionDataDelegate : NSObject <NSURLConnectionDataDelegate>
		@property NSMutableData *responseData;
		@property NSURLConnection *conn;
		@property NSDictionary *dictionary;
		@property void* myself;
		@end

		@implementation MyNSURLConnectionDataDelegate
		@synthesize dictionary;
		- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
			int code;
			NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;	
			if ([response respondsToSelector:@selector(allHeaderFields)]) {
				dictionary = [httpResponse allHeaderFields];
				code = [httpResponse statusCode];
			}
			eq_net_http_HTTPClientOperation_HTTPClientTask_on_response_headers(self.myself, (__bridge void*)dictionary, code);
			[self.responseData setLength:0];
		}	

		- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
			[self.responseData appendData:data];
		}

		- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
			NSData* data = self.responseData;
			uint8_t* bytePtr = (uint8_t  * )[data bytes];
			eq_net_http_HTTPClientOperation_HTTPClientTask_on_read_completed(self.myself, bytePtr, [data length]);
		}

		-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
			NSString* error_msg = [error localizedDescription];
			int error_code = (int)[error code];
			eq_net_http_HTTPClientOperation_HTTPClientTask_on_failed(self.myself, [error_msg UTF8String], error_code);
		}

		- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
		{
			return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
		}

		- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
		{
	        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
		}	
		@end
	}}}

	class HTTPClientTask : BackgroundTask
	{
		HTTPClientRequest rq;
		EventReceiver listener;
		Buffer post_buffer;
		bool aborted;
		ptr nsurlconnection;

		public static HTTPClientTask start(HTTPClientRequest rq, EventReceiver listener) {
			var v = new HTTPClientTask();
			v.rq = rq;
			v.listener = listener;
			v.do_run();
			return(v);
		}

		public void do_run() {
			trigger_event(listener, new HTTPClientStartEvent());
			if(rq == null) {
				trigger_event(listener, new HTTPClientErrorEvent().set_message("No request"));
				return;
			}
			var mm = rq.get_method();
			var urlo = rq.get_url();
			var hdrs = rq.get_headers();
			if(urlo == null) {
				trigger_event(listener, new HTTPClientErrorEvent().set_message("No URL"));
				return;
			}
			var urls = urlo.to_string();
			var f_url = urls.to_strptr();
			embed "objc" {{{
				ref_eq_api_Object(self);
				MyNSURLConnectionDataDelegate* vc = [[MyNSURLConnectionDataDelegate alloc] init];
				vc.myself = self;
				NSMutableData* data = [[NSMutableData alloc] init];
				vc.responseData = data;
				NSURL* url = [NSURL URLWithString:[[NSString alloc] initWithUTF8String:f_url]];
				NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
				NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
				eq_net_http_HTTPClientOperation_HTTPClientTask_get_headers(self, (__bridge void*) dict);
				NSArray* keys;
				int i, count;
				id keystr, valstr, key, value;
				keys = [dict allKeys];
				count = [keys count];
				for (i = 0; i < count; i++)
				{
					keystr = [keys objectAtIndex: i];
					valstr = [dict objectForKey: keystr];
					[request setValue:valstr forHTTPHeaderField:keystr];
				}
			}}}
			if("GET".equals(mm)) {
				embed "objc" {{{
					[request setHTTPMethod:@"GET"];
				}}}
			}
			else if("POST".equals(mm) || "PUT".equals(mm)) {
				ptr np = null;
				int sz = 0;
				var rr = InputStream.create(rq.get_body());
				if(rr != null) {
					post_buffer = rr.read_all_buffer();
					if(post_buffer != null) {
						var ptr = post_buffer.get_pointer();
						sz = post_buffer.get_size();
						if(ptr != null) {
							np = ptr.get_native_pointer();
						}
					}
				}
				embed "objc" {{{
					[vc.conn cancel];
				}}}
				if("PUT".equals(mm)) {
					embed {{{
	    				[request setHTTPMethod:@"PUT"];
					}}}
				}
				else {
					embed {{{
	    				[request setHTTPMethod:@"POST"];
					}}}
				}
				embed {{{
					NSData* postData = [NSData dataWithBytes:np length:sz];				
    				[request setHTTPBody:postData];
				}}}
			}
			else if("DELETE".equals(mm)) {
				embed "objc" {{{
					[request setHTTPMethod:@"DELETE"];
				}}}
			}
			else {
				trigger_event(listener, new HTTPClientErrorEvent().set_message("Unsupported HTTP method: `%s'".printf().add(mm).to_string()));
				return;
			}
			ptr con;
			embed "objc" {{{			
				NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:vc];
	    		vc.conn = connection;
	    		[connection start];
				con = (__bridge_retained void*)connection;	
			}}}
			nsurlconnection = con;
		}

		void on_response_headers(ptr headers, ptr code) {
			var header = HashTable.create();
			strptr key, value;
			embed "objc" {{{
				NSDictionary *header_response = (__bridge NSDictionary*)headers;
				NSArray *keys;
				int i, count;
				id keystr, valstr;
				keys = [header_response allKeys];
				count = [keys count];
				for (i = 0; i < count; i++)
				{
					keystr = [keys objectAtIndex: i];
					valstr = [header_response objectForKey: keystr];
					key = [keystr UTF8String];
					value = [valstr UTF8String];
					}}}
					header.set(String.for_strptr(key).lowercase(), String.for_strptr(value));
					embed "objc" {{{
				}
			}}}
			var re = new HTTPClientResponseEvent();
			re.set_status(String.for_integer(code));
			re.set_headers(header);
			trigger_event(listener, re);
		}

		void get_headers(ptr header) {
			embed "objc" {{{
				NSMutableDictionary* dict = (__bridge NSMutableDictionary*)header;
			}}}
			String ua = null, content_type = null;
			var hdrs = rq.get_headers();
			if(hdrs != null) {
				foreach(String key in hdrs) {
					var val = hdrs.get_string(key);
					ptr value = val.to_strptr();
					ptr keys = key.to_strptr();
					if(val != null) {
						embed "objc" {{{
							NSString* valstr = [[NSString alloc] initWithUTF8String:value];
							NSString* keystr = [[NSString alloc] initWithUTF8String:keys];
							[dict setValue:valstr forKey:keystr];
							
						}}}
					}
				}
				ua = EqelaUserAgent.get_platform_user_agent(hdrs.get("User-Agent") as String);
			}
			if(ua != null) {
				ptr uaa = ua.to_strptr();
				embed "objc" {{{
					NSString* uastr = [[NSString alloc] initWithUTF8String:uaa];
					[dict setValue:uastr forKey:@"User-Agent"];
				}}}
			}
		}

		void trigger_event(EventReceiver listener, Object event) {
			if(event != null && event is Stringable) {
				Log.debug("(HTTPClientOperation) %s".printf().add(String.as_string(event)));
			}
			EventReceiver.event(listener, event);
			if(event is HTTPClientErrorEvent) {
				rq = null;
				trigger_event(listener, (Object)new HTTPClientEndEvent().set_complete(false));
			}
			if(event is HTTPClientEndEvent) {
				ptr con = nsurlconnection;
				nsurlconnection = null;
				embed "objc" {{{
					NSURLConnection* newconn = (__bridge_transfer NSURLConnection*)con;
					unref_eq_api_Object(self);
				}}}
			}
		}

		void on_failed(strptr cstr, int err) {
			String message = String.for_strptr(cstr);
			message = "%s: code `%d'".printf().add(message).add(err).to_string();
			trigger_event(listener, new HTTPClientErrorEvent().set_message(message));
		}

		void on_read_completed(ptr data, int size) {
			if(size == 0) {
				trigger_event(listener, new HTTPClientErrorEvent().set_message("Connection closed."));
				return;
			}
			var buffer = DynamicBuffer.create(size);
			if(buffer == null) {
				trigger_event(listener, new HTTPClientErrorEvent().set_message("Failed to allocate memory."));
				return;
			}
			var pbuffer = buffer.get_pointer();
			pbuffer.cpyfrom(Pointer.create(data), 0, 0, size);
			var de = new HTTPClientDataEvent();
			de.set_buffer(buffer);
			trigger_event(listener, (Object)de);
			trigger_event(listener, (Object)new HTTPClientEndEvent().set_complete(true));
		}

		public bool abort() {
			if(nsurlconnection == null) {
				return(false);
			}
			ptr con = nsurlconnection;
			embed "objc" {{{
				if(con != NULL) {
					NSURLConnection* abortcon = (__bridge NSURLConnection*)con;
					[abortcon cancel];
				}	
			}}}
			trigger_event(listener, new HTTPClientErrorEvent().set_message("Aborted"));
			return(true);
		}
	}

	public static BackgroundTask start(BackgroundTaskManager el, HTTPClientRequest rq, EventReceiver listener) {
		return(HTTPClientTask.start(rq, listener));
	}

	public static bool execute(HTTPClientRequest rq, EventReceiver listener) {
		HTTPClientTask.start(rq, listener);
		return(true);
	}
}
