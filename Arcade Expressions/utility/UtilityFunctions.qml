import QtQuick 2.9



Item {
    property var openHtmlTags:[]

    /**********This function modifies/adds certain tags in the input html to  make the images and the UI look better in RichText ****  */

    function getHtmlSupportedByRichText(inputString, imagewidth, defaultString){

        let tagText = ""
        let updatedHtml = ""
        let previoustag = ""

        let txt = inputString.replace("http://", "https://")

        for (var i = 0; i < txt.length; i++) {
            let nextChar = txt.charAt(i)

            switch(nextChar)
            {
                // if it is start of a tag the initialize a variable
            case "<":
                tagText = "<"
                break;
                //if it is end of the tag then process the whole tag and set the tag variable to empty
            case ">":
                tagText += ">"
                let modifiedTag = processHtmlTag(tagText, imagewidth, previoustag)
                previoustag = modifiedTag
                if(modifiedTag === "</div>")
                {
                    let opentag = openHtmlTags.pop()
                    if(opentag)
                        modifiedTag = opentag.replace("<","</")

                }
                else
                {
                    if(modifiedTag.includes("</"))
                        openHtmlTags.pop()
                }
                updatedHtml += modifiedTag


                tagText = ""

                break;
                //if it is within a tag then just append to the tag body. If it is outside of a tag
                // then if it is outside of href and is within a <td> then create a new <td>. This will resolve the issue
                // where the table cell is specified as display:table-cell and the text content is enclosed within a div
            default:
                if(tagText > "")
                    tagText += nextChar
                else
                {
                    if(nextChar > ""){
                        if((previoustag === "</a>") && openHtmlTags[openHtmlTags.length -1] === "<td>")
                        {
                            previoustag = "<td>"
                            updatedHtml += "</td><td>" + nextChar
                        }
                        else
                            updatedHtml += nextChar
                    }
                }

            }


        }

        return updatedHtml

    }

    function processHtmlTag(txt, imagewidth, previoustag)
    {
        let modifiedTag = ""
        if(txt.includes("style=")){

            //get the substring excluding '<' in the beginning and "'>" at the end
            //e.g. <div style='margin: 1em 0;'>
            let txtToSplit = txt.substr(1,txt.length-2)

            let csstags = txtToSplit.split(" ")
            let tag = csstags[0]
            //processing just the div tags for now
            if(tag === "div")
            {

                modifiedTag = processStyleOfDivTag(txtToSplit,txt)

            }
            else if(tag === "img")
            {

                modifiedTag = scrubImgStyle(txt, imagewidth, previoustag,true)

            }

            if(modifiedTag === ""){
                modifiedTag = txt

            }

        }
        else
        {
            let txtToSplit1 = txt.substr(1,txt.length-2)

            let csstags1 = txtToSplit1.split(" ")
            let tag1 = csstags1[0]

            if(tag1 === "img")
            {

                modifiedTag = scrubImgStyle(txt, imagewidth, previoustag,false)

            }

            else{
                //get the first html markup
                let starttag = ""
                let tagindex =   txt.indexOf(" ")
                if(tagindex > -1)
                {
                    let _tag = txt.substr(0,tagindex)
                    starttag = _tag + ">"
                }
                else
                {
                    starttag = txt

                }


                if(txt.substr(0,2) !== "</" && !txt.includes("/>") )
                    openHtmlTags.push(starttag)

                modifiedTag = txt
            }
        }

        return modifiedTag

    }

    function processStyleOfDivTag(enclosedText,inputString)
    {
        let modifiedTagAfterProcessingDiv = ""
        let tagdesc = enclosedText.substr(3,enclosedText.length -1)
        //" style='margin: 1em 0;'"
        //get the style
        if(tagdesc > "")
        {
            if(enclosedText.includes("style="))
            {
                let styleindx = enclosedText.indexOf("style=")
                let styleindxstart = enclosedText.indexOf("'")

                let styleindxend = enclosedText.indexOf("'", styleindxstart + 1)
                let no_of_chars = styleindxend - styleindxstart
                let stylestring = enclosedText.substr(styleindxstart + 1,no_of_chars - 1)
                //e.g. stylestring - "'margin: 1em 0;'"
                let stylesubsplits = stylestring.split(';')
                for(let k=0;k< stylesubsplits.length; k++)
                {
                    let _tagcss = stylesubsplits[k]
                    if(_tagcss > ""){
                        let tagcss = _tagcss.replace(" ","")
                        if(tagcss === "display:table")
                        {
                            modifiedTagAfterProcessingDiv = "<table>"
                            openHtmlTags.push(modifiedTagAfterProcessingDiv)
                        }
                        else if(tagcss === "display:table-cell")
                        {

                            modifiedTagAfterProcessingDiv = "<tr><td>"
                            openHtmlTags.push("<td>")
                        }
                        else if(tagcss === "display:table-row")
                        {
                            modifiedTagAfterProcessingDiv = "<tr>"
                            openHtmlTags.push(modifiedTagAfterProcessingDiv)
                        }
                        else
                        {
                            if(!modifiedTagAfterProcessingDiv.includes("<table>") && !modifiedTagAfterProcessingDiv.includes("<tr>") && !modifiedTagAfterProcessingDiv.includes("<td")){
                                let subtag = tagcss.split(':')
                                if(subtag[0] !== "box-sizing" && subtag[0] !== "border-radius" && subtag[0] !== "margin"){
                                    if(modifiedTagAfterProcessingDiv > "")
                                        modifiedTagAfterProcessingDiv += ";" + tagcss
                                    else
                                        modifiedTagAfterProcessingDiv = "<div style='"+ tagcss
                                }
                            }
                        }


                    }
                }
                if(modifiedTagAfterProcessingDiv.includes("style="))
                    modifiedTagAfterProcessingDiv +="'>"



            }
        }
        if(modifiedTagAfterProcessingDiv.substr(0,2) !== "</" && !inputString.includes("/>") )
        {
            if(modifiedTagAfterProcessingDiv.includes("<div"))

                openHtmlTags.push("<div>")

        }
        return modifiedTagAfterProcessingDiv


    }

    //construct the img tag
    function scrubImgStyle(txt, imagewidth, previoustag, asStyle)
    {
        let modifiedTag = txt[0] + "img "

        let regex = /width=(\s*)\d+/
        if(asStyle)
            regex = /width:(\s*)\d+/

        let srcexpr = txt.match(/src='(.*?)'/);
        if(srcexpr)
        {
            modifiedTag += srcexpr[0]
        }

        let widthexpr = txt.match(regex);
        if(widthexpr){
            let width = widthexpr[0].substr(6)
            if (width > imagewidth)
                width = imagewidth - app.units(40)

            modifiedTag += " width=" + width
        }
        else
        {
            //if a div tag then width must be present inside style
            let previousdivwidthexpr = previoustag.match(/width:(\s*)\d+/);
            if(previousdivwidthexpr)
            {
                let _width = previousdivwidthexpr[0].substr(6)
                if (parseInt(_width) > imagewidth)
                {
                    _width = imagewidth - app.units(40)
                    modifiedTag += " width=" + _width.toString()
                }
            }
            else
            {
                let newwidth = imagewidth - app.units(40)
                modifiedTag += " width=" + newwidth.toString()
            }
        }



        modifiedTag += " />"
        return modifiedTag

    }

}
