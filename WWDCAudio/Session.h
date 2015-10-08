//
//  Session.h
//  WWDCAudio
//
//  Created by ernesto on 7/10/15.
//  Copyright © 2015 cocoawithchurros. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Session: NSObject
@property (nonatomic,strong,readonly) NSString *sessionID;
@property (nonatomic,strong,readonly) NSString *title;
@property (nonatomic,strong,readonly) NSString *info;
@property (nonatomic,strong,readonly) NSURL *videoURL;
@property (nonatomic,strong,readonly) NSString *year;

+(instancetype)sessionWithId:(NSString*)sessionID title:(NSString*)title year:(NSString*)year info:(NSString*)info videoURL:(NSURL*)videoURL;
-(instancetype)initWithId:(NSString*)sessionID title:(NSString*)title  year:(NSString*)year info:(NSString*)info videoURL:(NSURL*)videoURL;
-(BOOL)containsSearchQuery:(NSString*)query;

@end

