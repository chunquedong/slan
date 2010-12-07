//
// Copyright (c) 2010, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2010-9-22  Jed Young  Creation
//

using webmod
using web

**
** javascript mod
**
const class FwtMod : WebMod
{
  const Uri dir
  const Uri[]? usings := null

  new make(Uri dir, Uri[]? usings := null)
  {
    this.dir = dir
    this.usings = usings
  }

  override Void onService()
  {
   // rel := req.modRel.relTo(`/`)
    //ps := dir + rel
    //File file := Config.cur.getUri(ps).get

    //res.headers["Content-Type"] = "text/html; charset=utf-8"
    //JsCompiler.render(res.out, file, usings, [:])
    typeName := req.uri.basename
    typeRes := ResourceHelper.i.findTypeUri(typeName, dir)
    if (typeRes is Str)
    {
      type := Pod.find(typeRes).type(typeName)
      res.headers["Content-Type"] = "text/html; charset=utf-8"
      JsCompiler.renderByType(res.out, typeRes, type.qname, usings, [:])
    }
    else
    {
      file := (typeRes as Uri).get
      res.headers["Content-Type"] = "text/html; charset=utf-8"
      JsCompiler.render(res.out, file, usings, [:])
    }
  }
}