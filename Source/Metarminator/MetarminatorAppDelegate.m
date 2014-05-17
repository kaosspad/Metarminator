//
//  MetarminatorAppDelegate.m
//  Metarminator
//
//  Copyright (c) 2014 Cai, Zhi-Wei. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import <AVFoundation/AVFoundation.h>
#import "MetarminatorAppDelegate.h"

#import <dispatch/dispatch.h>

@implementation MetarminatorAppDelegate

#pragma mark - Synthesize

@synthesize ui_m_Window, ui_m_DrawerOptions, ui_m_New, ui_m_Save, ui_m_SaveAll, ui_m_Remove, ui_m_Drawer, ui_m_Play, ui_m_Edit, ui_m_Queue, ui_m_Indicator, ui_mm_Add, ui_mm_Save, ui_mm_SaveAll, ui_mm_SaveAs, ui_mm_Remove, ui_m_ExportView ,ui_m_ExportType, ui_m_ExportQuality, ui_m_ExportQualityValue, ui_m_MultipleSavingView, ui_m_MultipleSavingCheckbox, ui_m_PermanentRemovingView, ui_m_PermanentRemovingText, ui_m_PermanentRemovingCheckbox, ui_is_Name, ui_is_Artist, ui_is_AlbumArtist, ui_is_Album, ui_is_Grouping, ui_is_Composer, ui_is_Comments, ui_is_Genre, ui_is_GenreID, ui_is_Year, ui_is_TrackNumberFirst, ui_is_TrackNumberLast, ui_is_DiscNumberFirst, ui_is_DiscNumberLast, ui_is_BPM, ui_is_PartOfACompilation, ui_is_Advisory, ui_ss_Name, ui_ss_Artist, ui_ss_AlbumArtist, ui_ss_Album, ui_ss_Composer, ui_ss_Show, ui_ss_Encoder, ui_ss_EncodedBy, ui_ss_VideoDescription, ui_ss_VideoLongDescription, ui_ss_VideoNetwork, ui_ss_VideoShow, ui_ss_VideoEpisodeID, ui_ss_VideoSeasonNumber, ui_ss_VideoEpisodeNumber, ui_ss_MediaType, ui_ss_HDVideo, ui_ss_Gapless, ui_ps_PodcastURL, ui_ps_PodcastGUID, ui_ps_Podcast, ui_ps_PodcastKeywords, ui_ps_PodcastCategory, ui_ls_Lyrics, ui_as_Artwork, ui_cs_Copyright, ui_cs_PurchaseBy, ui_cs_PurchaseDate, ui_cs_AppleID, ui_cs_AccountType, ui_cs_iTunesCatalogID, ui_cs_StoreID, ui_cs_Description, ui_cs_ISRC, ui_cs_UserID, ui_cs_AACType, ui_i_Artwork, ui_i_Name, ui_i_Artist, ui_i_AlbumArtist, ui_i_Album, ui_i_Grouping, ui_i_Composer, ui_i_Comments, ui_i_Genre, ui_i_GenreID, ui_i_Year, ui_i_TrackNumberFirst, ui_i_TrackNumberLast, ui_i_DiscNumberFirst, ui_i_DiscNumberLast, ui_i_BPM, ui_i_PartOfACompilation, ui_i_Advisory, ui_s_Name, ui_s_Artist, ui_s_AlbumArtist, ui_s_Album, ui_s_Composer, ui_s_Show, ui_s_Encoder, ui_s_EncodedBy, ui_s_VideoDescription, ui_s_VideoLongDescription, ui_s_VideoNetwork, ui_s_VideoShow, ui_s_VideoEpisodeID, ui_s_VideoSeasonNumber, ui_s_VideoEpisodeNumber, ui_s_MediaType, ui_s_HDVideo, ui_s_Gapless, ui_p_PodcastURL, ui_p_PodcastGUID, ui_p_Podcast, ui_p_PodcastKeywords, ui_p_PodcastCategory, ui_l_Lyrics, ui_a_Artwork, ui_a_ArtworkScale, ui_a_Stepper, ui_a_Info, ui_c_Copyright, ui_c_PurchaseBy, ui_c_PurchaseDate, ui_c_AppleID, ui_c_AccountType, ui_c_iTunesCatalogID, ui_c_StoreID, ui_c_Description, ui_c_ISRC, ui_c_UserID, ui_c_AACType;

#pragma mark - System Methods

- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
    [self createImage];
    [self createStoreList];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"]) {
        [self optionsCalibrate:YES];
        [self optionsDrawerCalibrate:nil];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];
    }
    [self optionsDrawerCalibrate];
    [self UICalibrate];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self checkUpdateWithFeedback:YES];
    
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
    return YES;
}

#pragma mark - Non-UI Functions

NSData *dataFromHEXString(NSString *theHEX)
{
    // Source: http://stackoverflow.com/a/17511588
    
    const char *chars = theHEX.UTF8String;
    NSUInteger i = 0, len = theHEX.length;
    NSMutableData *data = [NSMutableData dataWithCapacity:len / 2];
    char byteChars[3] = {'\0','\0','\0'};
    unsigned long wholeByte;
    while (i < len) {
        byteChars[0] = chars[i++];
        byteChars[1] = chars[i++];
        wholeByte = strtoul(byteChars, NULL, 16);
        [data appendBytes:&wholeByte length:1];
    }
    return data;
}

NSUInteger searchOffsetFromURLWithKey(NSURL *theURL, NSString *theKey)
{
    
    NSData *data  = [[NSFileHandle fileHandleForReadingFromURL:theURL
                                                        error:nil]
                    readDataToEndOfFile];
    NSRange range = [data rangeOfData:dataFromHEXString(theKey)
                              options:0
                                range:NSMakeRange(0, data.length)];
    
    if (range.location != NSNotFound &&
        range.location + range.length < data.length) {
        return range.location;
    }
    
    return 0;
    
}

void writeDataToURLWithHEXAndCapacity(NSData *theData, NSURL *theURL, NSString *theHEX, NSUInteger theCapacity)
{
    NSUInteger offset, len;
    NSMutableData *data;
    NSFileHandle *file;
    
    offset = searchOffsetFromURLWithKey(theURL, theHEX);
    if (offset) {
        data = [[NSMutableData alloc] initWithCapacity:theCapacity];
        len  = theData.length;
        if (len > theCapacity) {
            len = theCapacity;
            theData = [theData subdataWithRange:NSMakeRange(0, theCapacity)];
        }
        [data setData:theData];
        [data resetBytesInRange:NSMakeRange(len, theCapacity-len)];

        file = [NSFileHandle fileHandleForWritingToURL:theURL error:nil];
        [file seekToFileOffset:offset+theHEX.length/2];
        [file writeData:data];
        [file closeFile];
    }
}

NSData *readDataFromURLWithHEXAndCapacity(NSURL *theURL, NSString *theHEX, NSUInteger theCapacity)
{
    NSUInteger offset;
    NSData *data;
    NSFileHandle *file;
    
    data = nil;
    offset = searchOffsetFromURLWithKey(theURL, theHEX);
    if (offset) {
        file = [NSFileHandle fileHandleForReadingFromURL:theURL error:nil];
        [file seekToFileOffset:offset+theHEX.length/2];
        data = [[NSData alloc] initWithData:[file readDataOfLength:theCapacity]];
        [file closeFile];
    }
    return data;
}

#pragma mark - Non-UI Methods - AVFoundation

- (BOOL)writeAssetToURL:(NSURL *)theURL withDictionary:(NSDictionary *)assetDict andFileType:(NSString *)theFileType andFormat:(NSString *)theAVFormat andKeySpace:(NSString *)theKeySpace
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:theURL options:nil];
    if (!asset || ![asset isExportable]) {
        return NO;
    }
    AVAssetExportSession *session = [AVAssetExportSession exportSessionWithAsset:asset
                                                                      presetName:AVAssetExportPresetPassthrough];
    if (![[session supportedFileTypes] containsObject:theFileType]) {
        return NO;
    }
    NSString *exportPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[self getUUID]];
    NSURL *exportUrl = [NSURL fileURLWithPath:exportPath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];
    }
    
    NSMutableDictionary *mutableMetadataDict = [NSMutableDictionary dictionaryWithDictionary:assetDict];
    [mutableMetadataDict removeObjectForKey:@"com.apple.iTunes.iTunSMPB"];
    [mutableMetadataDict removeObjectForKey:@"com.apple.iTunes.iTunNORM"];
    
    NSMutableArray *newMetadata = [NSMutableArray array];
    for (id key in [mutableMetadataDict keyEnumerator]) {
		id value = [mutableMetadataDict objectForKey:key];
		if (value) {
			AVMutableMetadataItem *newItem = [AVMutableMetadataItem metadataItem];
			newItem.key = key;
			if (nil != theKeySpace) {
				newItem.keySpace = theKeySpace;
			}
			else {
				newItem.keySpace = AVMetadataKeySpaceCommon;
			}
			newItem.value = value;
			[newMetadata addObject:newItem];
		}
	}
    
    session.outputURL      = exportUrl;
    session.outputFileType = theFileType;
    session.metadata       = newMetadata;
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    __block BOOL result   = NO;
    [session exportAsynchronouslyWithCompletionHandler:^{
        
        switch (session.status) {
            case AVAssetExportSessionStatusFailed:
#ifdef DEBUG
                NSLog(@"Export Status %@", session.error);
#endif
                break;
            case AVAssetExportSessionStatusCancelled:
#ifdef DEBUG
                NSLog(@"Export canceled");
#endif
                break;
            case AVAssetExportSessionStatusExporting:
#ifdef DEBUG
                NSLog(@"Export Exporting");
#endif
                break;
            case AVAssetExportSessionStatusCompleted:
#ifdef DEBUG
                NSLog(@"Export completed");
#endif
                result = YES;
                break;
            default:
                break;
        }
        
        if (result) {
            NSError *err;
            NSFileManager *fm = [NSFileManager defaultManager];
            if ([fm fileExistsAtPath:theURL.path]) {
                [fm removeItemAtPath:theURL.path error:&err];
#ifdef DEBUG
                NSLog(@"Removing file: %@", err);
#endif
            }
            err = nil;
            [fm moveItemAtURL:exportUrl toURL:theURL error:&err];
            if (err) {
                result = NO;
            }
#ifdef DEBUG
            NSLog(@"Moving file: %@", err);
#endif
        }
        
		dispatch_semaphore_signal(semaphore);
    }];
    
    long r = 0;
	do {
        r = dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC));
	} while ( r );
    
    return result;
}

#pragma mark - Non-UI Functions - AVFoundation

NSDictionary *dictionaryAssetWithURL(NSURL *theURL)
{
    AVURLAsset *ast = [AVURLAsset URLAssetWithURL:theURL
                                          options:nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (NSString *fmt in [ast availableMetadataFormats]) {
		NSArray *items = [ast metadataForFormat:fmt];
		if ([items count]) {
			for (AVMetadataItem *item in items) {
                if (nil != fmt) {
                    NSString *keyAsString = nil;
                    if ([item.key isKindOfClass:[NSString class]]) {
                        keyAsString  = (NSString *)item.key;
                    } else if ([item.key isKindOfClass:[NSNumber class]]) {
                        keyAsString = stringForOSType([(NSNumber *)item.key unsignedIntValue]);
                    } else if ([item.key isKindOfClass:[NSObject class]]) {
                        keyAsString = [(NSObject *)item.key description];
                    } else {
                        // Do nothing.
                    }
                    [dict setObject:item.value forKey:keyAsString];
                } else {
                    [dict setObject:item.value forKey:item.commonKey];
                }
            }
		}
	}
    return dict;
}

NSArray *coverArrayWithURL(NSURL *theURL)
{
    return [AVMetadataItem metadataItemsFromArray:[AVURLAsset URLAssetWithURL:theURL options:nil].commonMetadata
                                          withKey:AVMetadataCommonKeyArtwork
                                         keySpace:AVMetadataKeySpaceCommon];
}

NSUInteger intgerForData(NSData *theData)
{
    NSUInteger i = *(NSInteger*)(theData.bytes);
    return (NSUInteger)((theData.length < 4) ? EndianU16_BtoN(i) : EndianU32_BtoN(i));
}

NSData *dataForInteger(NSUInteger theInteger)
{
    int i = (sizeof(theInteger) < 4) ? EndianU16_NtoB(theInteger) : EndianU32_NtoB(theInteger);
    return [NSData dataWithBytes:&i length:sizeof(i)];
}

NSString *intgerStringForDataWithRange(NSData *theData, NSUInteger theLocation, NSUInteger theLength)
{
    NSUInteger i = *(NSInteger*)([theData subdataWithRange:NSMakeRange(theLocation, theLength)].bytes);
    i = (NSUInteger)((theLength < 4) ? EndianU16_BtoN(i) : EndianU32_BtoN(i));
    return (i) ? [NSString stringWithFormat:@"%lu", i] : @"";
}

NSString *stringForOSType(OSType theOSType)
{
    // Taken from: https://developer.apple.com/library/mac/samplecode/avmetadataeditor/Introduction/Intro.html
    
	size_t len = sizeof(OSType);
	long addr = (unsigned long)&theOSType;
	char cstring[5];
	
	len = (theOSType >> 24) == 0 ? len - 1 : len;
	len = (theOSType >> 16) == 0 ? len - 1 : len;
	len = (theOSType >>  8) == 0 ? len - 1 : len;
	len = (theOSType >>  0) == 0 ? len - 1 : len;
	
	addr += (4 - len);
	
	theOSType = EndianU32_NtoB(theOSType);
	
	strncpy(cstring, (char *)addr, len);
	cstring[len] = 0;
	
	return [NSString stringWithCString:(char *)cstring encoding:NSMacOSRomanStringEncoding];
}

#pragma mark - Non-UI Methods

- (NSString *)getUUID
{
    CFUUIDRef   uuidRef         = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef uuidStringRef   = CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
    if (uuidRef) CFRelease(uuidRef);
    return CFBridgingRelease(uuidStringRef);
}

- (id)objectOfKey:(NSString *)theKey fromDictionary:(NSDictionary *)theDict
{
    return [[[NSDictionary alloc] initWithDictionary:theDict] objectForKey:theKey];
}

- (NSString *)applicationName
{
    return NSRunningApplication.currentApplication.localizedName;
}

- (NSURL *)URLFromPath:(NSString *)thePath
{
    return [NSURL fileURLWithPath:thePath];
}

- (NSImage *)resizeImage:(NSImage*)theImage size:(NSSize)newSize
{
    NSImage *sourceImage = theImage;
    [sourceImage setScalesWhenResized:YES];
    
    // Report an error if the source isn't a valid image
    if (![sourceImage isValid]){
#ifdef DEBUG
        NSLog(@"Invalid Image");
#endif
    } else {
        NSImage *smallImage = [[NSImage alloc] initWithSize:newSize];
        [smallImage lockFocus];
        [sourceImage setSize:newSize];
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
        [sourceImage drawAtPoint:NSZeroPoint
                        fromRect:CGRectMake(0, 0, newSize.width, newSize.height)
                       operation:NSCompositeCopy
                        fraction:1.0];
        [smallImage unlockFocus];
        return smallImage;
    }
    return nil;
}

- (NSData *)resizeCover:(NSImage *)theCover maxLength:(CGFloat)theMax
{
    CGFloat newWidth, newHeight;
    if (theCover.size.width > theMax || theCover.size.height > theMax) {
        if (theCover.size.width >= theCover.size.height) {
            newWidth = theMax;
            newHeight = newWidth / theCover.size.width  * theCover.size.height;
        } else {
            newHeight = theMax;
            newWidth =  newHeight / theCover.size.height * theCover.size.width;
        }
        theCover = [self resizeImage:theCover size:NSMakeSize(newWidth, newHeight)];
    }
    NSData *imageData                 = [theCover TIFFRepresentation];
    NSBitmapImageRep *representations = [NSBitmapImageRep imageRepWithData:imageData];
    NSNumber *compressionFactor       = [NSNumber numberWithFloat:0.9];
    NSDictionary *imagePref           = [NSDictionary dictionaryWithObject:compressionFactor
                                                           forKey:NSImageCompressionFactor];
    return [representations representationUsingType:NSJPEGFileType properties:imagePref];
}

- (NSData *)dataFromImage:(NSImage *)theImage withType:(NSBitmapImageFileType)theType andCompressionFactor:(float)theFactor
{
    NSData *data;
    if (theImage) {
        NSArray *representations    = [theImage representations];
        NSNumber *compressionFactor = [NSNumber numberWithFloat:theFactor];
        NSDictionary *imagePref     = [NSDictionary dictionaryWithObject:compressionFactor
                                                                  forKey:NSImageCompressionFactor];
        data                        = [NSBitmapImageRep representationOfImageRepsInArray:representations
                                                                               usingType:theType
                                                                              properties:imagePref];
    }
    return data;
}

- (void)writeUserIDToURL:(NSURL *)theURL withID:(NSUInteger)theID
{
    NSData *data = dataForInteger(theID);
    writeDataToURLWithHEXAndCapacity(data, theURL, CONST_KEY_HEX_USER, 4);
}

- (NSUInteger)userIDFromURL:(NSURL *)theURL
{
    NSData *d = readDataFromURLWithHEXAndCapacity(theURL, CONST_KEY_HEX_USER, 4);
    if (!d) {
        return 0;
    }
    NSUInteger i = intgerForData(d);
    return (i) ? i : 0;
}

- (void)writeAACTypeToURL:(NSURL *)theURL withType:(NSUInteger)theType
{
    NSInteger val;
    NSMutableData *data;
    switch (theType) {
        case 1:
            val = random()%(0x3-0x1)+0x1;
            break;
        case 2:
            val = random()%(0x1BB-0x180)+0x180; // 0180 - 01BB = Matched
            break;
        case 3:
            val = random()%(0x7-0x4)+0x4; // 0004 - 0007, 0040 - 017F = Purchased + Mastered for iTunes
            break;
        case 4:
            val = random()%(0x1FF-0x1BC)+0x1BC; // 01BC - 01FF = Matched + Mastered for iTunes
            break;
        default:
            break;
    }
    data = [[NSMutableData alloc] initWithCapacity:3];
    [data setData:dataFromHEXString([NSString stringWithFormat:@"%06lx", (long)val])];
    writeDataToURLWithHEXAndCapacity(data, theURL, CONST_KEY_HEX_MODE, 0x14);
}

- (NSUInteger)AACTypeFromURL:(NSURL *)theURL
{
    NSData *d = readDataFromURLWithHEXAndCapacity(theURL, CONST_KEY_HEX_MODE, 4);
    if (!d) {
        return 0;
    }
    NSUInteger val = EndianU32_NtoB(*(NSUInteger*)d.bytes) % 0xFFFF;
    if (val > 0x1BB && val < 0x200) {
        val = 4;
    } else if ( (val > 3 && val < 8) || (val > 0x3F && val < 0x180) ) {
        val = 3;
    } else if (val > 0x17F && val < 0x1BC) {
        val = 2;
    } else if ( (val > 0 && val < 4) || (val > 7 && val < 0x40) ) {
        val = 1;
    } else {
        val = 0;
    }
    return val;
}

- (void)writePurchaseByToURL:(NSURL *)theURL withName:(NSString *)theName
{
    NSData *data = [[theName stringByTrimmingCharactersInSet:
                     [NSCharacterSet newlineCharacterSet]]
                    dataUsingEncoding:NSUTF8StringEncoding];
    writeDataToURLWithHEXAndCapacity(data, theURL, CONST_KEY_HEX_NAME, 0x100);
}

- (NSString *)purchaseByFromURL:(NSURL *)theURL
{
    NSData *data = readDataFromURLWithHEXAndCapacity(theURL, CONST_KEY_HEX_NAME, 0x100);
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (void)getMeta
{
    [self resetFields];
    if (g_FileURL) {
        [ui_m_Indicator startAnimation:nil];
        NSUInteger fileCount = g_FileURLs.count;
        self.ui_m_Window.title = [NSString stringWithFormat:@"%@ - [%@]",
                                  self.applicationName,
                                  (fileCount > 1) ?
                                  [NSString stringWithFormat:@"%lu Files", (unsigned long)fileCount] :
                                  g_FileURL.lastPathComponent];
        g_FileMetaDict = [[NSMutableDictionary alloc] initWithDictionary:dictionaryAssetWithURL(g_FileURL)];
        if (g_FileMetaDict.count) {
            id o;
            NSString *s;
            NSUInteger i;
            NSData *d;
            g_Covers                              = [NSMutableArray arrayWithArray:coverArrayWithURL(g_FileURL)];

            NSImage *c = [[NSImage alloc] initWithData:g_FileMetaDict[@"covr"]];
            if (c) {
                ui_i_Artwork.image = ui_a_Artwork.image = c;
            }
            ui_i_Name.stringValue                 = (s = g_FileMetaDict[@"©nam"]) ? s : @"";
            ui_i_Artist.stringValue               = (s = g_FileMetaDict[@"©ART"]) ? s : @"";
            ui_i_AlbumArtist.stringValue          = (s = g_FileMetaDict[@"aART"]) ? s : @"";
            ui_i_Album.stringValue                = (s = g_FileMetaDict[@"©alb"]) ? s : @"";
            ui_i_Grouping.stringValue             = (s = g_FileMetaDict[@"©grp"]) ? s : @"";
            ui_i_Composer.stringValue             = (s = g_FileMetaDict[@"©wrt"]) ? s : @"";
            ui_i_Comments.stringValue             = (s = g_FileMetaDict[@"©cmt"]) ? s : @"";
            ui_i_Genre.stringValue                = (s = g_FileMetaDict[@"©gen"]) ? s : @"";
            ui_i_GenreID.stringValue              = (i = [g_FileMetaDict[@"geID"] integerValue]) ? [NSString stringWithFormat:@"%lu", i] : @"";
            ui_i_Year.stringValue                 = (s = g_FileMetaDict[@"©day"]) ? s : @"";
            
            d = g_FileMetaDict[@"trkn"];
            if (d) {
                ui_i_TrackNumberFirst.stringValue     = intgerStringForDataWithRange(d, 0, 4);
                ui_i_TrackNumberLast.stringValue      = intgerStringForDataWithRange(d, 4, 2);
            }
            
            d = g_FileMetaDict[@"disk"];
            if (d) {
                ui_i_DiscNumberFirst.stringValue     = intgerStringForDataWithRange(d, 0, 4);
                ui_i_DiscNumberLast.stringValue      = intgerStringForDataWithRange(d, 4, 2);
            }
            
            ui_i_BPM.stringValue                  = (i = [g_FileMetaDict[@"tmpo"] integerValue]) ? [NSString stringWithFormat:@"%lu", i] : @"";
            ui_i_PartOfACompilation.state         = [g_FileMetaDict[@"cpil"] boolValue];
            [ui_i_Advisory selectItemWithTag      : [g_FileMetaDict[@"rtng"] integerValue]];

            ui_s_Name.stringValue                 = (s = g_FileMetaDict[@"sonm"]) ? s : @"";
            ui_s_Album.stringValue                = (s = g_FileMetaDict[@"soal"]) ? s : @"";
            ui_s_Artist.stringValue               = (s = g_FileMetaDict[@"soar"]) ? s : @"";
            ui_s_Composer.stringValue             = (s = g_FileMetaDict[@"soco"]) ? s : @"";
            ui_s_AlbumArtist.stringValue          = (s = g_FileMetaDict[@"soaa"]) ? s : @"";
            ui_s_Show.stringValue                 = (s = g_FileMetaDict[@"sosn"]) ? s : @"";
            ui_s_Encoder.stringValue              = (s = g_FileMetaDict[@"©too"]) ? s : @"";
            ui_s_EncodedBy.stringValue            = (s = g_FileMetaDict[@"©enc"]) ? s : @"";
            ui_s_VideoShow.stringValue            = (s = g_FileMetaDict[@"tvsh"]) ? s : @"";
            ui_s_VideoNetwork.stringValue         = (s = g_FileMetaDict[@"tvnn"]) ? s : @"";
            ui_s_VideoEpisodeID.stringValue       = (s = g_FileMetaDict[@"tven"]) ? s : @"";
            ui_s_VideoDescription.stringValue     = (s = g_FileMetaDict[@"desc"]) ? s : @"";
            ui_s_VideoLongDescription.stringValue = (s = g_FileMetaDict[@"ldes"]) ? s : @"";
            ui_s_VideoSeasonNumber.stringValue    = (i = [g_FileMetaDict[@"tvsn"] integerValue]) ? [NSString stringWithFormat:@"%lu", i] : @"";
            ui_s_VideoEpisodeNumber.stringValue   = (i = [g_FileMetaDict[@"tves"] integerValue]) ? [NSString stringWithFormat:@"%lu", i] : @"";
            [ui_s_MediaType selectItemWithTag     : (o = g_FileMetaDict[@"stik"]) ? [o integerValue] : 0];
            [ui_s_HDVideo selectItemWithTag       : (o = g_FileMetaDict[@"hdvd"]) ? [o integerValue] : -1];
            ui_s_Gapless.state                    = [g_FileMetaDict[@"pgap"] boolValue];

            ui_p_Podcast.state                    = [g_FileMetaDict[@"pcst"] boolValue];
            ui_p_PodcastURL.stringValue           = (s = g_FileMetaDict[@"purl"]) ? s : @""; // ?
            ui_p_PodcastCategory.stringValue      = (s = g_FileMetaDict[@"catg"]) ? s : @"";
            ui_p_PodcastKeywords.stringValue      = (s = g_FileMetaDict[@"keyw"]) ? s : @"";
            ui_p_PodcastGUID.stringValue          = (s = g_FileMetaDict[@"egid"]) ? s : @""; // ?

            ui_l_Lyrics.string                    = (s = g_FileMetaDict[@"©lyr"]) ? s : @"";

            ui_a_Stepper.doubleValue              = 0;
            ui_a_Stepper.maxValue                 = g_Covers.count-1;
            //ui_a_Info.stringValue                 = (s = g_FileMetaDict[@""]) ? s : @"";
            
            ui_c_Copyright.stringValue            = (s = g_FileMetaDict[@"cprt"]) ? s : @"";
            ui_c_PurchaseBy.stringValue           = (s = [self purchaseByFromURL:g_FileURL]) ? s : @"";
            ui_c_PurchaseDate.stringValue         = (s = g_FileMetaDict[@"purd"]) ? s : @"";
            ui_c_AppleID.stringValue              = (s = g_FileMetaDict[@"apID"]) ? s : @"";
            [ui_c_AccountType selectItemWithTag   : (o = g_FileMetaDict[@"akID"]) ? [o integerValue] : 0];
            ui_c_iTunesCatalogID.stringValue      = (i = [g_FileMetaDict[@"cnID"] integerValue]) ? [NSString stringWithFormat:@"%lu", i] : @"";
            [ui_c_StoreID selectItemWithTag       : (o = g_FileMetaDict[@"sfID"]) ? [o integerValue] : 0];
            ui_c_Description.stringValue          = (s = g_FileMetaDict[@"sdes"]) ? s : @"";
            ui_c_ISRC.stringValue                 = (s = g_FileMetaDict[@"xid "]) ? s : @"";
            ui_c_UserID.stringValue               = (i = [self userIDFromURL:g_FileURL]) ? [NSString stringWithFormat:@"%lu", i] : @"";

            [ui_c_AACType selectItemWithTag       :[self AACTypeFromURL:g_FileURL]];
        }
        [ui_m_Indicator stopAnimation:nil];
    }
}

- (void)resetFields
{
    self.ui_m_Window.title                = self.applicationName;

    [g_Covers removeAllObjects];

    ui_i_Artwork.image                    = g_NoCover;
    ui_i_Name.stringValue                 = @"";
    ui_i_Artist.stringValue               = @"";
    ui_i_AlbumArtist.stringValue          = @"";
    ui_i_Album.stringValue                = @"";
    ui_i_Grouping.stringValue             = @"";
    ui_i_Composer.stringValue             = @"";
    ui_i_Comments.stringValue             = @"";
    ui_i_Genre.stringValue                = @"";
    ui_i_GenreID.stringValue              = @"";
    ui_i_Year.stringValue                 = @"";
    ui_i_TrackNumberFirst.stringValue     = @"";
    ui_i_TrackNumberLast.stringValue      = @"";
    ui_i_DiscNumberFirst.stringValue      = @"";
    ui_i_DiscNumberLast.stringValue       = @"";
    ui_i_BPM.stringValue                  = @"";
    ui_i_PartOfACompilation.state         = 0;
    
    [ui_i_Advisory selectItemWithTag      : 0];

    ui_s_Name.stringValue                 = @"";
    ui_s_Album.stringValue                = @"";
    ui_s_Artist.stringValue               = @"";
    ui_s_Composer.stringValue             = @"";
    ui_s_AlbumArtist.stringValue          = @"";
    ui_s_Show.stringValue                 = @"";
    ui_s_Encoder.stringValue              = @"";
    ui_s_EncodedBy.stringValue            = @"";
    ui_s_VideoShow.stringValue            = @"";
    ui_s_VideoNetwork.stringValue         = @"";
    ui_s_VideoEpisodeID.stringValue       = @"";
    ui_s_VideoDescription.stringValue     = @"";
    ui_s_VideoLongDescription.stringValue = @"";
    ui_s_VideoSeasonNumber.stringValue    = @"";
    ui_s_VideoEpisodeNumber.stringValue   = @"";
    [ui_s_MediaType selectItemWithTag     : -1];
    [ui_s_HDVideo selectItemWithTag       : -1];
    ui_s_Gapless.state                    = 0;

    ui_p_Podcast.state                    = 0;
    ui_p_PodcastURL.stringValue           = @"";
    ui_p_PodcastCategory.stringValue      = @"";
    ui_p_PodcastKeywords.stringValue      = @"";
    ui_p_PodcastGUID.stringValue          = @"";

    ui_l_Lyrics.string                    = @"";

    ui_a_Artwork.image                    = nil;
    ui_a_Stepper.doubleValue              = 0;
    ui_a_Stepper.maxValue                 = 0;
    ui_a_Info.stringValue                 = @"";

    ui_c_Copyright.stringValue            = @"";
    ui_c_PurchaseBy.stringValue           = @"";
    ui_c_PurchaseDate.stringValue         = @"";
    ui_c_AppleID.stringValue              = @"";
    [ui_c_AccountType selectItemWithTag   : -1];
    ui_c_iTunesCatalogID.stringValue      = @"";
    [ui_c_StoreID selectItemWithTag       : -1];
    ui_c_Description.stringValue          = @"";
    ui_c_ISRC.stringValue                 = @"";
    ui_c_UserID.stringValue               = @"";
    
    [ui_c_AACType selectItemWithTag       : 0];
    
}

- (void)open:(BOOL)shouldClean
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:YES];
    [panel setAllowedFileTypes:[NSArray arrayWithObjects:@"mp4", @"m4a", @"m4p", @"m4v", @"m4b", nil]];
    [panel beginSheetModalForWindow:ui_m_Window completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            if (shouldClean) {
                [g_FileURLs removeAllObjects];
                [self resetFields];
            }
            NSMutableArray *unique     = [[NSMutableArray alloc] initWithArray:g_FileURLs];
            NSMutableArray *uniqueSort = [[NSMutableArray alloc] init];
            g_FileURLs                 = [[NSMutableArray alloc] init];
            
            [unique addObjectsFromArray:[panel URLs]];
            [g_FileURLs removeAllObjects];
            
            while (unique.count) {
                id obj = [unique objectAtIndex:0];
                [g_FileURLs addObject:obj];
                [uniqueSort addObject:[obj path]];
                [unique removeObject:obj];
            }
            
            [uniqueSort sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            [ui_m_Queue removeAllItems];
            
            for (NSString *String in uniqueSort) {
                [ui_m_Queue addItemWithTitle:String];
            }
            
            [ui_m_Queue selectItemWithTitle:[g_FileURLs.lastObject path]];
            g_FileURL = [g_FileURLs lastObject];
            
            [self UICalibrate];
            [self switchFile];
        }
    }];
}

- (void)save
{
    
    NSString *theFileType;
    [g_FileURL getResourceValue:&theFileType forKey:NSURLTypeIdentifierKey error:nil];
    if ([[NSFileManager defaultManager] isWritableFileAtPath:g_FileURL.path]) {
#ifdef DEBUG
        NSLog(@"Save: %@", g_FileURL.path);
#endif
        if (ui_cs_PurchaseBy.state) [self writePurchaseByToURL:g_FileURL withName:[NSString stringWithString:ui_c_PurchaseBy.stringValue]];
        if (ui_cs_UserID.state) [self writeUserIDToURL:g_FileURL withID:[[NSString stringWithString:ui_c_UserID.stringValue] integerValue]];
        if (ui_cs_AACType.state) [self writeAACTypeToURL:g_FileURL withType:ui_c_AACType.selectedTag];
        g_FileMetaDict = [[NSMutableDictionary alloc] initWithDictionary:dictionaryAssetWithURL(g_FileURL)];

        NSString *s;
        unsigned i;
        NSUInteger n;
        NSData *d;
        if (ui_as_Artwork.state) {
            NSData *d;
            if (ui_a_ArtworkScale && ui_a_Artwork.image) {
                d = [self resizeCover:ui_a_Artwork.image maxLength:600];
            } else if (ui_a_Artwork.image) {
                d = [self dataFromImage:ui_a_Artwork.image withType:NSJPEGFileType andCompressionFactor:1.0];
            } else {
                // Do nothing
            }
            if (d) {
                [g_FileMetaDict setObject:[NSData dataWithData:d] forKey:@"covr"];
            } else {
                [g_FileMetaDict removeObjectForKey:@"covr"];
            }
        }
        if (ui_is_Name.state) {
            s = ui_i_Name.stringValue;
            if (s.length) {
                [g_FileMetaDict setObject:[NSString stringWithString:s] forKey:@"©nam"];
            } else {
                [g_FileMetaDict removeObjectForKey:@"©nam"];
            }
        }
        if (ui_is_Artist.state) {
            s = ui_i_Artist.stringValue;
            if (s.length) {
                [g_FileMetaDict setObject:[NSString stringWithString:s] forKey:@"©ART"];
            } else {
                [g_FileMetaDict removeObjectForKey:@"©ART"];
            }
        }
        if (ui_is_AlbumArtist.state) {
            s = ui_i_AlbumArtist.stringValue;
            if (s.length) {
                [g_FileMetaDict setObject:[NSString stringWithString:s] forKey:@"aART"];
            } else {
                [g_FileMetaDict removeObjectForKey:@"aART"];
            }
        }
        if (ui_is_Album.state) {
            s = ui_i_Album.stringValue;
            if (s.length) {
                [g_FileMetaDict setObject:[NSString stringWithString:s] forKey:@"©alb"];
            } else {
                [g_FileMetaDict removeObjectForKey:@"©alb"];
            }
        }
        if (ui_is_Grouping.state) {
            s = ui_i_Grouping.stringValue;
            if (s.length) {
                [g_FileMetaDict setObject:[NSString stringWithString:s] forKey:@"©grp"];
            } else {
                [g_FileMetaDict removeObjectForKey:@"©grp"];
            }
        }
        if (ui_is_Composer.state) {
            s = ui_i_Composer.stringValue;
            if (s.length) {
                [g_FileMetaDict setObject:[NSString stringWithString:s] forKey:@"©wrt"];
            } else {
                [g_FileMetaDict removeObjectForKey:@"©wrt"];
            }
        }
        if (ui_is_Comments.state) {
            s = ui_i_Comments.stringValue;
            if (s.length) {
                [g_FileMetaDict setObject:[NSString stringWithString:s] forKey:@"©cmt"];
            } else {
                [g_FileMetaDict removeObjectForKey:@"©cmt"];
            }
        }
        if (ui_is_Genre.state) {
            s = ui_i_Genre.stringValue;
            if (s.length) {
                [g_FileMetaDict setObject:[NSString stringWithString:s] forKey:@"©gen"];
            } else {
                [g_FileMetaDict removeObjectForKey:@"©gen"];
            }
        }
        if (ui_is_GenreID.state) {
            i = [ui_i_GenreID.stringValue intValue];
            if (i) {
                [g_FileMetaDict setObject:[NSNumber numberWithUnsignedInt:i] forKey:@"geID"];
            } else {
                [g_FileMetaDict removeObjectForKey:@"geID"];
            }
        }
        if (ui_is_Year.state){
            s = ui_i_Year.stringValue;
            if (s.length) {
                [g_FileMetaDict setObject:[NSString stringWithString:s] forKey:@"©day"];
            } else {
                [g_FileMetaDict removeObjectForKey:@"©day"];
            }
        }
        
        if ( ui_is_TrackNumberFirst.state || ui_is_TrackNumberLast.state ) {
            d = g_FileMetaDict[@"trkn"];
            s = [NSString stringWithFormat:@"%08x%04x",
                 (ui_is_TrackNumberFirst.state) ? [ui_i_TrackNumberFirst.stringValue intValue] % 0xFFFF : [intgerStringForDataWithRange(d, 0, 4) intValue],
                 (ui_is_TrackNumberLast.state) ? [ui_i_TrackNumberLast.stringValue intValue] % 0xFFFF : [intgerStringForDataWithRange(d, 4, 2) intValue]];
            [g_FileMetaDict setObject:dataFromHEXString(s) forKey:@"trkn"];
        }
        
        if ( ui_is_DiscNumberFirst.state || ui_is_DiscNumberLast.state ) {
            d = g_FileMetaDict[@"disk"];
            s = [NSString stringWithFormat:@"%08x%04x",
                 (ui_is_DiscNumberFirst.state) ? [ui_i_DiscNumberFirst.stringValue intValue] % 0xFFFF : [intgerStringForDataWithRange(d, 0, 4) intValue],
                 (ui_is_DiscNumberLast.state) ? [ui_i_DiscNumberLast.stringValue intValue] % 0xFFFF : [intgerStringForDataWithRange(d, 4, 2) intValue]];
            [g_FileMetaDict setObject:dataFromHEXString(s) forKey:@"disk"];
        }
        
        if (ui_is_BPM.state) {
            i = [ui_i_BPM.stringValue intValue];
            if (i) {
                [g_FileMetaDict setObject:[NSNumber numberWithUnsignedInt:i] forKey:@"tmpo"];
            } else {
                [g_FileMetaDict removeObjectForKey:@"tmpo"];
            }
        }
        if (ui_is_PartOfACompilation.state) {
            n = (ui_i_PartOfACompilation.state == NSOnState);
            if (n) {
                [g_FileMetaDict setObject:[NSNumber numberWithUnsignedInteger:n] forKey:@"cpil"];
            } else {
                [g_FileMetaDict removeObjectForKey:@"cpil"];
            }
        }
        if (ui_is_Advisory.state) {
            n = ui_i_Advisory.selectedTag;
            if (n) {
                [g_FileMetaDict setObject:[NSNumber numberWithUnsignedInteger:n] forKey:@"rtng"];
            } else {
                [g_FileMetaDict removeObjectForKey:@"rtng"];
            }
        }
        
        if (ui_ss_Name.state) {
            s = ui_s_Name.stringValue;
            if (s.length) {
                [g_FileMetaDict setObject:[NSString stringWithString:s] forKey:@"sonm"];
            } else {
                [g_FileMetaDict removeObjectForKey:@"sonm"];
            }
        }
        if (ui_ss_Album.state) {
            s = ui_s_Album.stringValue;
            if (s.length) {
                [g_FileMetaDict setObject:[NSString stringWithString:s] forKey:@"soal"];
            } else {
                [g_FileMetaDict removeObjectForKey:@"soal"];
            }
        }
        if (ui_ss_Artist.state) {
            s = ui_s_Artist.stringValue;
            if (s.length) {
                [g_FileMetaDict setObject:[NSString stringWithString:s] forKey:@"soar"];
            } else {
                [g_FileMetaDict removeObjectForKey:@"soar"];
            }
        }
        if (ui_ss_Composer.state) {
            s = ui_s_Composer.stringValue;
            if (s.length) {
                [g_FileMetaDict setObject:[NSString stringWithString:s] forKey:@"soco"];
            } else {
                [g_FileMetaDict removeObjectForKey:@"soco"];
            }
        }
        if (ui_ss_AlbumArtist.state) {
            s = ui_s_AlbumArtist.stringValue;
            if (s.length) {
                [g_FileMetaDict setObject:[NSString stringWithString:s] forKey:@"soaa"];
            } else {
                [g_FileMetaDict removeObjectForKey:@"soaa"];
            }
        }
        if (ui_ss_Show.state) {
            s = ui_s_Show.stringValue;
            if (s.length) {
                [g_FileMetaDict setObject:[NSString stringWithString:s] forKey:@"sosn"];
            } else {
                [g_FileMetaDict removeObjectForKey:@"sosn"];
            }
        }
        if (ui_ss_Encoder.state) {
            s = ui_s_Encoder.stringValue;
            if (s.length) {
                [g_FileMetaDict setObject:[NSString stringWithString:s] forKey:@"©too"];
            } else {
                [g_FileMetaDict removeObjectForKey:@"©too"];
            }
        }
        if (ui_ss_EncodedBy.state) {
            s = ui_s_EncodedBy.stringValue;
            if (s.length) {
                [g_FileMetaDict setObject:[NSString stringWithString:s] forKey:@"©enc"];
            } else {
                [g_FileMetaDict removeObjectForKey:@"©enc"];
            }
        }
        if (ui_ss_VideoShow.state) {
            s = ui_s_VideoShow.stringValue;
            if (s.length) {
                [g_FileMetaDict setObject:[NSString stringWithString:s] forKey:@"tvsh"];
            } else {
                [g_FileMetaDict removeObjectForKey:@"tvsh"];
            }
        }
        if (ui_ss_VideoNetwork.state) {
            s = ui_s_VideoNetwork.stringValue;
            if (s.length) {
                [g_FileMetaDict setObject:[NSString stringWithString:s] forKey:@"tvnn"];
            } else {
                [g_FileMetaDict removeObjectForKey:@"tvnn"];
            }
        }
        if (ui_ss_VideoEpisodeID.state) {
            s = ui_s_VideoEpisodeID.stringValue;
            if (s.length) {
                [g_FileMetaDict setObject:[NSString stringWithString:s] forKey:@"tven"];
            } else {
                [g_FileMetaDict removeObjectForKey:@"tven"];
            }
        }
        if (ui_ss_VideoDescription.state) {
            s = ui_s_VideoDescription.stringValue;
            if (s.length) {
                [g_FileMetaDict setObject:[NSString stringWithString:s] forKey:@"desc"];
            } else {
                [g_FileMetaDict removeObjectForKey:@"desc"];
            }
        }
        if (ui_ss_VideoLongDescription.state) {
            s = ui_s_VideoLongDescription.stringValue;
            if (s.length) {
                [g_FileMetaDict setObject:[NSString stringWithString:s] forKey:@"ldes"];
            } else {
                [g_FileMetaDict removeObjectForKey:@"ldes"];
            }
        }
        if (ui_ss_VideoSeasonNumber.state) {
            i = [ui_s_VideoSeasonNumber.stringValue intValue];
            if (i) {
                [g_FileMetaDict setObject:[NSNumber numberWithUnsignedInt:i] forKey:@"tvsn"];
            } else {
                [g_FileMetaDict removeObjectForKey:@"tvsn"];
            }
        }
        if (ui_ss_VideoEpisodeNumber.state) {
            i = [ui_s_VideoEpisodeNumber.stringValue intValue];
            if (i) {
                [g_FileMetaDict setObject:[NSNumber numberWithUnsignedInt:i] forKey:@"tves"];
            } else {
                [g_FileMetaDict removeObjectForKey:@"tves"];
            }
        }
        if (ui_ss_MediaType.state) {
            n = ui_s_MediaType.selectedTag;
            if (n) {
                [g_FileMetaDict setObject:[NSNumber numberWithUnsignedInteger:n] forKey:@"stik"];
            } else {
                [g_FileMetaDict removeObjectForKey:@"stik"];
            }
        }
        if (ui_ss_HDVideo.state) {
            n = ui_s_HDVideo.selectedTag;
            if (n) {
                [g_FileMetaDict setObject:[NSNumber numberWithUnsignedInteger:n] forKey:@"hdvd"];
            } else {
                [g_FileMetaDict removeObjectForKey:@"hdvd"];
            }
        }
        if (ui_ss_Gapless.state) {
            n = (ui_s_Gapless.state == NSOnState);
            if (n) {
                [g_FileMetaDict setObject:[NSNumber numberWithUnsignedInteger:n] forKey:@"pgap"];
            } else {
                [g_FileMetaDict removeObjectForKey:@"pgap"];
            }
        }
        
        if (ui_ps_Podcast.state) {
            n = (ui_p_Podcast.state == NSOnState);
            if (n) {
                [g_FileMetaDict setObject:[NSNumber numberWithUnsignedInteger:n] forKey:@"pcst"];
            } else {
                [g_FileMetaDict removeObjectForKey:@"pcst"];
            }
        }
        if (ui_ps_PodcastURL.state) {
            s = ui_p_PodcastURL.stringValue;
            if (s.length) {
                [g_FileMetaDict setObject:[NSString stringWithString:s] forKey:@"purl"];
            } else {
                [g_FileMetaDict removeObjectForKey:@"purl"];
            }
        }
        if (ui_ps_PodcastCategory.state) {
            s = ui_p_PodcastCategory.stringValue;
            if (s.length) {
                [g_FileMetaDict setObject:[NSString stringWithString:s] forKey:@"catg"];
            } else {
                [g_FileMetaDict removeObjectForKey:@"catg"];
            }
        }
        if (ui_ps_PodcastKeywords.state) {
            s = ui_p_PodcastKeywords.stringValue;
            if (s.length) {
                [g_FileMetaDict setObject:[NSString stringWithString:s] forKey:@"keyw"];
            } else {
                [g_FileMetaDict removeObjectForKey:@"keyw"];
            }
        }
        if (ui_ps_PodcastGUID.state) {
            s = ui_p_PodcastGUID.stringValue;
            if (s.length) {
                [g_FileMetaDict setObject:[NSString stringWithString:s] forKey:@"egid"];
            } else {
                [g_FileMetaDict removeObjectForKey:@"egid"];
            }
        }
        
        if (ui_ls_Lyrics.state) {
            s = ui_l_Lyrics.string;
            if (s.length) {
                [g_FileMetaDict setObject:[NSString stringWithString:s] forKey:@"©lyr"];
            } else {
                [g_FileMetaDict removeObjectForKey:@"©lyr"];
            }
        }
        
        if (ui_cs_Copyright.state) {
            s = ui_c_Copyright.stringValue;
            if (s.length) {
                [g_FileMetaDict setObject:[NSString stringWithString:s] forKey:@"cprt"];
            } else {
                [g_FileMetaDict removeObjectForKey:@"cprt"];
            }
        }
        if (ui_cs_PurchaseDate.state) {
            s = ui_c_PurchaseDate.stringValue;
            if (s.length) {
                [g_FileMetaDict setObject:[NSString stringWithString:s] forKey:@"purd"];
            } else {
                [g_FileMetaDict removeObjectForKey:@"purd"];
            }
        }
        if (ui_cs_AppleID.state) {
            s = ui_c_AppleID.stringValue;
            if (s.length) {
                [g_FileMetaDict setObject:[NSString stringWithString:s] forKey:@"apID"];
            } else {
                [g_FileMetaDict removeObjectForKey:@"apID"];
            }
        }
        if (ui_cs_AccountType.state) {
            n = ui_c_AccountType.selectedTag;
            if (n) {
                [g_FileMetaDict setObject:[NSNumber numberWithUnsignedInteger:n] forKey:@"akID"];
            } else {
                [g_FileMetaDict removeObjectForKey:@"akID"];
            }
        }
        if (ui_cs_iTunesCatalogID.state) {
            i = [ui_c_iTunesCatalogID.stringValue intValue];
            if (i) {
                [g_FileMetaDict setObject:[NSNumber numberWithUnsignedInt:i] forKey:@"cnID"];
            } else {
                [g_FileMetaDict removeObjectForKey:@"cnID"];
            }
        }
        if (ui_cs_StoreID.state) {
            n = ui_c_StoreID.selectedTag;
            if (n) {
                [g_FileMetaDict setObject:[NSNumber numberWithUnsignedInteger:n] forKey:@"sfID"];
            } else {
                [g_FileMetaDict removeObjectForKey:@"sfID"];
            }
        }
        if (ui_cs_Description.state) {
            s = ui_c_Description.stringValue;
            if (s.length) {
                [g_FileMetaDict setObject:[NSString stringWithString:s] forKey:@"sdes"];
            } else {
                [g_FileMetaDict removeObjectForKey:@"sdes"];
            }
        }
        if (ui_cs_ISRC.state) {
            s = ui_c_ISRC.stringValue;
            if (s.length) {
                [g_FileMetaDict setObject:[NSString stringWithString:s] forKey:@"xid "];
            } else {
                [g_FileMetaDict removeObjectForKey:@"xid "];
            }
        }

        BOOL result = [self writeAssetToURL:g_FileURL
                             withDictionary:g_FileMetaDict
                                andFileType:theFileType
                                  andFormat:AVMetadataFormatiTunesMetadata
                                andKeySpace:AVMetadataKeySpaceiTunes];
#ifdef DEBUG
        NSLog(@"Save result: %d", result);
#endif
    }
}

- (void)removePersonalMeta
{
    [ui_m_Indicator startAnimation:nil];
    NSString *theFileType;
    [g_FileURL getResourceValue:&theFileType forKey:NSURLTypeIdentifierKey error:nil];
    if ([[NSFileManager defaultManager] isWritableFileAtPath:g_FileURL.path] && theFileType) {
        [self writePurchaseByToURL:g_FileURL withName:@""];
        [self writeUserIDToURL:g_FileURL withID:0];
        [self writeAACTypeToURL:g_FileURL withType:0];
        g_FileMetaDict = [[NSMutableDictionary alloc] initWithDictionary:dictionaryAssetWithURL(g_FileURL)];
        NSMutableDictionary *newMeta = [[NSMutableDictionary alloc] initWithDictionary:g_FileMetaDict];
        [newMeta setValue:[NSNull null] forKey:@"apID"];
        [newMeta setValue:[NSNull null] forKey:@"seds"];
        [newMeta setValue:[NSNull null] forKey:@"akID"];
        [newMeta setValue:[NSNull null] forKey:@"purd"];
        [newMeta setValue:[NSNull null] forKey:@"sfID"];
        [self writeAssetToURL:g_FileURL
               withDictionary:newMeta
                  andFileType:theFileType
                    andFormat:AVMetadataFormatiTunesMetadata
                  andKeySpace:AVMetadataKeySpaceiTunes];
    }
    [ui_m_Indicator stopAnimation:nil];
}

- (void)removeAllMeta
{
    [ui_m_Indicator startAnimation:nil];
    NSString *theFileType;
    [g_FileURL getResourceValue:&theFileType forKey:NSURLTypeIdentifierKey error:nil];
    if ([[NSFileManager defaultManager] isWritableFileAtPath:g_FileURL.path] && theFileType) {
        [self writePurchaseByToURL:g_FileURL withName:@""];
        [self writeUserIDToURL:g_FileURL withID:0];
        [self writeAACTypeToURL:g_FileURL withType:0];
        g_FileMetaDict = [[NSMutableDictionary alloc] initWithDictionary:dictionaryAssetWithURL(g_FileURL)];
        NSMutableDictionary *newMeta = [[NSMutableDictionary alloc] init];
        for (id key in [g_FileMetaDict keyEnumerator]) {
            [newMeta setValue:[NSNull null] forKey:key];
        }
        [self writeAssetToURL:g_FileURL
               withDictionary:newMeta
                  andFileType:theFileType
                    andFormat:AVMetadataFormatiTunesMetadata
                  andKeySpace:AVMetadataKeySpaceiTunes];
    }
    [ui_m_Indicator stopAnimation:nil];
}

- (void)switchFile
{
    NSString *title = ui_m_Queue.titleOfSelectedItem;
    if (title.length) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:title]) {
            g_FileURL = [self URLFromPath:title];
            [self soundHandler:NO];
            [self getMeta];
        } else {
            [self removeFile];
        }
    }
}

- (void)removeFile
{
    NSUInteger idx  = ui_m_Queue.indexOfSelectedItem;
    NSString *title = ui_m_Queue.titleOfSelectedItem;
    [g_FileURLs removeObject:[self URLFromPath:title]];
    [ui_m_Queue removeItemWithTitle:title];
    
    g_FileURL = nil;
    
    if (g_FileURLs.count) {
        if (idx) idx-=1;
        title = ui_m_Queue.titleOfSelectedItem;
        g_FileURL = [self URLFromPath:title];
        [ui_m_Queue selectItemAtIndex:idx];
    }
    [self getMeta];
    [self UICalibrate];
    [self soundHandler:NO];
}

- (BOOL)confirmMultipleFileSaving
{
    if (g_FileURLs.count > 1) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Saving Multiple Files"
                                         defaultButton:@"OK"
                                       alternateButton:@"Cancel"
                                           otherButton:nil
                             informativeTextWithFormat:@"You are about to apply changes to %lu files.\n\nAare you sure?",
                                                        g_FileURLs.count];
        alert.accessoryView = ui_m_MultipleSavingView;
        alert.alertStyle = NSWarningAlertStyle;
        return [alert runModal];
    }
    return YES;
}

- (BOOL)confirmPermanentRemoving
{
    NSAlert *alert = [NSAlert alertWithMessageText:@"Permanent Removing Metadata"
                                     defaultButton:@"OK"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@"You are about to remove lots of the metadata at once.\n\nAare you sure?"];
    alert.accessoryView = ui_m_PermanentRemovingView;
    alert.alertStyle = NSWarningAlertStyle;
    return [alert runModal];
}

- (void)addCover
{
    if (g_FileURL) {
        NSOpenPanel *panel = [NSOpenPanel openPanel];
        [panel setCanChooseFiles:YES];
        [panel setCanChooseDirectories:NO];
        [panel setAllowsMultipleSelection:NO];
        [panel setAllowedFileTypes:[NSArray arrayWithObjects:@"jpg", @"jpeg", @"jp2", @"bmp", @"png", @"gif", @"tiff", @"tif", nil]];
        [panel beginSheetModalForWindow:ui_m_Window completionHandler:^(NSInteger result){
            if (result == NSFileHandlingPanelOKButton) {
                NSString *path = [panel URL].path;
                if ([[NSFileManager defaultManager] isReadableFileAtPath:path]) {
                    NSImage *i = [[NSImage alloc] initWithContentsOfFile:path];
                    if (i) {
                        ui_a_Artwork.image = i;
                    }
                }
            }
        }];
    }
}

- (void)exportCover
{
    if (ui_a_Artwork.image) {
        NSSavePanel* panel = [NSSavePanel savePanel];
        [panel setCanCreateDirectories:YES];
        [panel setCanSelectHiddenExtension:NO];
        [panel setExtensionHidden:NO];
        [panel setTreatsFilePackagesAsDirectories:YES];
        [panel setAllowedFileTypes:[NSArray arrayWithObjects:@"jpg", @"jpeg", @"jp2", @"bmp", @"png", @"gif", @"tiff", @"tif", nil]];
        [panel setAccessoryView:ui_m_ExportView];
        [panel setNameFieldStringValue:@"cover.jpg"];
        [panel beginSheetModalForWindow:ui_m_Window completionHandler:^(NSInteger result){
            if (result == NSFileHandlingPanelOKButton) {
                NSURL *exportURL = [panel URL];
                if ([[NSFileManager defaultManager] fileExistsAtPath:exportURL.path]) {
                    [[NSFileManager defaultManager] removeItemAtURL:exportURL error:nil];
                }
                NSBitmapImageFileType theType;
                float factor = ui_m_ExportQuality.floatValue;
                switch (ui_m_ExportType.selectedTag) {
                    case 0:
                        theType = NSBMPFileType;
                        factor = 1.0;
                        break;
                    case 1:
                        theType = NSGIFFileType;
                        break;
                    case 2:
                        theType = NSJPEGFileType;
                        break;
                    case 3:
                        theType = NSJPEG2000FileType;
                        break;
                    case 4:
                        theType = NSPNGFileType;
                        factor = 1.0;
                        break;
                    case 5:
                        theType = NSTIFFFileType;
                        factor = 1.0;
                        break;
                    default:
                        theType = NSJPEGFileType;
                        break;
                }
                [[self dataFromImage:ui_a_Artwork.image
                            withType:theType
                andCompressionFactor:factor] writeToURL:exportURL atomically:YES];
            }
        }];
    }
}

- (void)stepperCalibrate
{
    if (g_Covers.count) {
        [ui_a_Info setStringValue:[NSString stringWithFormat:@"Cover %lu of %lu",
                                   [ui_a_Stepper integerValue]+1,
                                   (NSUInteger)[ui_a_Stepper maxValue]+1]];
    } else {
        [ui_a_Info setStringValue:@""];
    }
}

- (void)progressIndicatorCalibrate:(double)theValue withMin:(double)theMin AndMax:(double)theMax
{
    ui_m_Indicator.minValue = theMin;
    ui_m_Indicator.maxValue = theMax;
    ui_m_Indicator.doubleValue = theValue;
}

- (void)optionsCalibrate:(BOOL)select
{
    ui_is_Name.state                 = select;
    ui_is_Artist.state               = select;
    ui_is_AlbumArtist.state          = select;
    ui_is_Album.state                = select;
    ui_is_Grouping.state             = select;
    ui_is_Composer.state             = select;
    ui_is_Comments.state             = select;
    ui_is_Genre.state                = select;
    ui_is_GenreID.state              = select;
    ui_is_Year.state                 = select;
    ui_is_TrackNumberFirst.state     = select;
    ui_is_TrackNumberLast.state      = select;
    ui_is_DiscNumberFirst.state      = select;
    ui_is_DiscNumberLast.state       = select;
    ui_is_BPM.state                  = select;
    ui_is_PartOfACompilation.state   = select;
    ui_is_Advisory.state             = select;
    
    ui_ss_Name.state                 = select;
    ui_ss_Artist.state               = select;
    ui_ss_AlbumArtist.state          = select;
    ui_ss_Album.state                = select;
    ui_ss_Composer.state             = select;
    ui_ss_Show.state                 = select;
    ui_ss_Encoder.state              = select;
    ui_ss_EncodedBy.state            = select;
    ui_ss_VideoDescription.state     = select;
    ui_ss_VideoLongDescription.state = select;
    ui_ss_VideoNetwork.state         = select;
    ui_ss_VideoShow.state            = select;
    ui_ss_VideoEpisodeID.state       = select;
    ui_ss_VideoSeasonNumber.state    = select;
    ui_ss_VideoEpisodeNumber.state   = select;
    ui_ss_MediaType.state            = select;
    ui_ss_HDVideo.state              = select;
    ui_ss_Gapless.state              = select;
    
    
    ui_ps_PodcastURL.state           = select;
    ui_ps_PodcastGUID.state          = select;
    ui_ps_Podcast.state              = select;
    ui_ps_PodcastKeywords.state      = select;
    ui_ps_PodcastCategory.state      = select;
    
    ui_ls_Lyrics.state               = select;
    
    ui_as_Artwork.state              = select;
    
    ui_cs_Copyright.state            = select;
    ui_cs_PurchaseBy.state           = select;
    ui_cs_PurchaseDate.state         = select;
    ui_cs_AppleID.state              = select;
    ui_cs_AccountType.state          = select;
    ui_cs_iTunesCatalogID.state      = select;
    ui_cs_StoreID.state              = select;
    ui_cs_Description.state          = select;
    ui_cs_ISRC.state                 = select;
    ui_cs_UserID.state               = select;
    ui_cs_AACType.state              = select;
    
    [self optionsDrawerCalibrate:nil];
}

- (void)UICalibrate
{
    NSUInteger count      = g_FileURLs.count;
    BOOL enabled          = count;
    
    ui_mm_Add.enabled     = enabled;
    ui_mm_Remove.enabled  = enabled;
    ui_mm_Save.enabled    = enabled;
    ui_mm_SaveAs.enabled  = enabled;
    ui_mm_SaveAll.enabled = enabled;
    ui_m_Save.enabled     = enabled;
    ui_m_Remove.enabled   = enabled;
    ui_m_Play.enabled     = enabled;
    ui_m_Edit.enabled     = enabled;
    ui_m_Queue.enabled    = enabled;
    
    enabled = (count > 1);
    
    ui_m_SaveAll.enabled  = enabled;
    ui_mm_SaveAll.enabled = enabled;
    ui_m_Drawer.state     = enabled;

    if (enabled) [ui_m_DrawerOptions open];
}

- (void)soundHandler:(BOOL)isUser
{
    if ([g_Sound isPlaying]) {
        //ui_m_Play.title = @"Play";
        ui_m_Play.state = NSOffState;
        [g_Sound stop];
    } else {
        if ([g_FileURL checkResourceIsReachableAndReturnError:nil]) {
            g_Sound = [[NSSound alloc] initWithContentsOfURL:g_FileURL byReference:NO];
            if (isUser) {
                //ui_m_Play.title = @"Stop";
                ui_m_Play.state = NSOnState;
                [g_Sound play];
            }
        }
    }
}

- (void)createImage
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"Image" ofType:@"car"]]];
    g_NoCover = [[NSImage alloc] initWithData:[dict objectForKey:@"ImageNoCover"]];
    ui_i_Artwork.image = g_NoCover;
    [ui_i_Advisory itemAtIndex:1].image = [[NSImage alloc] initWithData:[dict objectForKey:@"ImageExplicit"]];
    [ui_i_Advisory itemAtIndex:2].image = [[NSImage alloc] initWithData:[dict objectForKey:@"ImageClean"]];
}

- (void)createStoreList
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"Data" ofType:@"car"]]];
    NSArray *keys  = [[dict allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
    NSMenu *m      = [[NSMenu alloc] init];
    NSMenuItem *mi = [[NSMenuItem alloc] init];
    mi.Title = @"---";
    mi.tag = -1;
    [m addItem:mi];
    for (NSUInteger i=0;i<keys.count;i++) {
        mi = [[NSMenuItem alloc] init];
        mi.Title = [keys objectAtIndex:i];
        mi.tag = [[dict objectForKey:[keys objectAtIndex:i]] integerValue];
        [m addItem:mi];
    }
    ui_c_StoreID.menu = m;
}

- (void)optionsDrawerCalibrate
{
    ui_is_Name.state                 = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_is_Name"];
    ui_is_Artist.state               = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_is_Artist"];
    ui_is_AlbumArtist.state          = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_is_AlbumArtist"];
    ui_is_Album.state                = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_is_Album"];
    ui_is_Grouping.state             = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_is_Grouping"];
    ui_is_Composer.state             = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_is_Composer"];
    ui_is_Comments.state             = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_is_Comments"];
    ui_is_Genre.state                = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_is_Genre"];
    ui_is_GenreID.state              = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_is_GenreID"];
    ui_is_Year.state                 = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_is_Year"];
    ui_is_TrackNumberFirst.state     = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_is_TrackNumberFirst"];
    ui_is_TrackNumberLast.state      = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_is_TrackNumberLast"];
    ui_is_DiscNumberFirst.state      = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_is_DiscNumberFirst"];
    ui_is_DiscNumberLast.state       = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_is_DiscNumberLast"];
    ui_is_BPM.state                  = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_is_BPM"];
    ui_is_PartOfACompilation.state   = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_is_PartOfACompilation"];
    ui_is_Advisory.state             = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_is_Advisory"];
    
    ui_ss_Name.state                 = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_ss_Name"];
    ui_ss_Artist.state               = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_ss_Artist"];
    ui_ss_AlbumArtist.state          = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_ss_AlbumArtist"];
    ui_ss_Album.state                = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_ss_Album"];
    ui_ss_Composer.state             = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_ss_Composer"];
    ui_ss_Show.state                 = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_ss_Show"];
    ui_ss_Encoder.state              = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_ss_Encoder"];
    ui_ss_EncodedBy.state            = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_ss_EncodedBy"];
    ui_ss_VideoDescription.state     = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_ss_VideoDescription"];
    ui_ss_VideoLongDescription.state = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_ss_VideoLongDescription"];
    ui_ss_VideoNetwork.state         = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_ss_VideoNetwork"];
    ui_ss_VideoShow.state            = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_ss_VideoShow"];
    ui_ss_VideoEpisodeID.state       = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_ss_VideoEpisodeID"];
    ui_ss_VideoSeasonNumber.state    = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_ss_VideoSeasonNumber"];
    ui_ss_VideoEpisodeNumber.state   = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_ss_VideoEpisodeNumber"];
    ui_ss_MediaType.state            = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_ss_MediaType"];
    ui_ss_HDVideo.state              = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_ss_HDVideo"];
    ui_ss_Gapless.state              = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_ss_Gapless"];
    
    
    ui_ps_PodcastURL.state           = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_ps_PodcastURL"];
    ui_ps_PodcastGUID.state          = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_ps_PodcastGUID"];
    ui_ps_Podcast.state              = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_ps_Podcast"];
    ui_ps_PodcastKeywords.state      = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_ps_PodcastKeywords"];
    ui_ps_PodcastCategory.state      = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_ps_PodcastCategory"];
    
    ui_ls_Lyrics.state               = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_ls_Lyrics"];
    
    ui_as_Artwork.state              = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_as_Artwork"];
    
    ui_cs_Copyright.state            = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_cs_Copyright"];
    ui_cs_PurchaseBy.state           = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_cs_PurchaseBy"];
    ui_cs_PurchaseDate.state         = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_cs_PurchaseDate"];
    ui_cs_AppleID.state              = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_cs_AppleID"];
    ui_cs_AccountType.state          = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_cs_AccountType"];
    ui_cs_iTunesCatalogID.state      = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_cs_iTunesCatalogID"];
    ui_cs_StoreID.state              = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_cs_StoreID"];
    ui_cs_Description.state          = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_cs_Description"];
    ui_cs_ISRC.state                 = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_cs_ISRC"];
    ui_cs_UserID.state               = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_cs_UserID"];
    ui_cs_AACType.state              = [[NSUserDefaults standardUserDefaults] boolForKey:@"DrawerOptionUI_cs_AACType"];
}

- (void)resetWarnings
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"AllowMultipleSaving"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"AllowPermanentRemoving"];
    [[NSUserDefaults standardUserDefaults] boolForKey:@""];
}

- (void)checkUpdateWithFeedback:(BOOL)feedback
{
    NSURL *requestResult = [NSURL URLWithString:CONST_UPDATE_CHECK_URL];
    NSString *remoteCFBundleShortVersionString = [[NSDictionary dictionaryWithContentsOfURL:requestResult] objectForKey:@"CFBundleShortVersionString"];
    NSString *localCFBundleShortVersionString  = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    if(remoteCFBundleShortVersionString) {
        if ([localCFBundleShortVersionString isEqualToString:remoteCFBundleShortVersionString]) {
            if (feedback) {
                NSAlert *alert = [NSAlert alertWithMessageText:@"We are up-to-date!"
                                                 defaultButton:@"Nice"
                                               alternateButton:nil
                                                   otherButton:nil
                                     informativeTextWithFormat:@"You are using the latest version of %@.\n", [[NSRunningApplication currentApplication] localizedName]];
                [alert setAlertStyle:NSWarningAlertStyle];
                [alert runModal];
            }
        } else {
            NSAlert *alert = [NSAlert alertWithMessageText:@"New Version Available!"
                                             defaultButton:@"Sure"
                                           alternateButton:@"Maybe Next Time"
                                               otherButton:@"Release Note"
                                 informativeTextWithFormat:@"There's a new version available for download:\n\nVersion %@ (You have %@)\n\nWould you like to download it now?\n",
                              remoteCFBundleShortVersionString,
                              localCFBundleShortVersionString];
            [alert setAlertStyle:NSWarningAlertStyle];
            NSInteger returnCode = [alert runModal];
            if (returnCode == 1) {
                [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:CONST_UPDATE_DOWNLOAD_URL]];
            } else if (returnCode != 0) {
                [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:CONST_RELEASE_NOTE_URL]];
            } else {
                // Do nothing.
            }
        }
    }
}

#pragma mark - UI Methods

- (IBAction)openFiles:(id)sender
{
    [self open:YES];
}

- (IBAction)addFiles:(id)sender
{
    [self open:NO];
}

- (IBAction)saveFile:(id)sender
{
    [ui_m_Indicator startAnimation:nil];
    [self save];
    [ui_m_Indicator stopAnimation:nil];
    [self getMeta];
}

- (IBAction)saveFileAs:(id)sender
{
    if ([[NSFileManager defaultManager] isReadableFileAtPath:g_FileURL.path]) {
        NSSavePanel* panel = [NSSavePanel savePanel];
        [panel setCanCreateDirectories:YES];
        [panel setCanSelectHiddenExtension:YES];
        [panel setExtensionHidden:YES];
        [panel setTreatsFilePackagesAsDirectories:YES];
        [panel setAllowedFileTypes:[NSArray arrayWithObjects:@"mp4", @"m4a", @"m4p", @"m4v", @"m4b", nil]];
        [panel setNameFieldStringValue:[NSString stringWithFormat:@"%@", [g_FileURL lastPathComponent]]];
        [panel beginSheetModalForWindow:ui_m_Window  completionHandler:^(NSInteger result){
            if (result == NSFileHandlingPanelOKButton) {
                NSError *err;
                NSURL *saveURL = [panel URL];
                if ([[NSFileManager defaultManager] fileExistsAtPath:saveURL.path]) {
                    [[NSFileManager defaultManager] removeItemAtURL:saveURL error:&err];
                }
                if (!err) {
                    NSURL *originalURL = g_FileURL;
                    [[NSFileManager defaultManager] copyItemAtURL:g_FileURL toURL:saveURL error:&err];
                    g_FileURL = saveURL;
                    if (!err) {
                        [ui_m_Indicator startAnimation:nil];
                        [self save];
                        [ui_m_Indicator stopAnimation:nil];
                        g_FileURL = originalURL;
                    }
                }
            }
        }];
    }
}

- (IBAction)saveAllFiles:(id)sender
{
    NSURL *currentURL = g_FileURL;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"AllowMultipleSaving"] || [self confirmMultipleFileSaving]) {
        [ui_m_Indicator startAnimation:nil];
        NSUInteger count = g_FileURLs.count;
        for (NSUInteger i=0; i<count; i++) {
            g_FileURL = [g_FileURLs objectAtIndex:i];
            [self progressIndicatorCalibrate:(double)i withMin:0.0 AndMax:(double)count];
            [self save];
        }
        [ui_m_Indicator stopAnimation:nil];
    }
    g_FileURL = currentURL;
    [self getMeta];
}

- (IBAction)removePersonalMeta:(id)sender
{
    NSURL *currentURL = g_FileURL;
    [self writePurchaseByToURL:g_FileURL withName:@""];
    [self writeUserIDToURL:g_FileURL withID:0];
    [self writeAACTypeToURL:g_FileURL withType:0];
    ui_m_PermanentRemovingText.stringValue = @"- Purchase Info.\n- iTunes Store & User Info.";
    if ( ([[NSUserDefaults standardUserDefaults] boolForKey:@"AllowMultipleSaving"] || [self confirmMultipleFileSaving]) && ([[NSUserDefaults standardUserDefaults] boolForKey:@"AllowPermanentRemoving"] || [self confirmPermanentRemoving]) ) {
        for (NSUInteger i=0; i<g_FileURLs.count; i++) {
            g_FileURL = [g_FileURLs objectAtIndex:i];
            [self removePersonalMeta];
        }
    }
    g_FileURL = currentURL;
    [self getMeta];
}

- (IBAction)removeAllMeta:(id)sender
{
    NSURL *currentURL = g_FileURL;
    ui_m_PermanentRemovingText.stringValue = @"- All iTunes metadata.";
    if ( ([[NSUserDefaults standardUserDefaults] boolForKey:@"AllowMultipleSaving"] || [self confirmMultipleFileSaving]) && ([[NSUserDefaults standardUserDefaults] boolForKey:@"AllowPermanentRemoving"] || [self confirmPermanentRemoving]) ) {
        for (NSUInteger i=0; i<g_FileURLs.count; i++) {
            g_FileURL = [g_FileURLs objectAtIndex:i];
            [self removeAllMeta];
        }
    }
    g_FileURL = currentURL;
    [self getMeta];
}

- (IBAction)switchFile:(id)sender
{
    [self switchFile];
}

- (IBAction)removeFile:(id)sender
{
    [self removeFile];
}

- (IBAction)addCover:(id)sender
{
    [self addCover];
}

- (IBAction)exportCover:(id)sender
{
    [self exportCover];
}

- (IBAction)exportTypeChange:(NSPopUpButton *)sender
{
    NSSavePanel *savePanel = (NSSavePanel *)[sender window];
    NSString *ext;
    BOOL hasQualitySetting = NO;
    switch (sender.selectedTag) {
        case 0:
            ext = @"bmp";
            break;
        case 1:
            ext = @"gif";
            hasQualitySetting = YES;
            break;
        case 2:
            ext = @"jpg";
            hasQualitySetting = YES;
            break;
        case 3:
            ext = @"jp2";
            hasQualitySetting = YES;
            break;
        case 4:
            ext = @"png";
            break;
        case 5:
            ext = @"tiff";
            break;
        default:
            break;
    }
    ui_m_ExportQuality.hidden = !hasQualitySetting;
    NSString *nameFieldStringWithExt = [NSString stringWithFormat:@"%@.%@",
                                        [[savePanel nameFieldStringValue] stringByDeletingPathExtension],
                                        ext];
    [savePanel setNameFieldStringValue:nameFieldStringWithExt];
}

- (IBAction)sliderValue:(NSSlider *)sender
{
    ui_m_ExportQualityValue.stringValue = [NSString stringWithFormat:@"Quality (%d%%):", (int)roundf(sender.floatValue * 100)];
}

- (IBAction)play:(id)sender
{
    [self soundHandler:YES];
}

- (IBAction)optionsSwitch:(id)sender
{
    [self optionsCalibrate:[[sender title] isEqualToString:@"Select All"]];
}

- (IBAction)optionsDrawerCalibrate:(NSButton *)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:(ui_is_Name.state == NSOnState) forKey:@"DrawerOptionUI_is_Name"];
    [[NSUserDefaults standardUserDefaults] setBool:(ui_is_Artist.state == NSOnState) forKey:@"DrawerOptionUI_is_Artist"];
    [[NSUserDefaults standardUserDefaults] setBool:(ui_is_AlbumArtist.state == NSOnState) forKey:@"DrawerOptionUI_is_AlbumArtist"];
    [[NSUserDefaults standardUserDefaults] setBool:(ui_is_Album.state == NSOnState) forKey:@"DrawerOptionUI_is_Album"];
    [[NSUserDefaults standardUserDefaults] setBool:(ui_is_Grouping.state == NSOnState) forKey:@"DrawerOptionUI_is_Grouping"];
    [[NSUserDefaults standardUserDefaults] setBool:(ui_is_Composer.state == NSOnState) forKey:@"DrawerOptionUI_is_Composer"];
    [[NSUserDefaults standardUserDefaults] setBool:(ui_is_Comments.state == NSOnState) forKey:@"DrawerOptionUI_is_Comments"];
    [[NSUserDefaults standardUserDefaults] setBool:(ui_is_Genre.state == NSOnState) forKey:@"DrawerOptionUI_is_Genre"];
    [[NSUserDefaults standardUserDefaults] setBool:(ui_is_GenreID.state == NSOnState) forKey:@"DrawerOptionUI_is_GenreID"];
    [[NSUserDefaults standardUserDefaults] setBool:(ui_is_Year.state == NSOnState) forKey:@"DrawerOptionUI_is_Year"];
    [[NSUserDefaults standardUserDefaults] setBool:(ui_is_TrackNumberFirst.state == NSOnState) forKey:@"DrawerOptionUI_is_TrackNumberFirst"];
    [[NSUserDefaults standardUserDefaults] setBool:(ui_is_TrackNumberLast.state == NSOnState) forKey:@"DrawerOptionUI_is_TrackNumberLast"];
    [[NSUserDefaults standardUserDefaults] setBool:(ui_is_DiscNumberFirst.state == NSOnState) forKey:@"DrawerOptionUI_is_DiscNumberFirst"];
    [[NSUserDefaults standardUserDefaults] setBool:(ui_is_DiscNumberLast.state == NSOnState) forKey:@"DrawerOptionUI_is_DiscNumberLast"];
    [[NSUserDefaults standardUserDefaults] setBool:(ui_is_BPM.state == NSOnState) forKey:@"DrawerOptionUI_is_BPM"];
    [[NSUserDefaults standardUserDefaults] setBool:(ui_is_PartOfACompilation.state == NSOnState) forKey:@"DrawerOptionUI_is_PartOfACompilation"];
    [[NSUserDefaults standardUserDefaults] setBool:(ui_is_Advisory.state == NSOnState) forKey:@"DrawerOptionUI_is_Advisory"];
    
    [[NSUserDefaults standardUserDefaults] setBool:(ui_ss_Name.state == NSOnState) forKey:@"DrawerOptionUI_ss_Name"];
    [[NSUserDefaults standardUserDefaults] setBool:(ui_ss_Artist.state == NSOnState) forKey:@"DrawerOptionUI_ss_Artist"];
    [[NSUserDefaults standardUserDefaults] setBool:(ui_ss_AlbumArtist.state == NSOnState) forKey:@"DrawerOptionUI_ss_AlbumArtist"];
    [[NSUserDefaults standardUserDefaults] setBool:(ui_ss_Album.state == NSOnState) forKey:@"DrawerOptionUI_ss_Album"];
    [[NSUserDefaults standardUserDefaults] setBool:(ui_ss_Composer.state == NSOnState) forKey:@"DrawerOptionUI_ss_Composer"];
    [[NSUserDefaults standardUserDefaults] setBool:(ui_ss_Show.state == NSOnState) forKey:@"DrawerOptionUI_ss_Show"];
    [[NSUserDefaults standardUserDefaults] setBool:(ui_ss_Encoder.state == NSOnState) forKey:@"DrawerOptionUI_ss_Encoder"];
    [[NSUserDefaults standardUserDefaults] setBool:(ui_ss_EncodedBy.state == NSOnState) forKey:@"DrawerOptionUI_ss_EncodedBy"];
    [[NSUserDefaults standardUserDefaults] setBool:(ui_ss_VideoDescription.state == NSOnState) forKey:@"DrawerOptionUI_ss_VideoDescription"];
    [[NSUserDefaults standardUserDefaults] setBool:(ui_ss_VideoLongDescription.state == NSOnState) forKey:@"DrawerOptionUI_ss_VideoLongDescription"];
    [[NSUserDefaults standardUserDefaults] setBool:(ui_ss_VideoNetwork.state == NSOnState) forKey:@"DrawerOptionUI_ss_VideoNetwork"];
    [[NSUserDefaults standardUserDefaults] setBool:(ui_ss_VideoShow.state == NSOnState) forKey:@"DrawerOptionUI_ss_VideoShow"];
    [[NSUserDefaults standardUserDefaults] setBool:(ui_ss_VideoEpisodeID.state == NSOnState) forKey:@"DrawerOptionUI_ss_VideoEpisodeID"];
    [[NSUserDefaults standardUserDefaults] setBool:(ui_ss_VideoSeasonNumber.state == NSOnState) forKey:@"DrawerOptionUI_ss_VideoSeasonNumber"];
    [[NSUserDefaults standardUserDefaults] setBool:(ui_ss_VideoEpisodeNumber.state == NSOnState) forKey:@"DrawerOptionUI_ss_VideoEpisodeNumber"];
    [[NSUserDefaults standardUserDefaults] setBool:(ui_ss_MediaType.state == NSOnState) forKey:@"DrawerOptionUI_ss_MediaType"];
    [[NSUserDefaults standardUserDefaults] setBool:(ui_ss_HDVideo.state == NSOnState) forKey:@"DrawerOptionUI_ss_HDVideo"];
    [[NSUserDefaults standardUserDefaults] setBool:(ui_ss_Gapless.state == NSOnState) forKey:@"DrawerOptionUI_ss_Gapless"];
    
    
    [[NSUserDefaults standardUserDefaults] setBool:(ui_ps_PodcastURL.state == NSOnState) forKey:@"DrawerOptionUI_ps_PodcastURL"];
    [[NSUserDefaults standardUserDefaults] setBool:(ui_ps_PodcastGUID.state == NSOnState) forKey:@"DrawerOptionUI_ps_PodcastGUID"];
    [[NSUserDefaults standardUserDefaults] setBool:(ui_ps_Podcast.state == NSOnState) forKey:@"DrawerOptionUI_ps_Podcast"];
    [[NSUserDefaults standardUserDefaults] setBool:(ui_ps_PodcastKeywords.state == NSOnState) forKey:@"DrawerOptionUI_ps_PodcastKeywords"];
    [[NSUserDefaults standardUserDefaults] setBool:(ui_ps_PodcastCategory.state == NSOnState) forKey:@"DrawerOptionUI_ps_PodcastCategory"];
    
    [[NSUserDefaults standardUserDefaults] setBool:(ui_ls_Lyrics.state == NSOnState) forKey:@"DrawerOptionUI_ls_Lyrics"];
    
    [[NSUserDefaults standardUserDefaults] setBool:(ui_as_Artwork.state == NSOnState) forKey:@"DrawerOptionUI_as_Artwork"];
    
    [[NSUserDefaults standardUserDefaults] setBool:(ui_cs_Copyright.state == NSOnState) forKey:@"DrawerOptionUI_cs_Copyright"];
    [[NSUserDefaults standardUserDefaults] setBool:(ui_cs_PurchaseBy.state == NSOnState) forKey:@"DrawerOptionUI_cs_PurchaseBy"];
    [[NSUserDefaults standardUserDefaults] setBool:(ui_cs_PurchaseDate.state == NSOnState) forKey:@"DrawerOptionUI_cs_PurchaseDate"];
    [[NSUserDefaults standardUserDefaults] setBool:(ui_cs_AppleID.state == NSOnState) forKey:@"DrawerOptionUI_cs_AppleID"];
    [[NSUserDefaults standardUserDefaults] setBool:(ui_cs_AccountType.state == NSOnState) forKey:@"DrawerOptionUI_cs_AccountType"];
    [[NSUserDefaults standardUserDefaults] setBool:(ui_cs_iTunesCatalogID.state == NSOnState) forKey:@"DrawerOptionUI_cs_iTunesCatalogID"];
    [[NSUserDefaults standardUserDefaults] setBool:(ui_cs_StoreID.state == NSOnState) forKey:@"DrawerOptionUI_cs_StoreID"];
    [[NSUserDefaults standardUserDefaults] setBool:(ui_cs_Description.state == NSOnState) forKey:@"DrawerOptionUI_cs_Description"];
    [[NSUserDefaults standardUserDefaults] setBool:(ui_cs_ISRC.state == NSOnState) forKey:@"DrawerOptionUI_cs_ISRC"];
    [[NSUserDefaults standardUserDefaults] setBool:(ui_cs_UserID.state == NSOnState) forKey:@"DrawerOptionUI_cs_UserID"];
    [[NSUserDefaults standardUserDefaults] setBool:(ui_cs_AACType.state == NSOnState) forKey:@"DrawerOptionUI_cs_AACType"];
}

- (IBAction)resetWarnings:(id)sender
{
    [self resetWarnings];
}

- (IBAction)update:(id)sender
{
    [self checkUpdateWithFeedback:YES];
}

- (IBAction)getSupport:(id)sender
{
    NSString *url;
    NSUInteger tag;
    if ([sender isKindOfClass:[NSMenuItem class]]) {
        NSMenuItem *s = (NSMenuItem *)sender;
        tag = s.tag;
    } else if ([sender isKindOfClass:[NSButton class]]) {
        NSButton *s = (NSButton *)sender;
        tag = s.tag;
    }
    switch (tag) {
        case 1:
            url = CONST_DEVELOPER_URL;
            break;
        default:
            url = CONST_SUPPORT_URL;
            break;
    }
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
}

@end
