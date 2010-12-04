//
// Copyright (c) 2010, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2010-9-22  Jed Young  Creation
//

using slanWeb::SlanRouteMod
using slanWeb::Config
using slanWeb::LogedMod
using wisp
using util

**
** Main
**
class Main : AbstractMain
{
  override Int run()
  {
    Config.cur.toProductMode(Main#.pod.name)
    pod := Main#.pod
    wisp := WispService
    {
      it.port = pod.config("port", "8080").toInt
      it.root = LogedMod(SlanRouteMod())
    }
    return runServices([wisp])
  }
}