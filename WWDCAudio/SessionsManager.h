//
//  SessionsManager.h
//  WWDCAudio
//
//  Created by ernesto on 7/10/15.
//  Copyright © 2015 cocoawithchurros. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Session.h"


extern NSInteger const kErrorSessionsStillDownloading ;

typedef void(^SessionCompletionBlock)(NSArray<Session*>* sessions, NSError* error);

@interface SessionsManager : NSObject

-(void)sessionsWithQuery:(NSString*)query completionBlock:(SessionCompletionBlock)completionBlock;

@end
