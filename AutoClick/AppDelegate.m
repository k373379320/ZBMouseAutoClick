//
//
//  AutoClick
//
//  Created by xzb on 2017/11/24.
//  Copyright © 2017年 lucas. All rights reserved.
//

#import "AppDelegate.h"
#import "ZBMouseTapModel.h"

@interface AppDelegate () <NSWindowDelegate,NSTableViewDelegate,NSTableViewDataSource>


@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTableView *recordTableView;
@property (nonatomic, strong) NSMutableArray <ZBMouseTapModel *>*recordMouseDataArray;
@property (nonatomic, strong) NSEvent *mEventMonitor;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger time;
@property (nonatomic, assign) BOOL begin;
@property (weak) IBOutlet NSTextField *countTextField;
@property (nonatomic, assign) NSInteger repeatCount;
@property (nonatomic, assign) NSInteger interval;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    
    self.recordMouseDataArray = [[NSMutableArray alloc] init];
    self.recordTableView.delegate = self;
    self.recordTableView.dataSource = self;
    
    [self observeMouse];
    self.time = 0;
    __weak typeof(self) weakSelf = self;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        if (!weakSelf.begin) {
            return ;
        }
        weakSelf.time++;
        weakSelf.interval++;
    }];
    
}
#pragma mark - 记录鼠标事件
- (void)observeMouse{
    __weak typeof(self) weakSelf = self;
    [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseDownMask|NSLeftMouseUpMask handler:^(NSEvent * _Nonnull event) {
        if (!weakSelf.begin) {
            return ;
        }
        if (event.type == NSLeftMouseDown) {
            NSLog(@"__按下");
            weakSelf.interval = 0;
        }
        if (event.type == NSLeftMouseUp) {
            NSLog(@"__松手");
            [weakSelf addEvent:event];
        }
    }];
}
- (void)addEvent:(NSEvent *)event{
    NSPoint p = [event locationInWindow];
    NSLog(@"__鼠标点击坐标_%@ 时长:%ld",NSStringFromPoint(p),self.interval);
    if (self.recordMouseDataArray.count == 0) {
        [self recoverTimer];
    }
    ZBMouseTapModel *model = [[ZBMouseTapModel alloc] init];
    
   
    p.y =  [NSScreen mainScreen].frame.size.height - p.y;
    model.point = p;
    model.pointStr = NSStringFromPoint(p);
    model.index = self.recordMouseDataArray.count;
    model.time = self.time;
    model.interval = self.interval;
    [self.recordMouseDataArray addObject:model];
    [self.recordTableView reloadData];
    [self recoverTimer];
    [self.recordTableView scrollRowToVisible:self.recordMouseDataArray.count - 1];
}
- (void)recoverTimer{
    self.time = 0;
}
#pragma mark - NSTableViewDelegate,NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.recordMouseDataArray.count;
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    NSTextField *view   = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 100, 30)];
    view.bordered       = NO;
    view.editable       = NO;
    ZBMouseTapModel *model = self.recordMouseDataArray[row];
    view.stringValue = [NSString stringWithFormat:@"NO: %ld  < %@ > time : %ld",model.index,model.pointStr,model.time];
    
    return view;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 30;
}
#pragma mark - 开始记录按钮
- (IBAction)startBtnClick:(NSButton *)sender {
    if (!self.begin) {
        [sender setTitle:@"停止记录"];
    }else{
        [sender setTitle:@"开始记录"];
    }
    self.begin = !self.begin;
    [self.recordMouseDataArray removeAllObjects];
    [self.recordTableView reloadData];
    self.time = 0;
    self.repeatCount =  self.countTextField.stringValue.integerValue;
    
}
#pragma mark - 开始执行
- (IBAction)executeBtnClick:(id)sender {
    self.begin =  NO;
    NSLog(@"准备进入循环,总共循环:%ld 次",self.repeatCount);
    [self startExecuteWithDataArray:[self.recordMouseDataArray mutableCopy]];
}

- (void)startExecuteWithDataArray:(NSMutableArray *)dataArray {
    if (dataArray.count < 1) {
        return;
    }
    NSLog(@"------------------------------------ 一次点击开始\n剩余执行队列:\n%@",dataArray);
    {
ZBMouseTapModel *model = [dataArray firstObject];
NSLog(@"-->准备点击%@",model);
CGPoint mousePoint = model.point;
CGEventRef click1_down = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseDown, mousePoint, kCGMouseButtonLeft);
CGEventPost(kCGHIDEventTap, click1_down);
CFRelease(click1_down);

__weak typeof(self) weakSelf = self;
CGFloat interval = [@(model.time) floatValue]/10.0f;
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    CGEventRef click1_up = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseUp, mousePoint, kCGMouseButtonLeft);
    CGEventPost(kCGHIDEventTap, click1_up);
    CFRelease(click1_up);
    [weakSelf completeOnceEventWithDataArray:dataArray];
});
        
    }
}

- (void)completeOnceEventWithDataArray:(NSMutableArray *)dataArray {
    NSLog(@"------------------------------------ 一次点击完成");
    NSLog(@"-->还剩下 :%ld 次",self.repeatCount);
    [dataArray removeObjectAtIndex:0];
    if (dataArray.count  <1 ) {
        [self completeAllEvent];
        return;
    }
    ZBMouseTapModel *nextModel = [dataArray firstObject];
    CGFloat interval = [@(nextModel.time) floatValue]/10.0f;
    NSLog(@"-->将在 %.2f 秒后 点击 %@", interval,NSStringFromPoint(nextModel.point));
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf startExecuteWithDataArray:dataArray];
    });
}

- (void)completeAllEvent{
    self.repeatCount--;
    if (self.repeatCount  < 1) {
        self.repeatCount = 0;
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self executeBtnClick:nil];
    });
}
#pragma mark - 重复次数
- (IBAction)countTextField:(id)sender {
}
@end

