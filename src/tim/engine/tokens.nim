# A High-performance, compiled template engine
# inspired by Emmmet Syntax.
# 
# Tim Engine can be used as a Nim Library via Nimble
# or as a binary application for language agnostic
# projects.
# 
#       (c) 2022 George Lemon | Released under MIT License
#       Made by Humans from OpenPeep
#       https://github.com/openpeep/tim
import toktok

tokens:
    A_Link       > "a"
    Abbr         > "abbr"
    Acronym      > "acronym"
    Address      > "address"
    Applet       > "applet"
    Area         > "area"
    Article      > "article"
    Aside        > "aside"
    Audio        > "audio"
    Bold         > "b"
    Base         > "base"
    Basefont     > "basefont"
    Bdi          > "bdi"
    Bdo          > "bdo"
    Big          > "big"
    Blockquote   > "blockquote"
    Body         > "body"
    Br           > "br"
    Button       > "button"
    Divide       > '/':
        Comment  ? '/' .. EOL   # Inline commnet ollecting everything to EOL
    Canvas       > "canvas"
    Caption      > "caption"
    Center       > "center"
    Cite         > "cite"
    Code         > "code"
    Col          > "col"
    Colgroup     > "colgroup"
    Data         > "data"
    Datalist     > "datalist"
    DD           > "dd"
    Del          > "del"
    Details      > "details"
    DFN          > "dfn"
    Dialog       > "dialog"
    Dir          > "dir"
    Div          > "div"
    Doctype      > "doctype"
    DL           > "dl"
    DT           > "dt"
    EM           > "em"
    Embed        > "embed"
    Fieldset     > "fieldset"
    Figcaption   > "figcaption"
    Figure       > "figure"
    Font         > "font"
    Footer       > "footer"
    Form         > "form"
    Frame        > "frame"
    Frameset     > "frameset"
    H1           > "h1"
    H2           > "h2"
    H3           > "h3"
    H4           > "h4"
    H5           > "h5"
    H6           > "h6"
    Head         > "head"
    Header       > "header"
    Hr           > "hr"
    Html         > "html"
    Italic       > "i"
    Iframe       > "iframe"
    Img          > "img"
    Input        > "input"
    Ins          > "ins"
    Kbd          > "kbd"
    Label        > "label"
    Legend       > "legend"
    Li           > "li"
    Link         > "link"
    Main         > "main"
    Map          > "map"
    Mark         > "mark"
    Meta         > "meta"
    Meter        > "meter"
    Nav          > "nav"
    Noframes     > "noframes"
    Noscript     > "noscript"
    Object       > "object"
    Ol           > "ol"
    Optgroup     > "optgroup"
    Option       > "option"
    Output       > "output"
    Paragraph    > "p"
    Param        > "param"
    Pre          > "pre"
    Progress     > "progress"
    Quotation    > "q"
    RP           > "rp"
    RT           > "rt"
    Ruby         > "ruby"
    Strike       > "s"
    Samp         > "samp"
    Script       > "script"
    Section      > "section"
    Select       > "select"
    Small        > "small"
    Source       > "source"
    Span         > "span"
    Strike_Long  > "strike"
    Strong       > "strong"
    Style        > "style"
    Sub          > "sub"
    Summary      > "summary"
    Sup          > "sup"
    # 
    # SVG Support
    # 
    SVG                  > "svg"
    SVG_Animate          > "animate"
    SVG_AnimateMotion    > "animateMotion"
    SVG_AnimateTransform > "animateTransform"
    SVG_Circle           > "circle"
    SVG_ClipPath         > "clipPath"
    SVG_Defs             > "defs"
    SVG_Desc             > "desc"
    SVG_Discard          > "discard"
    SVG_Ellipse          > "ellipse"
    SVG_Fe_Blend         > "feBlend"
    SVG_Fe_ColorMatrix   > "feColorMatrix"
    SVG_Fe_ComponentTransfer    > "feComponentTransfer"
    SVG_Fe_Composite            > "feComposite"
    SVG_Fe_ConvolveMatrix       > "feConvolveMatrix"
    SVG_Fe_DiffuseLighting      > "feDiffuseLighting"
    SVG_Fe_DisplacementMap      > "feDisplacementMap"
    SVG_Fe_DistantLight         > "feDistantLight"
    SVG_Fe_DropShadow           > "feDropShadow"
    SVG_Fe_Flood                > "feFlood"
    SVG_Fe_FuncA                > "feFuncA"
    SVG_Fe_FuncB                > "feFuncB"
    SVG_Fe_FuncG                > "feFuncG"
    SVG_Fe_FuncR                > "feFuncR"
    SVG_Fe_GaussianBlur         > "feGaussianBlur"
    SVG_Fe_Image                > "feImage"
    SVG_Fe_Merge                > "feMerge"
    SVG_Fe_Morphology           > "feMorphology"
    SVG_Fe_Offset               > "feOffset"
    SVG_Fe_PointLight           > "fePointLight"
    SVG_Fe_SpecularLighting     > "feSpecularLighting"
    SVG_Fe_SpotLight            > "feSpotLight"
    SVG_Fe_Title                > "feTitle"
    SVG_Fe_Turbulence           > "feTurbulence"
    SVG_Filter                  > "filter"
    SVG_foreignObject           > "foreignObject"
    SVG_G                       > "g"
    SVG_Hatch                   > "hatch"
    SVG_HatchPath               > "hatchpath"
    SVG_Image                   > "image"
    SVG_Line                    > "line"
    SVG_LinearGradient          > "linearGradient"
    SVG_Marker                  > "marker"
    SVG_Mask                    > "mask"
    SVG_Metadata                > "metadata"
    SVG_Mpath                   > "mpath"
    SVG_Path                    > "path"
    SVG_Pattern                 > "pattern"
    SVG_Polygon                 > "polygon"
    SVG_Polyline                > "polyline"
    SVG_RadialGradient          > "radialGradient"
    SVG_Rect                    > "rect"
    SVG_Set                     > "set"
    SVG_Stop                    > "stop"
    SVG_Switch                  > "switch"
    SVG_Symbol                  > "symbol"
    SVG_Text                    > "text"
    SVG_TextPath                > "textpath"
    SVG_TSpan                   > "tspan"
    SVG_Use                     > "use"
    SVG_View                    > "view"

    Table        > "table"
    Tbody        > "tbody"
    TD           > "td"
    Template     > "template"
    Textarea     > "textarea"
    Tfoot        > "tfoot"
    TH           > "th"
    Thead        > "thead"
    Time         > "time"
    Title        > "title"
    TR           > "tr"
    Track        > "track"
    TT           > "tt"
    Underline    > "u"  
    UL           > "ul"
    Var          > "var"
    Video        > "video"
    WBR          > "wbr"
    Attr                        # TK_IDENTIFIER followed by `=` becomes TK_ATTR
    Attr_Class   > '.'
    Attr_ID      > '#'
    Assign       > '='
    Colon        > ':' 
    Nest_OP      > '>'
    And          > '&'
    Variable     > identWith('$')
    If           > "if"
    Elif         > "elif"
    Else         > "else"
    For          > "for"
    In           > "in"
    Or           > "or"
    Eq           > ('=', '=')
    Neq          > ('!', '=')
    Include      > ('@', "include")
    Plus         > '+'
    Minus        > '-'
    Multiply     > '*'
    Defer        > "defer"
    None

export TokenTuple, TokenKind