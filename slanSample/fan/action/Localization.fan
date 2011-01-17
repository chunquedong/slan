//
// Copyright (c) 2010, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2010-9-22  Jed Young  Creation
//

using web
using slanWeb
using slanUtil

**
** route and template
**
class Localization : SlanWeblet
{
  Void index()
  {
    render
  }

  override Obj? onInvoke(Str name, Obj?[]? args)
  {
    return this.trap(name, args)
  }
}