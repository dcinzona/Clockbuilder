/*
 * JScrollingRow
 * Copyright © 2010, Jeremy Tregunna, All Rights Reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

#import "JScrollingRow.h"
#import "JScrollingRowCell.h"


NSString* const kJScrollingRowMemoryWarningNotification = @"kJScrollingRowMemoryWarningNotification";


@interface JScrollingRow (Private)
- (BOOL)isDisplayingCellForIndex:(NSUInteger)index;
- (void)layoutCells;
@end


@implementation JScrollingRow


@synthesize indexPath = _indexPath;
@synthesize dataSource = _dataSource;
@dynamic delegate;


#pragma mark -
#pragma mark Memory management


- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
        [self setShowsVerticalScrollIndicator: NO];
		recycledCells = [[NSMutableSet alloc] init];
		visibleCells = [[NSMutableSet alloc] init];
		
		// No sense in keeping the recycled cells set in tact if we're short on memory.
		// This just means in tight memory situations, we'll have to do more allocation,
		// which isn't as fast.
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(emptyRecycledCells)
													 name:UIApplicationDidReceiveMemoryWarningNotification
												   object:nil];
	}
    return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[recycledCells release];
	[visibleCells release];
	[_indexPath release];
	[super dealloc];
}


#pragma mark -
#pragma mark Dealing with reusable cells


- (BOOL)isDisplayingCellForIndex:(NSUInteger)index
{
	BOOL foundCell = NO;
	
	for(JScrollingRowCell* cell in visibleCells)
	{
		if(cell.index == index)
		{
			foundCell = YES;
			break;
		}
	}
	
	return foundCell;
}


- (CGRect)frameForCellAtIndex:(NSUInteger)index
{
	// Use our bounds rather than our frame so the rotation transform is applied.
    CGRect bounds = self.bounds;
    CGRect cellFrame = bounds;
    cellFrame.size.width = [self.delegate scrollingRowView:self widthForCellAtIndex:index];
    cellFrame.origin.x = cellFrame.size.width * index;
    return cellFrame;
}


- (void)layoutCells
{
	// Calculate which pages should be visible
	CGRect visibleBounds = self.bounds;
    CGFloat cellWidth = [self.delegate scrollingRowView:self widthForCellAtIndex:0];
	int firstNeededCellIndex = MAX(floorf(CGRectGetMinX(visibleBounds) / cellWidth), 0);
	int lastNeededCellIndex = MIN(floorf((CGRectGetMaxX(visibleBounds) - 1) / cellWidth + cellWidth),
								  [self.dataSource numberOfColumnsInRow:self atIndexPath:self.indexPath] - 1);
    
	// Recycle no longer needed cells
	for(JScrollingRowCell* cell in visibleCells)
	{
		if(cell.index < firstNeededCellIndex || cell.index > lastNeededCellIndex)
		{
			[recycledCells addObject:cell];
			[cell removeFromSuperview];
		}
	}
	
	// Remove recycled items from the visible set
	[visibleCells minusSet:recycledCells];
	
	// Add any missing cells...
	for(NSUInteger index = firstNeededCellIndex; index <= lastNeededCellIndex; index++)
	{
		// ...that we're not displaying.
		if(![self isDisplayingCellForIndex:index])
		{
			JScrollingRowCell* cell = [self.dataSource scrollingRowView:self cellForColumnAtIndex:index];
            cell.frame = [self frameForCellAtIndex:index];
			[visibleCells addObject:cell];
            [self addSubview:cell];
		}
	}
}


- (JScrollingRowCell*)dequeueReusableCellWithIdentifier:(NSString*)identifier
{
	NSSet* filteredSet = [recycledCells filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"reuseIdentifier == %@", identifier]];
	JScrollingRowCell* cell = [filteredSet anyObject];
	
	if(cell)
	{
		// Take ownership so our cell doesn't disappear when we return
		[[cell retain] autorelease];
		[recycledCells removeObject:cell];
	}
	
	return cell;
}


#pragma mark -
#pragma mark Callbacks

- (void)emptyRecycledCells
{
	[recycledCells removeAllObjects];
}


#pragma mark -
#pragma mark Touch handling


// Use the old style responder touch events to maintain 3.0 compatibility. I'm moving this to gesture recognizers once I drop 3.0 support.
- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
	if(!self.dragging)
	{
		UITouch* touch = [touches anyObject];
		CGPoint location = [touch locationInView:self];
		NSUInteger index = location.x / [self.delegate scrollingRowView:self widthForCellAtIndex:0];
		if([self.delegate respondsToSelector:@selector(scrollingRowView:didSelectCellAtIndex:)])
			[self.delegate scrollingRowView:self didSelectCellAtIndex:index];
	}
	else
		[super touchesEnded:touches withEvent:event];
}



@end