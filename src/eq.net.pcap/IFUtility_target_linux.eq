
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

public class IFUtility
{
	embed "c" {{{
		#include <arpa/inet.h>
		#include <sys/socket.h>
		#include <netdb.h>
		#include <ifaddrs.h>
		#include <stdio.h>
		#include <stdlib.h>
		#include <unistd.h>
		#include <linux/if_link.h>
	}}}

	static Collection addresses;

	public static bool is_address_local(String ip) {
		foreach(String address in get_if_addresses()) {
			if(address.equals(ip)) {
				return(true);
			}
		}
		return(false);
	}

	public static Collection get_if_addresses(bool new_copy = false) {
		if(new_copy == false && addresses != null) {
			return(addresses);
		}
		addresses = LinkedList.create();
		var failed = 0;
		strptr if_str = null;
		embed "c" {{{
			struct ifaddrs *ifaddr, *ifa;
			int family, s, n;
			char host[NI_MAXHOST];
			if(getifaddrs(&ifaddr) == -1) {
				perror("getifaddrs");
				failed = 1;
			}
			else {
				for(ifa = ifaddr, n = 0; ifa != NULL; ifa = ifa->ifa_next, n++) {
					if(ifa->ifa_addr == NULL)
						continue;
					if(ifa->ifa_addr->sa_family == AF_INET) {
						s = getnameinfo(ifa->ifa_addr, sizeof(struct sockaddr_in), host, NI_MAXHOST, NULL, 0, NI_NUMERICHOST);
						if(s != 0) {
							printf("IFUtility: getnameinfo() failed: %s\n", gai_strerror(s));
							failed = 1;
							break;
						}
						if_str = strdup(host);
						}}}
							addresses.add(String.for_strptr(if_str));
						embed "c" {{{
					}
				}
				freeifaddrs(ifaddr);
			}
		}}}
		if(failed != 0) {
			addresses = null;
		}
		return(addresses);
	}
}