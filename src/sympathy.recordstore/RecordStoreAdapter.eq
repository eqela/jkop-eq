
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

public class RecordStoreAdapter : RecordStore
{
	public bool append(Object record, Error error) {
		Error.set_error_message(error, "RecordStoreAdapter.append: Not implemented.");
		return(false);
	}

	public bool update(Object record, RecordFilter filter, Error error) {
		Error.set_error_message(error, "RecordStoreAdapter.update: Not implemented.");
		return(false);
	}

	public bool delete(RecordFilter filter, Error error) {
		Error.set_error_message(error, "RecordStoreAdapter.delete: Not implemented.");
		return(false);
	}

	public int get_record_count(RecordFilter filter, Error error) {
		Error.set_error_message(error, "RecordStoreAdapter.get_record_count: Not implemented.");
		return(-1);
	}

	public Collection get_records(RecordFilter filter, int offset, int limit, Collection sorting, Collection fields, Error error) {
		Error.set_error_message(error, "RecordStoreAdapter.get_records: Not implemented.");
		return(null);
	}

	public Collection get_all_records(Collection sorting, Collection fields, Error error) {
		return(get_records(null, 0, 0, sorting, fields, error));
	}

	public Collection get_all_matching_records(RecordFilter filter, Collection sorting, Collection fields, Error error) {
		return(get_records(filter, 0, 0, sorting, fields, error));
	}

	class OneMatchListener : CollectionOperationListener
	{
		property ObjectOperationListener listener;
		public void on_collection(Collection coll, Error error) {
			Object o;
			if(coll != null) {
				o = coll.get(0);
			}
			if(listener != null) {
				listener.on_object(o, error);
			}
		}
	}

	public Object get_one_matching(RecordFilter filter, Collection fields, Error error) {
		var recs = get_records(filter, 0, 0, null, fields, error);
		if(recs == null) {
			return(null);
		}
		return(recs.get(0));
	}
}
