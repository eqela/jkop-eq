
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

class FileImpl : FileAdapter
{
	embed {{{
		Windows.Storage.StorageFolder storage;
		string subdirectory;
		System.Threading.ManualResetEvent mutex;
	}}}

	public FileImpl() {
		embed {{{
			mutex = new System.Threading.ManualResetEvent(false);
		}}}
	}

	public static File for_path(String apath, String substr = null) {
		if(String.is_empty(apath)) {
			return(new InvalidFile());
		}
		var v = new FileImpl();
		embed {{{
			var ia = Windows.Storage.StorageFolder.GetFolderFromPathAsync(apath.to_strptr());
			ia.Completed = (sender, status) => {
				v.mutex.Set();
			};
			v.mutex.WaitOne();
			v.mutex.Reset();
			try {
				v.storage = ia.GetResults();
			}
			catch(System.Exception e) {
				if(e is System.UnauthorizedAccessException) {
					v = null;
				}
				else {
					var rbs = apath.rchr('\\');
					if(rbs > -1) {
						var root = apath.substring(0, rbs);
						var ent = apath.substring(rbs+1, -1);
						v = (FileImpl)FileImpl.for_path(root, ent);
					}
				}
			}
			ia.Close();
		}}}
		if(v == null) {
			return(new InvalidFile());
		}
		return(v.entry(substr));
	}

	public static File for_current_directory() {
		return(new InvalidFile());
	}

	public static File for_app_directory() {
		var v = new FileImpl();
		embed {{{
			var pkgdir = Windows.ApplicationModel.Package.Current;
			if(pkgdir != null) {
				v.storage = pkgdir.InstalledLocation;
			}
		}}}
		return(v);
	}

	public static File for_home_directory() {
		var v = new FileImpl();
		embed {{{
			var ad = Windows.Storage.ApplicationData.Current;
			if(ad != null) {
				v.storage = ad.LocalFolder;
			}
		}}}
		return(v);
	}

	public static File for_temporary_directory() {
		var v = new FileImpl();
		embed {{{
			var ad = Windows.Storage.ApplicationData.Current;
			if(ad != null) {
				try {
					v.storage = ad.TemporaryFolder;
				}
				catch(System.NotImplementedException) {
					v.storage = ad.LocalFolder;
					v.subdirectory = "Temp";
				}
			}
			if(v.exists() == false) {
				v.create_directory();
			}
		}}}
		return(v);
	}

	public String get_eqela_path() {
		strptr absp = null;
		embed {{{
			absp = storage.Path;
			if(subdirectory != null) {
				 absp += '\\' + subdirectory;
			}
		}}}
		var path = Path.from_native_notation(String.for_strptr(absp));
		if(path != null) {
			return("/native%s".printf().add(path).to_string());
		}
		return(null);
	}

	public String get_native_path() {
		strptr p;
		embed {{{
			if(storage != null) {
				p = storage.Path;
				if(subdirectory != null) {
					p += '\\' + subdirectory;
				}
			}
		}}}
		if(p!=null) {
			return(String.for_strptr(p));
		}
		return(null);
	}

	public String to_string() {
		return(get_native_path());
	}

	public File entry(String e) {
		if(String.is_empty(e)) {
			return(this);
		}
		var v = new FileImpl();
		embed {{{
			v.storage = storage;
			if(subdirectory != null) {
				v.subdirectory = System.IO.Path.Combine(subdirectory, e.to_strptr());
			}
			else {
				v.subdirectory = e.to_strptr();
			}
		}}}
		return(v);
	}

	public File get_parent() {
		var v = new FileImpl();
		IFNDEF("target_wpcs") {
		embed {{{
			if(subdirectory == null || subdirectory.Length < 1) {
				var ia = storage.GetParentAsync();
				ia.Completed = (sender, status) => {
					mutex.Set();
				};
				mutex.WaitOne();
				mutex.Reset(); 
				v.storage = ia.GetResults();
			}
		}}}
		}
		embed {{{
			if(v.storage == null) {
				v.storage = storage;
				v.subdirectory = System.IO.Path.GetDirectoryName(subdirectory);
			}
		}}}
		return(v);
	}

	public FileInfo stat() {
		var stat = new FileInfo();
		embed {{{
			Windows.Storage.IStorageItem item = storage;
			if(subdirectory != null && subdirectory.Length > 0) {
				var ia = storage.GetItemAsync(subdirectory);
				if(ia == null) {
					return(null);
				}
				ia.Completed = (sender, status) => {
					mutex.Set();
				};
				mutex.WaitOne();
				mutex.Reset();
				try {
					item = ia.GetResults();
					ia.Close();
				}
				catch(System.Exception e) {
					item = null;
					System.Diagnostics.Debug.WriteLine("[ERROR] stat: " + e.Message + "\n\tsubdirectory: " + subdirectory);
				}
			}
			if(item != null) {
				if(item.IsOfType(Windows.Storage.StorageItemTypes.File)) {
					stat.set_type(eq.os.FileInfo.FILE_TYPE_FILE);
				}
				else if(item.IsOfType(Windows.Storage.StorageItemTypes.Folder)) {
					stat.set_type(eq.os.FileInfo.FILE_TYPE_DIR);
				}
				var ia = item.GetBasicPropertiesAsync();
				ia.Completed = (sender, status) => {
					mutex.Set();
				};
				mutex.WaitOne();
				mutex.Reset();
				var props = ia.GetResults();
				ia.Close();
				stat.set_size((int)props.Size);
			}
		}}}
		return(stat);
	}

	public bool create_directory() {
		bool v = false;
		embed {{{
			var ia = storage.CreateFolderAsync(subdirectory);
			ia.Completed = (sender, status) => {
				mutex.Set();
			};
			mutex.WaitOne();
			mutex.Reset();
			Windows.Storage.StorageFolder dir;
			try {
				dir = ia.GetResults();
				ia.Close();
			}
			catch(System.Exception e) {
				dir = null;
				System.Diagnostics.Debug.WriteLine("[ERROR] create_directory: " + e.Message + "\n\tsubdirectory: " + subdirectory);
			}
			if(dir != null) {
				v = true;
			}
		}}}
		return(v);
	}

	public bool touch() {
		bool v = false;
		embed {{{
			var ia = storage.CreateFileAsync(subdirectory, Windows.Storage.CreationCollisionOption.OpenIfExists);
			ia.Completed = (sender, status) => {
				mutex.Set();
			};
			mutex.WaitOne();
			mutex.Reset();
			Windows.Storage.StorageFile file = null;
			try {
				file = ia.GetResults();
				ia.Close();
			}
			catch(System.Exception e) {
				file = null;
				System.Diagnostics.Debug.WriteLine("[ERROR] touch: " + e.Message + "\n\tsubdirectory: " + subdirectory);
			}
			if(file != null) {
				v = true;
			}
		}}}
		return(v);
	}

	class MyFileWriter : Writer
	{
		property bool append;
		int seek_value = 0;
		embed {{{
			System.Threading.ManualResetEvent mutex;
			Windows.Storage.StorageFile file = null;

			public MyFileWriter(Windows.Storage.StorageFile file) {
				mutex = new System.Threading.ManualResetEvent(false);
				this.file = file;
			}
		}}}

		public int write(Buffer buf, int asz) {
			if(buf == null) {
				return(0);
			}
			var bytes = buf.get_pointer().get_native_pointer();
			int sz = asz;
			if(sz < 0) {
				sz = buf.get_size();
			}
			int v = 0;
			embed {{{
				var ia = file.OpenTransactedWriteAsync();
				ia.Completed = (sender, status) => {
					mutex.Set();
				};
				mutex.WaitOne();
				mutex.Reset();
				Windows.Storage.StorageStreamTransaction writer;
				try {
					writer = ia.GetResults();
					ia.Close();
				}
				catch(System.Exception e) {
					writer = null;
					System.Diagnostics.Debug.WriteLine("[ERROR] write: " + e.Message);
				}
				if(writer != null) {
					int write_size = sz;
					if(append) {
						seek_value = (int)writer.Stream.Size;
					}
					if(seek_value > 0) {
						writer.Stream.Seek((ulong)seek_value);
						write_size += seek_value;
					}
					using(var dw = new Windows.Storage.Streams.DataWriter(writer.Stream)) {
						dw.WriteBytes(bytes);
						var ias = dw.StoreAsync();
						ias.Completed = (sender, status) => {
							mutex.Set();
						};
						mutex.WaitOne();
						mutex.Reset();
						v = (int)ias.GetResults();
						ias.Close();
						writer.Stream.Size = (ulong)write_size;
						var iac = writer.CommitAsync();
						iac.Completed = (sender, status) => {
							mutex.Set();
						};
						mutex.WaitOne();
						mutex.Reset();
						iac.Close();
						seek_value = (int)writer.Stream.Size;
					}
				}
			}}}
			return(v);
		}
	}

	public Writer write() {
		Writer v;
		embed {{{
			var ia = storage.CreateFileAsync(subdirectory, Windows.Storage.CreationCollisionOption.OpenIfExists);
			ia.Completed = (sender, status) => {
				mutex.Set();
			};
			mutex.WaitOne();
			mutex.Reset();
			Windows.Storage.StorageFile file;
			try {
				file = ia.GetResults();
				ia.Close();
			}
			catch(System.Exception e) {
				file = null;
			}
			if(file != null) {
				v = new MyFileWriter(file);
			}
		}}}
		return(v);
	}

	public Writer append() {
		var v = (MyFileWriter)write();
		if(v != null) {
			v.set_append(true);
		}
		return(v);
	}

	class MyFileReader : SizedReader, Reader
	{
		int size;
		embed {{{
			System.Threading.ManualResetEvent mutex;
			System.IO.Stream stream = null;

			public MyFileReader(Windows.Storage.StorageFile file) {
				mutex = new System.Threading.ManualResetEvent(false);
				var task = System.IO.WindowsRuntimeStorageExtensions.OpenStreamForReadAsync(file);
				var stream = task.Result;
				if(stream != null) {
					this.stream = stream;
					size = (int)stream.Length;
				}
			}
		}}}

		public int read(Buffer buf) {
			if(buf == null) {
				return(0);
			}
			var bytes = buf.get_pointer().get_native_pointer();
			int sz = buf.get_size();
			int v = 0;
			embed {{{
				if(stream != null) {
					v = stream.Read(bytes, 0, sz);
					if(sz > v) {
						stream.Dispose();
						stream = null;
					}
				}
			}}}
			return(v);
		}

		public int get_size() {
			return(size);
		}
	}

	embed {{{
		public Windows.Storage.StorageFile get_file_sync() {
			Windows.Storage.StorageFile v = null;
			var ia = storage.GetFileAsync(subdirectory);
			ia.Completed = (sender, status) => {
				mutex.Set();
			};
			mutex.WaitOne();
			mutex.Reset();
			try {
				v = ia.GetResults();
				ia.Close();
			}
			catch(System.Exception e) {
				v = null;
			}
			return(v);
		}

		public Windows.Storage.StorageFolder get_folder_sync() {
			if(subdirectory == null || subdirectory.Length < 1) {
				return(storage);
			}
			Windows.Storage.StorageFolder v = null;
			var ia = storage.GetFolderAsync(subdirectory);
			ia.Completed = (sender, status) => {
				mutex.Set();
			};
			mutex.WaitOne();
			mutex.Reset();
			try {
				v = ia.GetResults();
				ia.Close();
			}
			catch(System.Exception e) {
				v = null;
				System.Diagnostics.Debug.WriteLine("[ERROR] get_folder_sync: " + e.Message + "\n\tsubdirectory: " + subdirectory);
			}
			return(v);
		}
	}}}

	public SizedReader read() {
		SizedReader v;
		embed {{{
			var file = get_file_sync();
			if(file != null) {
				v = new MyFileReader(file);
			}
		}}}
		return(v);
	}

	public bool move(File dest, bool replace) {
		if(is_directory()) {
			Log.error("FIXME: Moving directory is N/A in Windows Phone 8 API");
			return(false);
		}
		if(dest.exists()) {
			if(replace == false) {
				return(false);
			}
			dest.remove();
		}
		var ddest = dest.get_parent() as FileImpl;
		var dfname = dest.basename();
		if(ddest != null && String.is_empty(dfname) == false) {
			embed {{{
				var file = get_file_sync();
				var dfolder = ddest.get_folder_sync();
				if(file != null && dfolder != null) {
					var ia = file.MoveAsync(dfolder, dfname.to_strptr());
					ia.Completed = (sender, status) => {
						mutex.Set();
					};
					mutex.WaitOne();
					mutex.Reset();
				}
			}}}
		}
		return(dest.exists());
	}

	public bool remove_directory() {
		bool v = false;
		embed {{{
			var folder = get_folder_sync();
			if(folder != null) {
				var ia = folder.DeleteAsync();
				ia.Completed = (sender, status) => {
					mutex.Set();
				};
				mutex.WaitOne();
				mutex.Reset();
			}
		}}}
		return(exists() == false);
	}

	public bool remove() {
		if(exists() == false) {
			return(false);
		}
		embed {{{
			var ia = storage.GetItemAsync(subdirectory);
			ia.Completed = (sender, status) => {
				mutex.Set();
			};
			mutex.WaitOne();
			mutex.Reset();
			Windows.Storage.IStorageItem item = null;
			try {
				item = ia.GetResults();
				ia.Close();
			}
			catch(System.Exception e) {
				item = null;
				System.Diagnostics.Debug.WriteLine("[ERROR] remove: " + e.Message + "\n\tsubdirectory: " + subdirectory);
			}
			if(item != null) {
				var iad = item.DeleteAsync();
				iad.Completed = (sender, status) => {
					mutex.Set();
				};
				mutex.WaitOne();
				mutex.Reset();
			}
		}}}
		return(exists() == false);
	}

	public bool is_same(File af) {
		if(af == null) {
			return(false);
		}
		var afullpath = get_native_path();
		var bfullpath = af.get_native_path();
		if(afullpath != null) {
			return(afullpath.equals(bfullpath));
		}
		return(false);
	}

	class EntryIterator : Iterator
	{
		FileImpl file;
		embed {{{
			System.Threading.ManualResetEvent mutex;
			System.Collections.Generic.IEnumerator<Windows.Storage.IStorageItem> iterator = null;
		}}}

		public static EntryIterator create(FileImpl file) {
			var v = new EntryIterator();
			embed {{{
				v.mutex = new System.Threading.ManualResetEvent(false);
			}}}
			v.file = file;
			if(v.initialize() == false) {
				return(null);
			}
			return(v);
		}

		public bool initialize() {
			embed {{{
				var folder = file.get_folder_sync();
				if(folder == null) {
					return(false);
				}
				var ia = folder.GetItemsAsync();
				ia.Completed = (sender, status) => {
					mutex.Set();
				};
				mutex.WaitOne();
				mutex.Reset();
				System.Collections.Generic.IReadOnlyList<Windows.Storage.IStorageItem> list = null;
				try {
					list = ia.GetResults();
					ia.Close();
				}
				catch(System.Exception e) {
					list = null;
					System.Diagnostics.Debug.WriteLine("[ERROR] EntryIterator: " + e.Message);
				}
				if(list != null) {
					iterator = list.GetEnumerator();
					return(true);
				}
			}}}
			return(false);
		}

		public Object next() {
			strptr entry_name = null;
			embed {{{
				if(iterator != null) {
					try {
						iterator.MoveNext();
						var item = iterator.Current;
						if(item != null) {
							entry_name = item.Name;
						}
					}
					catch(System.Exception e) {
						entry_name = null;
						System.Diagnostics.Debug.WriteLine("[ERROR] EntryIterator.next(): " + e.Message);
					}
				}
			}}}
			if(entry_name != null) {
				return(file.entry(String.for_strptr(entry_name)));
			}
			return(null);
		}
	}

	public Iterator entries() {
		return(EntryIterator.create(this));
	}
}
