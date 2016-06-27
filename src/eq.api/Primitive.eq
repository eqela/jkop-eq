
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

public class Primitive
{
	private class IntegerPrimitive : Object, Integer, Double, Boolean, Stringable
	{
		private int val = 0;

		public static IntegerPrimitive create(int val) {
			var v = new IntegerPrimitive();
			v.val = val;
			return(v);
		}

		public IntegerPrimitive() {
		}

		public String to_string() {
			return(String.for_integer(val));
		}

		public int to_integer() {
			return(val);
		}

		public double to_double() {
			return((double)val);
		}

		public bool to_boolean() {
			if(val == 0) {
				return(false);
			}
			return(true);
		}
	}

	private class DoublePrimitive : Object, Integer, Double, Boolean, Stringable
	{
		private double val = 0.0;

		public static DoublePrimitive create(double val) {
			var v = new DoublePrimitive();
			v.val = val;
			return(v);
		}

		public DoublePrimitive() {
		}

		public String to_string() {
			return(String.for_double(val));
		}

		public int to_integer() {
			return((int)val);
		}

		public double to_double() {
			return(val);
		}

		public bool to_boolean() {
			if(val == 0.0) {
				return(false);
			}
			return(true);
		}
	}

	private class BooleanPrimitive : Object, Integer, Double, Boolean, Stringable
	{
		private bool val = false;

		public static BooleanPrimitive create(bool val) {
			var v = new BooleanPrimitive();
			v.val = val;
			return(v);
		}

		public BooleanPrimitive() {
		}

		public String to_string() {
			return(String.for_boolean(val));
		}

		public int to_integer() {
			if(val == false) {
				return(0);
			}
			return(1);
		}

		public double to_double() {
			if(val == false) {
				return(0.0);
			}
			return(1.0);
		}

		public bool to_boolean() {
			return(val);
		}
	}

	public static Integer for_integer(int val) {
		return(IntegerPrimitive.create(val));
	}

	public static Double for_double(double val) {
		return(DoublePrimitive.create(val));
	}

	public static Boolean for_boolean(bool val) {
		return(BooleanPrimitive.create(val));
	}
}

