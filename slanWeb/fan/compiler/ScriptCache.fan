//
// Copyright (c) 2010, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2010-9-22  Jed Young  Creation
//

using web
using compiler

**
** cache for script by
**
internal const class ScriptCache
{
  protected const SingletonMap cache := SingletonMap()
  private const Log log := Pod.of(this).log

  Obj getOrAdd(File file, |File->Obj| f)
  {
    obj := getCache(file)
    if(obj == null)
    {
      obj = f(file)
      putCache(file, obj)
    }
    return obj
  }

  Void clear()
  {
    cache.clear
  }

  private Obj? getCache(File file)
  {
    key := file.toStr
    CacheObj? c := cache[key]
    if (c == null) return null

    //remove if out date
    if (!c.eq(file))
    {
      cache.remove(key)
      return null
    }

    if (log.isDebug)
      log.debug("using cache $key")

    return c.value
  }

  private Void putCache(File file, Obj value)
  {
    obj := CacheObj
    {
      modified = file.modified
      size = file.size
      it.value = value
    }
    cache[file.toStr] = obj

    if (log.isDebug)
      log.debug("put cache $file.toStr")
  }
}

**************************************************************************
** Script Cache Object
**************************************************************************

internal const class CacheObj
{
  const DateTime modified;
  const Int size;
  const Obj? value;

  Bool eq(File file)
  {
    if (this.modified != file.modified) return false
    if (this.size != file.size) return false
    return true
  }

  new make(|This| f)
  {
    f(this)
  }
}