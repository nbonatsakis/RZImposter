//
//  RZHTTPRequestMatcherTests.m
//
// Copyright 2015 Raizlabs and other contributors
// http://raizlabs.com/
//
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

@import UIKit;
#import <XCTest/XCTest.h>
#import "NSURL+RZIExtensions.h"
#import "NSURLRequest+RZIExtensions.h"

@interface RZIExtensionsTests : XCTestCase

@end

@implementation RZIExtensionsTests

- (void)testTokenReplacedPathValuesFromPopulatedURL
{
    NSURL *templateURL = [NSURL URLWithString:@"/user/:userID/items/:itemID"];
    NSDictionary *params =
        [templateURL rzi_tokenReplacedPathValuesFromPopulatedURL:
                         [NSURL URLWithString:@"/user/21/items/1"]];

    expect(params).notTo.beNil();
    expect(params.count).to.equal(2);
    expect(params[@"userID"]).to.equal(@"21");
    expect(params[@"itemID"]).to.equal(@"1");
}

- (void)testTokenReplacedQueryValuesFromPopulatedURL
{
    NSURL *templateURL =
        [NSURL URLWithString:@"/user?userID=:userID&itemID=:itemID"];
    NSDictionary *params =
        [templateURL rzi_tokenReplacedQueryValuesFromPopulatedURL:
                         [NSURL URLWithString:@"/user?userID=21&itemID=1"]];
    expect(params).notTo.beNil();
    expect(params.count).to.equal(2);
    expect(params[@"userID"]).to.equal(@"21");
    expect(params[@"itemID"]).to.equal(@"1");
}

- (void)testMatchesRequestHeaders
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
        initWithURL:[NSURL URLWithString:@"http://google.com"]];
    [request setValue:@"bar" forHTTPHeaderField:@"foo"];
    [request setValue:@"abc" forHTTPHeaderField:@"auth"];

    NSDictionary *expected = @{ @"foo" : @"bar",
                                @"auth" : @"abc" };

    expect([request rzi_containsHeaders:expected]).to.beTruthy();
}

- (void)testMatchesRequestHeaders_DifferentContent
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
        initWithURL:[NSURL URLWithString:@"http://google.com"]];
    [request setValue:@"bar" forHTTPHeaderField:@"foo"];
    [request setValue:@"abc" forHTTPHeaderField:@"auth"];

    NSDictionary *expected = @{ @"foo" : @"bar",
                                @"auth" : @"abcdef" };

    expect([request rzi_containsHeaders:expected]).to.beFalsy();
}

- (void)testMatchesRequestHeaders_DifferentNumValues
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
        initWithURL:[NSURL URLWithString:@"http://google.com"]];
    [request setValue:@"bar" forHTTPHeaderField:@"foo"];

    NSDictionary *expected = @{ @"foo" : @"bar",
                                @"auth" : @"abcdef" };

    expect([request rzi_containsHeaders:expected]).to.beFalsy();
}

@end
