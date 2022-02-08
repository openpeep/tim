import std/[json, jsonutils]
import ./lexer, ./tokens, ./ast
from std/strutils import `%`

type
    Parser* = object
        lexer: Lexer
        prev, current, next: TokenTuple
        error: string
        statements: seq[HtmlNode]

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

proc isNestable[T: TokenTuple](token: T): bool =
    ## Determine if current token can contain more nodes
    return token.kind in {TK_ARTICLE, TK_DIV, TK_SECTION}

proc walk(p: var Parser, parentNode: HtmlNode = nil) =
    var htmlNode: HtmlNode
    while p.hasError() == false and p.current.kind != TK_EOF:
        if p.current.isNestable():
            let htmlNodeType = getHtmlNodeType(p.current)
            htmlNode = HtmlNode(nodeType: htmlNodeType, nodeName: getSymbolName(htmlNodeType))
            var attrs: seq[HtmlAttribute]
            var id: IDAttribute
            jump p # jump from div
            while true:
                if p.current.kind == TK_ATTR_CLASS and p.next.kind == TK_IDENTIFIER:
                    attrs.add(HtmlAttribute(name: "class", value: p.next.value))
                elif p.current.kind == TK_ATTR_ID and p.next.kind == TK_IDENTIFIER:
                    id = IDAttribute(value: p.next.value)
                elif p.current.kind == TK_IDENTIFIER and p.next.kind == TK_ASSIGN:
                    let attrName = p.current.value
                    jump p
                    if p.next.kind != TK_STRING:
                        p.setError("Missing value for \"$1\" attribute" % [attrName])
                        break
                    attrs.add(HtmlAttribute(name: attrName, value: p.next.value))
                else: break
                jump p, 2

            htmlNode.attributes = attrs     # set available html attributes
            htmlNode.id = id                # set ID html attribute or null

            if p.current.kind == TK_NEST_OP:
                p.walk(htmlNode)
    
            if parentNode != nil: parentNode.nodes.add(htmlNode)

        if parentNode == nil:
            p.statements.add(htmlNode)
        jump p

proc getStatements*[T: Parser](p: var T): string = 
    return pretty(toJson(p.statements))

proc parse*(contents: string): Parser =
    var p: Parser = Parser(lexer: Lexer.init(contents))
    p.current = p.lexer.getToken()
    p.next    = p.lexer.getToken()
    p.walk()
    return p
