
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

interface SystemEnvironmentInterface
{
	public HashTable get_env_vars();
	public String get_env_var(String key);
	public bool set_env_var(String key, String val);
	public bool unset_env_var(String key);
	public void set_current_directory(String d);
	public void terminate(int rv);
	public void sleep(int sec);
	public void usleep(int usec);
	public File find_command(String cmd);
	public String get_current_url();
	public File get_photo_dir();
	public File get_documents_dir();
	public File get_music_dir();
	public File get_download_dir();
	public File get_home_dir();
	public File get_temporary_dir();
	public File get_current_dir();
	public File find_self();
	public String get_current_user_id();
	public String get_current_process_id();
	public File get_program_files_dir();
	public File get_program_files_x86_dir();
	public bool is_os(String id);
}
