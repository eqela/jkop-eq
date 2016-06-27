
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

class PhotoLibraryBackendIOS : PhotoLibrary
{
	embed "objc" {{{
		#import <UIKit/UIKit.h>
		#import <AssetsLibrary/AssetsLibrary.h>
	}}}

	public static PhotoLibrary instance() {
		var pl = new PhotoLibraryBackendIOS();
		if(pl.initialize()) {
			return(pl);
		}
		return(null);
	}

	ptr ptrlibrary = null;
	ptr ptrassets = null;

	~PhotoLibraryBackendIOS() {
		cleanup();
	}

	void cleanup() {
		if(ptrlibrary != null) {
			var ptrl = ptrlibrary;
			embed "objc" {{{
				ALAssetsLibrary *library = (__bridge_transfer ALAssetsLibrary*)ptrl;
				library = nil;
			}}}
		}
		ptrlibrary = null;
		if(ptrassets != null) {
			var ptra = ptrassets;
			embed "objc" {{{
				NSMutableArray *assets = (__bridge_transfer NSMutableArray*)ptra;
				[assets removeAllObjects];
				assets = nil;
			}}}
		}
		ptrassets = null;
	}

	bool initialize() {
		bool v = false;
		ptr ptrl = null;
		ptr ptra = null;
		embed "objc" {{{
			ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
			dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
			__block BOOL accessGranted = YES;
			__block NSMutableArray *assets = [[NSMutableArray alloc] init];
			[library enumerateGroupsWithTypes: ALAssetsGroupAll
				usingBlock: ^(ALAssetsGroup *group, BOOL *stop) {
					if (group) {
						[group setAssetsFilter:[ALAssetsFilter allPhotos]];
						[group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
							if (asset) {
								[assets addObject:asset];
							}
						}];
					}
					else {
						dispatch_semaphore_signal(semaphore);
					}
				}
				failureBlock: ^(NSError *error) {
					accessGranted = NO;
					dispatch_semaphore_signal(semaphore);
				}
			];
			dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
			v = accessGranted;
			ptrl = (__bridge_retained void*)library;
			ptra = (__bridge_retained void*)assets;
		}}}
		ptrlibrary = ptrl;
		ptrassets = ptra;
		if(!v) {
			ModalDialog.message("Access to photos not granted. Change privacy setting on settings app.");
		}
		return(v);
	}

	public int get_photo_count() {
		int cnt = 0;
		if(ptrassets == null) {
			return(cnt);
		}
		var ptra = ptrassets;
		embed "objc" {{{
			NSMutableArray *assets = (__bridge NSMutableArray*)ptra;
			cnt = [assets count];
			ptra = (__bridge_retained void*)assets;
		}}}
		ptrassets = ptra;
		return(cnt);
	}

	public PhotoLibraryEntry get_fullsize_by_index(int index) {
		if(index < 0) {
			return(null);
		}
		var ptra = ptrassets;
		ptr fs = null;
		ptr fn = null;
		embed "objc" {{{
			NSMutableArray *assets = (__bridge NSMutableArray*)ptra;
			ALAsset *asset = [assets objectAtIndex:index];
			ALAssetRepresentation *representation = [asset defaultRepresentation];
			UIImageOrientation orientation = UIImageOrientationUp;
			NSNumber* orientationValue = [asset valueForProperty:@"ALAssetPropertyOrientation"];
			if (orientationValue != nil) {
				orientation = [orientationValue intValue];
			}
			fs = (__bridge void*)[UIImage imageWithCGImage:[representation fullResolutionImage]
				scale:[representation scale] orientation:orientation];
			fn = [[representation filename] UTF8String];
			ptra = (__bridge_retained void*)assets;
		}}}
		if(fn == null || fs == null) {
			return(null);
		}
		ptrassets = ptra;
		var ple = new PhotoLibraryEntry();
		ple.set_image(render_image(fs));
		ple.set_filename(String.for_strptr(fn));
		return(ple);
	}

	QuartzBitmapImage render_image(ptr img) {
		ptr nimg = img;
		int iw, ih;
		embed {{{
			UIImage *uiimage = (__bridge UIImage*)nimg;
			if(uiimage != nil) {
				iw = uiimage.size.width;
				ih = uiimage.size.height;
			}
		}}}
		var bm = QuartzBitmapImage.create(iw, ih, false);
		if(bm != null) {
			var qctx = bm.get_context();
			if(qctx != null) {
				embed "objc" {{{
					UIGraphicsPushContext((CGContextRef)qctx);
					[uiimage drawInRect:CGRectMake(0,0,iw,ih)];
					UIGraphicsPopContext();
				}}}
			}
		}
		return(bm);
	}

	public void get_thumbnail_by_index(int index, PhotoLibraryThumbnailListener listener) {
		if(index < 0 || ptrassets == null) {
			if(listener != null) {
				listener.on_thumbnail_photo(null);
			}
			return;
		}
		var ptra = ptrassets;
		ptr tmb = null;
		ptr fn = null;
		embed "objc" {{{
			NSMutableArray *assets = (__bridge NSMutableArray*)ptra;
			ALAsset *asset = [assets objectAtIndex:index];
			ALAssetRepresentation *representation = [asset defaultRepresentation];
			tmb = (__bridge void*)[UIImage imageWithCGImage:[asset thumbnail]];
			fn = [[representation filename] UTF8String];
			ptra = (__bridge_retained void*)assets;
		}}}
		if(listener != null) {
			if(fn == null || tmb == null) {
				return;
			}
			var ple = new PhotoLibraryEntry();
			ple.set_image(render_image(tmb));
			ple.set_filename(String.for_strptr(fn));
			listener.on_thumbnail_photo(ple);
		}
		ptrassets = ptra;
	}
}
