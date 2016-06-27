
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

public class ContactsRetrieverBackend
{
	public static Collection retrieve_contacts() {
		LinkedList contact_info = LinkedList.create();
		embed "java" {{{
			java.lang.String phonenumber = null;
			java.lang.String email = null;
			android.net.Uri content_uri = android.provider.ContactsContract.Contacts.CONTENT_URI;
			java.lang.String id = android.provider.ContactsContract.Contacts._ID;
			java.lang.String display_name = android.provider.ContactsContract.Contacts.DISPLAY_NAME;
			java.lang.String has_phone_number = android.provider.ContactsContract.Contacts.HAS_PHONE_NUMBER;

			android.net.Uri phone_content_uri = android.provider.ContactsContract.CommonDataKinds.Phone.CONTENT_URI;
			java.lang.String phone_contact_id = android.provider.ContactsContract.CommonDataKinds.Phone.CONTACT_ID;
			java.lang.String phone_number = android.provider.ContactsContract.CommonDataKinds.Phone.NUMBER;

			android.net.Uri email_content_uri = android.provider.ContactsContract.CommonDataKinds.Email.CONTENT_URI;
			java.lang.String email_contact_id = android.provider.ContactsContract.CommonDataKinds.Email.CONTACT_ID;
			java.lang.String email_add = android.provider.ContactsContract.CommonDataKinds.Email.DATA;

			android.content.ContentResolver content_resolver = eq.api.Android.context.getContentResolver();
			android.database.Cursor cursor = content_resolver.query(content_uri, null, null, null, android.provider.ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME + " ASC");
			if(cursor.getCount() > 0) {
				while(cursor.moveToNext()) {
					java.lang.String contact_id = cursor.getString(cursor.getColumnIndex( id ));
					java.lang.Long long_contact_id = cursor.getLong(cursor.getColumnIndex( id ));
					java.lang.String contact_name = cursor.getString(cursor.getColumnIndex( display_name ));
					int contact_has_phone_number = Integer.parseInt(cursor.getString(cursor.getColumnIndex( has_phone_number )));
					Contact c = new Contact();
					if(contact_has_phone_number > 0) {
						c.set_name(eq.api.String.Static.for_strptr(contact_name));
						android.database.Cursor phone_cursor = content_resolver.query(phone_content_uri, null, phone_contact_id
								+ " = ?", new String[] { contact_id }, null);
						eq.api.LinkedList phonenumber_list = eq.api.LinkedList.Static.create();
						while(phone_cursor.moveToNext()) {
							phonenumber = phone_cursor.getString(phone_cursor.getColumnIndex(phone_number));
							phonenumber_list.add((eq.api.Object)eq.api.String.Static.for_strptr(phonenumber));
						}
						c.set_phone_numbers(phonenumber_list);
						phone_cursor.close();
						android.net.Uri photo_uri = android.content.ContentUris.withAppendedId(content_uri, long_contact_id);
						java.io.InputStream input = android.provider.ContactsContract.Contacts.openContactPhotoInputStream(content_resolver, photo_uri);
						android.graphics.Bitmap thumbnail = null;
						if(input != null) {
							thumbnail = android.graphics.BitmapFactory.decodeStream(input);
						}
						eq.gui.Image tmb = (eq.gui.Image)eq.gui.sysdep.android.AndroidBitmapImage.for_android_bitmap(thumbnail);
						c.set_image(tmb);
						android.database.Cursor email_cursor = content_resolver.query(email_content_uri, null, email_contact_id 
								+ " = ?", new String[] { contact_id }, null);
						eq.api.LinkedList email_list = eq.api.LinkedList.Static.create();
						while(email_cursor.moveToNext()) {
							email = email_cursor.getString(email_cursor.getColumnIndex(email_add));
							email_list.add((eq.api.Object)eq.api.String.Static.for_strptr(email));
						}
						c.set_email_addresses(email_list);
						email_cursor.close();
					}
					contact_info.add(c);
				}
			}
		}}}
		return(contact_info);
	}
}
