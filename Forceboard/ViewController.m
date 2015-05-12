//
//  ViewController.m
//  Forceboard
//
//  Created by 修敏傑 on 2015/5/11.
//  Copyright (c) 2015年 jessehsiu. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize sensor;
- (void)viewDidLoad {
    [super viewDidLoad];
    sensor = [[SerialGATT alloc] init];
    [sensor setup];
    sensor.delegate = self;
    
    discoveredBLEs = [[NSMutableArray alloc]init];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)scanHMSoftDevices:(id)sender {
    
    //UI stuff
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [tableview setAlpha:1.0];
    [UIView commitAnimations];
    
    
    
    if ([sensor activePeripheral]) {
        if (sensor.activePeripheral.state == CBPeripheralStateConnected) {
            [sensor.manager cancelPeripheralConnection:sensor.activePeripheral];
            sensor.activePeripheral = nil;
        }
    }
    
    if ([sensor peripherals]) {
        sensor.peripherals = nil;
    }
    
    sensor.delegate = self;
    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(scanTimer:) userInfo:nil repeats:NO];
    
    [sensor findHMSoftPeripherals:10];
}

#pragma mark - tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [discoveredBLEs count];

}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = ((CBPeripheral *)[discoveredBLEs objectAtIndex:indexPath.row]).name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    
    sensor.activePeripheral = [discoveredBLEs objectAtIndex:row];
    [sensor connect:sensor.activePeripheral];
    [self stopScanning];
    
    
    //UI stuff
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [tableview setAlpha:0];
    [searchBtn setAlpha:0];
    [UIView commitAnimations];
}

-(void)scanTimer:(NSTimer *)timer
{
    [self stopScanning];
}

-(void)stopScanning
{
    [sensor stopScan];
    [discoveredBLEs removeAllObjects];
}

#pragma mark - HMSoftSensorDelegate
-(void) peripheralFound:(CBPeripheral *)peripheral
{
    if (![discoveredBLEs containsObject:peripheral]) {
        [discoveredBLEs addObject:peripheral];
    }
    
}

- (void) serialGATTCharValueUpdated: (NSString *)UUID value: (NSData *)data
{
    NSString *value = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSLog(@"%@",value);
}

#pragma mark - HMSoftSendingFunction
-(void)sendStringToArduino:(NSString*)string{
    NSData *data = [string dataUsingEncoding:[NSString defaultCStringEncoding]];
    if(data.length > 20)
    {
        int i = 0;
        while ((i + 1) * 20 <= data.length) {
            NSData *dataSend = [data subdataWithRange:NSMakeRange(i * 20, 20)];
            [sensor write:sensor.activePeripheral data:dataSend];
            i++;
        }
        i = data.length % 20;
        if(i > 0)
        {
            NSData *dataSend = [data subdataWithRange:NSMakeRange(data.length - i, i)];
            [sensor write:sensor.activePeripheral data:dataSend];
        }
        
    }else
    {
        //NSData *data = [MsgToArduino.text dataUsingEncoding:[NSString defaultCStringEncoding]];
        [sensor write:sensor.activePeripheral data:data];
    }
}


@end
