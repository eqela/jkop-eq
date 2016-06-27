
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

public class TwitterSignatureHelper
{
	public static String percent_encode(String str) {
		if(str == null) {
			return(null);
		}
		var sb = StringBuffer.create();
		var it = str.iterate();
		while(it != null) {
			var c = it.next_char();
			if(c < 1) {
				break;
			}
			if((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '-' || c == '.' || c == '_' || c == '~') {
				sb.append_c(c);
			}
			else {
				sb.append("%%%02X".printf().add(c).to_string());
			}
		}
		return(sb.to_string());
	}

	public static HashTable get_query_and_body_parameters(HTTPClientRequest req) {
		HashTable query_parameters;
		HashTable body_parameters;
		var body = String.as_string(req.get_body());
		if(body != null) {
			body_parameters = QueryString.parse(body);
		}
		var url = req.get_url();
		if(url != null) {
			query_parameters = url.get_query_parameters();
		}
		var parameters = HashTable.create();
		if(query_parameters != null) {
			foreach(String key in query_parameters.iterate_keys()) {
				parameters.set(key, query_parameters.get_string(key));
			}
		}
		if(body_parameters != null) {
			foreach(String key in body_parameters.iterate_keys()) {
				parameters.set(key, body_parameters.get_string(key));
			}
		}
		return(parameters);
	}

	public static void debug_signature(Logger logger, String message, String method, String base_url, String parameter_string, String signature_base_string, String signing_key, String oauth_signature, String http_header_string) {
		Log.debug("*** %s ***".printf().add(message), logger);
		Log.debug("HTTP method: `%s'".printf().add(method), logger);
		Log.debug("Base URL: `%s'".printf().add(base_url), logger);
		Log.debug("Parameter string: `%s'".printf().add(parameter_string), logger);
		Log.debug("Signature base string: `%s'".printf().add(signature_base_string), logger);
		Log.debug("Signing key: `%s'".printf().add(signing_key));
		Log.debug("OAuth signature: `%s'".printf().add(oauth_signature));
		Log.debug("HTTP header string: `%s'".printf().add(http_header_string));
	}

	public static String create_signature_base_string(String method, String base_url, String parameter_string) {
		return("%s&%s&%s".printf().add(method).add(percent_encode(base_url)).add(percent_encode(parameter_string)).to_string());
	}

	public static String create_signing_key(String csecret, String tsecret) {
		return("%s&%s".printf().add(percent_encode(csecret)).add(percent_encode(tsecret)).to_string());
	}
}
