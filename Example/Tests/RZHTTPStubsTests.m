//
//  RZHTTPStubsTests.m
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
#import "RZIHost.h"
#import "RZIRoutes.h"
#import "OHHTTPStubsResponse+JSON.h"
#import "AFHTTPSessionManager.h"

@interface RZHTTPStubsTests : XCTestCase

@property (strong, nonatomic) RZIHost *host;
@property (strong, nonatomic) AFHTTPSessionManager *sessionmanager;

@end

@implementation RZHTTPStubsTests

- (void)setUp
{
    [super setUp];

    self.sessionmanager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://google.com"]];
    self.host = [[RZIHost alloc] initWithBaseURL:[NSURL URLWithString:@"http://google.com"]];
}

- (void)testGet_NoParams
{
    RZIRoutes *routes = [[RZIRoutes alloc] init];
    [routes get:@"/users"
             do:^OHHTTPStubsResponse *(NSURLRequest *request,
                                       NSDictionary *requestInfo) {
                 OHHTTPStubsResponse *response =
                     [OHHTTPStubsResponse responseWithJSONObject:@{
                         @"key" : @44
                     } statusCode:201 headers:@{
                         @"Content-Type" : @"application/json"
                     }];
                 return response;
             }];

    [self.host registerRoutes:routes];

    __block BOOL success = NO;
    [self.sessionmanager GET:@"/users" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        success = YES;
        expect(responseObject).notTo.beNil();
        expect(responseObject[@"key"]).to.equal(@44);
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        expect(response.statusCode).to.equal(201);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        XCTFail(@"Failed request, error: %@", error);
    }];

    expect(success).will.beTruthy();
}

- (void)testGet_NoRoute
{
    RZIRoutes *routes = [[RZIRoutes alloc] init];
    [routes get:@"/users"
             do:^OHHTTPStubsResponse *(NSURLRequest *request, NSDictionary *requestInfo) {
                 OHHTTPStubsResponse *response = [OHHTTPStubsResponse responseWithJSONObject:@{
                         @"key" : @44
                     } statusCode:201 headers:@{
                         @"Content-Type" : @"application/json"
                     }];
                 return response;
             }];

    [self.host registerRoutes:routes];

    __block BOOL failed = NO;
    [self.sessionmanager GET:@"/contacts" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        XCTFail(@"Test should fail, shouldn't find route");
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failed = YES;
    }];

    expect(failed).will.beTruthy();
}

- (void)testGet_PathParamsMatch
{
    RZIRoutes *routes = [[RZIRoutes alloc] init];
    [routes get:@"/users/:userID/items/:itemID"
             do:^OHHTTPStubsResponse *(NSURLRequest *request, NSDictionary *requestInfo) {
                 NSDictionary *pathParams = requestInfo[kRZIRequestPathParametersKey];
                 NSString *userID = pathParams[@"userID"];
                 expect(userID).to.equal(@"44");

                 NSString *itemID = pathParams[@"itemID"];
                 expect(itemID).to.equal(@"2");

                 OHHTTPStubsResponse *response = [OHHTTPStubsResponse responseWithJSONObject:@{
                         @"userID" : @([userID intValue])
                     } statusCode:201 headers:@{
                         @"Content-Type" : @"application/json"
                     }];
                 return response;
             }];

    [self.host registerRoutes:routes];

    __block BOOL success = NO;
    [self.sessionmanager GET:@"/users/44/items/2" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        success = YES;
        expect(responseObject).notTo.beNil();
        expect(responseObject[@"userID"]).to.equal(@44);
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        expect(response.statusCode).to.equal(201);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        XCTFail(@"Failed request, error: %@", error);
    }];

    expect(success).will.beTruthy();
}

- (void)testGet_QueryParamsMatch
{
    RZIRoutes *routes = [[RZIRoutes alloc] init];
    [routes get:@"/users"
             do:^OHHTTPStubsResponse *(NSURLRequest *request, NSDictionary *requestInfo) {
                 NSDictionary *queryParams = requestInfo[kRZIRequestQueryParametersKey];
                 NSString *userID = queryParams[@"userID"];
                 expect(userID).to.equal(@"44");

                 OHHTTPStubsResponse *response = [OHHTTPStubsResponse responseWithJSONObject:@{
                         @"userID" : @([userID intValue])
                     } statusCode:201 headers:@{
                         @"Content-Type" : @"application/json"
                     }];
                 return response;
             }];

    [self.host registerRoutes:routes];

    __block BOOL success = NO;
    [self.sessionmanager GET:@"/users?userID=44" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        success = YES;
        expect(responseObject).notTo.beNil();
        expect(responseObject[@"userID"]).to.equal(@44);
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        expect(response.statusCode).to.equal(201);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        XCTFail(@"Failed request, error: %@", error);
    }];

    expect(success).will.beTruthy();
}

- (void)testGet_MatchHeaders
{
    RZIRoutes *routes = [[RZIRoutes alloc] init];
    NSDictionary *matchDict = @{
        kRZIRequestMatchHeadersKey : @{@"foo" : @"bar"}
    };
    [routes get:@"/users"
          match:matchDict
             do:^OHHTTPStubsResponse *(NSURLRequest *request, NSDictionary *requestInfo) {
                 OHHTTPStubsResponse *response = [OHHTTPStubsResponse responseWithJSONObject:@{
                         @"key" : @44
                     } statusCode:201 headers:@{
                         @"Content-Type" : @"application/json"
                     }];
                 return response;
             }];

    [self.host registerRoutes:routes];

    [self.sessionmanager.requestSerializer setValue:@"bar"
                                 forHTTPHeaderField:@"foo"];

    __block BOOL success = NO;
    [self.sessionmanager GET:@"/users" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        success = YES;
        expect(responseObject).notTo.beNil();
        expect(responseObject[@"key"]).to.equal(@44);
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        expect(response.statusCode).to.equal(201);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        XCTFail(@"Failed request, error: %@", error);
    }];

    expect(success).will.beTruthy();
}

- (void)testGet_MatchHeadersBadValue
{
    RZIRoutes *routes = [[RZIRoutes alloc] init];
    NSDictionary *matchDict = @{
        kRZIRequestMatchHeadersKey : @{@"foo" : @"bar"}
    };
    [routes get:@"/users"
          match:matchDict
             do:^OHHTTPStubsResponse *(NSURLRequest *request, NSDictionary *requestInfo) {
                 OHHTTPStubsResponse *response = [OHHTTPStubsResponse responseWithJSONObject:@{
                         @"key" : @44
                     } statusCode:201 headers:@{
                         @"Content-Type" : @"application/json"
                     }];
                 return response;
             }];

    [self.host registerRoutes:routes];

    [self.sessionmanager.requestSerializer setValue:@"badVal"
                                 forHTTPHeaderField:@"foo"];

    __block BOOL failed = NO;
    [self.sessionmanager GET:@"/users" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        XCTFail(@"Reuqest should fail");
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failed = YES;
    }];

    expect(failed).will.beTruthy();
}

@end
