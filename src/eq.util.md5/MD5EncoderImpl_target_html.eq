
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

class MD5EncoderImpl : MD5Encoder
{
	class ReaderUtil
	{
		public static String as_string(Reader rd) {
			if(rd == null) {
				return(null);
			}
			var ist = rd as InputStream;
			if(ist == null) {
				ist = InputStream.create(rd);
			}
			return(ist.read_all_string());
		}
	}

	public static MD5Encoder create() {
		return(new MD5EncoderImpl());
	}

	public String hash(Object o) {
		String v;
		if(o is String) {
			v = MD5(o as String);
		}
		else if(o is Buffer) {
			v = MD5(String.for_utf8_buffer(o as Buffer));
		}
		else if(o is Reader) {
			v = MD5(ReaderUtil.as_string(o as Reader));
		}
		return(v);
	}

	private String MD5(String o) {
		if(o == null) {
			return(null);
		}
		var x = get_word_array(o);
		int a = 0x67452301, b = 0xEFCDAB89, c = 0x98BADCFE, d = 0x10325476;
		int S11 = 7, S12 = 12, S13 = 17, S14 = 22;
		int S21 = 5, S22 = 9 , S23 = 14, S24 = 20;
		int S31 = 4, S32 = 11, S33 = 16, S34 = 23;
		int S41 = 6, S42 = 10, S43 = 15, S44 = 21;
		int k, AA, BB, CC, DD;
		for (k=0; k < x.count(); k += 16) {
			AA = a; BB = b; CC = c; DD = d;
			a = FF(a, b, c, d, (x.get_index(k+0) as Integer), S11, 0xD76AA478);
			d = FF(d, a, b, c, (x.get_index(k+1) as Integer), S12, 0xE8C7B756);
			c = FF(c, d, a, b, (x.get_index(k+2) as Integer), S13, 0x242070DB);
			b = FF(b, c, d, a, (x.get_index(k+3) as Integer), S14, 0xC1BDCEEE);
			a = FF(a, b, c, d, (x.get_index(k+4) as Integer), S11, 0xF57C0FAF);
			d = FF(d, a, b, c, (x.get_index(k+5) as Integer), S12, 0x4787C62A);
			c = FF(c, d, a, b, (x.get_index(k+6) as Integer), S13, 0xA8304613);
			b = FF(b, c, d, a, (x.get_index(k+7) as Integer), S14, 0xFD469501);
			a = FF(a, b, c, d, (x.get_index(k+8) as Integer), S11, 0x698098D8);
			d = FF(d, a, b, c, (x.get_index(k+9) as Integer), S12, 0x8B44F7AF);
			c = FF(c, d, a, b, (x.get_index(k+10) as Integer), S13, 0xFFFF5BB1);
			b = FF(b, c, d, a, (x.get_index(k+11) as Integer), S14, 0x895CD7BE);
			a = FF(a, b, c, d, (x.get_index(k+12) as Integer), S11, 0x6B901122);
			d = FF(d, a, b, c, (x.get_index(k+13) as Integer), S12, 0xFD987193);
			c = FF(c, d, a, b, (x.get_index(k+14) as Integer), S13, 0xA679438E);
			b = FF(b, c, d, a, (x.get_index(k+15) as Integer), S14, 0x49B40821);
			a = GG(a, b, c, d, (x.get_index(k+1) as Integer), S21, 0xF61E2562);
			d = GG(d, a, b, c, (x.get_index(k+6) as Integer), S22, 0xC040B340);
			c = GG(c, d, a, b, (x.get_index(k+11) as Integer), S23, 0x265E5A51);
			b = GG(b, c, d, a, (x.get_index(k+0) as Integer), S24, 0xE9B6C7AA);
			a = GG(a, b, c, d, (x.get_index(k+5) as Integer), S21, 0xD62F105D);
			d = GG(d, a, b, c, (x.get_index(k+10) as Integer), S22, 0x2441453);
			c = GG(c, d, a, b, (x.get_index(k+15) as Integer), S23, 0xD8A1E681);
			b = GG(b, c, d, a, (x.get_index(k+4) as Integer), S24, 0xE7D3FBC8);
			a = GG(a, b, c, d, (x.get_index(k+9) as Integer), S21, 0x21E1CDE6);
			d = GG(d, a, b, c, (x.get_index(k+14) as Integer), S22, 0xC33707D6);
			c = GG(c, d, a, b, (x.get_index(k+3) as Integer), S23, 0xF4D50D87);
			b = GG(b, c, d, a, (x.get_index(k+8) as Integer), S24, 0x455A14ED);
			a = GG(a, b, c, d, (x.get_index(k+13) as Integer), S21, 0xA9E3E905);
			d = GG(d, a, b, c, (x.get_index(k+2) as Integer), S22, 0xFCEFA3F8);
			c = GG(c, d, a, b, (x.get_index(k+7) as Integer), S23, 0x676F02D9);
			b = GG(b, c, d, a, (x.get_index(k+12) as Integer), S24, 0x8D2A4C8A);
			a = HH(a, b, c, d, (x.get_index(k+5) as Integer), S31, 0xFFFA3942);
			d = HH(d, a, b, c, (x.get_index(k+8) as Integer), S32, 0x8771F681);
			c = HH(c, d, a, b, (x.get_index(k+11) as Integer), S33, 0x6D9D6122);
			b = HH(b, c, d, a, (x.get_index(k+14) as Integer), S34, 0xFDE5380C);
			a = HH(a, b, c, d, (x.get_index(k+1) as Integer), S31, 0xA4BEEA44);
			d = HH(d, a, b, c, (x.get_index(k+4) as Integer), S32, 0x4BDECFA9);
			c = HH(c, d, a, b, (x.get_index(k+7) as Integer), S33, 0xF6BB4B60);
			b = HH(b, c, d, a, (x.get_index(k+10) as Integer), S34, 0xBEBFBC70);
			a = HH(a, b, c, d, (x.get_index(k+13) as Integer), S31, 0x289B7EC6);
			d = HH(d, a, b, c, (x.get_index(k+0) as Integer), S32, 0xEAA127FA);
			c = HH(c, d, a, b, (x.get_index(k+3) as Integer), S33, 0xD4EF3085);
			b = HH(b, c, d, a, (x.get_index(k+6) as Integer), S34, 0x4881D05);
			a = HH(a, b, c, d, (x.get_index(k+9) as Integer), S31, 0xD9D4D039);
			d = HH(d, a, b, c, (x.get_index(k+12) as Integer), S32, 0xE6DB99E5);
			c = HH(c, d, a, b, (x.get_index(k+15) as Integer), S33, 0x1FA27CF8);
			b = HH(b, c, d, a, (x.get_index(k+2) as Integer), S34, 0xC4AC5665);
			a = II(a, b, c, d, (x.get_index(k+0) as Integer), S41, 0xF4292244);
			d = II(d, a, b, c, (x.get_index(k+7) as Integer), S42, 0x432AFF97);
			c = II(c, d, a, b, (x.get_index(k+14) as Integer), S43, 0xAB9423A7);
			b = II(b, c, d, a, (x.get_index(k+5) as Integer), S44, 0xFC93A039);
			a = II(a, b, c, d, (x.get_index(k+12) as Integer), S41, 0x655B59C3);
			d = II(d, a, b, c, (x.get_index(k+3) as Integer), S42, 0x8F0CCC92);
			c = II(c, d, a, b, (x.get_index(k+10) as Integer), S43, 0xFFEFF47D);
			b = II(b, c, d, a, (x.get_index(k+1) as Integer), S44, 0x85845DD1);
			a = II(a, b, c, d, (x.get_index(k+8) as Integer), S41, 0x6FA87E4F);
			d = II(d, a, b, c, (x.get_index(k+15) as Integer), S42, 0xFE2CE6E0);
			c = II(c, d, a, b, (x.get_index(k+6) as Integer), S43, 0xA3014314);
			b = II(b, c, d, a, (x.get_index(k+13) as Integer), S44, 0x4E0811A1);
			a = II(a, b, c, d, (x.get_index(k+4) as Integer), S41, 0xF7537E82);
			d = II(d, a, b, c, (x.get_index(k+11) as Integer), S42, 0xBD3AF235);
			c = II(c, d, a, b, (x.get_index(k+2) as Integer), S43, 0x2AD7D2BB);
			b = II(b, c, d, a, (x.get_index(k+9) as Integer), S44, 0xEB86D391);
			a = add_unsigned(a, AA);
			b = add_unsigned(b, BB);
			c = add_unsigned(c, CC);
			d = add_unsigned(d, DD);
		}
		var temp = "%s%s%s%s".printf().add(to_string_hex(a)).add(to_string_hex(b)).add(to_string_hex(c)).add(to_string_hex(d)).to_string();
		return(temp.lowercase());
	}

	private int rotate_left(int val, int bits) {
		int v;
		embed "js" {{{
			v = (val << bits) | (val >>> (32 - bits));
		}}}
		return(v);
	}

	private int add_unsigned(int x, int y) {
		int x4, y4, x8, y8, result;
		x8 = (x & 0x80000000);
		y8 = (y & 0x80000000);
		x4 = (x & 0x40000000);
		y4 = (y & 0x40000000);
		result = (x & 0x3FFFFFFF) + (y & 0x3FFFFFFF);
		if(x4 & y4) {
			return(result ^ 0x80000000 ^ x8 ^ y8);
		}
		if(x4 | y4) {
			if(result & 0x40000000) {
				return(result ^ 0xC0000000 ^ x8 ^ y8);
			}
			else {
				return(result ^ 0x40000000 ^ x8 ^ y8);
			}
		}
		else {
			return (result ^ x8 ^ y8);
		}
		return(0);
 	}

 	private int F(int x, int y, int z) {
 		var w = ~ x;
 		return((x & y) | (w & z));
 	}

 	private int G(int x,int y,int z) {
 		var w = ~ z;
 		return((x & z) | (y & w));
 	}

 	private int H(int x, int y, int z) {
 		return(x ^ y ^ z);
 	}

	private int I(int x, int y, int z) {
		var w = ~ z;
		return(y ^ (x | w));
	}

	private int FF(int a, int b, int c, int d, Integer o, int s, int ac) {
		int x = 0;
		if(o != null) {
			x = o.to_integer();
		}
		var v = add_unsigned(a, add_unsigned(add_unsigned(F(b, c, d), x), ac));
		return(add_unsigned(rotate_left(v, s), b));
	}

	private int GG(int a, int b, int c, int d, Integer o, int s, int ac) {
		int x;
		if(o != null) {
			x = o.to_integer();
		}
		var v = add_unsigned(a, add_unsigned(add_unsigned(G(b, c, d), x), ac));
		return(add_unsigned(rotate_left(v, s), b));
	}

	private int HH(int a, int b, int c, int d, Integer o, int s, int ac) {
		int x;
		if(o != null) {
			x = o.to_integer();
		}
		var v = add_unsigned(a, add_unsigned(add_unsigned(H(b, c, d), x), ac));
		return(add_unsigned(rotate_left(v, s), b));
	}

	private int II(int a, int b, int c, int d, Integer o, int s, int ac) {
		int x;
		if(o != null) {
			x = o.to_integer();
		}
		var v = add_unsigned(a, add_unsigned(add_unsigned(I(b, c, d), x), ac));
		return(add_unsigned(rotate_left(v, s), b));
	}

	private Collection get_word_array(String str) {
		int strlength = str.get_length();
		int n = ((strlength + 8) - ((strlength + 8) % 64)) / 64;
		int num_words = (n + 1) * 16;
		var array = Array.create(num_words-1);
		int word_count, byte_count, byte_pos;
		while (byte_count < strlength) {
			word_count = (byte_count - (byte_count % 4)) / 4;
			byte_pos = (byte_count % 4) * 8;
			int temp = 0;
			var o = array.get_index(word_count);
			if(o != null) {
				temp = (o as Integer).to_integer();
			}
			int x = temp | (str.get_char(byte_count) << byte_pos);
			array.set_index(word_count, Primitive.for_integer(x));
			byte_count++;
		}
		word_count = (byte_count - (byte_count % 4)) / 4;
		byte_pos = (byte_count % 4) * 8;
		int xx = 0;
		var xxo = array.get_index(word_count);
		if(xxo !=  null) {
			xx = ((Integer)xxo).to_integer();
		}
		int v = xx | (0x80 << byte_pos);
		array.set_index(word_count, Primitive.for_integer(v));
		array.set_index(num_words - 2, Primitive.for_integer(strlength << 3));
		int r;
		embed "js" {{{
			r = strlength >>> 29;
		}}}
		array.set_index(num_words-1, Primitive.for_integer(r));
		return(array);
	}

	private String to_string_hex(int val) {
		var result = "", temp = "";
		int count, byte;
		for (count = 0; count <= 3; count++) {
			int v;
			embed "js" {{{
				v = val >>> (count * 8);
			}}}
			byte = v & 255;
			temp = "00%x".printf().add(Primitive.for_double(byte)).to_string();
			result = result.append(temp.substring(temp.get_length() - 2, 2));
		}
		return(result);
	}
}

