//
// Copyright (c) 2010, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2010-9-22  Jed Young  Creation
//

using compiler

**
** err show
**
const class TemplateErr : Err
{
  const CompilerErr err
  const Str source
  const File file

  new make(CompilerErr err, Str source, File file) : super(err.msg, err)
  {
    this.err = err
    this.source = source
    this.file = file
  }

  Str dump()
  {
    colorSource := dumpSource(source, err.line, err.col)

    //new line
    line := err.line - 9
    col := err.col - 23

    s:="""<html>
            <head><title>template error</title></head>
            <body>
              <h1>TemplateErr: $err.msg</h1>
              <h2>$file.toStr ($line,$col)
              </h2>
              <p>$colorSource</p>
            </body>
          </html>"""
    return s
  }

  //dump error source
  private Str dumpSource(Str source, Int line, Int col)
  {
    line -= 1//to base 0
    lines := source.splitLines

    errorLine := """<span style="background-color:red; font-weight:bold;">${replace(lines[line])}</span>"""
    errorCursor := Str.spaces(col) + "^\n"
    above := replace(lines[0..<line].join("\n"))
    below := replace(lines[line+1..-1].join("\n"))
    code := """<div style="background-color:#aaa">
               <code><pre>
               $above
               $errorLine
               $errorCursor
               $below
               </pre></code>
               </div>"""
    return code + "<p>by slanweb</p>"
  }

  private Str replace(Str s)
  {
    s.replace("<","&lt;").replace(">","&gt;")
  }
}