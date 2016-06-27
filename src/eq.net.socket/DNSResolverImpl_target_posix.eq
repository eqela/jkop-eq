
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
	IFDEF("target_ios") {
		embed "objc" {{{
			#include <Foundation/Foundation.h>
			#include <stdio.h>
			#include <netdb.h>
			#include <unistd.h>
			#include <sys/socket.h>
			#include <netinet/in.h>
			#include <arpa/inet.h>
		}}}
	}
	ELSE {
		embed "c" {{{
			#include <netdb.h>
			#include <sys/socket.h>
			#include <netinet/in.h>
			#include <arpa/inet.h>
		}}}
	}

	embed {{{
		#define BIND_8_COMPAT
		#include <string.h>
		#include <sys/types.h>
		#include <arpa/nameser.h>
		#include <resolv.h>
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
		if(host == null) {
			return(null);
		}
		var hp = host.to_strptr();
		if(hp == null) {
			return(null);
		}
		int tt = -1;
		if(String.is_empty(type)) {
			embed {{{
				tt = T_ANY;
			}}}
		}
		else {
			var tl = type.lowercase();
			var tp = tl.to_strptr();
			embed {{{
				if(!strcmp(tp, "a")) { tt = T_A; }
				else if(!strcmp(tp, "ns")) { tt = T_NS; }
				else if(!strcmp(tp, "md")) { tt = T_MD; }
				else if(!strcmp(tp, "mf")) { tt = T_MF; }
				else if(!strcmp(tp, "cname")) { tt = T_CNAME; }
				else if(!strcmp(tp, "soa")) { tt = T_SOA; }
				else if(!strcmp(tp, "mb")) { tt = T_MB; }
				else if(!strcmp(tp, "mg")) { tt = T_MG; }
				else if(!strcmp(tp, "mr")) { tt = T_MR; }
				else if(!strcmp(tp, "null")) { tt = T_NULL; }
				else if(!strcmp(tp, "wks")) { tt = T_WKS; }
				else if(!strcmp(tp, "ptr")) { tt = T_PTR; }
				else if(!strcmp(tp, "hinfo")) { tt = T_HINFO; }
				else if(!strcmp(tp, "minfo")) { tt = T_MINFO; }
				else if(!strcmp(tp, "mx")) { tt = T_MX; }
				else if(!strcmp(tp, "txt")) { tt = T_TXT; }
				else if(!strcmp(tp, "rp")) { tt = T_RP; }
				else if(!strcmp(tp, "afsdb")) { tt = T_AFSDB; }
				else if(!strcmp(tp, "x25")) { tt = T_X25; }
				else if(!strcmp(tp, "isdn")) { tt = T_ISDN; }
				else if(!strcmp(tp, "rt")) { tt = T_RT; }
				else if(!strcmp(tp, "nsap")) { tt = T_NSAP; }
				else if(!strcmp(tp, "nsap_ptr")) { tt = T_NSAP_PTR; }
				else if(!strcmp(tp, "sig")) { tt = T_SIG; }
				else if(!strcmp(tp, "key")) { tt = T_KEY; }
				else if(!strcmp(tp, "px")) { tt = T_PX; }
				else if(!strcmp(tp, "gpos")) { tt = T_GPOS; }
				else if(!strcmp(tp, "aaaa")) { tt = T_AAAA; }
				else if(!strcmp(tp, "loc")) { tt = T_LOC; }
				else if(!strcmp(tp, "nxt")) { tt = T_NXT; }
				else if(!strcmp(tp, "eid")) { tt = T_EID; }
				else if(!strcmp(tp, "nimloc")) { tt = T_NIMLOC; }
				else if(!strcmp(tp, "srv")) { tt = T_SRV; }
				else if(!strcmp(tp, "atma")) { tt = T_ATMA; }
				else if(!strcmp(tp, "naptr")) { tt = T_NAPTR; }
				else if(!strcmp(tp, "ixfr")) { tt = T_IXFR; }
				else if(!strcmp(tp, "axfr")) { tt = T_AXFR; }
				else if(!strcmp(tp, "mailb")) { tt = T_MAILB; }
				else if(!strcmp(tp, "maila")) { tt = T_MAILA; }
				else if(!strcmp(tp, "any")) { tt = T_ANY; }
			}}}
			if(tt < 0) {
				Log.debug("Unknown DNS record type `%s'".printf().add(type), logger);
				return(null);
			}
		}
		int r;
		embed {{{
			char buffer[8192];
			r = res_search(hp, C_IN, tt, (u_char*)buffer, 8192);
		}}}
		if(r < 0) {
			Log.debug("res_search for %s / `%s' failed.".printf().add(type).add(host), logger);
			return(null);
		}
		embed {{{
			ns_msg msg;
			r = ns_initparse((const u_char*)buffer, r, &msg);
		}}}
		if(r < 0) {
			Log.debug("ns_initparse for %s / `%s' failed.".printf().add(type).add(host), logger);
			return(null);
		}
		var v = LinkedList.create();
		int cc = 0;
		embed {{{
			cc = ns_msg_count(msg, ns_s_an);
		}}}
		if(cc < 1) {
			Log.debug("Looking for %s / `%s': No results".printf().add(type).add(host), logger);
			return(v);
		}
		int n;
		strptr name;
		int pr;
		int ttl;
		embed {{{
			char namebuf[MAXDNAME];
		}}}
		for(n=0; n<cc; n++) {
			name = null;
			embed {{{
				ns_rr rr;
				if(ns_parserr(&msg, ns_s_an, n, &rr) < 0) {
					continue;
				}
				ttl = ns_rr_ttl(rr);
				int rt = ns_rr_type(rr);
				if(rt == T_MX) {
					pr = ns_get16(ns_rr_rdata(rr));
					if(ns_name_uncompress(ns_msg_base(msg), ns_msg_end(msg), ns_rr_rdata(rr) + NS_INT16SZ, namebuf, MAXDNAME) < 0) {
						continue;
					}
					name = namebuf;
					}}}
					if(name != null) {
						var mx = new DNSRecordMX();
						mx.set_ttl(ttl);
						mx.set_priority(pr);
						mx.set_address(String.for_strptr(name).dup());
						v.add(mx);
					}
					embed {{{
				}
				else if(rt == T_NS) {
					if(ns_name_uncompress(ns_msg_base(msg), ns_msg_end(msg), ns_rr_rdata(rr), namebuf, MAXDNAME) < 0) {
						continue;
					}
					name = namebuf;
					}}}
					if(name != null) {
						var mx = new DNSRecordNS();
						mx.set_ttl(ttl);
						mx.set_address(String.for_strptr(name).dup());
						v.add(mx);
					}
					embed {{{
				}
				else if(rt == T_A) {
					struct in_addr* a = (struct in_addr*)ns_rr_rdata(rr);
					if(a == NULL) {
						continue;
					}
					name = inet_ntoa(*a);
					}}}
					if(name != null) {
						var mx = new DNSRecordA();
						mx.set_ttl(ttl);
						mx.set_address(String.for_strptr(name).dup());
						v.add(mx);
					}
					embed {{{
				}
				else if(rt == T_CNAME) {
					struct in_addr* a = (struct in_addr*)ns_rr_rdata(rr);
					if(a == NULL) {
						continue;
					}
					name = inet_ntoa(*a);
					}}}
					if(name != null) {
						var mx = new DNSRecordCNAME();
						mx.set_ttl(ttl);
						mx.set_address(String.for_strptr(name).dup());
						v.add(mx);
					}
					embed {{{
				}
			}}}
		}
		return(v);
	}
}
