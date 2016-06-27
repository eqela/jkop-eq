
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

public interface CollectionOperationListener
{
	public static EventReceiver to_event_receiver(CollectionOperationListener ll) {
		return(new CollectionOperationListenerEventReceiver().set_listener(ll));
	}

	public void on_collection(Collection coll, Error error);
}

class CollectionOperationListenerEventReceiver : EventReceiver
{
	property CollectionOperationListener listener;
	public void on_event(Object o) {
		if(listener == null) {
			return;
		}
		if(o == null) {
			listener.on_collection(null, null);
			return;
		}
		if(o is Error) {
			listener.on_collection(null, (Error)o);
			return;
		}
		if(o is Collection) {
			listener.on_collection((Collection)o, null);
			return;
		}
		listener.on_collection(null, null);
	}
}
