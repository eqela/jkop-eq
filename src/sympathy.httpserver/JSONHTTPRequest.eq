
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

public class JSONHTTPRequest
{
	public static Object get_body_json(HTTPRequest req) {
		if(req == null) {
			return(null);
		}
		var ct = req.get_header("content-type");
		if(ct == null) {
			return(null);
		}
		var sp = ct.split((int)';', 2);
		if(sp == null) {
			return(null);
		}
		var cts = String.as_string(sp.next());
		if("application/json".equals(cts) == false) {
			return(null);
		}
		return(JSONParser.parse_string(req.get_body_string()));
	}

	public static HashTable get_body_json_hash_table(HTTPRequest req) {
		return(get_body_json(req) as HashTable);
	}
}
