//
//  main.m
//  EditWithX
//
//  Created by fukayatsu on 2013/10/05.
//  Copyright (c) 2013年 fukayatsu. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <MacRuby/MacRuby.h>

int main(int argc, const char * argv[])
{
    return macruby_main("rb_main.rb", argc, argv);
}
