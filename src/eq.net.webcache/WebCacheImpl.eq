
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

IFNDEF("target_html") {

class WebCacheImpl : WebCache, LoggerObject
{
	property File cachedir;
	property int local_norefresh_ttl = 60 * 60 * 24;

	String get_etag(File file) {
		var ef = get_etag_file(file);
		if(ef == null || ef.is_file() == false) {
			return(null);
		}
		var ss = ef.get_contents_string();
		if(ss == null) {
			return(null);
		}
		return(ss.strip());
	}

	File get_etag_file(File file) {
		if(file == null) {
			return(null);
		}
		return(file.get_sibling("%s.__etag__".printf().add(file.basename()).to_string()));
	}

	public File get_cache_file(URL url) {
		if(cachedir == null || url == null) {
			return(null);
		}
		var ff = cachedir;
		var host = url.get_host();
		var port = url.get_port();
		if(String.is_empty(port) == false) {
			host = "%s:%s".printf().add(host).add(port).to_string();
		}
		if(String.is_empty(host)) {
			host = "UNKNOWN";
		}
		ff = ff.entry(host);
		foreach(String cc in StringSplitter.split(url.get_path(), (int)'/')) {
			if(String.is_empty(cc)) {
				continue;
			}
			ff = ff.entry(cc);
		}
		return(ff);
	}

	public void remove_cache_file(File file) {
		if(file == null) {
			return;
		}
		file.remove();
		var etag = get_etag_file(file);
		if(etag != null) {
			etag.remove();
		}
	}

	class MyHTTPClientFileWriter : HTTPClientFileWriter
	{
		property WebCacheImpl cache;
		property EventReceiver mylistener;
		property File realfile;

		public void on_file_response(HTTPClientFileResponse resp) {
			if(resp == null) {
				EventReceiver.event(mylistener, null);
				return;
			}
			var file = resp.get_file();
			if(file == null || file.is_file() == false) {
				EventReceiver.event(mylistener, null);
				return;
			}
			if(realfile != null) {
				if(file.move(realfile, true) == false) {
					log_error("Failed to move file: `%s' -> `%s'".printf().add(file).add(realfile));
				}
				file = realfile;
			}
			var hdro = get_header();
			if(hdro != null) {
				var etag = hdro.get_header("etag");
				if(String.is_empty(etag) == false) {
					var etagfile = file.get_sibling("%s.__etag__".printf().add(file.basename()).to_string());
					if(etagfile.set_contents_string(etag) == false) {
						log_error("Failed to write file: `%s'".printf().add(etagfile));
					}
				}
			}
			var status = get_status();
			log_debug("HTTP status = `%s'".printf().add(status));
			if(status == null) {
				status = "";
			}
			if(status.has_prefix("2") || "304".equals(status) || status.has_prefix("5")) {
				; // all good, at least sort of. make sure the file timestamp is up to date.
				if(file.is_file()) {
					file.touch();
				}
			}
			else if(status.has_prefix("4") || status.has_prefix("3")) {
				if(cache != null) {
					cache.remove_cache_file(file);
				}
			}
			if(file.is_file() == false) {
				file = null;
			}
			EventReceiver.event(mylistener, file);
		}
	}

	public bool clear() {
		bool v = true;
		if(cachedir != null) {
			foreach(File f in cachedir.entries()) {
				if(f.delete_recursive() == false) {
					log_error("Failed to delete: `%s'".printf().add(f));
					v = false;
				}
			}
		}
		return(v);
	}

	public Object execute_get_file_request(BackgroundTaskManager el, URL url, bool reload, EventReceiver er) {
		if(url == null) {
			return(null);
		}
		var path = url.get_path();
		if(path != null && path.has_suffix(".__etag__")) {
			return(null);
		}
		var ff = get_cache_file(url);
		log_debug("Cache file for URL `%s': `%s'".printf().add(url).add(ff));
		if(reload) {
			remove_cache_file(ff);
		}
		var etag = get_etag(ff);
		if(ff.is_file() == false) {
			etag = null;
		}
		if(ff.is_file() && etag != null && local_norefresh_ttl > 0) {
			var st = ff.stat();
			if(st != null) {
				var ffmt = st.get_modify_time();
				var now = SystemClock.seconds();
				if(ffmt + local_norefresh_ttl > now) {
					log_debug("File `%s' is %d / %s seconds old, using it without checking the origin server.".printf()
						.add(ff).add((int)(now - ffmt)).add(local_norefresh_ttl));
					return(ff);
				}
			}
		}
		var ffd = ff.get_parent();
		if(ffd != null && ffd.is_directory() == false) {
			if(ffd.mkdir_recursive() == false) {
				log_error("Failed to create cache directory: `%s'".printf().add(ffd));
			}
		}
		var rq = HTTPClientRequest.get(url);
		if(String.is_empty(etag) == false) {
			rq.set_header("If-None-Match", etag);
		}
		if(rq == null) {
			return(null);
		}
		var listener = new MyHTTPClientFileWriter().set_mylistener(er).set_realfile(ff)
			.set_destfile(TemporaryFile.for_directory(ff.get_parent()));
		listener.set_logger(get_logger());
		if(er != null) {
			return(rq.start(el, listener));
		}
		rq.execute(listener);
		if(ff.is_file() == false) {
			ff = null;
		}
		return(ff);
	}

	public File get_file_sync(URL url, bool reload) {
		return(execute_get_file_request(null, url, reload, null) as File);
	}

	public BackgroundTask get_file_async(BackgroundTaskManager el, URL url, bool reload, EventReceiver er) {
		var r = execute_get_file_request(el, url, reload, er);
		if(r == null) {
			return(null);
		}
		if(r is File) {
			EventReceiver.event(er, r);
			return(null);
		}
		if(r is BackgroundTask) {
			return((BackgroundTask)r);
		}
		return(null);
	}
}

}
