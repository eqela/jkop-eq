
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
	embed "objc" {{{
			#import <AddressBook/ABAddressBook.h>
			#import <AddressBookUI/AddressBookUI.h>
	}}}

	public static Collection retrieve_contacts() {
		LinkedList contact_info = LinkedList.create();
		bool has_access;
		embed "objc" {{{
			CFErrorRef *error = nil;
			ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
			__block BOOL accessGranted = NO;
			if(ABAddressBookRequestAccessWithCompletion != NULL) {
				dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
				ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
					accessGranted = granted;
					dispatch_semaphore_signal(semaphore);
				});
				dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
			}
			else {
				accessGranted = YES;
			}
			has_access = accessGranted;
		}}}
		if(has_access) {
			int npips = 0;
			embed {{{
				ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
				ABRecordRef source = ABAddressBookCopyDefaultSource(addressBook);
				CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, source, kABPersonSortByFirstName);
				npips = (int) CFArrayGetCount(allPeople);
			}}}
			int i;
			for(i = 0; i < npips; i++) {
				Contact c = new Contact();
				strptr c_name, c_phone_number, c_email_address;
				embed "objc" {{{
					ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
					NSString *firstname = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
					NSString *lastname = (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
					if(firstname == nil) {
						firstname = @"";
					}
					if(lastname == nil) {
						lastname = @"";
					}
					NSString *fullname = [NSString stringWithFormat:@"%@ %@", firstname, lastname];
					c_name = (char*) [fullname UTF8String];
				}}}
				c.set_name(String.for_strptr(c_name).dup());
				ptr image_data;
				int len;
				embed "objc" {{{
					NSData *imgData = (__bridge NSData *)ABPersonCopyImageData(person);
					len = (int) [imgData length];
					image_data = (const void*) [imgData bytes];
				}}}
				if(image_data != null) {
					Buffer buf = Buffer.for_pointer(Pointer.create(image_data), len);
					ImageBuffer imgbuffer = ImageBuffer.create().set_buffer(buf);
					c.set_image(Image.create_image_for_buffer(imgbuffer));
				}
				int pns;
				embed "objc" {{{
					ABMultiValueRef multiPhones = ABRecordCopyValue(person, kABPersonPhoneProperty);
					pns = (int)ABMultiValueGetCount(multiPhones);
				}}}
				LinkedList phone_number_list = LinkedList.create();
				int x;
				for(x = 0; x < pns; x++) {
					embed "objc" {{{
						CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(multiPhones, x);
						NSString *phoneNumber = (__bridge NSString *) phoneNumberRef;
						c_phone_number = (char*) [phoneNumber UTF8String];
					}}}
					phone_number_list.add(String.for_strptr(c_phone_number).dup());
				}
				c.set_phone_numbers(phone_number_list);
				int eas;
				embed "objc" {{{
					ABMultiValueRef multiEmails = ABRecordCopyValue(person, kABPersonEmailProperty);
					eas = (int)ABMultiValueGetCount(multiEmails);
				}}}
				LinkedList email_add_list = LinkedList.create();
				int y;
				for(y = 0; y < eas; y++) {
					embed "objc" {{{
						CFStringRef contactEmailRef = ABMultiValueCopyValueAtIndex(multiEmails, y);
						NSString *contactEmail = (__bridge NSString *)contactEmailRef;
						c_email_address = (char*) [contactEmail UTF8String];
					}}}
					email_add_list.add(String.for_strptr(c_email_address).dup());
				}
				c.set_email_addresses(email_add_list);
				contact_info.add(c);
			}
		}
		else {
			ModalDialog.message("Access to contact list not granted. Change privacy setting on settings app.");
		}
		return(contact_info);
	}
}
