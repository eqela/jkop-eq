
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

public interface Integer
{
	IFDEF("target_win32") {
		embed "c" {{{
			#include <string.h>
		}}}
	}

	public int to_integer();

	public static int as_integer(Object i, int def = 0) {
		if(i == null) {
			return(def);
		}
		if(i is Integer == false) {
			return(def);
		}
		return(((Integer)i).to_integer());
	}

	public static Buffer int_to_buffer(int x) {
		IFDEF("target_c") {
			int len;
			embed "c" {{{
				len = sizeof(x);
			}}}
			if(len < 1) {
				return(null);
			}
			var db = DynamicBuffer.create(len);
			if(db == null) {
				return(null);
			}
			var ptr = db.get_pointer();
			if(ptr == null) {
				return(null);
			}
			var pp = ptr.get_native_pointer();
			if(pp == null) {
				return(null);
			}
			embed "c" {{{
				memcpy((void*)pp, &x, len);
			}}}
			return(db);
		}
		IFDEF("target_dotnet") {
			ptr bytes;
			int sz = 0;
			embed {{{
				bytes = System.BitConverter.GetBytes(x);
				sz = bytes.Length;
			}}}
			return(Buffer.for_pointer(Pointer.create(bytes), sz));
		}
		// FIXME: Java, JavaScript
		return(null);
	}

	public static Buffer long_to_buffer(long x) {
		IFDEF("target_c") {
			int len;
			embed "c" {{{
				len = sizeof(x);
			}}}
			if(len < 1) {
				return(null);
			}
			var db = DynamicBuffer.create(len);
			if(db == null) {
				return(null);
			}
			var ptr = db.get_pointer();
			if(ptr == null) {
				return(null);
			}
			var pp = ptr.get_native_pointer();
			if(pp == null) {
				return(null);
			}
			embed "c" {{{
				memcpy((void*)pp, &x, len);
			}}}
			return(db);
		}
		IFDEF("target_dotnet") {
			ptr bytes;
			int sz = 0;
			// FIXME: The type cast below is not right. It's not an int. It's a long.
			embed "cs" {{{
				bytes = System.BitConverter.GetBytes((int)x);
				sz = bytes.Length;
			}}}
			return(Buffer.for_pointer(Pointer.create(bytes), sz));
		}
		// FIXME: Java, JavaScript
		return(null);
	}

	public static Buffer to_buffer8(int x) {
		var b = DynamicBuffer.create(1);
		if(b != null) {
			var ptr = b.get_pointer();
			if(ptr == null) {
				 b = null;
			}
			else {
				ptr.set_byte(0, (uint8)x);
			}
		}
		return(b);
	}

	private static Buffer to_buffer(int x, int bytes) {
		IFDEF("target_java") { // Java: Naturally Network-Endian
			if(true) {
				ptr p;
				IFDEF("target_bbjava") {
					embed {{{
						p = java.nio.ByteBuffer.allocateDirect(bytes).putInt(x).array();
					}}}
				}
				ELSE IFDEF("target_j2me") {
				}
				ELSE {
					embed {{{
						p = java.nio.ByteBuffer.allocate(bytes).putInt(x).array();
					}}}
				}
				return(Buffer.for_pointer(Pointer.create(p), bytes));
			}
		}
		IFDEF("target_c") {
			var b = DynamicBuffer.create(bytes);
			if(b == null) {
				return(null);
			}
			var ptr = b.get_pointer();
			if(ptr == null) {
				 return(null);
			}
			var ppx = ptr.get_native_pointer();
			if(ppx == null) {
				return(null);
			}
			embed {{{
				int isz = sizeof(int);
				unsigned char* sptr = (unsigned char*)&x;
				unsigned char* pp = (unsigned char*)ppx;
				int o = 1;
				if(*(char*)&o == 1) { // little endian
					*pp = *(sptr+bytes-1);
					if(bytes >= 2) {
						*(pp+1) = *(sptr+bytes-2);
					}
					if(bytes >= 4) {
						*(pp+2) = *(sptr+bytes-3);
						*(pp+3) = *(sptr+bytes-4);
					}
					if(bytes >= 8) {
						*(pp+4) = *(sptr+bytes-5);
						*(pp+5) = *(sptr+bytes-6);
						*(pp+6) = *(sptr+bytes-7);
						*(pp+7) = *(sptr+bytes-8);
					}
				}
				else { // big endian
					sptr += (isz - bytes);
					*pp = *sptr;
					if(bytes >= 2) {
						*(pp+1) = *(sptr+1);
					}
					if(bytes >= 4) {
						*(pp+2) = *(sptr+2);
						*(pp+3) = *(sptr+3);
					}
					if(bytes >= 8) {
						*(pp+4) = *(sptr+4);
						*(pp+5) = *(sptr+5);
						*(pp+6) = *(sptr+6);
						*(pp+7) = *(sptr+7);
					}
				}
			}}}
			return(b);
		}
		IFDEF("target_dotnet") {
			ptr p = null;
			embed {{{
				var memstream = new System.IO.MemoryStream(bytes);
				using(var writer = new System.IO.BinaryWriter(memstream)) {
					int le2be = System.Net.IPAddress.HostToNetworkOrder(x);
					writer.Write(le2be);
				}
				p = memstream.ToArray();
			}}}
			return(Buffer.for_pointer(Pointer.create(p), bytes));
		}
		IFDEF("target_js") {
			Log.debug("Integer.to_buffer(): PLEASE IMPLEMENT ME");
		}
		return(null);
	}

	public static Buffer to_buffer16(int x) {
		return(Integer.to_buffer(x, 2));
	}

	public static Buffer to_buffer32(int x) {
		return(Integer.to_buffer(x, 4));
	}

	/*
	public static Buffer to_buffer64(int x) {
	}
	*/

	public static int from_buffer8(Buffer b) {
		int v = 0;
		if(b != null) {
			var ptr = b.get_pointer();
			if(ptr != null) {
				v = (int)ptr.get_byte(0);
			}
		}
		return(v);
	}

	IFDEF("target_win32") {
		embed "c" {{{
		#include <windows.h>
		#define htons(A) ((((WORD)(A) & 0xff00) >> 8) | (((WORD)(A) & 0x00ff) << 8))
		#define htonl(A) ((((DWORD)(A) & 0xff000000) >> 24) | (((DWORD)(A) & 0x00ff0000) >> 8) | (((DWORD)(A) & 0x0000ff00) << 8) | (((DWORD)(A) & 0x000000ff) << 24))
		#define ntohs htons
		#define ntohl htonl
		}}}
	}
	ELSE {
		embed "c" {{{
			#include <arpa/inet.h>
		}}}
	}

	public static int from_buffer16(Buffer x) {
		if(x == null) {
			return(0);
		}
		var ptr = x.get_pointer();
		if(ptr == null) {
			return(0);
		}
		var pp = ptr.get_native_pointer();
		if(pp == null) {
			return(0);
		}
		IFDEF("target_bbjava") {
			embed "java" {{{
				if(true) {
					return(java.nio.ByteBuffer.wrap(pp).getShort());
				}
			}}}
		}
		ELSE IFDEF("target_j2me") {
		}
		ELSE IFDEF("target_dotnet") {
			embed "cs" {{{
				var stream = new System.IO.MemoryStream(pp, 0, 2);
				int v = 0;
				using(var reader = new System.IO.BinaryReader(stream)) {
					v = reader.ReadInt16();
				}
				v = System.Net.IPAddress.HostToNetworkOrder((short)v);
				return(v);
			}}}
		}
		ELSE {
			embed "java" {{{
				if(true) {
					return(java.nio.ByteBuffer.wrap(pp).getShort());
				}
			}}}
		}
		embed "c" {{{
			return(ntohs(*((unsigned short*)pp)));
		}}}
		return(0);
	}

	public static int from_buffer32(Buffer x) {
		if(x == null) {
			return(0);
		}
		var ptr = x.get_pointer();
		if(ptr == null) {
			return(0);
		}
		var pp = ptr.get_native_pointer();
		if(pp == null) {
			return(0);
		}
		IFDEF("target_bbjava") {
			embed "java" {{{
				if(true) {
					return(java.nio.ByteBuffer.wrap(pp).getInt());
				}
			}}}
		}
		ELSE IFDEF("target_j2me") {
		}
		ELSE IFDEF("target_dotnet") {
			embed "cs" {{{
				var stream = new System.IO.MemoryStream(pp);
				int v = 0;
				using(var reader = new System.IO.BinaryReader(stream)) {
					v = reader.ReadInt32();
				}
				v = System.Net.IPAddress.HostToNetworkOrder(v);
				return(v);
			}}}
		}
		ELSE {
			embed "java" {{{
				if(true) {
					return(java.nio.ByteBuffer.wrap(pp).getInt());
				}
			}}}
		}
		embed "c" {{{
			return(ntohl(*((unsigned int*)pp)));
		}}}
		return(0);
	}

	public static int int_from_buffer(Buffer x) {
		if(x == null) {
			return(0);
		}
		var ptr = x.get_pointer();
		if(ptr == null) {
			return(0);
		}
		var pp = ptr.get_native_pointer();
		if(pp == null) {
			return(0);
		}
		int v;
		embed "c" {{{
			memcpy((void*)&v, pp, sizeof(int));
		}}}
		embed "cs" {{{
			v = System.BitConverter.ToInt32(pp, 0);
		}}}
		return(v);
	}

	public static long long_from_buffer(Buffer x) {
		if(x == null) {
			return(0);
		}
		var ptr = x.get_pointer();
		if(ptr == null) {
			return(0);
		}
		var pp = ptr.get_native_pointer();
		if(pp == null) {
			return(0);
		}
		long v;
		embed "c" {{{
			memcpy((void*)&v, pp, sizeof(long));
		}}}
		// FIXME: It shouldn't be 32 bits, should it?
		embed "cs" {{{
			v = System.BitConverter.ToInt32(pp, 0);
		}}}
		return(v);
	}
}

