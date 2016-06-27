
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

IFNDEF("target_j2me") {
	class UDPSocketImpl : UDPSocket
	{
		embed "Java" {{{
			java.net.DatagramSocket socket = null;
		}}}

		public UDPSocketImpl() {
			embed "Java" {{{
				try {
					socket = new java.net.DatagramSocket();
				}
				catch(Exception e) {
					System.out.println("EXCEPTION CAUGHT IN UDPSocketImpl construction:");
					e.printStackTrace();
				}
			}}}
		}

		public void close() {
			embed "Java" {{{
				try {
					socket.close();
				}
				catch(Exception e) {
					System.out.println("EXCEPTION CAUGHT IN UDPSocketImpl.close:");
					e.printStackTrace();
				}
			}}}
		}

		public int send(Buffer message, String address, int port) {
			if(message == null || address == null || port < 0) {
				return(0);
			}
			ptr jbuffer = message.get_pointer().get_native_pointer();
			strptr jaddress = address.to_strptr();
			int length = message.get_size();
			int v = 0;
			embed "Java" {{{
				try {
					socket.setBroadcast(false);
					socket.send(new java.net.DatagramPacket(jbuffer, length, java.net.InetAddress.getByName(jaddress), port));
					v = jbuffer.length;
				}
				catch(Exception e) {
					System.out.println("EXCEPTION CAUGHT IN UDPSocketImpl.send:");
					e.printStackTrace();
				}
			}}}
			return(v);
		}

		public int send_broadcast(Buffer message, String address, int port) {
			if(message == null || address == null || port < 0) {
				return(0);
			}
			ptr jbuffer = message.get_pointer().get_native_pointer();
			strptr jaddress = address.to_strptr();
			int length = message.get_size();
			int v = 0;
			embed "Java" {{{
				try {
					socket.setBroadcast(true);
					socket.send(new java.net.DatagramPacket(jbuffer, length, java.net.InetAddress.getByName(jaddress), port));
					v = jbuffer.length;
				}
				catch(Exception e) {
					System.out.println("EXCEPTION CAUGHT IN UDPSocketImpl.send_broadcast:");
					e.printStackTrace();
				}
			}}}
			return(v);
		}

		public int receive(Buffer message, int timeout) {
			if(message == null) {
				return(0);
			}
			ptr jbuffer = message.get_pointer().get_native_pointer();
			int length = message.get_size();
			int v = 0;
			embed "Java" {{{
				try {
					socket.setSoTimeout(timeout/1000);
					socket.receive(new java.net.DatagramPacket(jbuffer, length));
					v = jbuffer.length;
				}
				catch(Exception e) {
					System.out.println("EXCEPTION CAUGHT IN UDPSocketImpl.receive:");
					e.printStackTrace();
				}
			}}}
			return(v);
		}

		public bool bind(int port) {
			bool v = false;
			embed "Java" {{{
				try {
					socket = new java.net.DatagramSocket(port);
				}
				catch(Exception e) {
					System.out.println("EXCEPTION CAUGHT IN UDPSocketImpl.bind:");
					e.printStackTrace();
				}
				if(socket != null) {
					v = (port == socket.getLocalPort());
				}
			}}}
			return(v);
		}

		public static UDPSocket create() {
			var v = new UDPSocketImpl();
			embed "Java" {{{
				if(v.socket == null) {
					return(null);
				}
			}}}
			return(v);
		}
	}
}

