//
//  ViewController.m
//  agent
//
//  Created by daniele on 22/12/16.
//  Copyright © 2016 MiSiedo. All rights reserved.
//

#import "ViewController.h"
#import <JSQMessagesViewController/JSQMessage.h>
#import <JSQMessagesViewController/JSQMessagesBubbleImage.h>
#import <JSQMessagesViewController/JSQMessagesBubbleImageFactory.h>
#import <JSQMessagesViewController/JSQMessagesTimestampFormatter.h>

#import <ApiAI/ApiAI.h>


static NSString* kSender = @"daniele";


@interface ViewController ()
@property (nonatomic, strong) NSMutableArray<JSQMessage*>* messages;
@property (nonatomic, strong) JSQMessagesBubbleImage* incomingBubbleImageData;
@property (nonatomic, strong) JSQMessagesBubbleImage* outgoingBubbleImageData;
@property(nonatomic, strong) ApiAI *apiAI;
- (void) sendToAiWithText:(NSString*)text;
@end


@implementation ViewController

- (NSMutableArray*) messages
{
    if (!_messages) {
        _messages = [NSMutableArray array];
    }
    return _messages;
}

- (JSQMessagesBubbleImage *)outgoingBubbleImageData
{
    if (!_outgoingBubbleImageData) {
        JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
        _outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor lightGrayColor]];
    }
    return _outgoingBubbleImageData;
}

- (JSQMessagesBubbleImage *)incomingBubbleImageData
{
    if (!_incomingBubbleImageData) {
        JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
        _incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor colorWithRed:92/255.0 green:186/255.0 blue:225/255.0 alpha:1.0]];
    }
    return _incomingBubbleImageData;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    self.senderId = kSender;
    self.senderDisplayName = @"daniele";
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    [super viewDidLoad];
    
    self.apiAI = [[ApiAI alloc] init];
    id <AIConfiguration> configuration = [[AIDefaultConfiguration alloc] init];
    configuration.clientAccessToken = @"2c0878d8ec794b4790bf3038aa2c92f4";
    
    self.apiAI.configuration = configuration;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.messages[indexPath.row];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.messages.count;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date
{
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
                                             senderDisplayName:senderDisplayName
                                                          date:date
                                                          text:text];
    
    [self.messages addObject:message];
    [self sendToAiWithText:text];
    [self finishSendingMessageAnimated:YES];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessagesCollectionViewCell* cell = [super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    JSQMessage* msg = self.messages[indexPath.row];
    
    if ([msg.senderId isEqualToString:kSender]) {
        cell.textView.textColor = [UIColor whiteColor];
    } else {
        cell.textView.textColor = [UIColor whiteColor];
    }
    return cell;
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.outgoingBubbleImageData;
    }
    
    return self.incomingBubbleImageData;
}

- (void) sendToAiWithText:(NSString*)text
{
    AITextRequest *request = [self.apiAI textRequest];
    request.query = @[text];
    __weak typeof(self) weakSelf = self;
    [request setCompletionBlockSuccess:^(AIRequest *request, id response) {
        NSDictionary* resp = (NSDictionary*)response;
        JSQMessage *message = [[JSQMessage alloc] initWithSenderId:@"Adam"
                                                 senderDisplayName:@"Adam"
                                                              date:[NSDate date]
                                                              text:resp[@"result"][@"fulfillment"][@"speech"]];
        
        [weakSelf.messages addObject:message];
        [weakSelf.collectionView reloadData];
    } failure:^(AIRequest *request, NSError *error) {
        NSLog(@"%@", error);
    }];
    
    [_apiAI enqueue:request];
}


@end
