#! /usr/bin/env fan
//
// Copyright (c) 2010, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2010-9-22  Jed Young  Creation
//

using build
using slanWeb

class Build : build::BuildPod
{
  new make()
  {
    podName = "slanDemo"
    summary = "it's demo for slanweb"
    srcDirs = [`fan/`, `fan/action/`, `fan/jsfan/`]
    depends =
    [
      "sys 1.0",
      "webmod 1.0",
      "web 1.0",
      "compiler 1.0",
      "wisp 1.0",
      "concurrent 1.0",
      "slanWeb 1.0",
      "slanUtil 1.0",
      "dom 1.0",
      "gfx 1.0",
      "fwt 1.0",
      "util 1.0"
    ]
    resDirs =
    [
      `locale/`,
      `res/fwt/`
    ].addAll(Util.allDir(scriptDir.uri, `res/view/`)).
      addAll(Util.allDir(scriptDir.uri, `public/`))
  }
}