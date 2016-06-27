
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

public class IOSCalendarManager : CalendarManager
{
	embed "objc" {{{
		#import <EventKit/EventKit.h>
		#import <EventKitUI/EventKitUI.h>
	}}}

	ptr es;

	public IOSCalendarManager() {
		ptr pes;
		embed "objc" {{{
			EKEventStore *eventStore = [[EKEventStore alloc] init];
			pes = (__bridge_retained void*)eventStore;
		}}}
		es = pes;
		request_calendar_access();
	}

	public String add_calendar(String title, Color c) {
		if(String.is_empty(title)) {
			return(null);
		}
		if(c == null) {
			return(null);
		}
		ptr p = es;
		var titlep = title.to_strptr();
		double cr = c.get_r(), cg = c.get_g(), cb = c.get_b(), ca = c.get_a();
		bool added;
		embed "objc" {{{
			NSString *nsTitle = [NSString stringWithUTF8String:titlep];
			EKEventStore *eventStore = (__bridge EKEventStore*)p;
			EKCalendar *calendar = nil;
			NSString *reqSysVer = @"6.0";
			NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
			if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending) {
				calendar = [EKCalendar calendarForEntityType:EKEntityTypeEvent  eventStore:eventStore];	
			}
			else {
				calendar = [EKCalendar calendarWithEventStore:eventStore];
			}
			calendar.title = nsTitle;
			CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
			CGFloat components[] = { cr, cg, cb, ca };
			CGColorRef color = CGColorCreate(colorspace, components);
			calendar.CGColor = color;
			CGColorSpaceRelease(colorspace);
			CGColorRelease(color);
			EKSource *theSource = nil;
			for (EKSource *source in eventStore.sources) {
			  if (source.sourceType == EKSourceTypeLocal) {
					theSource = source;
					break;
			   }
			}
			if(theSource) {
			  calendar.source = theSource;
			} else {
			   return(nil);
			}
			added = eq_util_calendar_IOSCalendarManager_save_calendar(self, (__bridge void*)calendar);
		}}}
		String id = null;
		if(added) {
			strptr pid;
			embed "objc" {{{
				pid = [calendar.calendarIdentifier UTF8String];
			}}}
			return(String.for_strptr(pid).dup());
		}
		return(id);
	}

	public bool remove_calendar(String calendar_id) {
		if(String.is_empty(calendar_id)) {
			return(false);
		}
		ptr p = es;
		bool removed;
		ptr cal = get_calendar_by_id(calendar_id);
		if(cal == null) {
			return(false);
		}
		embed "objc" {{{
			NSError *err;
			removed = [(__bridge EKEventStore*)p removeCalendar:(__bridge EKCalendar*)cal commit:YES error:&err];
		}}}
		return(removed);
	}

	private bool save_calendar(ptr cal) {
		ptr p = es;
		bool saved;
		embed "objc" {{{
			NSError *err;
			saved = [(__bridge EKEventStore*)p saveCalendar:(__bridge EKCalendar*)cal commit:YES error:&err];
		}}}
		return(saved);
	}

	private void request_calendar_access() {
		ptr p = es;
		embed "objc" {{{
			EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
			if(status == EKAuthorizationStatusNotDetermined || status == EKAuthorizationStatusDenied
				|| status == EKAuthorizationStatusRestricted) {
				[(__bridge EKEventStore*)p requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
				}];
			}
		}}}
	}

	private ptr get_calendar_by_id(String id) {
		ptr cal;
		ptr p = es;
		ptr idp = id.to_strptr();
		embed "objc" {{{
			NSString *nsId = [NSString stringWithUTF8String:idp];
			EKEventStore *eventStore = (__bridge EKEventStore*)p;
			EKCalendar *calendar = [eventStore calendarWithIdentifier:nsId];
			cal = (__bridge void*)calendar;
		}}}
		return(cal);
	}

	private ptr get_event_by_id(String id) {
		ptr e;
		ptr p = es;
		var idp = id.to_strptr();
		embed "objc" {{{
			NSString *nsId = [NSString stringWithUTF8String:idp];
			EKEventStore *eventStore = (__bridge EKEventStore*)p;
			EKEvent *event = [eventStore eventWithIdentifier:nsId];
			e = (__bridge void*)event;
		}}}
		return(e);
	}

	public bool add_event(String title, long date_in_seconds = 0, String calendar_id, String desc = null) {
		if(String.is_empty(title) || String.is_empty(calendar_id)) {
			return(false);
		}
		bool added;
		ptr p = es;
		var titlep = title.to_strptr();
		strptr descp = null;
		if(String.is_empty(desc) == false) {
			descp = desc.to_strptr();
		}
		ptr cal = get_calendar_by_id(calendar_id);
		if(cal == null) {
			return(false);
		}
		embed "objc" {{{
			NSString *nsTitle = [NSString stringWithUTF8String:titlep];
			EKEventStore *eventStore = (__bridge EKEventStore*)p;
			EKEvent *event = [EKEvent eventWithEventStore:eventStore];
			event.title = nsTitle;
			if(descp != nil) {
				NSString *nsDesc = [NSString stringWithUTF8String:descp];
				event.notes = nsDesc;
			}
			NSDate *nsDate = [NSDate dateWithTimeIntervalSince1970:date_in_seconds];
			event.startDate = nsDate;
			event.endDate = nsDate;
			EKCalendar *calendar = (__bridge EKCalendar*)cal;
			event.calendar = calendar;	
			added = eq_util_calendar_IOSCalendarManager_save_event(self, (__bridge void*)event);
		}}}
		return(added);
	}

	private bool save_event(ptr e) {
		ptr p = es;
		bool saved;
		embed "objc" {{{
			NSError *err;
			saved = [(__bridge EKEventStore*)p saveEvent:(__bridge EKEvent*)e span:nil commit:YES error:&err];
		}}}
		return(saved);
	}

	public Collection get_all_events()
	{
		var col = LinkedList.create();
		ptr p = es;
		strptr idp, titlep, descp, datep;
		long stdate = 0;
		Event eq_event;
		embed "objc" {{{
			EKEventStore *eventStore = (__bridge EKEventStore*)p;
			NSCalendar *calendar = [NSCalendar currentCalendar];
			NSDateComponents *yearsAgoComponents = [[NSDateComponents alloc] init];
			yearsAgoComponents.year = -50;
			NSDate *start = [calendar dateByAddingComponents:yearsAgoComponents toDate:[NSDate date] options:0];
			NSDateComponents *yearsFromNowComponents = [[NSDateComponents alloc] init];
			yearsFromNowComponents.year = 50;
			NSDate *finish = [calendar dateByAddingComponents:yearsFromNowComponents toDate:[NSDate date]options:0];
			NSMutableArray *events = [[NSMutableArray alloc] init];
			NSDate* currentStart = [NSDate dateWithTimeInterval:0 sinceDate:start];
			NSDateComponents *oneYearFromCurrentStartComponents = [[NSDateComponents alloc] init];
			oneYearFromCurrentStartComponents.year = 1;
			while ([currentStart compare:finish] == NSOrderedAscending) {
				NSDate* currentFinish = [calendar dateByAddingComponents:oneYearFromCurrentStartComponents toDate:currentStart options:0];
				if ([currentFinish compare:finish] == NSOrderedDescending) {
					currentFinish = [NSDate dateWithTimeInterval:0 sinceDate:finish];
				}
				NSPredicate *predicate = [eventStore predicateForEventsWithStartDate:currentStart endDate:currentFinish calendars:nil];
				[eventStore enumerateEventsMatchingPredicate:predicate
					usingBlock:^(EKEvent *event, BOOL *stop) {
						if (event) {
							[events addObject:event];
						}
					}
				];
				currentStart = [calendar dateByAddingComponents:oneYearFromCurrentStartComponents toDate:currentStart options:0];
			}
			NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
			[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
			[dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
			NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
			[dateFormatter setLocale:enUSPOSIXLocale];
			for(EKEvent *e in events) {
				idp = [[e eventIdentifier] UTF8String];
				titlep = [[e title] UTF8String];
				if(e.hasNotes) {
					descp = [[e notes] UTF8String];
				}
				stdate = e.startDate.timeIntervalSince1970;
				datep = [[dateFormatter stringFromDate:e.startDate] UTF8String];
				}}}
				eq_event = new Event();
				eq_event.set_id(String.for_strptr(idp).dup());
				eq_event.set_title(String.for_strptr(titlep).dup());
				if(descp != null) {
					eq_event.set_description(String.for_strptr(descp).dup());
				}
				eq_event.set_seconds(stdate);
				eq_event.set_date(String.for_strptr(datep).dup());
				col.add(eq_event);
				embed "objc" {{{
			}	
		}}}
		return(col);
	}
}
