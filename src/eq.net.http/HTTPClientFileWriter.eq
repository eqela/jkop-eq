
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

public class HTTPClientFileWriter : HTTPClientOutputStreamWriter
{
	property File destfile;
	property EventReceiver listener;
	bool not_modified = false;

	bool initialize() {
		if(destfile == null) {
			log_error("HTTPClientFileWriter: No destination file was given");
			return(false);
		}
		var oo = OutputStream.create(destfile.write());
		if(oo == null) {
			log_error("HTTPClientFileWriter: Unable to write file: `%s'".printf().add(destfile));
			return(false);
		}
		set_output(oo);
		return(true);
	}

	public void on_response(HTTPClientResponseEvent event) {
		base.on_response(event);
		var st = event.get_status();
		if("200".equals(st)) {
			if(initialize() == false) {
			}
		}
		else if("304".equals(st)) {
			not_modified = true;
		}
	}

	public void on_end(HTTPClientEndEvent event) {
		base.on_end(event);
		var started = false;
		if(get_output() != null) {
			started = true;
		}
		set_output(null);
		File v;
		if(is_ok() && event.get_complete()) {
			v = destfile;
		}
		else if(not_modified) {
			if(destfile.is_file()) {
				v = destfile;
			}
		}
		else {
			if(started && destfile != null) {
				destfile.remove();
			}
			v = null;
		}
		var fr = new HTTPClientFileResponse();
		fr.copy_header_from(get_header());
		fr.set_file(v);
		on_file_response(fr);
	}

	public virtual void on_file_response(HTTPClientFileResponse resp) {
		EventReceiver.event(listener, resp);
	}
}
