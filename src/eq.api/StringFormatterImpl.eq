
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

class StringFormatterImpl : Stringable, StringFormatter
{
	public static StringFormatterImpl create(String format) {
		var v = new StringFormatterImpl();
		v.fmt = format;
		return(v);
	}

	public StringFormatterImpl() {
		collect = LinkedList.create();
	}

	public static StringFormatterImpl format(String format) {
		return(StringFormatterImpl.create(format));
	}

	private String fmt = null;
	private Collection collect = null;
	private StringBuffer sbi  = null;
	private int flag = 1;
	private int temp;
	private StringIterator it = null;

	public StringFormatter add(Object o) {
		collect.add(o);
		return(this);
	}

	public String to_string() {
		sbi = StringBuffer.create();
		it = fmt.iterate();
		int s;
		int i = 0;
		if(it != null) {
			while((s = it.next_char()) > 0) {
				if(s == '%') {
					temp = it.next_char();
					switch(temp) {
						case '-': {
							flag = (int)'-';
							temp = it.next_char();
							if(temp == '+') {
								flag = (int)'*';
								temp = it.next_char();
							}
							else if(temp == '#') {
								flag = (int)'@';
								temp = it.next_char();
							}
						}
						case '+': {
							flag = (int)'+';
							temp = it.next_char();
							if(temp == '-') {
								flag = (int)'*';
								temp = it.next_char();
							}
						}
						case ' ': {
							flag = (int)' ';
							temp = it.next_char();
							if(temp == '+') {
								flag = (int)'*';
								temp = it.next_char();
							}
						}
						case '#': {
							flag = (int)'#';
							temp = it.next_char();
							if(temp == '-') {
								flag = (int)'@';
								temp = it.next_char();
							}
						}
						case '0': {
							flag = (int)'0';
							temp = it.next_char();
						}
						case '%': {
							flag = (int)'%';
							sbi.append_c((int)'%');
						}
					}
					if(flag != (int)'%') {
						if_specifier(i);
						i++;
					}
				}
				else {
					sbi.append_c(s);
				}
			}
		}
		return(sbi.to_string());
	}

	private bool specifier(int temp) {
		return(temp == 's' || temp == 'c' ||  temp == 'd' || temp == 'x' || temp == 'f' || temp == 'o' || temp == 'e' || temp == '%');
	}

	private void if_specifier(int i) {
		var width = StringBuffer.create();
		var precision = StringBuffer.create();
		int p = -1, w = 0, n = 0;
		var nextparam = collect.get_index(i);
		while(specifier(temp) == false && temp > 0) {
			if(temp == '.') {
				n = 1;
			}
			else if(temp >= '0' && temp <= '9') {
				if(n == 0) {
					width.append_c(temp);
				}
				else {
					precision.append_c(temp);
				}
			}
			temp = it.next_char();
		}
		w = width.to_string().to_integer();
		if(n == 1) {
			p = precision.to_string().to_integer();
		}
		if(temp == 's' && nextparam != null && nextparam is Stringable == true) {
			for_string(i, w, p, nextparam);
		}
		else if(temp == 'c' && nextparam != null && nextparam is Integer == true) {
			for_char(nextparam);
		}
		else if(temp == 'd' && nextparam != null && nextparam is Integer == true) {
			for_integer(i, w, p, nextparam);
		}
		else if(temp == 'x' && nextparam != null && nextparam is Integer == true) {
			for_hexadecimal(i, w, p, nextparam);
		}
		else if(temp == 'f' && nextparam != null && nextparam is Double == true) {
			for_float(i, w, p, nextparam);
		}
		else if(temp == 'o' && nextparam != null && nextparam is Integer == true) {
			for_octal(i, w, nextparam);
		}
		else if(temp == 'e' && nextparam != null && nextparam is Double == true) {
			for_exponential(i, w, p, nextparam);
		}
	}

	private String as_string(Object param) {
		if(param == null) {
			return(null);
		}
		var ss = param as Stringable;
		if(ss == null) {
			return(null);
		}
		return(ss.to_string());
	}

	private void for_string(int i, int w, int p, Object nextparam) {
		var temp_val = StringBuffer.create();
		var pstr = as_string(nextparam);
		if(pstr == null) {
			pstr = "";
		}
		int d = w - pstr.get_length();
		int j = 0;
		if(p > 0) {
			var str = pstr;
			var it = str.iterate();
			int s = it.next_char();
			for(j = 0; j < p && s > 0; j++) {
				temp_val.append_c(s);
				s = it.next_char();
			}
			d = w - j;
		}
		else {
			temp_val.append(pstr);
		}
		if(w > pstr.get_length()) {
			if(flag == '-') {
				flag = 1;
				sbi.append(temp_val.to_string());
				for(j = 1; j <= d; j++) {
					sbi.append(" ");
				}
			}
			else {
				for(j = 1; j <= d; j++) {
					sbi.append(" ");
				}
				sbi.append(temp_val.to_string());
			}
		}
		else {
			sbi.append(temp_val.to_string());
		}
	}

	private void for_char(Object nextparam) {
		sbi.append_c(((Integer)nextparam).to_integer());
	}

	private bool for_integer(int i, int w, int p, Object nextparam) {
		var str = int_to_string(((Integer)nextparam).to_integer());
		if(p == 0 && "0".equals(str)) {
			return(false);
		}
		var temp_val = StringBuffer.create();
		var it = str.iterate();
		int length = str.get_length();
		int s = it.next_char();
		int counter = 0, j = 0;
		int tag = 0, d = p - length;
		if(s > 0 && s != '-' && (flag == '+' || flag == '*')) {
			temp_val.append("+");
			counter++;
		}
		else if(s > 0 && flag == ' ') {
			flag = 1;
			if(s != '-') {
				temp_val.append(" ");
				counter++;
			}
		}
		else if(s > 0 && flag == '0' && s == '-') {
			tag = 1;
			sbi.append("-");
			counter++;
			length--;
			s = it.next_char();
		}
		if(p >= length) {
			if(s > 0 && s == '-') {
				temp_val.append("-");
				counter++;
				s = it.next_char();
				d++;
			}
			for(j = 1; j <= d; j++) {
				temp_val.append("0");
				counter++;
			}
		}
		if(tag != 1) {
			for(j = 0; j < length && s > 0; j++) {
				temp_val.append_c(s);
				counter++;
				s = it.next_char();
			}
		}
		else {
			d = w - counter;
			for(j = 1; j <= d; j++) {
				if(j <= d - length) {
					sbi.append("0");
				}
				else {
					temp_val.append_c(s);
					s = it.next_char();
				}
				counter++;
			}
		}
		if(w > counter) {
			d = w - counter;
			if(flag == '-' || flag == '*') {
				flag = 1;
				sbi.append(temp_val.to_string());
				for(j = 1; j <= d; j++) {
					sbi.append(" ");
				}
			}
			else {
				for(j = 1; j <= d; j++) {
					if(flag == '0' && tag == 0) {
						sbi.append("0");
					}
					else {
						sbi.append(" ");
					}
				}
				flag = 1;
				sbi.append(temp_val.to_string());
			}
		}
		else {
			sbi.append(temp_val.to_string());
		}
		flag = 1;
		return(true);
	}

	private void for_hexadecimal(int i, int w, int p, Object nextparam) {
		var temp_val = StringBuffer.create();
		var dec = ((Integer)nextparam).to_integer();
		bool val = false;
		int counter = 0;
		int m = 0, n = 0, hex = dec, d;
		var arr_hex = Array.create();
		while(hex != 0) {
			arr_hex.insert(Primitive.for_integer(hex % 16), n);
			hex = hex / 16;
			n++;
		}
		n--;
		if((flag == '#' || flag == '@') && val == false) {
			temp_val.append("0X");
			counter = counter + 2;
		}
		int j;
		for(j = n; j >= 0; j--){
			m = ((Integer)arr_hex.get_index(j)).to_integer();
			if(m == 10) {
				temp_val.append_c((int)'A');
				counter++;
			}
			else if(m == 11) {
				temp_val.append_c((int)'B');
				counter++;
			}
			else if(m == 12) {
				temp_val.append_c((int)'C');
				counter++;
			}
			else if(m == 13) {
				temp_val.append_c((int)'D');
				counter++;
			}
			else if(m == 14) {
				temp_val.append_c((int)'E');
				counter++;
			}
			else if(m == 15) {
				temp_val.append_c((int)'F');
				counter++;
			}
			else {
				temp_val.append(int_to_string(m));
				counter++;
			}
		}
		if(w > counter) {
			d = w - counter;
			if(flag == '-' || flag == '@') {
				sbi.append(temp_val.to_string());
				for(n = 1; n <= d; n++) {
					if(flag == '0') {
						sbi.append("0");
					}
					else {
						sbi.append(" ");
					}
				}
			}
			else {
				for(n = 1; n <= d; n++) {
					if(flag == '0') {
						sbi.append("0");
					}
					else {
						sbi.append(" ");
					}
				}
				sbi.append(temp_val.to_string());
			}
			flag = 1;
		}
		else {
			sbi.append(temp_val.to_string());
		}
	}

	private bool for_float(int i, int w, int ap, Object nextparam) {
		var p = ap;
		if(nextparam == null) {
			return(false);
		}
		if(p == -1) {
			p = 6;
		}
		var str = double_to_string(((Double)nextparam).to_double(), p);
		var temp_val = StringBuffer.create();
		var it = str.iterate();
		int s = it.next_char();
		int count = 0, d = str.get_length();
		if(s > 0 && s != '-' && (flag == '+' || flag == '*')) {
			temp_val.append("+");
		}
		else if(s > 0 && flag == ' ') {
			flag = 1;
			if(s != '-') {
				temp_val.append(" ");
			}
		}
		else if(s > 0 && flag == '0' && s == '-') {
			sbi.append("-");
		}
		str = (temp_val.to_string()).append(str);
		count = str.get_length();
		if(w > count) {
			d = w - count;
			if(flag == '-' || flag == '*') {
				sbi.append(str);
				int n2;
				for(n2 = 1; n2 <= d; n2++) {
					sbi.append(" ");
				}
			}
			else {
				int n2;
				for(n2 = 1; n2 <= d; n2++) {
					if(flag == '0') {
						sbi.append("0");
					}
					else {
						sbi.append(" ");
					}
				}
				if(flag == '0' && str.has_prefix("-")) {
					str = str.remove(0, 1);
				}
				sbi.append(str);
			}
			flag = 1;
		}
		else {
			sbi.append(str);
		}
		return(true);
	}

	private void for_octal(int i, int w, Object nextparam) {
		var temp_val = StringBuffer.create();
		var dec = ((Integer)nextparam).to_integer();
		bool val = false;
		int counter = 0;
		int m = 0, n = 0, oct = dec, d;
		var arr_oct = Array.create();
		while(oct != 0) {
			arr_oct.insert(Primitive.for_integer(oct % 8), n);
			oct = oct / 8;
			n++;
		}
		n--;
		if((flag == '#' || flag == '@') && val == false) {
			temp_val.append("0");
			counter++;
		}
		int j;
		for(j = n; j >= 0; j--){
			m = ((Integer)arr_oct.get_index(j)).to_integer();
			temp_val.append(int_to_string(m));
			counter++;
		}
		if(w > counter) {
			d = w - counter;
			if(flag == '-' || flag == '@') {
				sbi.append(temp_val.to_string());
				for(n = 1; n <= d; n++) {
					if(flag == '0') {
						sbi.append("0");
					}
					else {
						sbi.append(" ");
					}
				}
			}
			else {
				for(n = 1; n <= d; n++) {
					if(flag == '0') {
						sbi.append("0");
					}
					else {
						sbi.append(" ");
					}
				}
				sbi.append(temp_val.to_string());
			}
			flag = 1;
		}
		else {
			sbi.append(temp_val.to_string());
		}
	}

	private void for_exponential(int i, int w, int ap, Object nextparam) {
		var p = ap;
		if(nextparam == null) {
			return;
		}
		String exponent = null;
		int exp = 0;
		double val = ((Double)nextparam).to_double();
		if(val < 1) {
			exponent = "e-";
			double num = ((Double)nextparam).to_double();
			double d_place;
			while((d_place = Math.floor(num)) == 0) {
				num -= d_place;
				num *= 10;
				val *= 10;
				exp++;
			}
		}
		else {
			exponent = "e+";
			double num = ((Double)nextparam).to_double();
			double d_place;
			while((d_place = Math.floor(num)) > 9) {
				num /= 10;
				val /= 10;
				exp++;
			}
		}
		if(p == -1) {
			p = 6;
		}
		var str = double_to_string(val, p);
		var temp_val = StringBuffer.create();
		var it = str.iterate();
		int s = it.next_char();
		int count = 0, d = str.get_length();
		if(s > 0 && s != '-' && (flag == '+' || flag == '*')) {
			temp_val.append("+");
		}
		else if(s > 0 && flag == ' ') {
			flag = 1;
			if(s != '-') {
				temp_val.append(" ");
			}
		}
		else if(s > 0 && flag == '0' && s == '-') {
			sbi.append("-");
		}
		str = (temp_val.to_string()).append(str);
		count = str.get_length();
		if(exp > 9) {
			exponent = exponent.append(int_to_string(exp));
		}
		else {
			exponent = exponent.append("0".append(int_to_string(exp)));
		}
		str = str.append(exponent);
		count += 3;
		if(w > count) {
			d = w - count;
			if(flag == '-' || flag == '@') {
				sbi.append(str);
				int n2;
				for(n2 = 1; n2 <= d; n2++) {
					sbi.append(" ");
				}
			}
			else {
				int n2;
				for(n2 = 1; n2 <= d; n2++) {
					if(flag == '0') {
						sbi.append("0");
					}
					else {
						sbi.append(" ");
					}
				}
				if(flag == '0' && str.has_prefix("-")) {
					str = str.remove(0, 1);
				}
				sbi.append(str);
			}
			flag = 1;
		}
		else {
			sbi.append(str);
		}
	}

	private String double_to_string(double av, int factor = 6) {
		var v = av;
		double val = Math.fabs(v);
		double whole = Math.floor(val);
		double digit = whole;
		var str = "";
		if(digit > 0) {
			while (digit>0) {
				int b = ((int)digit)%10;
				digit = Math.floor(digit/10);
				str = str.append(int_to_string(b));
			}
			str = str.reverse();
		}
		else {
			str = "0";
		}
		double decimal = val - whole;
		int d = str.get_length();
		int x;
		int rounding_value = 0;
		for(x = factor+1; x>0; x--) {
			int i= 0;
			if(decimal != 0) {
				decimal *= 10;
				i = (int)Math.floor(decimal);
				decimal -= i;
			}
			if(x == 1) {
				rounding_value = i;
			}
			else {
				str = str.append(int_to_string(i));
			}
		}
		if(rounding_value > 4) {
			var iter_r = str.iterate_reverse();
			int num = 0;
			bool inc = true;
			var sb = StringBuffer.create();
			while ((num = iter_r.next_char()) > 0) {
				if(inc && num == '9') {
					sb.append_c((int)'0');
				}
				else if(inc && num < '9') {
					sb.append_c(num+1);
					inc = false;
				}
				else {
					sb.append_c(num);
				}
			}
			if(inc && iter_r != null) {
				sb.append_c((int)'1');
				d++;
			}
			str = (sb.to_string()).reverse();
		}
		if(factor != 0) {
			str = str.insert(".", d);
		}
		if(v < 0) {
			str = "-".append(str);
		}
		return(str);
	}

	private String int_to_string(int av) {
		var v = av;
		var sb = StringBuffer.create();
		if (v<0) {
			sb.append_c((int)'-');
			v = (int)(Math.fabs(v));
		}
		int whole = (int)Math.floor(v);
		int a = whole;
		var digits = Array.create();
		while (a>0) {
			int b = a%10;
			digits.add(Primitive.for_integer(b+48));
			a = (int)Math.floor(a/10);
		}
		int c;
		for (c=digits.count()-1; c>=0; c--) {
			sb.append_c(((Integer)digits.get_index(c)).to_integer());
			digits.remove(digits.get_index(c));
		}
		if(v == 0) {
			sb.append_c((int)'0');
		}
		return(sb.to_string());
	}
}
