//
// Copyright (c) 2010 Yang Jiandong
// Licensed under Eclipse Public License version 1.0
//
// History:
//   yangjiandong 2010-9-30 - Initial Contribution
//


**
**
**
class TestBase:Test
{
  virtual CacheContext c:=TestContext.c
  
  Void execute(|->| f){
    log:=Pod.of(this).log
    level:=log.level
    try
    {
      log.level=LogLevel.debug
      c.db.open
      newTable(Student#)
      f()
    }
    catch (Err e)
    {
      throw e
    }
    finally
    {
      c.db.close
      log.level=level
    }
  }
  
  Void newTable(Type type){
    if(c.tableExists(type)){
      c.dropTable(type)
    }
    c.createTable(type)
    c.clearCache
  }
}
