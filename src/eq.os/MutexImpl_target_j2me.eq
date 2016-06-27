
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

class MutexImpl : Mutex
{
	embed "Java" {{{
		public class JMutex {
			boolean isLocked = false;
			java.lang.Thread lockedBy = null;
			int lockedCount = 0;

			public JMutex() {
			}

			public synchronized void jLock() {
				try {
					java.lang.Thread callingThread = java.lang.Thread.currentThread();
					while(isLocked && lockedBy != callingThread){
						wait();
					}
					isLocked = true;
					lockedCount++;
					lockedBy = callingThread;
				}
				catch(Exception e) {
					e.printStackTrace();
				}	
			}

			public synchronized void jUnlock() {
				try {
					if(java.lang.Thread.currentThread() == this.lockedBy){
						lockedCount--;
						if(lockedCount == 0){
							isLocked = false;
							notify();
						}
					}
				}
				catch(Exception e) {
					e.printStackTrace();
				}
			}
		}

		private JMutex mut = new JMutex();
	}}}

	public void lock() {
		embed "Java" {{{
			try {
				mut.jLock();
			} 
			catch (Exception e) {
				e.printStackTrace();
			}
		}}}
	}

	public void unlock() {
		embed "Java" {{{
			try {
				mut.jUnlock();
			} 
			catch (Exception e) {
				e.printStackTrace();
			}
			
		}}}
	}

	public static Mutex create() {
		return(new MutexImpl());
	}
}

