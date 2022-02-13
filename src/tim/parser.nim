# ⚡️ High-performance compiled
# template engine inspired by Emmet syntax.
# 
# MIT License
# Copyright (c) 2022 George Lemon from OpenPeep
# https://github.com/openpeep/tim

import std/[json, jsonutils]
import ./lexer, ./tokens, ./ast
from std/strutils import `%`, isDigit

type
    Parser* = object
        lexer: Lexer
        prev, current, next: TokenTuple
        error: string
        statements: seq[HtmlNode]
        prevln, currln, nextln: int
        parentNode: HtmlNode

proc setError[T: Parser](p: var T, msg: string) = p.error = "Error ($2:$3): $1" % [msg, $p.current.line, $p.current.col]
proc hasError*[T: Parser](p: var T): bool = p.error.len != 0
proc getError*[T: Parser](p: var T): string = p.error

proc jump[T: Parser](p: var T, offset = 1) =
    var i = 0
    while offset > i: 
        p.prev = p.current
        p.current = p.next
        p.next = p.lexer.getToken()
        inc i

proc isElement(): bool =
    ## Determine if current token is an HTML Element
    ## TODO
    discard

proc isAttributeName(): bool =
    ## Determine if current token is an attribute name based on its siblings.
    ## For example `title` is by default considered an HTMLElement,
    ## but it can be an HTMLAttribute too.
    ## TODO
    discard

proc isInline[T: TokenTuple](token: T): bool =
    ## Determine if current token is an inliner HTML Node
    ## such as TK_SPAN, TK_EM, TK_I, TK_STRONG TK_LINK and so on.
    ## TODO
    discard

proc hasID[T: HtmlNode](node: T): bool {.inline.} =
    result = node.id != nil

proc getID[T: HtmlNode](node: T): string {.inline.} =
    result = if node.id != nil: node.id.value else: ""

proc toJsonStr(nodes: HtmlNode) =
    echo pretty(toJson(nodes))

template setHTMLAttributes[T: Parser](p: var T, htmlNode: HtmlNode): untyped =
    var id: IDAttribute
    while true:
        if p.current.kind == TK_ATTR_CLASS and p.next.kind == TK_IDENTIFIER:
            htmlNode.attributes.add(HtmlAttribute(name: "class", value: p.next.value))
            jump p, 2
        elif p.current.kind == TK_ATTR_ID and p.next.kind == TK_IDENTIFIER:
            if htmlNode.hasID():
                p.setError("Elements can hold a single ID attribute.")
            id = IDAttribute(value: p.next.value)
            jump p, 2
        elif p.current.kind == TK_IDENTIFIER and p.next.kind == TK_ASSIGN:
            let attrName = p.current.value
            jump p
            if p.next.kind != TK_STRING:
                p.setError("Missing value for \"$1\" attribute" % [attrName])
                break
            htmlNode.attributes.add(HtmlAttribute(name: attrName, value: p.next.value))
            jump p, 2
        elif p.current.kind == TK_CONTENT:
            if p.next.kind != TK_STRING:
                p.setError("Missing string content for \"$1\" node" % [p.prev.value])
                break
            else:
                let htmlTextNode = HtmlNode(
                    nodeType: HtmlText,
                    nodeName: getSymbolName(HtmlText),
                    text: p.next.value,
                    meta: (column: p.next.col, indent: p.next.wsno, line: p.next.line)
                )
                htmlNode.nodes.add(htmlTextNode)
            jump p
            break
        else: break
    if id != nil: htmlNode.id = id

proc nindent(depth: int = 0): int {.inline.} =
    result = if depth == 0: 0 else: 2 * depth

proc walk(p: var Parser) =
    ## Magically walk and collect HtmlNodes, assign HtmlAttributes
    ## for creating document node of the current timl page
    var ndepth = 0
    var htmlNode: HtmlNode
    while p.hasError() == false and p.current.kind != TK_EOF:
        while p.current.isNestable():
            let htmlNodeType = getHtmlNodeType(p.current)
            htmlNode = HtmlNode(
                nodeType: htmlNodeType,
                nodeName: getSymbolName(htmlNodeType),
                meta: (column: p.current.col, indent: nindent(ndepth), line: p.current.line)
            )
            jump p
            p.setHTMLAttributes(htmlNode)     # set available html attributes
            inc ndepth

        # Collects the parent HtmlNode which is a headliner
        # Set current HtmlNode as parentNode. This is the headliner
        # that wraps the entire line
        if htmlNode != nil and p.parentNode == nil:
            p.parentNode = htmlNode
        var lazySequence: seq[HtmlNode]
        var child, childNodes: HtmlNode
        while p.current.line == p.currln:
            if p.current.isNestable():
                let htmlNodeType = getHtmlNodeType(p.current)
                child = HtmlNode(
                    nodeType: htmlNodeType,
                    nodeName: getSymbolName(htmlNodeType),
                    meta: (column: p.current.col, indent: nindent(ndepth), line: p.current.line))
                jump p
                p.setHTMLAttributes(child)     # set available html attributes
                lazySequence.add(child)
                inc ndepth
            jump p
            if p.current.kind == TK_EOF: break

        if lazySequence.len != 0:
            var i = 0
            var maxlen = (lazySequence.len - 1)
            while true:
                if i == maxlen: break
                lazySequence[(maxlen - (i + 1))].nodes.add(lazySequence[^1])
                lazySequence.delete( (maxlen - i) )
                inc i
            childNodes = lazySequence[0]
        if childNodes != nil:
            p.parentNode.nodes.add(childNodes)
            childNodes = nil
        p.statements.add(p.parentNode)
        p.parentNode = nil

        if p.current.line > p.currln:
            p.prevln = p.currln
            p.currln = p.current.line
            ndepth = 0
    jump p

proc getStatements*[T: Parser](p: T): string = 
    ## Retrieve all HtmlNodes available in current document as stringified JSON
    # result = pretty(toJson(p.statements))
    result = ""

proc getStatements*[T: Parser](p: T, asNodes: bool): seq[HtmlNode] =
    ## Return all HtmlNodes available in current document
    result = p.statements

proc parse*(contents: string): Parser =
    var p: Parser = Parser(lexer: Lexer.init(contents))
    p.current = p.lexer.getToken()
    p.next    = p.lexer.getToken()
    p.currln = p.current.line
    p.walk()
    return p
