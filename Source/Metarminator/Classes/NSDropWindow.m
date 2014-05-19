//
//  NSDropWindow.m
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

#import "NSDropWindow.h"
#import "MetarminatorAppDelegate.h"

@implementation NSDropWindow

- (void)awakeFromNib
{
    [self registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
}

- (NSDragOperation)draggingEntered:(id < NSDraggingInfo >)sender
{
    [[self contentView] setAlphaValue:.3];
    return NSDragOperationCopy;
}

- (NSDragOperation)draggingUpdated:(id < NSDraggingInfo >)sender
{
    return NSDragOperationCopy;
}

- (void)draggingEnded:(id < NSDraggingInfo >)sender
{
    [[self contentView] setAlphaValue:1.0];
}

- (void)draggingExited:(id < NSDraggingInfo >)sender
{
    [[self contentView] setAlphaValue:1.0];
}

- (BOOL)performDragOperation:(id < NSDraggingInfo >)sender
{
    [[self contentView] setAlphaValue:1.0];
    NSArray        *allowedTypes = [NSArray arrayWithObjects:@"mp4", @"m4a", @"m4p", @"m4v", @"m4b", nil];
    NSArray        *dragPaths    = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
    NSMutableArray *files        = [[NSMutableArray alloc] initWithCapacity:dragPaths.count];
    
    for (NSString *path in dragPaths) {
        if ([allowedTypes containsObject:[path pathExtension]]) {
            [files addObject:[NSURL fileURLWithPath:path]];
        }
    }
    
#ifdef DEBUG
    NSLog(@"Dragged in files = %@", files);
#endif
    
    if (files.count) {
        [(id)[NSApplication sharedApplication].delegate performSelectorInBackground:@selector(openProcess:) withObject:files];
    }
    
    return NO;
}

@end
