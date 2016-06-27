
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

public class SystemEnvironment
{
	static SystemEnvironmentInterface se;

	static void initialize() {
		if(se == null) {
			se = new SystemEnvironmentImpl();
		}
	}

	public static bool is_os(String id) {
		initialize();
		return(se.is_os(id));
	}

	public static HashTable get_env_vars() {
		initialize();
		return(se.get_env_vars());
	}

	public static String get_env_var(String key) {
		initialize();
		return(se.get_env_var(key));
	}

	public static bool set_env_var(String key, String val) {
		initialize();
		return(se.set_env_var(key, val));
	}

	public static bool unset_env_var(String key) {
		initialize();
		return(se.unset_env_var(key));
	}

	public static void set_current_dir(File d) {
		initialize();
		if(d != null) {
			se.set_current_directory(d.get_native_path());
		}
	}

	public static void terminate(int rv) {
		initialize();
		se.terminate(rv);
	}

	public static void sleep(int sec) {
		initialize();
		se.sleep(sec);
	}

	public static void usleep(int usec) {
		initialize();
		se.usleep(usec);
	}

	public static File find_command(String cmd) {
		initialize();
		return(se.find_command(cmd));
	}

	public static String get_current_url() {
		initialize();
		return(se.get_current_url());
	}

	public static File get_photo_dir() {
		initialize();
		return(se.get_photo_dir());
	}

	public static File get_documents_dir() {
		initialize();
		return(se.get_documents_dir());
	}

	public static File get_music_dir() {
		initialize();
		return(se.get_music_dir());
	}

	public static File get_download_dir() {
		initialize();
		return(se.get_download_dir());
	}

	public static File get_home_dir() {
		initialize();
		return(se.get_home_dir());
	}

	public static File get_temporary_dir() {
		initialize();
		return(se.get_temporary_dir());
	}

	public static File get_current_dir() {
		initialize();
		return(se.get_current_dir());
	}

	public static File find_self() {
		initialize();
		return(se.find_self());
	}

	public static String get_current_user_id() {
		initialize();
		return(se.get_current_user_id());
	}

	public static String get_current_process_id() {
		initialize();
		return(se.get_current_process_id());
	}

	public static File get_program_files_dir() {
		initialize();
		return(se.get_program_files_dir());
	}

	public static File get_program_files_x86_dir() {
		initialize();
		return(se.get_program_files_x86_dir());
	}
}
