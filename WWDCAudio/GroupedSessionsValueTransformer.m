//
//  GroupedSessionsValueTransformer.m
//  WWDCAudio
//
//  Created by ernesto on 8/10/15.
//  Copyright © 2015 cocoawithchurros. All rights reserved.
//

#import "GroupedSessionsValueTransformer.h"
#import "Session.h"

@implementation GroupedSessionsValueTransformer

+(BOOL)allowsReverseTransformation
{
  return NO;
}

+(Class)transformedValueClass
{
  return [NSArray class];
}


// Transformed the unordered list of sessions into a list grouped by year, and sorted by year (desc) and title.
-(id)transformedValue:(NSArray*)sessions
{
  NSMutableArray *groupedSessionsArray;
  if( [sessions isKindOfClass:[NSArray class]] )
  {
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO];
    NSArray *years = [[sessions valueForKeyPath:@"@distinctUnionOfObjects.year"] sortedArrayUsingDescriptors:@[sortDescriptor]];
    groupedSessionsArray = [NSMutableArray new];
    for( NSString *year in years )
    {
      [groupedSessionsArray addObject:year];
      NSArray *sortedSessions = [[sessions filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(Session *  _Nonnull session, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [session.year isEqualToString:year];
      }]] sortedArrayUsingComparator:^NSComparisonResult(Session *  _Nonnull obj1, Session *  _Nonnull obj2) {
        return [obj1.title compare:obj2.title];
      }];
      [groupedSessionsArray addObjectsFromArray:sortedSessions];
    }
  }
  return [groupedSessionsArray copy];
}

@end
