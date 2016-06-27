
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

public class RssFeed : Iterateable
{
	property String title;
	property String link;
	property String description;
	property String language;
	property String copyright;
	property String last_build_date;
	property Collection items;

	public RssFeed() {
		items = LinkedList.create();
	}

	public RssFeed add(RssFeedItem rfi) {
		if(rfi != null) {
			items.add(rfi);
		}
		return(this);
	}

	public int item_count() {
		return(items.count());
	}

	public Iterator iterate() {
		return(items.iterate());
	}

	public static RssFeed for_string(String xml) {
		if(xml == null) {
			return(null);
		}
		return(for_reader(StringReader.create(xml)));
	}

	public static RssFeed for_reader(Reader reader) {
		if(reader == null) {
			return(null);
		}
		return(RssFeedParser.create(reader).parse());
	}
}

