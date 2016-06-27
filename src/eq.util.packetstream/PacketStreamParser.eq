
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

public class PacketStreamParser
{
	Queue packets;
	Buffer current_packet;
	int current_bytes;
	property int max_packet_size;

	public PacketStreamParser() {
		packets = Queue.create();
	}

	public bool add_data(Buffer data) {
		if(data == null) {
			return(false);
		}
		if(current_packet == null) {
			if(data.get_size() < 4) {
				// FIXME: This fails here if the 4 byte packet size marker is separated into different input packets.
				return(false);
			}
			int sz = Integer.from_buffer32(data);
			if(sz < 0) {
				return(false);
			}
			if(max_packet_size > 0 && sz > max_packet_size) {
				return(false);
			}
			if(data.get_size() == 4 + sz) {
				packets.push(SubBuffer.create(data, 4, sz));
				return(true);
			}
			if(data.get_size() > 4 + sz) {
				packets.push(SubBuffer.create(data, 4, sz));
				return(add_data(SubBuffer.create(data, 4+sz, data.get_size()-4-sz)));
			}
			current_packet = DynamicBuffer.create(sz);
			var sptr = data.get_pointer();
			var dptr = current_packet.get_pointer();
			current_bytes = data.get_size()-4;
			dptr.cpyfrom(sptr, 4, 0, current_bytes);
			return(true);
		}
		var nsz = data.get_size() + current_bytes;
		var sptr = data.get_pointer();
		var dptr = current_packet.get_pointer();
		if(nsz <= current_packet.get_size()) {
			dptr.cpyfrom(sptr, 0, current_bytes, data.get_size());
			current_bytes += data.get_size();
			if(current_bytes == current_packet.get_size()) {
				packets.push(current_packet);
				current_packet = null;
				current_bytes = 0;
			}
			return(true);
		}
		var btc = current_packet.get_size() - current_bytes;
		dptr.cpyfrom(sptr, 0, current_bytes, btc);
		packets.push(current_packet);
		current_packet = null;
		current_bytes = 0;
		return(add_data(SubBuffer.create(data, btc, data.get_size()-btc)));
	}

	public Buffer get_next_packet() {
		return(packets.pop() as Buffer);
	}
}
