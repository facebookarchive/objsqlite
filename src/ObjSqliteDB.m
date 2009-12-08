// Copyright 2009 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may
// not use this file except in compliance with the License. You may obtain
// a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
// License for the specific language governing permissions and limitations
// under the License.

#import "ObjSqliteDB.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation ObjSqliteDB


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithPath:(NSString*)path {
  if (self = [super init]) {
    _path = [path retain];
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  @synchronized(self) {
    [_path release];
    _path = nil;
    [self close];
  }

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)close {
  @synchronized(self) {
    [_createStatement release];
    _createStatement = nil;

    if (nil != _db) {
      sqlite3_close(_db);
      _db = nil;
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (int)lastErrorCode {
  return sqlite3_errcode(_db);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)lastErrorMessage {
  return [NSString stringWithCString:sqlite3_errmsg(_db)];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)dbExists {
  return [[NSFileManager defaultManager] fileExistsAtPath:_path];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (ObjSqliteStatement*)createStatement {
  @synchronized(self) {
    if (nil == _createStatement && nil != _createSQL) {
      _createStatement = [[ObjSqliteStatement alloc] initWithSQL:_createSQL db:self];
    }
  }

  return _createStatement;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (sqlite3*)sqliteDB {
  @synchronized(self) {
    if (nil == _db && nil != _path) {
      // We need to check the existence of the db before sqlite3_open creates it.
      BOOL needsCreation = ![self dbExists];

      if (SQLITE_OK == sqlite3_open([_path UTF8String], &_db)) {
        // DB's been opened, now create the tables if necessary.

        if (needsCreation && nil != self.createStatement) {
          if ([self.createStatement step]) {
            [self.createStatement resetStatement];

          } else {
            sqlite3_close(_db);
            _db = nil;
          }
        }
      }
    }
  }

  return _db;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setCreateSQL:(const char*)sql {
  @synchronized(self) {
    [_createStatement release];
    _createStatement = nil;

    _createSQL = sql;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (const char*)createSQL {
  return _createSQL;
}


@end
