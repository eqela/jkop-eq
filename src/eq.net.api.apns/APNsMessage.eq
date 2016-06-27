
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

public class APNsMessage
{
	public static APNsMessage instance(String msg, String device_token) {
		return(new APNsMessage().set_alert(msg).set_device_token(device_token));
	}

	property String alert;
	property int badge;
	property String sound;
	property String device_token;

	public APNsMessage() {
		badge = 1;
		sound = "default";
	}

	String get_payload() {
		return("{\"aps\":{\"alert\":\"%s\",\"badge\":%d,\"sound\":\"%s\"}}".printf().add(alert).add(badge).add(sound).to_string());
	}

	public Buffer to_buffer() {
		var payload = get_payload();
		if(String.is_empty(payload) || String.is_empty(device_token)) {
			return(null);
		}
		var dtb = get_device_token_as_buffer(device_token);
		if(dtb == null) {
			return(null);
		}
		var dtb_sz = get_device_token_length_as_buffer(dtb);
		if(dtb_sz == null) {
			return(null);
		}
		var pb = get_payload_as_buffer(payload);
		if(pb == null) {
			return(null);
		}
		var pb_sz = get_payload_length_as_buffer(pb);
		if(pb_sz == null) {
			return(null);
		}
		var db = DynamicBuffer.create(0);
		var bw = BufferWriter.for_buffer(db);
		var os = OutputStream.for_writer(bw);
		os.write_byte(0);
		os.write_buffer(dtb_sz);
		os.write_buffer(dtb);
		os.write_buffer(pb_sz);
		os.write_buffer(pb);
		return(db);
	}

	Buffer get_device_token_as_buffer(String device_token) {
		if(String.is_empty(device_token)) {
			return(null);
		}
		var buffer = DynamicBuffer.create(device_token.get_length() / 2);
		var ptr = buffer.get_pointer();
		int i;
		for(i = 0; i < device_token.get_length(); i += 2) {
			var str = device_token.substring(i, 2);
			var hex = str.to_integer_base(16);
			ptr.set_byte((i / 2), hex);
		}
		return(buffer);
	}

	Buffer get_device_token_length_as_buffer(Buffer device_token_buffer) {
		if(device_token_buffer == null) {
			return(null);
		}
		var v = Integer.to_buffer16(device_token_buffer.get_size());
		return(v);
	}

	Buffer get_payload_as_buffer(String payload) {
		if(String.is_empty(payload)) {
			return(null);
		}
		return(payload.to_utf8_buffer(false));
	}

	Buffer get_payload_length_as_buffer(Buffer payload_buffer) {
		if(payload_buffer == null) {
			return(null);
		}
		var v = Integer.to_buffer16(payload_buffer.get_size());
		return(v);
	}
}
