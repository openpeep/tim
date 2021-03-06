# High-performance, compiled template engine inspired by Emmet syntax.
# 
# MIT License
# Copyright (c) 2022 George Lemon from OpenPeep
# https://github.com/openpeep/tim

from std/strutils import toUpperAscii, startsWith
from std/enumutils import symbolName, symbolRank
from std/json import JsonNode, JsonNodeKind
# from ./lexer import TokenTuple
from ./tokens import TokenKind, TokenTuple

type
    HtmlNodeType* = enum
        HtmlDoctype
        HtmlA
        HtmlAbbr
        HtmlAcronym
        HtmlAddress
        HtmlApplet
        HtmlArea
        HtmlArticle
        HtmlAside
        HtmlAudio
        HtmlB
        HtmlBase
        HtmlBasefont
        HtmlBdi
        HtmlBdo
        HtmlBig
        HtmlBlockquote
        HtmlBody
        HtmlBr
        HtmlButton
        HtmlCanvas
        HtmlCaption
        HtmlCenter
        HtmlCite
        HtmlCode
        HtmlCol
        HtmlColgroup
        HtmlData
        HtmlDatalist
        HtmlDd
        HtmlDel
        HtmlDetails
        HtmlDfn
        HtmlDialog
        HtmlDir
        HtmlDiv
        HtmlDl
        HtmlDt
        HtmlEm
        HtmlEmbed
        HtmlFieldset
        HtmlFigcaption
        HtmlFigure
        HtmlFont
        HtmlFooter
        HtmlForm
        HtmlFrame
        HtmlFrameset
        HtmlH1
        HtmlH2
        HtmlH3
        HtmlH4
        HtmlH5
        HtmlH6
        HtmlHead
        HtmlHeader
        HtmlHr
        HtmlHtml
        HtmlI
        HtmlIframe
        HtmlImg
        HtmlInput
        HtmlIns
        HtmlKbd
        HtmlLabel
        HtmlLegend
        HtmlLi
        HtmlLink
        HtmlMain
        HtmlMap
        HtmlMark
        HtmlMeta
        HtmlMeter
        HtmlNav
        HtmlNoframes
        HtmlNoscript
        HtmlObject
        HtmlOl
        HtmlOptgroup
        HtmlOption
        HtmlOutput
        HtmlP
        HtmlParam
        HtmlPre
        HtmlProgress
        HtmlQ
        HtmlRp
        HtmlRT
        HtmlRuby
        HtmlS
        HtmlSamp
        HtmlScript
        HtmlSection
        HtmlSelect
        HtmlSmall
        HtmlSource
        HtmlSpan
        HtmlStrike
        HtmlStrong
        HtmlStyle
        HtmlSub
        HtmlSummary
        HtmlSup
        #
        # AST SVG Support
        #
        HtmlSvg
        HtmlSvgAnimate
        HtmlSvgAnimateMotion
        HtmlSvgAnimateTransform
        HtmlSvgCircle
        HtmlSvgClipPath
        HtmlSvgDefs
        HtmlSvgDesc
        HtmlSvgDiscard
        HtmlSvgEllipse
        HtmlSvgFeBlend
        HtmlSvgFeColorMatrix
        HtmlSvgFeComponentTransfer
        HtmlSvgFeComposite
        HtmlSvgFeConvolveMatrix
        HtmlSvgFeDiffuseLighting
        HtmlSvgFeDisplacementMap
        HtmlSvgFeDistantMap
        HtmlSvgFeDistantLight
        HtmlSvgFeDropShadow
        HtmlSvgFeFlood
        HtmlSvgFeFuncA
        HtmlSvgFeFuncB
        HtmlSvgFeFuncG
        HtmlSvgFeFuncR
        HtmlSvgFeGaussianBlur
        HtmlSvgFeImage
        HtmlSvgFeMerge
        HtmlSvgFeMorphology
        HtmlSvgFeOffset
        HtmlSvgFePointLight
        HtmlSvgFeSpecularLighting
        HtmlSvgFeSpotLight
        HtmlSvgFeTitle
        HtmlSvgFeTurbulence
        HtmlSvgFilter
        HtmlSvgForeignObject
        HtmlSvgG
        HtmlSvgHatch
        HtmlSvgHatchPath
        HtmlSvgImage
        HtmlSvgLine
        HtmlSvgLinearGradient
        HtmlSvgMarker
        HtmlSvgMask
        HtmlSvgMetadata
        HtmlSvgMPath
        HtmlSvgPath
        HtmlSvgPattern
        HtmlSvgPolygon
        HtmlSvgPolyline
        HtmlSvgRadialGradient
        HtmlSvgRect
        HtmlSvgSet
        HtmlSvgStop
        HtmlSvgSwitch
        HtmlSvgSymbol
        HtmlSvgText
        HtmlSvgTextpath
        HtmlSvgTspan
        HtmlSvgUse
        HtmlSvgView

        HtmlText
        HtmlTable
        HtmlTbody
        HtmlTd
        HtmlTemplate
        HtmlTfoot
        HtmlTh
        HtmlThead
        HtmlTime
        HtmlTitle
        HtmlTr
        HtmlTrack
        HtmlTt
        HtmlU
        HtmlUl
        HtmlVar
        HtmlVideo
        HtmlWbr
        HtmlUnknown

    HtmlAttribute* = object
        name*: string
        value*: string

    IDAttribute* = ref object
        value*: string

    MetaNode* = tuple[column, indent, line, childOf, depth: int]

    HtmlNode* = ref object
        case nodeType*: HtmlNodeType
        of HtmlText:
            text*: string
            vasAssignment*: VariableNode
            concat*: seq[HtmlNode]
        else: nil
        nodeName*: string
        id*: IDAttribute
        attributes*: seq[HtmlAttribute]
        nodes*: seq[HtmlNode]
        meta*: MetaNode

    VariableContentType* = enum
        ValueInvalid
        ValueBool
        ValueInt
        ValueFloat
        ValueNull
        ValueString

    VariableNode* = ref object
        varName: string
        varTypeName: string
        varType*: VariableContentType
        # case varType*: VariableContentType
        # of ValueBool: boolValue: bool
        # of ValueInt: intValue: BiggestInt
        # of ValueFloat: floatValue: float
        # of ValueNull: nullValue: string
        # of ValueString: stringValue: string
        # of ValueInvalid: invalidValue: string
        meta*: MetaNode

    ConditionalType* = enum
        If              = "if"
        Elif            = "elif"
        Else            = "else"

    ComparatorType* = enum
        Equal           = "=="
        NotEqual        = "!="
        Great           = ">"
        GreatOrEqual    = ">="
        Less            = "<"
        LessOrEqual     = "<="

    ComparatorNode* = ref object
        comparator*: ComparatorType
            ## The logical comparator used to compare ``aNode`` and ``bNode``.
            ## It can be either ``Equal``, ``NotEqual``, ``Great``,
            ## ``GreatOrEqual``, ``Less`` or ``LessOrEqual``
        aNode*: VariableNode
            ## A version of ``VariableNode``
        bNode*: VariableNode
            ## B version of ``VariableNode``

    ConditionalNode* = ref object
        ## Object representation for conditional statements
        conditionType*: ConditionalType
            ## It can be either, ``If``, ``Elif`` or ``Else``
        nodeName*: string
        comparatorNode*: ComparatorNode
            ## The logical comparator used for current conditional statement
        nodes*: seq[HtmlNode]
            ## A sequence holding one or more HtmlNode inside
            ## current Conditional statement
        meta*: MetaNode
            ## ``MetaNode`` of current statement

    IterationNode* = ref object
        ## Object representation for handling loop statements
        varItemName*: string
            ## A temporary variable name available for current iteration
        varItemsName*: string
            ## The variable name that contains data
        nodes*: seq[Node]
            # A sequence containing `HtmlNode` for the current iteration

    NodeType* = enum
        ConditionalStatement
        HtmlElement
        LoopStatement
    
    Node* = ref object
        nodeName*: string
            ## Symbol name of NodeType
        case nodeType*: NodeType            ## get the NodeType from ``NodeType`` enum
        of ConditionalStatement:
            conditionNode*: ConditionalNode
                ## Handle ``ConditionalNode`` instances
        of HtmlElement:
            htmlNode*: HtmlNode
                ## Handle ``HtmlNode`` instances
        of LoopStatement:
            iterationNode*: IterationNode

    Program* = object
        nodes*: seq[Node]

proc isEmptyAttribute*[T: HtmlAttribute](attr: var T): bool = attr.name.len == 0 and attr.value.len == 0
proc isEmptyAttribute*[T: IDAttribute](attr: var T): bool = attr.value.len == 0

proc getSymbolName*[T: HtmlNodeType](nodeType: T): string =
    ## Get stringified symbol name of the given HtmlNodeType
    var nodeName = nodeType.symbolName
    if nodeName.startsWith("HtmlSvg") and nodeName != "HtmlSvg":
        result = toUpperAscii(nodeName[7 .. ^1])
    else:
        result = toUpperAscii(nodeName[4 .. ^1])

proc getSymbolName*[T: ConditionalType](nodeType: T): string =
    ## Get stringified symbol name of the given ConditonalType
    var nodeName = nodeType.symbolName
    result = toUpperAscii(nodeName)

proc getSymbolName*[T: VariableContentType](nodeType: T): string =
    ## Get stringified symbol name of the given VariableContentType
    var nodeName = nodeType.symbolName
    result = toUpperAscii(nodeName[5 .. ^1])

proc getSymbolName*[T: ComparatorType](nodeType: T): string =
    ## Retrieve the stringified symbol name of ComparatorType
    var nodeName = nodeType.symbolName
    result = toUpperAscii(nodeName)

proc getSymbolName*[T: NodeType](nodeType: T): string =
    ## Retrieve the stringified symbol name of NodeType
    result = nodeType.symbolName

proc getHtmlNodeType*[T: TokenTuple](token: T): HtmlNodeType = 
    result = case token.kind:
    of TK_DOCTYPE: HtmlDoctype
    of TK_A_LINK: HtmlA
    of TK_ABBR: HtmlAbbr
    of TK_ACRONYM: HtmlAcronym
    of TK_ADDRESS: HtmlAddress
    of TK_APPLET: HtmlApplet
    of TK_AREA: HtmlArea
    of TK_ARTICLE: HtmlArticle
    of TK_ASIDE: HtmlAside
    of TK_AUDIO: HtmlAudio
    of TK_BOLD: HtmlB
    of TK_BASE: HtmlBase
    of TK_BASEFONT: HtmlBasefont
    of TK_BDI: HtmlBdi
    of TK_BDO: HtmlBdo
    of TK_BIG: HtmlBig
    of TK_BLOCKQUOTE: HtmlBlockquote
    of TK_BODY: HtmlBody
    of TK_BR: HtmlBr
    of TK_BUTTON: HtmlButton
    of TK_CANVAS: HtmlCanvas
    of TK_CAPTION: HtmlCaption
    of TK_CENTER: HtmlCenter
    of TK_CITE: HtmlCite
    of TK_CODE: HtmlCode
    of TK_COL: HtmlCol
    of TK_COLGROUP: HtmlColgroup
    of TK_DATA: HtmlData
    of TK_DATALIST: HtmlDatalist
    of TK_DD: HtmlDd
    of TK_DEL: HtmlDel
    of TK_Details: HtmlDetails
    of TK_DFN: HtmlDfn
    of TK_DIALOG: HtmlDialog
    of TK_DIR: HtmlDir
    of TK_DIV: HtmlDiv
    of TK_DL: HtmlDl
    of TK_DT: HtmlDt
    of TK_EM: HtmlEm
    of TK_EMBED: HtmlEmbed
    of TK_FIELDSET: HtmlFieldset
    of TK_FIGCAPTION: HtmlFigcaption
    of TK_FIGURE: HtmlFigure
    of TK_FONT: HtmlFont
    of TK_FOOTER: HtmlFooter
    of TK_FORM: HtmlForm
    of TK_FRAME: HtmlFrame
    of TK_FRAMESET: HtmlFrameset
    of TK_H1: HtmlH1
    of TK_H2: HtmlH2
    of TK_H3: HtmlH3
    of TK_H4: HtmlH4
    of TK_H5: HtmlH5
    of TK_h6: HtmlH6
    of TK_HEAD: HtmlHead
    of TK_HEADER: HtmlHeader
    of TK_HR: HtmlHr
    of TK_HTML: HtmlHtml
    of TK_Italic: HtmlI
    of TK_IFRAME: HtmlIframe
    of TK_IMG: HtmlImg
    of TK_INPUT: HtmlInput
    of TK_INS: HtmlIns
    of TK_KBD: HtmlKbd
    of TK_LABEL: HtmlLabel
    of TK_LEGEND: HtmlLegend
    of TK_LI: HtmlLi
    of TK_LINK: HtmlLink
    of TK_MAIN: HtmlMain
    of TK_MAP: HtmlMap
    of TK_MARK: HtmlMark
    of TK_META: HtmlMeta
    of TK_METER: HtmlMeter
    of TK_NAV: HtmlNav
    of TK_NOFRAMES: HtmlNoframes
    of TK_NOSCRIPT: HtmlNoscript
    of TK_OBJECT: HtmlObject
    of TK_OL: HtmlOl
    of TK_OPTGROUP: HtmlOptgroup
    of TK_OPTION: HtmlOption
    of TK_OUTPUT: HtmlOutput
    of TK_Paragraph: HtmlP
    of TK_PARAM: HtmlParam
    of TK_PRE: HtmlPre
    of TK_PROGRESS: HtmlProgress
    of TK_QUOTATION: HtmlQ
    of TK_RP: HtmlRp
    of TK_RT: HtmlRT
    of TK_RUBY: HtmlRuby
    of TK_STRIKE: HtmlS
    of TK_SAMP: HtmlSamp
    of TK_SCRIPT: HtmlScript
    of TK_SECTION: HtmlSection
    of TK_STRING: HtmlText
    of TK_SELECT: HtmlSelect
    of TK_SMALL: HtmlSmall
    of TK_SOURCE: HtmlSource
    of TK_SPAN: HtmlSpan
    of TK_STRIKE_LONG: HtmlStrike
    of TK_STRONG: HtmlStrong
    of TK_STYLE: HtmlStyle
    of TK_SUB: HtmlSub
    of TK_SUMMARY: HtmlSummary
    of TK_SUP: HtmlSup
    of TK_SVG: HtmlSvg
    of TK_SVG_ANIMATE: HtmlSvgAnimate
    of TK_SVG_ANIMATEMOTION: HtmlSvgAnimateMotion
    of TK_SVG_ANIMATETRANSFORM: HtmlSvgAnimateTransform
    of TK_SVG_CIRCLE: HtmlSvgCircle
    of TK_SVG_CLIPPATH: HtmlSvgClipPath
    of TK_SVG_DEFS: HtmlSvgDefs
    of TK_SVG_DESC: HtmlSvgDesc
    of TK_SVG_DISCARD: HtmlSvgDiscard
    of TK_SVG_ELLIPSE: HtmlSvgEllipse
    of TK_SVG_FE_BLEND: HtmlSvgFe_Blend
    of TK_SVG_FE_COLORMATRIX: HtmlSvgFeColorMatrix
    of TK_SVG_FE_COMPONENTTRANSFER: HtmlSvgFeComponentTransfer
    of TK_SVG_FE_COMPOSITE: HtmlSvgFeComposite
    of TK_SVG_FE_CONVOLVEMATRIX: HtmlSvgFeConvolveMatrix
    of TK_SVG_FE_DIFFUSELIGHTING: HtmlSvgFeDiffuseLighting
    of TK_SVG_FE_DISPLACEMENTMAP: HtmlSvgFeDisplacementMap
    of TK_SVG_FE_DISTANTLIGHT: HtmlSvgFeDistantLight
    of TK_SVG_FE_DROPSHADOW: HtmlSvgFeDropShadow
    of TK_SVG_FE_FLOOD: HtmlSvgFe_Flood
    of TK_SVG_FE_FUNCA: HtmlSvgFe_FuncA
    of TK_SVG_FE_FUNCB: HtmlSvgFe_FuncB
    of TK_SVG_FE_FUNCG: HtmlSvgFe_FuncG
    of TK_SVG_FE_FUNCR: HtmlSvgFe_FuncR
    of TK_SVG_FE_GAUSSIANBLUR: HtmlSvgFeGaussianBlur
    of TK_SVG_FE_IMAGE: HtmlSvgFeImage
    of TK_SVG_FE_MERGE: HtmlSvgFeMerge
    of TK_SVG_FE_MORPHOLOGY: HtmlSvgFeMorphology
    of TK_SVG_FE_OFFSET: HtmlSvgFeOffset
    of TK_SVG_FE_POINTLIGHT: HtmlSvgFePointLight
    of TK_SVG_FE_SPECULARLIGHTING: HtmlSvgFeSpecularLighting
    of TK_SVG_FE_SPOTLIGHT: HtmlSvgFeSpotLight
    of TK_SVG_FE_TITLE: HtmlSvgFeTitle
    of TK_SVG_FE_TURBULENCE: HtmlSvgFeTurbulence
    of TK_SVG_FILTER: HtmlSvgFilter
    of TK_SVG_FOREIGNOBJECT: HtmlSvgforeignObject
    of TK_SVG_G: HtmlSvgG
    of TK_SVG_HATCH: HtmlSvgHatch
    of TK_SVG_HATCHPATH: HtmlSvgHatchPath
    of TK_SVG_IMAGE: HtmlSvgImage
    of TK_SVG_LINE: HtmlSvgLine
    of TK_SVG_LINEARGRADIENT: HtmlSvgLinearGradient
    of TK_SVG_MARKER: HtmlSvgMarker
    of TK_SVG_MASK: HtmlSvgMask
    of TK_SVG_METADATA: HtmlSvgMetadata
    of TK_SVG_MPATH: HtmlSvgMpath
    of TK_SVG_PATH: HtmlSvgPath
    of TK_SVG_PATTERN: HtmlSvgPattern
    of TK_SVG_POLYGON: HtmlSvgPolygon
    of TK_SVG_POLYLINE: HtmlSvgPolyline
    of TK_SVG_RADIALGRADIENT: HtmlSvgRadialGradient
    of TK_SVG_RECT: HtmlSvgRect
    of TK_SVG_SET: HtmlSvgSet
    of TK_SVG_STOP: HtmlSvgStop
    of TK_SVG_SWITCH: HtmlSvgSwitch
    of TK_SVG_SYMBOL: HtmlSvgSymbol
    of TK_SVG_TEXT: HtmlSvgText
    of TK_SVG_TEXTPATH: HtmlSvgTextPath
    of TK_SVG_TSPAN: HtmlSvgTSpan
    of TK_SVG_USE: HtmlSvgUse
    of TK_SVG_VIEW: HtmlSvgView
    of TK_TABLE: HtmlTable
    of TK_TBODY: HtmlTbody
    of TK_TD: HtmlTd
    of TK_TEMPLATE: HtmlTemplate
    of TK_TFOOT: HtmlTfoot
    of TK_TH: HtmlTh
    of TK_THEAD: HtmlThead
    of TK_TIME: HtmlTime
    of TK_TITLE: HtmlTitle
    of TK_TR: HtmlTr
    of TK_TRACK: HtmlTrack
    of TK_TT: HtmlTt
    of TK_UNDERLINE: HtmlU
    of TK_UL: HtmlUl
    of TK_VAR: HtmlVar
    of TK_VIDEO: HtmlVideo
    of TK_WBR: HtmlWbr
    else: HtmlUnknown

const SvgSelfClosingTags = {HtmlSvgPath, HtmlSvgCircle, HtmlSvgPolyline}

proc isSelfClosingTag*(nodeType: HtmlNodeType): bool =
    result = nodeType in {HtmlArea, HtmlBase, HtmlBr, HtmlCol, HtmlEmbed,
                         HtmlHr, HtmlImg, HtmlInput, HtmlLink, HtmlMeta,
                         HtmlParam, HtmlSource, HtmlTrack, HtmlWbr} + SvgSelfClosingTags


proc getConditionalNodeType*(kind: TokenKind): ConditionalType = 
    case kind:
        of TK_IF: result = If
        of TK_ELIF: result = Elif
        of TK_ELSE: result = Else
        else: discard

proc newTextNode*(nodeTextValue: string,
    metaTuple: tuple[column, indent, line, childOf, depth: int], nodeConcat: seq[HtmlNode] = @[]): HtmlNode =
    result = HtmlNode(
        nodeType: HtmlText,
        nodeName: getSymbolName(HtmlText),
        text: nodeTextValue,
        concat: nodeConcat,
        meta: metaTuple
    )

proc newConditionNode*(token: TokenTuple): ConditionalNode = 
    ## Create new Conditional Node
    let ctype = getConditionalNodeType(token.kind)
    result = ConditionalNode(
        conditionType: ctype,
        nodeName: getSymbolName(ctype),
        meta: (token.col, token.wsno, token.line, 0, 0)
    )

proc getComparatorNodeType*[T: TokenTuple](token: T): ComparatorType =
    case token.kind:
        of TK_EQ: result = Equal
        of TK_NEQ: result = NotEqual
        else: discard

proc newComparatorNode*(nodeType: TokenTuple, variables: seq[VariableNode]): ComparatorNode = 
    ## TODO
    # let compNodeType = getComparatorNodeType(nodeType)
    # result = ComparatorNode(
    #     comparator: compNodeType,
    #     nodeName: getSymbolName(compNodeType),
    #     variables: variables
    # )

proc getVarType[T: JsonNode](token: T): VariableContentType =
    result = case token.kind:
    of JBool: ValueBool
    of JInt: ValueInt
    of JFloat: ValueFloat
    of JString: ValueString
    of JNull: ValueNull
    else: ValueInvalid

proc newVariableNode*(varName: string, varValue: JsonNode): VariableNode =
    ## Create a new VariableNode using given varName and varValue
    let varNodeType = getVarType(varValue)
    var varNode = VariableNode(
        varName: varName,
        varType: varNodeType,
        varTypeName: getSymbolName(varNodeType)
    )

    # case varNodeType:
    # of ValueBool: varNode.boolValue = varValue.bval
    # of ValueInt: varNode.intValue = varValue.num
    # of ValueFloat: varNode.floatValue = varValue.fnum
    # of ValueString: varNode.stringValue = varValue.str
    # else: varnode.nullValue = ""
    result = varNode