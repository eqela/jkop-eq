
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

public class SMTPMessage
{
	Collection rcpts_to;
	Collection rcpts_cc;
	Collection rcpts_bcc;
	String reply_to;
	String subject;
	String content_type;
	String text;
	String my_name;
	String my_address;
	String message_body;
	String message_id;
	String date;
	property Collection exclude_addresses;
	static int counter = 0;

	public SMTPMessage() {
		date = VerboseDateTimeString.for_now();
	}

	void on_changed() {
		message_body = null;
	}

	public SMTPMessage generate_message_id(String host) {
		message_id = "%d-%d-%d@%s".printf().add((int)SystemClock.seconds()).add(Math.random(0,1000000)).add(counter).add(host).to_string();
		counter++;
		on_changed();
		return(this);
	}

	public String get_date() {
		return(date);
	}

	public String get_reply_to() {
		return(reply_to);
	}

	public SMTPMessage set_date(String date) {
		this.date = date;
		on_changed();
		return(this);
	}

	public SMTPMessage set_message_id(String id) {
		message_id = id;
		on_changed();
		return(this);
	}

	public SMTPMessage set_reply_to(String v) {
		reply_to = v;
		on_changed();
		return(this);
	}

	public String get_message_id() {
		return(message_id);
	}

	bool is_excluded_address(String add) {
		foreach(String ea in exclude_addresses) {
			if(ea.equals(add)) {
				return(true);
			}
		}
		return(false);
	}

	public Collection get_all_rcpts() {
		var rcpts = LinkedList.create();
		foreach(String r in get_rcpts_to()) {
			if(is_excluded_address(r)) {
				continue;
			}
			rcpts.add(r);
		}
		foreach(String r in get_rcpts_cc()) {
			if(is_excluded_address(r)) {
				continue;
			}
			rcpts.add(r);
		}
		foreach(String r in get_rcpts_bcc()) {
			if(is_excluded_address(r)) {
				continue;
			}
			rcpts.add(r);
		}
		return(rcpts);
	}

	public Collection get_rcpts_to() {
		return(rcpts_to);
	}

	public Collection get_rcpts_cc() {
		return(rcpts_cc);
	}

	public Collection get_rcpts_bcc() {
		return(rcpts_bcc);
	}

	public String get_subject() {
		return(subject);
	}

	public String get_content_type() {
		return(content_type);
	}

	public String get_text() {
		return(text);
	}

	public String get_my_name() {
		return(my_name);
	}

	public String get_my_address() {
		return(my_address);
	}

	public SMTPMessage set_subject(String s) {
		subject = s;
		on_changed();
		return(this);
	}

	public SMTPMessage set_content_type(String c) {
		content_type = c;
		on_changed();
		return(this);
	}

	public SMTPMessage set_text(String t) {
		text = t;
		on_changed();
		return(this);
	}

	public SMTPMessage set_my_name(String n) {
		my_name = n;
		on_changed();
		return(this);
	}

	public SMTPMessage set_my_address(String a) {
		my_address = a;
		on_changed();
		return(this);
	}

	public SMTPMessage set_to(String address) {
		rcpts_to = LinkedList.create();
		rcpts_to.append(address);
		on_changed();
		return(this);
	}

	public SMTPMessage add_to(String address) {
		if(String.is_empty(address) == false) {
			if(rcpts_to == null) {
				rcpts_to = LinkedList.create();
			}
			rcpts_to.add(address);
		}
		on_changed();
		return(this);
	}

	public SMTPMessage add_cc(String address) {
		if(String.is_empty(address) == false) {
			if(rcpts_cc == null) {
				rcpts_cc = LinkedList.create();
			}
			rcpts_cc.add(address);
		}
		on_changed();
		return(this);
	}

	public SMTPMessage add_bcc(String address) {
		if(String.is_empty(address) == false) {
			if(rcpts_bcc == null) {
				rcpts_bcc = LinkedList.create();
			}
			rcpts_bcc.add(address);
		}
		on_changed();
		return(this);
	}

	public SMTPMessage set_recipients(Collection to, Collection cc, Collection bcc) {
		rcpts_to = to;
		rcpts_cc = cc;
		rcpts_bcc = bcc;
		on_changed();
		return(this);
	}

	public int get_size_bytes() {
		var b = get_message_body();
		if(b == null) {
			return(0);
		}
		var bb = b.to_utf8_buffer(false);
		if(bb == null) {
			return(0);
		}
		return(bb.get_size());
	}

	public virtual String get_message_body() {
		if(message_body != null) {
			return(message_body);
		}
		var sb = StringBuffer.create();
		sb.append("From: ");
		sb.append(my_name);
		sb.append(" <");
		sb.append(my_address);
		if(String.is_empty(reply_to) == false) {
			sb.append(">\r\nReply-To: ");
			sb.append(my_name);
			sb.append(" <");
			sb.append(reply_to);
		}
		sb.append(">\r\nTo: ");
		bool first = true;
		foreach(String to in rcpts_to) {
			if(first == false) {
				sb.append(", ");
			}
			sb.append(to);
			first = false;
		}
		sb.append("\r\nCc: ");
		first = true;
		foreach(String to in rcpts_cc) {
			if(first == false) {
				sb.append(", ");
			}
			sb.append(to);
			first = false;
		}
		sb.append("\r\nSubject: ");
		sb.append(subject);
		sb.append("\r\nContent-Type: ");
		sb.append(content_type);
		sb.append("\r\nDate: ");
		sb.append(date);
		sb.append("\r\nMessage-ID: <");
		sb.append(message_id);
		sb.append(">\r\n\r\n");
		sb.append(text);
		message_body = sb.to_string();
		return(message_body);
	}
}
