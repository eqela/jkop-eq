
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

class MathImpl : MathInterface
{
	embed "cs" {{{
		private System.Random rnd = null;
	}}}

	public static MathInterface create() {
		return(new MathImpl());
	}

	public int abs(int n) {
		int v = 0;
		embed "cs" {{{
			v = System.Math.Abs(n);
		}}}
		return(v);
	}

	public double fabs(double n) {
		double v = 0;
		embed "cs" {{{
			v = System.Math.Abs(n);
		}}}
		return(v);
	}

	public double ceil(double n) {
		double v = 0;
		embed "cs" {{{
			v = System.Math.Ceiling(n);
		}}}
		return(v);
	}

	public double floor(double n) {
		double v = 0;
		embed "cs" {{{
			v = System.Math.Floor(n);
		}}}
		return(v);
	}

	public double rint(double n) {
		double v = 0;
		embed "cs" {{{
			v = System.Math.Round(n);
		}}}
		return(v);
	}

	public double sin(double n) {
		double v = 0;
		embed "cs" {{{
			v = System.Math.Sin(n);
		}}}
		return(v);
	}

	public double asin(double n) {
		double v = 0;
		embed "cs" {{{
			v = System.Math.Asin(n);
		}}}
		return(v);
	}

	public double cos(double n) {
		double v = 0;
		embed "cs" {{{
			v = System.Math.Cos(n);
		}}}
		return(v);
	}

	public double acos(double n) {
		double v = 0;
		embed "cs" {{{
			v = System.Math.Acos(n);
		}}}
		return(v);
	}

	public double tan(double n) {
		double v = 0;
		embed "cs" {{{
			v = System.Math.Tan(n);
		}}}
		return(v);
	}

	public double atan(double n) {
		double v = 0;
		embed "cs" {{{
			v = System.Math.Atan(n);
		}}}
		return(v);
	}

	public double atan2(double a, double b) {
		double v = 0;
		embed "cs" {{{
			v = System.Math.Atan2(a, b);
		}}}
		return(v);
	}

	public double sqrt(double n) {
		double v = 0;
		embed "cs" {{{
			v = System.Math.Sqrt(n);
		}}}
		return(v);
	}

	public double cbrt(double n) {
		double v = 0;
		embed "cs" {{{
			v = System.Math.Pow(n, 1/3);
		}}}
		return(v);
	}

	public double log(double n) {
		double v = 0;
		embed "cs" {{{
			v = System.Math.Log(n);
		}}}
		return(v);
	}

	public double log10(double n) {
		double v = 0;
		embed "cs" {{{
			v = System.Math.Log10(n);
		}}}
		return(v);
	}

	public double exp(double x) {
		double v;
		embed "cs" {{{
			v = System.Math.Exp(x);
		}}}
		return(v);
	}

	public double pow(double a, double b) {
		double v;
		embed "cs" {{{
			v = System.Math.Pow(a, b);
		}}}
		return(v);
	}

	public int random(int min, int max) {
		int v = 0;
		embed "cs" {{{
			if (rnd == null) {
				rnd = new System.Random();
			}
			v = rnd.Next(min, max);
		}}}
		return(v);
	}
}
