//
//  MetarminatorAppDelegate.h
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

#pragma mark - Define Consts

#define CONST_DEVELOPER_URL       @"http://reversi.ng"
#define CONST_RELEASE_NOTE_URL    @"https://github.com/x43x61x69/Metarminator"
#define CONST_SUPPORT_URL         @"https://github.com/x43x61x69/Metarminator/issues"
#define CONST_UPDATE_CHECK_URL    @"https://raw.githubusercontent.com/x43x61x69/Metarminator/master/Source/Metarminator/Metarminator-Info.plist"
#define CONST_UPDATE_DOWNLOAD_URL @"https://github.com/x43x61x69/Metarminator/raw/master/Release/Metarminator.zip"

#define CONST_KEY_HEX_USER        @"00000C75736572"
#define CONST_KEY_HEX_MODE        @"0000016D6F6465"
#define CONST_KEY_HEX_NAME        @"000001086E616D65"

#pragma mark - Header Files

#import <Cocoa/Cocoa.h>

@interface MetarminatorAppDelegate : NSObject <NSApplicationDelegate> {
    NSURL               * g_FileURL;
    NSMutableDictionary * g_FileMetaDict;
    NSMutableArray      * g_FileURLs;
    NSMutableArray      * g_Covers;
    NSSound             * g_Sound;
    NSImage             * g_NoCover;
}

#pragma mark - UI Objects - Main

@property (assign) IBOutlet NSWindow            *ui_m_Window;
@property (assign) IBOutlet NSDrawer            *ui_m_DrawerOptions;

@property (assign) IBOutlet NSButton            *ui_m_New;
@property (assign) IBOutlet NSButton            *ui_m_Save;
@property (assign) IBOutlet NSMenuItem          *ui_m_SaveAll;
@property (assign) IBOutlet NSButton            *ui_m_Remove;
@property (assign) IBOutlet NSButton            *ui_m_Drawer;
@property (assign) IBOutlet NSButton            *ui_m_Play;
@property (assign) IBOutlet NSButton            *ui_m_Edit;
@property (assign) IBOutlet NSPopUpButton       *ui_m_Queue;
@property (assign) IBOutlet NSProgressIndicator *ui_m_Indicator;

@property (assign) IBOutlet NSMenuItem          *ui_mm_Add;
@property (assign) IBOutlet NSMenuItem          *ui_mm_Save;
@property (assign) IBOutlet NSMenuItem          *ui_mm_SaveAll;
@property (assign) IBOutlet NSMenuItem          *ui_mm_SaveAs;
@property (assign) IBOutlet NSMenuItem          *ui_mm_Remove;

#pragma mark UI Objects - Cover Export

@property (assign) IBOutlet NSView              *ui_m_ExportView;
@property (assign) IBOutlet NSPopUpButton       *ui_m_ExportType;
@property (assign) IBOutlet NSSlider            *ui_m_ExportQuality;
@property (assign) IBOutlet NSTextField         *ui_m_ExportQualityValue;

#pragma mark UI Objects - Multiple Saving

@property (assign) IBOutlet NSView              *ui_m_MultipleSavingView;
@property (assign) IBOutlet NSButton            *ui_m_MultipleSavingCheckbox;

#pragma mark UI Objects - Permanent Removing

@property (assign) IBOutlet NSView              *ui_m_PermanentRemovingView;
@property (assign) IBOutlet NSTextField         *ui_m_PermanentRemovingText;
@property (assign) IBOutlet NSButton            *ui_m_PermanentRemovingCheckbox;

#pragma mark UI Objects - Drawer

@property (assign) IBOutlet NSButton            *ui_is_Name;
@property (assign) IBOutlet NSButton            *ui_is_Artist;
@property (assign) IBOutlet NSButton            *ui_is_AlbumArtist;
@property (assign) IBOutlet NSButton            *ui_is_Album;
@property (assign) IBOutlet NSButton            *ui_is_Grouping;
@property (assign) IBOutlet NSButton            *ui_is_Composer;
@property (assign) IBOutlet NSButton            *ui_is_Comments;
@property (assign) IBOutlet NSButton            *ui_is_Genre;
@property (assign) IBOutlet NSButton            *ui_is_GenreID;
@property (assign) IBOutlet NSButton            *ui_is_Year;
@property (assign) IBOutlet NSButton            *ui_is_TrackNumberFirst;
@property (assign) IBOutlet NSButton            *ui_is_TrackNumberLast;
@property (assign) IBOutlet NSButton            *ui_is_DiscNumberFirst;
@property (assign) IBOutlet NSButton            *ui_is_DiscNumberLast;
@property (assign) IBOutlet NSButton            *ui_is_BPM;
@property (assign) IBOutlet NSButton            *ui_is_PartOfACompilation;
@property (assign) IBOutlet NSButton            *ui_is_Advisory;

@property (assign) IBOutlet NSButton            *ui_ss_Name;
@property (assign) IBOutlet NSButton            *ui_ss_Artist;
@property (assign) IBOutlet NSButton            *ui_ss_AlbumArtist;
@property (assign) IBOutlet NSButton            *ui_ss_Album;
@property (assign) IBOutlet NSButton            *ui_ss_Composer;
@property (assign) IBOutlet NSButton            *ui_ss_Show;
@property (assign) IBOutlet NSButton            *ui_ss_Encoder;
@property (assign) IBOutlet NSButton            *ui_ss_EncodedBy;
@property (assign) IBOutlet NSButton            *ui_ss_VideoDescription;
@property (assign) IBOutlet NSButton            *ui_ss_VideoLongDescription;
@property (assign) IBOutlet NSButton            *ui_ss_VideoNetwork;
@property (assign) IBOutlet NSButton            *ui_ss_VideoShow;
@property (assign) IBOutlet NSButton            *ui_ss_VideoEpisodeID;
@property (assign) IBOutlet NSButton            *ui_ss_VideoSeasonNumber;
@property (assign) IBOutlet NSButton            *ui_ss_VideoEpisodeNumber;
@property (assign) IBOutlet NSButton            *ui_ss_MediaType;
@property (assign) IBOutlet NSButton            *ui_ss_HDVideo;
@property (assign) IBOutlet NSButton            *ui_ss_Gapless;


@property (assign) IBOutlet NSButton            *ui_ps_PodcastURL;
@property (assign) IBOutlet NSButton            *ui_ps_PodcastGUID;
@property (assign) IBOutlet NSButton            *ui_ps_Podcast;
@property (assign) IBOutlet NSButton            *ui_ps_PodcastKeywords;
@property (assign) IBOutlet NSButton            *ui_ps_PodcastCategory;

@property (assign) IBOutlet NSButton            *ui_ls_Lyrics;

@property (assign) IBOutlet NSButton            *ui_as_Artwork;

@property (assign) IBOutlet NSButton            *ui_cs_Copyright;
@property (assign) IBOutlet NSButton            *ui_cs_PurchaseBy;
@property (assign) IBOutlet NSButton            *ui_cs_PurchaseDate;
@property (assign) IBOutlet NSButton            *ui_cs_AppleID;
@property (assign) IBOutlet NSButton            *ui_cs_AccountType;
@property (assign) IBOutlet NSButton            *ui_cs_iTunesCatalogID;
@property (assign) IBOutlet NSButton            *ui_cs_StoreID;
@property (assign) IBOutlet NSButton            *ui_cs_Description;
@property (assign) IBOutlet NSButton            *ui_cs_ISRC;
@property (assign) IBOutlet NSButton            *ui_cs_UserID;
@property (assign) IBOutlet NSButton            *ui_cs_AACType;

#pragma mark UI Objects - Info

@property (assign) IBOutlet NSImageView         *ui_i_Artwork;
@property (assign) IBOutlet NSTextField         *ui_i_Name;
@property (assign) IBOutlet NSTextField         *ui_i_Artist;
@property (assign) IBOutlet NSTextField         *ui_i_AlbumArtist;
@property (assign) IBOutlet NSTextField         *ui_i_Album;
@property (assign) IBOutlet NSTextField         *ui_i_Grouping;
@property (assign) IBOutlet NSTextField         *ui_i_Composer;
@property (assign) IBOutlet NSTextField         *ui_i_Comments;
@property (assign) IBOutlet NSTextField         *ui_i_Genre;
@property (assign) IBOutlet NSTextField         *ui_i_GenreID;
@property (assign) IBOutlet NSTextField         *ui_i_Year;
@property (assign) IBOutlet NSTextField         *ui_i_TrackNumberFirst;
@property (assign) IBOutlet NSTextField         *ui_i_TrackNumberLast;
@property (assign) IBOutlet NSTextField         *ui_i_DiscNumberFirst;
@property (assign) IBOutlet NSTextField         *ui_i_DiscNumberLast;
@property (assign) IBOutlet NSTextField         *ui_i_BPM;
@property (assign) IBOutlet NSButton            *ui_i_PartOfACompilation;
@property (assign) IBOutlet NSPopUpButton       *ui_i_Advisory;

#pragma mark UI Objects - Sort

@property (assign) IBOutlet NSTextField         *ui_s_Name;
@property (assign) IBOutlet NSTextField         *ui_s_Artist;
@property (assign) IBOutlet NSTextField         *ui_s_AlbumArtist;
@property (assign) IBOutlet NSTextField         *ui_s_Album;
@property (assign) IBOutlet NSTextField         *ui_s_Composer;
@property (assign) IBOutlet NSTextField         *ui_s_Show;
@property (assign) IBOutlet NSTextField         *ui_s_Encoder;
@property (assign) IBOutlet NSTextField         *ui_s_EncodedBy;
@property (assign) IBOutlet NSTextField         *ui_s_VideoDescription;
@property (assign) IBOutlet NSTextField         *ui_s_VideoLongDescription;
@property (assign) IBOutlet NSTextField         *ui_s_VideoNetwork;
@property (assign) IBOutlet NSTextField         *ui_s_VideoShow;
@property (assign) IBOutlet NSTextField         *ui_s_VideoEpisodeID;
@property (assign) IBOutlet NSTextField         *ui_s_VideoSeasonNumber;
@property (assign) IBOutlet NSTextField         *ui_s_VideoEpisodeNumber;
@property (assign) IBOutlet NSPopUpButton       *ui_s_MediaType;
@property (assign) IBOutlet NSPopUpButton       *ui_s_HDVideo;
@property (assign) IBOutlet NSButton            *ui_s_Gapless;

#pragma mark UI Objects - Podcast

@property (assign) IBOutlet NSTextField         *ui_p_PodcastURL;
@property (assign) IBOutlet NSTextField         *ui_p_PodcastGUID;
@property (assign) IBOutlet NSButton            *ui_p_Podcast;
@property (assign) IBOutlet NSTextField         *ui_p_PodcastKeywords;
@property (assign) IBOutlet NSTextField         *ui_p_PodcastCategory;

#pragma mark UI Objects - Lyrics

@property (assign) IBOutlet NSTextView          *ui_l_Lyrics;

#pragma mark UI Objects - Artwork

@property (assign) IBOutlet NSImageView         *ui_a_Artwork;
@property (assign) IBOutlet NSButton            *ui_a_ArtworkScale;
@property (assign) IBOutlet NSStepper           *ui_a_Stepper;
@property (assign) IBOutlet NSTextField         *ui_a_Info;

#pragma mark UI Objects - Copyright

@property (assign) IBOutlet NSTextField         *ui_c_Copyright;
@property (assign) IBOutlet NSTextField         *ui_c_PurchaseBy;
@property (assign) IBOutlet NSTextField         *ui_c_PurchaseDate;
@property (assign) IBOutlet NSTextField         *ui_c_AppleID;
@property (assign) IBOutlet NSPopUpButton       *ui_c_AccountType;
@property (assign) IBOutlet NSTextField         *ui_c_iTunesCatalogID;
@property (assign) IBOutlet NSPopUpButton       *ui_c_StoreID;
@property (assign) IBOutlet NSTextField         *ui_c_Description;
@property (assign) IBOutlet NSTextField         *ui_c_ISRC;
@property (assign) IBOutlet NSTextField         *ui_c_UserID;
@property (assign) IBOutlet NSPopUpButton       *ui_c_AACType;

#pragma mark - UI Methods

- (IBAction)openFiles:(id)sender;
- (IBAction)addFiles:(id)sender;
- (IBAction)saveFile:(id)sender;
- (IBAction)saveFileAs:(id)sender;
- (IBAction)saveAllFiles:(id)sender;
- (IBAction)removePersonalMeta:(id)sender;
- (IBAction)removeAllMeta:(id)sender;
- (IBAction)switchFile:(id)sender;
- (IBAction)removeFile:(id)sender;
- (IBAction)addCover:(id)sender;
- (IBAction)exportCover:(id)sender;
- (IBAction)exportTypeChange:(NSPopUpButton *)sender;
- (IBAction)sliderValue:(NSSlider *)sender;
- (IBAction)play:(id)sender;
- (IBAction)resetWarnings:(id)sender;
- (IBAction)optionsDrawerCalibrate:(NSButton *)sender;
- (IBAction)update:(id)sender;
- (IBAction)getSupport:(id)sender;
- (IBAction)developerWebsite:(id)sender;

@end
