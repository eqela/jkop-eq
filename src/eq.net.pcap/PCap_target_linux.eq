
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

public class PCap
{
	embed "c" {{{
		#include <pcap.h>
		#include <stdio.h>
		#include <string.h>
		#include <stdlib.h>
		#include <ctype.h>
		#include <errno.h>
		#include <sys/types.h>
		#include <sys/socket.h>
		#include <net/ethernet.h>
		#include <netinet/if_ether.h>
		#include <netinet/in.h>
		#include <netinet/ip.h>
		#include <netinet/ip_icmp.h>
		#include <netinet/tcp.h>
		#include <netinet/udp.h>
		#include <arpa/inet.h>
		/* default snap length (maximum bytes per packet to capture) */
		#define SNAP_LEN 1518

		void on_packet_captured_callback(u_char *args, const struct pcap_pkthdr *header, const u_char *packet);
		void on_icmp_packet_captured(u_char *args, int count, const char *ip_src, const char *ip_dst, const u_char* packet , int size);
		void on_tcp_packet_captured(u_char *args, int count, const char *ip_src, const char *ip_dst, const u_char* packet , int size);
		void on_udp_packet_captured(u_char *args, int count, const char *ip_src, const char *ip_dst, const u_char* packet , int size);

		void on_packet_captured_callback(u_char *args, const struct pcap_pkthdr *header, const u_char *packet)
		{
			static int packet_count = 0;
			packet_count++;
			int size = header->len;
			struct ip *ip = (struct ip*)(packet + sizeof(struct ethhdr));
			const char *ip_src = strdup(inet_ntoa(ip->ip_src));
			const char *ip_dst = strdup(inet_ntoa(ip->ip_dst));
			switch (ip->ip_p)
			{
				case IPPROTO_ICMP:
					on_icmp_packet_captured(args, packet_count, ip_src, ip_dst, packet , size);
					break;
				case IPPROTO_TCP:
					on_tcp_packet_captured(args, packet_count, ip_src, ip_dst, packet , size);
					break;
				case IPPROTO_UDP:
					on_udp_packet_captured(args, packet_count, ip_src, ip_dst, packet , size);
					break;
				default:
					eq_net_pcap_PCapListener_on_packet_captured(args, packet_count, "Unknown", ip_src, ip_dst, -1, -1, NULL, 0);
					break;
			}
		}

		void on_icmp_packet_captured(u_char *args, int count, const char *ip_src, const char *ip_dst, const u_char* packet , int size)
		{
			struct iphdr *ip_header = (struct iphdr*)(packet + sizeof(struct ethhdr));
			int ip_header_length = ip_header->ihl * 4;
			struct icmphdr *icmp_header = (struct icmphdr*)(packet + ip_header_length + sizeof(struct ethhdr));
			// const int icmph_type = (unsigned int)(icmp_header->type);
			// const int icmph_code = (unsigned int)(icmp_header->code);
			// const int icmph_checksum = ntohs(icmp_header->checksum);
			int icmp_header_size = sizeof(struct ethhdr) + ip_header_length + sizeof(icmp_header);
			const char *payload = (u_char*)(packet + icmp_header_size);
			int payload_size = size - icmp_header_size;
			eq_net_pcap_PCapListener_on_packet_captured(args, count, "ICMP", NULL, NULL, -1, -1, payload, payload_size);
		}

		void on_tcp_packet_captured(u_char *args, int count, const char *ip_src, const char *ip_dst, const u_char* packet , int size)
		{
			struct iphdr *ip_header = (struct iphdr*)(packet + sizeof(struct ethhdr));
			int ip_header_length = ip_header->ihl * 4;
			struct tcphdr *tcp_header = (struct tcphdr*)(packet + ip_header_length + sizeof(struct ethhdr));
			const int port_src = ntohs(tcp_header->th_sport);
			const int port_dst = ntohs(tcp_header->th_dport);
			// const int tcp_chk = ntohs(tcp_header->th_sum);
			int tcp_header_size = sizeof(struct ethhdr) + ip_header_length + tcp_header->doff*4;
			const char *payload = (u_char*)(packet + tcp_header_size);
			int payload_size = size - tcp_header_size;
			eq_net_pcap_PCapListener_on_packet_captured(args, count, "TCP", ip_src, ip_dst, port_src, port_dst, payload, payload_size);
		}

		void on_udp_packet_captured(u_char *args, int count, const char *ip_src, const char *ip_dst, const u_char* packet , int size)
		{
			struct iphdr *ip_header = (struct iphdr*)(packet + sizeof(struct ethhdr));
			int ip_header_length = ip_header->ihl * 4;
			struct udphdr *udp_header = (struct udphdr*)(packet + ip_header_length + sizeof(struct ethhdr));
			const int port_src = ntohs(udp_header->uh_sport);
			const int port_dst = ntohs(udp_header->uh_dport);
			// const int udp_len = ntohs(udp_header->len);
			// const int udp_chk = ntohs(udp_header->check);
			int udp_header_size = sizeof(struct ethhdr) + ip_header_length + sizeof(udp_header);
			const char *payload = (u_char*)(packet + udp_header_size);
			int payload_size = size - udp_header_size;
			eq_net_pcap_PCapListener_on_packet_captured(args, count, "UDP", ip_src, ip_dst, port_src, port_dst, payload, payload_size);
		}
	}}}

	class MyPCapListener : LoggerObject, PCapListener
	{
		class PacketCounter
		{
			property String ip;
			property int start_count_timestamp = 0;
			property int start_ignore_timestamp = 0;
			int packet_count = 1;

			public int get_count_after_increment() {
				return(++packet_count);
			}
		}

		public MyPCapListener() {
			packets = HashTable.create();
		}

		property PCapListener listener;
		property String protocol_filter;
		property int count_limit = 10;
		property int count_duration = 5;
		property int ignore_duration = 60;
		property int maintenance_cleanup_delay = 60;
		HashTable packets;
		int last_cleanup_timestamp = 0;

		public void on_maintenance_cleanup() {
			if(packets == null) {
				return;
			}
			var now = SystemClock.seconds();
			if((now - last_cleanup_timestamp) < maintenance_cleanup_delay) {
				return;
			}
			last_cleanup_timestamp = now;
			var keys = LinkedList.create();
			foreach(PacketCounter p in packets.iterate_values()) {
				if(p.get_start_ignore_timestamp() == 0 && (now - p.get_start_count_timestamp()) > count_duration) {
					keys.add(p.get_ip());
				}
			}
			foreach(String k in keys) {
				packets.remove(k);
			}
			Log.debug("PCapListener: on maintenance cleanup - Removed %d IP source(s)".printf().add(keys.count()).to_string());
		}

		public bool ignore_packet(String ip) {
			var now = SystemClock.seconds();
			var p = packets.get(ip) as PacketCounter;
			if(p == null) {
				packets.set(ip, new PacketCounter()
					.set_ip(ip)
					.set_start_count_timestamp(now));
				log_debug("PCapListener: ip_source: %s - Started counting".printf().add(ip).to_string());
				return(false);
			}
			if(p.get_start_ignore_timestamp() > 0) {
				if((now - p.get_start_ignore_timestamp()) <= ignore_duration) {
					log_debug("PCapListener: ip_source: %s - Ignoring in %d/%d seconds".printf().add(ip).add(now - p.get_start_ignore_timestamp()).add(ignore_duration).to_string());
					return(true);
				}
				log_debug("PCapListener: ip_source: %s - End ignoring".printf().add(ip).to_string());
				packets.remove(ip);
				return(false);
			}
			if((now - p.get_start_count_timestamp()) <= count_duration) {
				var count = p.get_count_after_increment();
				log_debug("PCapListener: ip_source: %s - Packet count: %d within %d/%d seconds".printf().add(ip).add(count).add(now - p.get_start_count_timestamp()).add(count_duration).to_string());
				if(count >= count_limit) {
					p.set_start_ignore_timestamp(now);
					log_message("PCapListener: ip_source: %s - Start ignoring (received %d packets in %d seconds, limit %d and %d)".printf().add(ip).add(count)
						.add(now-p.get_start_count_timestamp()).add(count_limit).add(count_duration).to_string());
					return(true);
				}
				return(false);
			}
			packets.remove(ip);
			return(false);
		}

		public void on_packet_captured(int packet_no, ptr protocol, ptr ip_src, ptr ip_dst, int port_src, int port_dst, ptr payload, int payload_size) {
			if(listener == null) {
				return;
			}
			on_maintenance_cleanup();
			var ip_source = String.for_strptr(ip_src);
			if(String.is_empty(ip_source)) {
				return;
			}
			if(IFUtility.is_address_local(ip_source)) {
				return;
			}
			if(ignore_packet(ip_source)) {
				return;
			}
			log_debug("PCapListener: id: %d protocol: %s from: %s:%d to: %s:%d size: %d bytes".printf()
				.add(packet_no)
				.add(String.for_strptr(protocol))
				.add(ip_source)
				.add(port_src)
				.add(String.for_strptr(ip_dst))
				.add(port_dst)
				.add(payload_size)
				.to_string());
			listener.on_packet_captured(packet_no, protocol, ip_src, ip_dst, port_src, port_dst, payload, payload_size);
		}

		public void on_error(String error = null) {
			if(listener != null) {
				listener.on_error(error);
			}
		}
	}

	class PCapSniffTask : RunnableTask
	{
		public static PCapSniffTask instance(PCapListener listener, String filter_expression = null, String device = null, int count_limit = 10, int count_duration = 5, int ignore_duration = 60, int maintenance_cleanup_delay = 60) {
			return(new PCapSniffTask()
				.set_listener(listener)
				.set_filter_expression(filter_expression)
				.set_device(device)
				.set_count_limit(count_limit)
				.set_count_duration(count_duration)
				.set_maintenance_cleanup_delay(maintenance_cleanup_delay));
		}

		property PCapListener listener;
		property String filter_expression;
		property String device;
		property int count_limit = 10;
		property int count_duration = 5;
		property int ignore_duration = 60;
		property int maintenance_cleanup_delay = 60;

		public void run(EventReceiver listener, BooleanValue abortflag) {
			if(abortflag.get_value()) {
				return;
			}
			PCap.sniff(get_listener(), filter_expression, device, count_limit, count_duration, ignore_duration, maintenance_cleanup_delay);
		}
	}

	public static BackgroundTask start_sniff(BackgroundTaskManager btm, PCapListener listener, String filter_expression = null, String device = null, int count_limit = 10, int count_duration = 5, int ignore_duration = 60, int maintenance_cleanup_delay = 60) {
		if(btm == null) {
			Log.error("PCap: No BackgroundTaskManager object specified!");
			return(null);
		}
		return(btm.start_task(PCapSniffTask.instance(listener, filter_expression, device, count_limit, count_duration, ignore_duration, maintenance_cleanup_delay), null));
	}

	public static void sniff(PCapListener listener, String filter_expression = null, String device = null, int count_limit = 10, int count_duration = 5, int ignore_duration = 60, int maintenance_cleanup_delay = 60) {
		if(listener == null) {
			Log.error("PCap: Cannot sniff, PCapListener object is null!");
			return;
		}
		strptr filter_exp = null;						/* capture device name */
		if(String.is_empty(filter_expression) == false) {
			filter_exp = filter_expression.to_strptr();
		}
		strptr dev = null;								/* capture device name */
		if(String.is_empty(device) == false) {
			dev = device.to_strptr();
		}
		int num_packets = -1;							/* number of packets to capture */
		strptr error_message = null;
		embed "c" {{{
			if(filter_exp == NULL) {
				filter_exp = "ip and udp";				/* filter expression [3] */
			}
			char errbuf[PCAP_ERRBUF_SIZE];				/* error buffer */
			pcap_t *handle;								/* packet capture handle */
			struct bpf_program fp;						/* compiled filter program (expression) */
			bpf_u_int32 mask;							/* subnet mask */
			bpf_u_int32 net;							/* ip */
			if(dev == NULL) {
				dev = pcap_lookupdev(errbuf);
				if (dev == NULL) {
					error_message = errbuf;
					}}} listener.on_error("PCap: Couldn't find default device: %s".printf().add(String.for_strptr(error_message)).to_string()); embed "c" {{{
					return;
				}
			}
			if(pcap_lookupnet(dev, &net, &mask, errbuf) == -1) {
				fprintf(stderr, "PCap: Couldn't get netmask for device %s: %s\n", dev, errbuf);
				net = 0;
				mask = 0;
			}
		}}}
		Log.debug("PCap: Device: %s".printf()
			.add(String.for_strptr(dev))
			.to_string());
		Log.debug("PCap: Number of packets: %d (a negative value means it should sniff until an error occurs)".printf()
			.add(num_packets)
			.to_string());
		Log.debug("PCap: Filter expression: %s".printf()
			.add(String.for_strptr(filter_exp))
			.to_string());
		embed "c" {{{
			handle = pcap_open_live(dev, SNAP_LEN, 1, 1000, errbuf);
			if (handle == NULL) {
				error_message = errbuf;
				}}} listener.on_error("PCap: Couldn't open device %s: %s".printf().add(String.for_strptr(dev)).add(String.for_strptr(error_message)).to_string()); embed "c" {{{
				return;
			}
			if (pcap_datalink(handle) != DLT_EN10MB) {
				}}} listener.on_error("PCap: %s is not an Ethernet".printf().add(String.for_strptr(dev)).to_string()); embed "c" {{{
				return;
			}
			if (pcap_compile(handle, &fp, filter_exp, 0, net) == -1) {
				error_message = pcap_geterr(handle);
				}}} listener.on_error("PCap: Couldn't parse filter %s: %s".printf().add(filter_expression).add(String.for_strptr(error_message)).to_string()); embed "c" {{{
				return;
			}
			if (pcap_setfilter(handle, &fp) == -1) {
				error_message = pcap_geterr(handle);
				}}} listener.on_error("PCap: Couldn't install filter %s: %s".printf().add(filter_expression).add(String.for_strptr(error_message)).to_string()); embed "c" {{{
				return;
			}
		}}}
		Log.message("PCap: Started sniffing - filter expression: '%s'".printf()
			.add(filter_expression)
			.to_string());
		var callback_listener = new MyPCapListener()
			.set_listener(listener)
			.set_count_limit(count_limit)
			.set_count_duration(count_duration)
			.set_ignore_duration(ignore_duration)
			.set_maintenance_cleanup_delay(maintenance_cleanup_delay);
		embed "c" {{{
			ref_eq_api_Object(callback_listener);
			pcap_loop(handle, num_packets, on_packet_captured_callback, callback_listener);
			unref_eq_api_Object(callback_listener);
			pcap_freecode(&fp);
			pcap_close(handle);
		}}}
		Log.message("PCap: Sniffing ended.");
	}
}
