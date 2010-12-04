//
// Copyright (c) 2010, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2010-9-22  Jed Young  Creation
//

using web
using concurrent

**
** enhanced Weblet for rendering template.
**
mixin SlanWeblet
{
//////////////////////////////////////////////////////////////////////////
// Request/Response
//////////////////////////////////////////////////////////////////////////

  **
  ** The WebReq instance for this current web request.  Raise an exception
  ** if the current actor thread is not serving a web request.
  **
  static WebReq req()
  {
    try
      return Actor.locals["web.req"]
    catch (NullErr e)
      throw Err("No web request active in thread")
  }

  **
  ** The WebRes instance for this current web request.  Raise an exception
  ** if the current actor thread is not serving a web request.
  **
  static WebRes res()
  {
    try
      return Actor.locals["web.res"]
    catch (NullErr e)
      throw Err("No web request active in thread")
  }

//////////////////////////////////////////////////////////////////////////
// template method
//////////////////////////////////////////////////////////////////////////

  **
  ** render the template
  **
  Void render(Uri html, |->|? lay := null)
  {
    file := Config.cur.getUri(`view/` + html).get
    TemplateCompiler.instance.render(file, lay)
  }

  **
  ** compile js file.
  **
  Str compileJs(Uri fwt, Uri[]? usings := null,
    Str:Str env := ["fwt.window.root":"fwt-root"])
  {
    file := Config.cur.getUri(`fwt/` + fwt).get
    strBuf := StrBuf()
    JsCompiler.render(WebOutStream(strBuf.out), file, usings, env)
    return strBuf.toStr
  }

//////////////////////////////////////////////////////////////////////////
// tools
//////////////////////////////////////////////////////////////////////////

  **
  ** text/html; charset=utf-8
  **
  Void writeContentType()
  {
    res.headers["Content-Type"] = "text/html; charset=utf-8"
  }

  ** go back to referer uri
  Void goback()
  {
    Str uri := req.headers["Referer"]
    res.redirect(uri.toUri)
  }

  ** convert method to uri
  Uri getUri(Type type, Method? method := null, Str? id := null)
  {
    uri := "/action/$type.name"
    if (method != null)
    {
      uri += "/$method.name"
    }
    if (id != null)
    {
      uri += "/$id"
    }
    return uri.toUri
  }

  ** id is the last word of uri
  Str? stashId()
  {
    req.stash["_stashId"]
  }

  ** req.stash[]
  const static ReqStash m := ReqStash()
}


**************************************************************************
** ReqStash
**************************************************************************

**
** wrap for req.stash
**
const class ReqStash : SlanWeblet
{
  ** call req.stash[name]
  override Obj? trap(Str name, Obj?[]? args)
  {
    if (args.size == 0) { return req.stash.get(name) }
    if (args.size == 1) { req.stash.set(name, args.first); return null }
    return super.trap(name, args)
  }
}