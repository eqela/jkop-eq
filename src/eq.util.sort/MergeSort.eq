
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

public class MergeSort
{
	public static Collection sort(Collection collection, Comparer comparer = null) {
		if(collection == null) {
			return(null);
		}
		var cc = comparer;
		if(cc == null) {
			cc = new StringComparer();
		}
		return(do_sort(collection, cc));
	}

	public static void sort_array(Array array, Comparer comparer = null) {
		if(array == null) {
			return;
		}
		var cc = comparer;
		if(cc == null) {
			cc = new StringComparer();
		}
		merge_sort(array, 0, array.count() - 1, cc);
	}

	private static Collection do_sort(Collection collection, Comparer compare) {
		var new_collection = Array.create();
		if(collection != null) {
			if(collection.count() != 0) {
				int i = 0;
				var iterator = collection.iterate();
				Object obj = null;
				while((obj = iterator.next()) != null) {
					new_collection.insert(obj, i++);
				}
				merge_sort(new_collection, 0, collection.count() - 1, compare);
			}
		}
		return(new_collection);
	}

	private static void merge_sort(Collection src_collection, int start, int end, Comparer compare) {
		if(start >= end) {
			return;
		}
		int mid = (end + start) / 2;
		merge_sort(src_collection, start, mid, compare);
		merge_sort(src_collection, mid + 1, end, compare);
		merge_arrays(src_collection, start, mid, end, compare);
	}

	private static void merge_arrays(Collection src_collection, int start, int mid, int end, Comparer compare) {
		int j = 0;
		int size = end - start + 1;
		int pos1 = 0;
		int pos2 = mid - start + 1;
		var temp = Array.create(size);
		var iterator = src_collection.iterate_from_index(start);
		Object obj = null;
		while((obj = iterator.next()) != null && j < size) {
			temp.insert(obj, j++);
		}
		for(j = 0; j < size; j++) {
			if(pos2 <= end - start) {
				if(pos1 <= mid - start) {
					if(compare.compare(temp.get_index(pos1), temp.get_index(pos2)) > 0) {
						src_collection.set_index(j+start, temp.get_index(pos2));
						pos2++;
					}
					else {
						src_collection.set_index(j+start, temp.get_index(pos1));
						pos1++;
					}
				}
				else {
					src_collection.set_index(j+start, temp.get_index(pos2));
					pos2++;
				}
			}
			else {
				src_collection.set_index(j+start, temp.get_index(pos1));
				pos1++;
			}
		}
	}
}

