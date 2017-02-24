/*
 * Copyright 2016 Wizcorp
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Cordova/CDV.h>
#import "CordovaPluginMemoryAlert.h"

@implementation CordovaPluginMemoryAlert

- (void)pluginInitialize
{
    activated = FALSE;
    memoryWarningEventName = @"cordova-plugin-memory-alert.memoryWarning";
    escapedMemoryWarningEventName = [memoryWarningEventName stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
}

- (void)activate:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    activated = [[command argumentAtIndex:0] boolValue];
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    NSLog(@"cordova-plugin-memory-alert: %@", activated ? @"activated" : @"disabled");
}

- (void)setEventName:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString *eventName = [command.arguments objectAtIndex:0];

    if (eventName != nil && [eventName length] > 0) {
        memoryWarningEventName = eventName;
        escapedMemoryWarningEventName = [memoryWarningEventName stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        NSLog(@"cordova-plugin-memory-alert: setting event name to %@", memoryWarningEventName);
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        NSLog(@"cordova-plugin-memory-alert: unable to set event name");
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)onMemoryWarning
{
    
    //struct mach_task_basic_info info;
    //mach_msg_type_number_t size = sizeof(info);
    //kern_return_t kerr = task_info(mach_task_self(), MACH_TASK_BASIC_INFO, (task_info_t)&info, &size);
    //if (kerr == KERN_SUCCESS)
    //{
        float used_bytes = 100; //info.resident_size;
        float total_bytes = 200; //[NSProcessInfo processInfo].physicalMemory;
        float percent = used_bytes / total_bytes;
        //NSLog(@"Used: %f MB out of %f MB (%f%%)", used_bytes / 1024.0f / 1024.0f, total_bytes / 1024.0f / 1024.0f, used_bytes * 100.0f / total_bytes);
    //}
    //[self.commandDelegate evalJs:@"alert('memwarn')"];
    if (!activated) return;
    NSString *jsCommand = [@[@"nativeWarning('", escapedMemoryWarningEventName, @"',{'percent':", @(percent), @", 'used':", @(used_bytes), @"});"] componentsJoinedByString:@""];
    [self.commandDelegate evalJs:jsCommand];
    NSLog(@"cordova-plugin-memory-alert: did received a memory warning, emitting `%@` on window", memoryWarningEventName);
}


@end
