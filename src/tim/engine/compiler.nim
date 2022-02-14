# High-performance, compiled template engine inspired by Emmet syntax.
# 
# MIT License
# Copyright (c) 2022 George Lemon from OpenPeep
# https://github.com/openpeep/tim

import ./ast
from ./parser import Parser
from std/strutils import toLowerAscii, `%`, indent

type
    Compiler* = object
        minified: bool
        nodes: seq[HtmlNode]
        solved: int
        html: string

proc indentIfEnabled[T: Compiler](c: var T, meta: MetaNode, fixTail = false) =
    if c.minified == false:
        if meta.column != 0 and meta.indent != 0:
            add c.html, "\n".indent( if fixTail: (meta.indent - 2) else: meta.indent )

proc hasNodes[T: HtmlNode](node: T): bool =
    ## Determine if current HtmlNode has any child nodes
    result = node.nodes.len != 0

proc hasAttributes[T: HtmlNode](node: T): bool =
    ## Determine if current HtmlNode has any HTML attributes attached 
    result = node.attributes.len != 0

proc writeAttributes[T: Compiler](c: var T, node: HtmlNode) =
    ## Inser HTML Attributes to current HtmlNode
    let total: int = (node.attributes.len - 1)
    for k, attr in node.attributes.pairs():
        add c.html, ("$1=\"$2\"" % [attr.name, attr.value]).indent(1)
        # if k != total: add c.html, " "

proc hasIDAttribute[T: HtmlNode](node: T): bool =
    ## Determine if current HtmlNode has an HTML ID attribute attached to it
    result = node.id != nil

proc writeIDAttribute[T: Compiler](c: var T, node: HtmlNode) =
    ## Insert ID HTML attribute to current HtmlNode
    add c.html, ("id=\"$1\"" % [node.id.value]).indent(1)

proc writeTagStart[T: Compiler](c: var T, node: HtmlNode) =
    ## Open tag of the current HtmlNode element
    ## TODO Handle indentation when minification disabled
    c.indentIfEnabled(node.meta)
    add c.html, "<" & toLowerAscii(node.nodeName)
    if node.hasIDAttribute():   c.writeIDAttribute(node)
    if node.hasAttributes():    c.writeAttributes(node)
    add c.html, ">"

proc writeTagEnd[T: Compiler](c: var T, node: HtmlNode, fixTail = false) =
    ## Close the current HtmlNode element
    ## TODO Handle self closers in HtmlNode based on HtmlNodeType
    ## TODO Handle indentation when minification disabled
    add c.html, "</" & toLowerAscii(node.nodeName) & ">"
    c.indentIfEnabled(node.meta, true)

proc writeText[T: Compiler](c: var T, node: HtmlNode) =
    ## Add HtmlNode to final HTML output
    add c.html, node.text

proc getHtml*[T: Compiler](c: T): string =
    ## Return compiled timl as html. By default the output is minfied,
    ## Set `minified` to `false` for regular output.
    result = c.html

proc program[T: Compiler](c: var T, childNodes: seq[HtmlNode] = @[], fixBr = false) =
    ## Start "compile" the current HtmlNode document
    var i = 0
    let nodeseq = if childNodes.len == 0: c.nodes else: childNodes
    while i < nodeseq.len:
        let mainNode: HtmlNode = nodeseq[i]
        if mainNode.nodeType == HtmlText:
            c.writeText(mainNode)
        else:
            if fixBr: add c.html, "\n"
            c.writeTagStart(mainNode)                   # start tag
            if mainNode.hasNodes():                     # parse child nodes, if any
                c.program(mainNode.nodes)
            c.writeTagEnd(mainNode, true)               # end tag
        inc i

proc init*[T: typedesc[Compiler]](compiler: T, parser: Parser, minified = true): Compiler =
    ## By default, Tim engine output is pure minified.
    ## Set `minified` to false to disable this feature.
    var c = compiler(nodes: parser.getStatements(asNodes = true), minified: minified)
    c.program(fixBr = true)
    result = c