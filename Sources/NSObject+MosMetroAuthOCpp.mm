//
//  NSObject+MosMetroAuthOCpp.m
//  mauth
//
//  Created by Marat S. on 21/03/16.
//  Copyright © 2016 m4rr. All rights reserved.
//

#import "NSObject+MosMetroAuthOCpp.h"
#include <tuple>

#include <string>

//class CppObject
//{
//public:
//  void ExampleMethod(const std::string &str);
//  CppObject();
//  ~CppObject();
//
//};


@implementation MyClass

- (BOOL)getLat:(double &)lat lon:(double &)lon {
  return lat == lon;
}

- (std::pair<double, double>)getLatLon {
  return std::make_pair(0, 0);
}

@end
