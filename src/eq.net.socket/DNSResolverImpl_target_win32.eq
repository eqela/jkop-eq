
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

class DNSResolverImpl : DNSResolver
{
	embed "c" {{{
		#include <winsock2.h>
	}}}

	public static DNSResolver create() {
		return(new DNSResolverImpl());
	}

	public String get_ip_address(String hostname, Logger logger) {
		var cc = get_ip_addresses(hostname, logger);
		if(cc == null || cc.count() < 1) {
			return(null);
		}
		return(cc.get_index(0) as String);
	}

	public Collection get_ip_addresses(String hostname, Logger logger) {
		if(hostname == null) {
			return(null);
		}
		Collection v = LinkedList.create();
		var sp = hostname.to_strptr();
		strptr ss;
		embed "c" {{{
			struct in_addr addr;
			struct hostent* he = gethostbyname(sp);
			if(he == NULL) {
				return(NULL);
			}
			int n = 0;
			while(he->h_addr_list[n] != 0) {
				addr.s_addr = *(u_long*)he->h_addr_list[n];
				ss = inet_ntoa(addr);
				if(ss != NULL) {
					}}}
					v.add(String.for_strptr(ss).dup());
					embed "c" {{{
				}
				n++;
			}
		}}}
		return(v);
	}

	public Collection get_ns_records(String host, String type = null, Logger logger = null) {
		// FIXME: Implement. Use DnsQuery: http://msdn.microsoft.com/en-us/library/windows/desktop/ms682016(v=vs.85).aspx
		return(null);
	}
}
