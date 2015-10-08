//
//  SessionListViewController.m
//  WWDCAudio
//
//  Created by ernesto on 7/10/15.
//  Copyright © 2015 cocoawithchurros. All rights reserved.
//

#import "SessionListViewController.h"
#import "SessionsManager.h"
#import "SessionCell.h"
#import "AudioExportManager.h"
#import "GroupedSessionsValueTransformer.h"

NSString * const kDefaultAudioExtension = @"m4a";
NSString * const kInitialFolder = @"~/Music";
NSString * const kHeaderCellID = @"headerCellID";
NSString * const kSessionCellID =@"sessionCellID";

@interface SessionListViewController ()<NSTableViewDataSource,NSTableViewDelegate, NSPathControlDelegate>

@property (nonatomic,strong) SessionsManager *sessionsManager;
@property (nonatomic,strong) NSArray *sessions;
@property (nonatomic,strong) IBOutlet NSTableView * tableView;
@property (nonatomic,strong) IBOutlet NSProgressIndicator *progresIndicator;
@property (nonatomic,strong) IBOutlet NSSearchField *searchField;
@property (nonatomic,strong) IBOutlet NSPathControl * pathControl;
@property (nonatomic,strong) AudioExportManager *exportManager;
@property (nonatomic,strong) GroupedSessionsValueTransformer *sessionsArrayTransformer;
@end

@implementation SessionListViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do view setup here.
  [self showProgress:YES];
  self.sessionsManager = [[SessionsManager alloc] init];
  self.exportManager = [[AudioExportManager alloc] init];
  self.sessionsArrayTransformer = [[GroupedSessionsValueTransformer alloc] init];
  // TODO: Should remember last used folder reading it from the user defaults.
  [self.pathControl setURL:[NSURL fileURLWithPath:[kInitialFolder stringByExpandingTildeInPath] ]];
  [self loadSessionsWithQuery:nil];
  
}

-(void)loadSessionsWithQuery:(NSString*)query
{
  
  [self.sessionsManager sessionsWithQuery:query completionBlock:^(NSArray<Session *> *sessions, NSError *error) {
    
    dispatch_async(dispatch_get_main_queue(), ^{
      [self showSessions:sessions];
      [self showProgress:(error.code == kErrorSessionsStillDownloading)? YES: NO];
    });
  }];
}



-(void)showSessions:(NSArray*)sessions
{
  self.sessions = [self.sessionsArrayTransformer transformedValue:sessions];
  [self.tableView reloadData];
}

-(void)showProgress:(BOOL)show
{
  [self.progresIndicator setHidden:!show];
  [self.searchField setHidden:show];
  if( show )
    [self.progresIndicator startAnimation:nil];
  else
    [self.progresIndicator stopAnimation:nil];
}

-(NSURL*)outputURLForSession:(Session*)session
{
  // TODO: should check if the file exists and add a suffix, or ask the user for confirmation to delete the existing file...
  NSURL *url = [self.pathControl.URL URLByAppendingPathComponent:session.title];
  url = [url URLByAppendingPathExtension:kDefaultAudioExtension];
  return url;
}


-(void)notifyExportedSession:(Session*)session endedWithError:(NSError*)error
{
  NSUserNotification *notification = [[NSUserNotification alloc] init];
  notification.title = NSLocalizedString(@"Audio export task ended", @"");
  notification.subtitle = session.title;
  
  if( error != nil )
  {

      notification.informativeText = [NSString stringWithFormat:@"%@\n%@", error.localizedDescription, error.localizedRecoverySuggestion ?: @""];
      
  }
  [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}



-(void)showSession:(Session*)session inCell:(SessionCell*)cell
{
  [cell.textField setStringValue:session.title];
  
  // Show info
  BOOL showProgress = NO;
  NSString *infoText = [NSString stringWithFormat:NSLocalizedString(@"Year: %@", @""), session.year];
  NSString *buttontitle = NSLocalizedString(@"Download", @"");
  BOOL buttonEnabled = YES;
  AudioExportTaskStatus status =  [self.exportManager statusForTaskWithVideoURL:session.videoURL];

  switch( status )
  {
    case NoTask:
    case Cancelled:
    case Failed:
      break;
    
    case FinishedOK:
      infoText = NSLocalizedString(@"Audio exported successfully", @"");
      buttonEnabled = NO;
      break;
    
    case Running:
      showProgress = YES;
      buttontitle = NSLocalizedString(@"Cancel", @"");
      break;

  }
  
  if( showProgress )
  {
    [cell.progressIndicator startAnimation:nil];
  }
  [cell.progressIndicator setHidden:!showProgress];
  [cell.infoTextField setHidden:showProgress];
  [cell.infoTextField setStringValue:infoText];
  [cell.button setTitle:buttontitle];
  [cell.button setEnabled:buttonEnabled];
}

-(void)updateCellForSession:(Session*)session
{
  NSInteger indexOfSession = [self.sessions indexOfObject:session];
  if( indexOfSession == NSNotFound )
    return;
  [self.tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:indexOfSession] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
}

@end


@implementation SessionListViewController(UIActions)
-(IBAction)searchFieldChanged:(id)sender
{
  [self loadSessionsWithQuery:[self.searchField stringValue] ];
}

-(void)pathControl:(NSPathControl *)pathControl willDisplayOpenPanel:(NSOpenPanel *)openPanel
{
  openPanel.canChooseDirectories = YES;
  openPanel.canChooseFiles = NO;
}

-(IBAction)downloadCancelButtonAction:(id)sender
{
  NSInteger row = [self.tableView rowForView:sender];
  if( row >= 0 && row < self.sessions.count )
  {
    Session *session = self.sessions[row];
    
    if( [self.exportManager statusForTaskWithVideoURL:session.videoURL] == Running )
    {
      // Cancel
      [self.exportManager stopTaskWithVideoURL:session.videoURL];
      
    }
    else
    {
      NSURL *videoURL = session.videoURL;
      NSURL *outputURL = [self outputURLForSession:session];
      
      
      [self.exportManager startTaskWithVideoURL:videoURL outputURL:outputURL completionBlock:^(NSError *error) {
        NSLog(@"%s. Task for %@ finished. Error: %@ ", __PRETTY_FUNCTION__, videoURL, error);
        dispatch_async(dispatch_get_main_queue(), ^{
          [self notifyExportedSession:session endedWithError:error];
          [self updateCellForSession:session];
        });
      }];
      
    }
    [self.tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:row] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
  }
}

@end


@implementation SessionListViewController(TableViewDelegateDataSource)

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
  return self.sessions.count;
}

-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
  
  return [self tableView:tableView isGroupRow:row] ? 20: tableView.rowHeight ;
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
  if( [self.sessions[row] isKindOfClass:[NSString class]] )
  {
    NSString *year = self.sessions[row];
    NSTableCellView * cell =  [tableView makeViewWithIdentifier:kHeaderCellID owner:nil];
    [cell.textField setStringValue:year];
    return cell;
  }
  else
  {
    Session * session = self.sessions[row];
    SessionCell * cell =  [tableView makeViewWithIdentifier:kSessionCellID owner:nil];
    [self showSession:session inCell:cell];
    return cell;
  }
  return nil;
}

-(BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row
{
  return [self.sessions[row] isKindOfClass:[NSString class]];
}



@end


