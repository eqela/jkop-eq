
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

public class AppleSSLSocket : LoggerObject, SSLSocket, Reader, Writer, ReaderWriter, ConnectedSocket, FileDescriptor, ConnectedSocketWrapper
{
	ConnectedSocket original = null;
	ptr ctx = null;

	embed "objc" {{{
		#import <Security/Security.h>
		#import <Security/SecureTransport.h>
		#import <Foundation/Foundation.h>
		#ifndef ioErr
		#define ioErr -36
		#endif
	}}}

	embed "objc" {{{
		OSStatus SSLReadFunction(SSLConnectionRef connection, void *data, size_t *dataLength);
		OSStatus SSLWriteFunction(SSLConnectionRef connection, const void *data, size_t *dataLength);
		
		OSStatus SSLReadFunction(SSLConnectionRef connection, void *data, size_t *dataLength) {
			int sockfd = (int)connection;
			size_t bytesToGo = *dataLength;
			size_t initLen = bytesToGo;
			UInt8 *currData = (UInt8 *)data;
			OSStatus err = noErr;
			ssize_t v = 0;
			for(;;) {
				v = read(sockfd, currData, bytesToGo);
				if(v <= 0) {
					if(v == 0) {
						NSLog(@"Failed to read data, error errSSLClosedGraceful occurred");
					}
					else {
						switch(errno) {
							case ENOENT:
								NSLog(@"Failed to read data, error errSSLClosedGraceful occurred");
								break;
							case ECONNRESET:
								NSLog(@"Failed to read data, error errSSLClosedAbort occurred");
								break;
							case EAGAIN:	
								NSLog(@"Failed to read data, error errSSLWouldBlock occurred");
								break;
							default:
								NSLog(@"Failed to read data, error ioErr occurred");
								break;
						}
					}
					err = ioErr;
					break;
				}
				else {
					bytesToGo -= v;
					currData += v;
				}
				if(bytesToGo == 0) {
					break;
				}
			}
			*dataLength = initLen - bytesToGo;
			return(err);
		}
		
		OSStatus SSLWriteFunction(SSLConnectionRef connection, const void *data, size_t *dataLength) {
			int sockfd = (int)connection;
			size_t dataLen = *dataLength;
			size_t bytesSent = 0;
			ssize_t v;
			OSStatus err = noErr;
			do {
				v = write(sockfd, (char *)data + bytesSent, dataLen - bytesSent);
			} while(v >= 0 && (bytesSent += v) < dataLen);
			if(v < 0) {
				switch(errno) {
					case EAGAIN:
						NSLog(@"Failed to write data, error errSSLWouldBlock occurred");
						break;
					case EPIPE:
					case ECONNRESET:
						NSLog(@"Failed to write data, error errSSLClosedAbort occurred");
						break;
					default:
						NSLog(@"Failed to write data, error ioErr occurred");
				}
				err = ioErr;
			}
			*dataLength = bytesSent;
			return(err);
		}
	}}}

	~AppleSSLSocket() {
		close();
	}

	public ConnectedSocket get_original() {
		return(original);
	}

	public int get_fd() {
		var ofd = original as FileDescriptor;
		if(ofd == null) {
			return(-1);
		}
		return(ofd.get_fd());
	}

	public void close() {
		ptr ctx = this.ctx;
		if(ctx != null) {
			embed "objc" {{{
				SSLClose(ctx);
				CFRelease(ctx);
			}}}
			this.ctx = null;
		}
		if(original != null) {
			original.close();
			original = null;
		}
	}

	public bool open(ConnectedSocket original, File certfile, File keyfile, bool server) {
		if(original as FileDescriptor == null) {
			return(false);
		}
		bool v = false;
		ptr ctx;
		int err;
		embed "objc" {{{
			SSLProtocolSide ps = kSSLClientSide;
			if(server) {
				ps = kSSLServerSide;
			}
			ctx = SSLCreateContext(NULL, ps, kSSLStreamType);
			err = SSLSetIOFuncs(ctx, SSLReadFunction, SSLWriteFunction);
		}}}
		if(err < 0) {
			log_error("Failed to specifies callback functions");
		}
		this.ctx = ctx;
		if(ctx != null && err >= 0) {
			int fdid = ((FileDescriptor)original).get_fd();
			embed "objc" {{{
				if(SSLSetConnection(ctx, (SSLConnectionRef)(long)fdid) != 0) {
					NSLog(@"SSLSetConnection error occured");
				}
				else {
					err = SSLHandshake(ctx);
				}
			}}}
			if(err < 0) {
				log_error("Failed to perform SSL handshake");
			}
			else {
				v = true;
			}
		}
		if(v == false) {
			close();
		}
		else {
			this.original = original;
		}
		return(v);
	}

	public int read(Buffer buf) {
		if(buf == null) {
			return(-1);
		}
		var ptr = buf.get_pointer();
		if(ptr == null) {
			return(-1);
		}
		int v;
		var np = ptr.get_native_pointer();
		var sz = buf.get_size();
		ptr context = this.ctx;
		embed "objc" {{{
			size_t t;
			SSLRead(context, np, sz, &t);
			v = (int)t;
		}}}
		return(v);
	}

	public int write(Buffer buf, int asize) {
		var size = asize;
		if(buf == null) {
			return(-1);
		}
		var ptr = buf.get_pointer();
		if(ptr == null) {
			return(-1);
		}
		if(size < 0) {
			size = buf.get_size();
		}
		int v;
		var np = ptr.get_native_pointer();
		ptr context = this.ctx;
		embed "objc" {{{
			size_t t;
			SSLWrite(context, np, size, &t);
			v = (int)t;
		}}}
		return(v);
	}
}
