local function get_attr(el,name,default)
    return el.attributes and el.attributes[name] or default
end

local function width_factor(w)
    local p=tostring(w or "100%"):match("^(%d*%.?%d+)%%$")
    return p and string.format("%.4f",tonumber(p)/100):gsub("0+$",""):gsub("%.$","") or tostring(w or "100%")
end

local function get_images(el)
    local r={}
    pandoc.walk_block(el,{Image=function(img) r[#r+1]=img end})
    return r
end

local function inline_to_latex(inlines)
    local d=pandoc.Pandoc({pandoc.Plain(inlines)})
    return pandoc.write(d,"latex"):gsub("%s+$","")
end

function Div(el)
    local classes=el.classes or {}
    local attr=el.attributes or {}

    if classes:includes("intro") then
        local title=inline_to_latex(el.content[1].content)
        local out=pandoc.List{
            pandoc.RawBlock("latex",string.format("\\begin{portfoliointro}{%s}",title))
        }
        for i=2,#el.content do out:insert(el.content[i]) end
        out:insert(pandoc.RawBlock("latex","\\end{portfoliointro}"))
        return out
    end

    if classes:includes("closing") then
        local a=el.content[1] and inline_to_latex(el.content[1].content) or ""
        local b=el.content[2] and inline_to_latex(el.content[2].content) or ""
        local c=el.content[3] and inline_to_latex(el.content[3].content) or ""
        return pandoc.RawBlock(
            "latex",
            string.format("\\portfolioclosing{%s}{%s}{%s}",a,b,c)
        )
    end

    if classes:includes("gallery") then
        local imgs=get_images(el)
        local layout=get_attr(el,"layout","row-three")
        local placement=attr.placement and "["..attr.placement.."]" or ""
        local br=attr["break-after"]=="page" and "\\clearpage" or ""
        local cmd=
            layout=="staggered-three" and "\\PortfolioGalleryStaggeredThree"
            or layout=="staggered-two" and "\\PortfolioGalleryStaggeredTwo"
            or "\\PortfolioGalleryRowThree"
        local args={"{"..placement.."}"}

        for _,img in ipairs(imgs) do
            args[#args+1]=string.format(
                "{%s}{%s}",
                width_factor(img.attributes.width),
                img.src:gsub("^%./","")
            )
        end

        return pandoc.RawBlock("latex",cmd..table.concat(args).."\n"..br)
    end

    if classes:includes("artwork") then
        local imgs=get_images(el)
        if #imgs==0 then return el end

        local placement=attr.placement and "["..attr.placement.."]" or ""
        local width=width_factor(attr.width)
        local align=get_attr(el,"align","center")
        local cap_align=get_attr(el,"caption-align",align)
        local cap_cmd=
            cap_align=="right" and "raggedleft"
            or cap_align=="left" and "raggedright"
            or "centering"

        local caption=""
        local body=pandoc.List()

        for _,block in ipairs(el.content) do
            if #get_images(block)==0 then body:insert(block) end
        end

        if #body>0 and (body[1].t=="Para" or body[1].t=="Plain") then
            caption=inline_to_latex(body[1].content)
            body:remove(1)
        end

        local tex=caption=="" and string.format(
            "\\PortfolioArtworkNoCaption{%s}{%s}{%s}{%s}",
            placement,width,align,imgs[1].src:gsub("^%./","")
        ) or string.format(
            "\\PortfolioArtwork{%s}{%s}{%s}{%s}{%s}{%s}",
            placement,width,align,cap_cmd,
            imgs[1].src:gsub("^%./",""),caption
        )

        local out=pandoc.List{pandoc.RawBlock("latex",tex)}
        out:extend(body)

        if attr["break-after"]=="page" then
            out:insert(pandoc.RawBlock("latex","\\clearpage"))
        end

        return out
    end
end
