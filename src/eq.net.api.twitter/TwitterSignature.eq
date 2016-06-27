
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

public class TwitterSignature
{
	public static bool sign_http_request(HTTPClientRequest req, String ckey, String csecret, String tkey, String tsecret, bool include_query_and_body_params = true, Logger logger = null, bool debug = false) {
		if(req == null) {
			Log.error("TwitterSignature: Null request!", logger);
			return(false);
		}
		var method = req.get_method();
		if(method == null) {
			Log.error("TwitterSignature: No HTTP method!", logger);
			return(false);
		}

		// 1. HTTP method
		method = method.uppercase();

		// 2. Base URL
		var url = req.get_url();
		String base_url;
		if(url != null) {
			var ud = url.dup();
			ud.set_query_parameters(null);
			base_url = ud.to_string();
		}
		if(base_url == null) {
			Log.error("TwitterSignature: No base URL!", logger);
			return(false);
		}
		// 3. Parameter string
		HashTable parameters = null;
		if(include_query_and_body_params) {
			parameters = TwitterSignatureHelper.get_query_and_body_parameters(req);
		}
		else {
			parameters = HashTable.create();
		}
		var now = SystemClock.seconds();
		var timestamp = String.for_integer(now);
		var nonce = MD5Encoder.encode("%d_%d".printf().add((int)now).add(Math.random(0, 1000000)).to_string());
		parameters.set("oauth_consumer_key", ckey);
		parameters.set("oauth_nonce", nonce);
		parameters.set("oauth_signature_method", "HMAC-SHA1");
		parameters.set("oauth_timestamp", timestamp);
		parameters.set("oauth_token", tkey);
		parameters.set("oauth_version", "1.0");
		var parr = Array.create();
		foreach(String key in parameters.iterate_keys()) {
			parr.add(key);
		}
		MergeSort.sort_array(parr);
		var sb = StringBuffer.create();
		foreach(String key in parr) {
			if(sb.count() > 0) {
				sb.append_c((int)'&');
			}
			sb.append(key);
			sb.append_c((int)'=');
			sb.append(TwitterSignatureHelper.percent_encode(parameters.get_string(key)));
		}
		var parameter_string = sb.to_string();

		// 4. Signature base string
		var signature_base_string = TwitterSignatureHelper.create_signature_base_string(method, base_url, parameter_string);

		// 5. Signing key
		var signing_key = TwitterSignatureHelper.create_signing_key(csecret, tsecret);

		// 6. OAuth signature
		var hmac = HMACSHA1.create();
		if(hmac == null) {
			Log.error("TwitterSignature: No HMAC-SHA1 implementation for this platform exists.", logger);
			return(false);
		}
		var hmacval = hmac.encrypt(signature_base_string, signing_key);
		if(hmacval == null) {
			return(false);
		}
		var oauth_signature = Base64Encoder.encode(hmacval);

		// 7. HTTP header string
		sb = StringBuffer.create();
		sb.append("OAuth ");
		sb.append("oauth_consumer_key=\"%s\", ".printf().add(TwitterSignatureHelper.percent_encode(ckey)).to_string());
		sb.append("oauth_nonce=\"%s\", ".printf().add(TwitterSignatureHelper.percent_encode(nonce)).to_string());
		sb.append("oauth_signature=\"%s\", ".printf().add(TwitterSignatureHelper.percent_encode(oauth_signature)).to_string());
		sb.append("oauth_signature_method=\"%s\", ".printf().add("HMAC-SHA1").to_string());
		sb.append("oauth_timestamp=\"%s\", ".printf().add(timestamp).to_string());
		sb.append("oauth_token=\"%s\", ".printf().add(TwitterSignatureHelper.percent_encode(tkey)).to_string());
		sb.append("oauth_version=\"%s\"".printf().add("1.0").to_string());
		var http_header_string = sb.to_string();
		req.set_header("Authorization", http_header_string);

		if(debug) {
			TwitterSignatureHelper.debug_signature(logger, "TWITTER SIGNATURE", method, base_url, parameter_string, signature_base_string, signing_key, oauth_signature, http_header_string);
		}
		return(true);
	}
}
