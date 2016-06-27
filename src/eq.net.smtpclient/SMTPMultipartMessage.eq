
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

public class SMTPMultipartMessage : SMTPMessage
{
	public SMTPMultipartMessage() {
		set_content_type("multipart/mixed");
	}

	property Collection attachments;
	String message;

	public override String get_message_body() {
		if(attachments == null || attachments.count() == 0) {
			return(null);
		}
		if(message != null) {
			return(message);
		}
		var subject = get_subject();
		var date = get_date();
		var my_name = get_my_name();
		var my_address = get_my_address();
		var text = get_text();
		var recipients_to = get_rcpts_to();
		var recipients_cc = get_rcpts_cc();
		var message_id = get_message_id();
		var reply_to = get_reply_to();
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
		foreach(String to in recipients_to) {
			if(first == false) {
				sb.append(", ");
			}
			sb.append(to);
			first = false;
		}
		sb.append("\r\nCc: ");
		first = true;
		foreach(String to in recipients_cc) {
			if(first == false) {
				sb.append(", ");
			}
			sb.append(to);
			first = false;
		}
		sb.append("\r\nSubject: ");
		sb.append(subject);
		sb.append("\r\nMIME-Version: 1.0");
		sb.append("\r\nContent-Type: ");
		sb.append("multipart/mixed");
		sb.append("; boundary=\"XXXXboundarytext\"");
		sb.append("\r\nDate: ");
		sb.append(date);
		sb.append("\r\nMessage-ID: <");
		sb.append(message_id);
		sb.append(">\r\n\r\n");
		sb.append("This is a multipart message in MIME format.");
		sb.append("\r\n");
		sb.append("\r\n--XXXXboundarytext");
		sb.append("\r\nContent-Type: text/plain");
		sb.append("\r\n");
		sb.append("\r\n");
		sb.append(text);
		foreach(File file in attachments) {
			sb.append("\r\n--XXXXboundarytext");
			sb.append("\r\nContent-Type: ");
			var content_type = MimeTypeRegistry.type_for_file(file);
			if(String.is_empty(content_type) == false && content_type.str("text") == 0) {
				sb.append(content_type);
				sb.append("\r\nContent-Disposition: attachment; filename=");
				sb.append(file.basename());
				sb.append("\r\n");
				sb.append("\r\n");
				sb.append(file.get_contents_string());
			}
			else {
				sb.append(content_type);
				sb.append("\r\nContent-Transfer-Encoding: Base64");
				sb.append("\r\nContent-Disposition: attachment; filename=");
				sb.append(file.basename());
				sb.append("\r\n");
				sb.append("\r\n");
				sb.append(Base64Encoder.encode(file.get_contents_buffer()));
			}
		}
		sb.append("\r\n");
		sb.append("\r\n--XXXXboundarytext--");
		return(message = sb.to_string());
	}
}
