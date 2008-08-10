/*!
@file NuAcornPlugin.m
@description The Nu Acorn plug-in.
@copyright Copyright (c) 2008 Neon Design Technology, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

#import <Cocoa/Cocoa.h>
#import <Nu/Nu.h>
#import "ACPlugin.h"

@interface NuAcornPlugin : NSObject <ACPlugin>
{

}

@end

@implementation NuAcornPlugin

+ (id) plugin
{
    return [[[self alloc] init] autorelease];
}

extern void NuInit();

- (void) willRegister:(id<ACPluginManager>)pluginManager
{
    NuInit();
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *main_path = [bundle pathForResource:@"acorn" ofType:@"nu"];
    if (main_path) {
        NSString *main = [NSString stringWithContentsOfFile:main_path];
        if (main) {
            id parser = [Nu parser];
            [parser setValue:pluginManager forKey:@"pluginManager"];
            id script = [parser parse:main];
            [parser eval:script];
        }
    }
}

- (void) didRegister
{

}

- (NSNumber*) worksOnShapeLayers:(id)userObject
{
    return [NSNumber numberWithBool:NO];
}

@end
