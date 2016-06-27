
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

public class RecordStoreFile : FileAdapter
{
	embed "java" {{{
		javax.microedition.rms.RecordStore store;
	}}}
	String id;
	bool is_dir = false;

	~RecordStoreFile() {
		embed "java" {{{
			store.closeRecordStore();
		}}}
	}

	public static RecordStoreFile for_name(String name) {
		var aname = name;
		if(aname == null) {
			aname = Application.get_name();
		}
		if(aname == null) {
			return(null);
		}
		var sname = aname.to_strptr();
		var v = new RecordStoreFile();
		v.id = aname;
		embed "java" {{{
			try {
				v.store = javax.microedition.rms.RecordStore.openRecordStore(sname, true);
			}
			catch(Exception e) {
				v = null;
				System.err.println("RecordStoreFile for: " + sname + ". Exception: " + e);
			}
		}}}
		return(v);
	}

	int get_record_id() {
		int id = -1;
		embed "java" {{{
			try {
				javax.microedition.rms.RecordEnumeration recs = store.enumerateRecords(null, null, true);
				if(recs.hasNextElement()) { //check if it a "file" and has a "content".
					id = recs.nextRecordId();
				}
			}
			catch(Exception e) {
				System.err.println("get_record_id: " + e);
			}
		}}}
		return(id);
	}

	public bool remove() {
		embed "java" {{{
			try {
				javax.microedition.rms.RecordEnumeration recs = store.enumerateRecords(null, null, true);
				while(recs.hasNextElement()) { //check if it a "file" and has a "content".
					store.deleteRecord(recs.nextRecordId());
				}
			}
			catch(Exception e) {
				System.err.println("get_record_id: " + e);
				return(false);
			}
		}}}
		return(true);
	}

	public File entry(String s) {
		return(for_name(id));
	}

	class RecordStoreReader : SizedReader, Reader
	{
		property int recordid;
		int size;
		embed "java" {{{
			javax.microedition.rms.RecordStore store;
			public RecordStoreReader(javax.microedition.rms.RecordStore store) {
				this.store = store;
			}
		}}}

		public int read(Buffer data) {
			if(data == null) {
				return(0);
			}
			var ptr = data.get_pointer().get_native_pointer();
			int v = 0;
			embed "java" {{{
				try {
					v = store.getRecord(recordid, ptr, 0);
				}
				catch(Exception e) {
					System.err.println("read: " + e);
				}
			}}}
			size = v;
			return(v);
		}

		public int get_size() {
			return(size);
		}
	}

	class RecordStoreWriter : Writer
	{
		embed "java" {{{
			javax.microedition.rms.RecordStore store;
			public RecordStoreWriter(javax.microedition.rms.RecordStore store) {
				this.store = store;
			}
		}}}
		public int write(Buffer data, int size) {
			if(data == null) {
				return(0);
			}
			var ptr = data.get_pointer().get_native_pointer();
			int sz = 0;
			embed "java" {{{
				sz = ptr.length;
				try {
					store.addRecord(ptr, 0, sz);
				}
				catch(Exception e) {
					System.err.println("write: " + e);
				}
			}}}
			return(sz);
		}
	}

	public SizedReader read() {
		int rec = get_record_id();
		embed "java" {{{
			if(rec > -1) {
				return(new RecordStoreReader(store).set_recordid(rec));
			}
		}}}
		return(null);
	}

	public Writer write() {
		Writer v;
		embed "java" {{{
			v = new RecordStoreWriter(store);
		}}}
		return(v);
	}

	public FileInfo stat() {
		var v = new FileInfo();
		int rec = get_record_id();
		if(rec < 0) {
			return(null);
		}
		embed "java" {{{
			try {
				v.set_size(store.getRecordSize(rec));
			}
			catch(Exception e) {
				System.err.println("stat: " + e);
			}
		}}}
		return(v);
	}

	public String to_string() {
		return(id);
	}

	public bool is_directory() {
		return(is_dir);
	}

	public bool create_directory() {
		embed "java" {{{
			try {
				javax.microedition.rms.RecordEnumeration recs = store.enumerateRecords(null, null, true);
				if(recs.hasNextElement()) { //check if it a "file" and has a "content".
					return(false);
				}
			}
			catch(Exception e) {
				System.err.println("create_directory: " + e);
			}
		}}}
		is_dir = true;
		return(true);
	}

	public bool remove_directory() {
		bool v = true;
		embed "java" {{{
			try {
				javax.microedition.rms.RecordStore.deleteRecordStore(id.to_strptr());
			}
			catch(Exception e) {
				System.err.println("remove_directory: " + e);
				v = false;
			}
		}}}
		return(v);
	}
}
