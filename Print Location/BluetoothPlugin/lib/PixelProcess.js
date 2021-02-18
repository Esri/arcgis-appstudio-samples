/* Copyright 2021 Esri
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

.pragma library


//--------------------------------------------------------------------------

function initilizePrintCommandList(printCommandList) {
    printCommandList = []
}

//------------------------------------------------------------------------------

function printTextWithParameter(font, size, x, y, text, printCommandList, bold, leftMargin) {
    var textPrintCommand = {}
    textPrintCommand.type = "text"
    textPrintCommand.content = text
    textPrintCommand.font = font
    textPrintCommand.bold = bold
    textPrintCommand.leftMargin = leftMargin
    textPrintCommand.fontSize = size
    textPrintCommand.position = {}
    textPrintCommand.position.x = x
    textPrintCommand.position.y = y

    printCommandList.push(textPrintCommand)

}

//------------------------------------------------------------------------------

function printImageWithParameter(imageUrl, x, y, printCommandList, width, height) {
    var imagePrintCommand = {}
    imagePrintCommand.type = "image"
    imagePrintCommand.content = imageUrl
    imagePrintCommand.position = {}
    imagePrintCommand.position.x = x
    imagePrintCommand.position.y = y
    imagePrintCommand.size = {}
    imagePrintCommand.size.width = width
    imagePrintCommand.size.height = height

    printCommandList.push(imagePrintCommand)

}

//------------------------------------------------------------------------------

function generateBitmapHexString(imageObject, imageData, imageDataInGray) {

    // refresh the height and width
    var height = imageObject.height
    var width = imageObject.width

    imageData = ""

    // extract each pixel value and convert it to bw
    toDitherFloydSteinberg(imageObject, imageDataInGray)

    for (var y = 0; y < height; y++) { // each row
        // clear rowPixel
        var rowPixel = ""
        for (var x = 0; x < Math.floor(width/8) * 8; x++) {// each column
            // get the r, g, b value of the pixel
            var bwPixel = imageDataInGray[y*width+x] > 127 ? 0 : 1
            // convert to string
            rowPixel += bwPixel.toString()
        }

        // convert binary value to hex value
        rowPixel = bin2hex(rowPixel)
        // add this line to imageData
        imageData += rowPixel
        //console.log("the line = ", rowPixel)
    }

    // printer only likes Capital Case of the hex characters
    imageData = imageData.toUpperCase()
    return imageData
}

function componentToHex(c) {
    var hex = c.toString(16);
    return hex.length == 1 ? "0" + hex : hex;
}

//------------------------------------------------------------------------------

function rgbToHex(r, g, b) {
    return "#" + componentToHex(r) + componentToHex(g) + componentToHex(b);
}

//------------------------------------------------------------------------------

function hexToRgb(hex) {
    var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    return result ? {
                        r: parseInt(result[1], 16),
                        g: parseInt(result[2], 16),
                        b: parseInt(result[3], 16)
                    } : null;
}

//------------------------------------------------------------------------------

function toDitherFloydSteinberg(imageObject, imageDataInGray) {
    var height = imageObject.height
    var width = imageObject.width
    // populate the gray array of the pixel
    for (var y = 0; y < height; y++) { // each row
        for (var x = 0; x < Math.floor(width/8) * 8; x++) {// each column
            // get the r, g, b value of the pixel
            var rgbPixel = hexToRgb(imageObject.pixel(x,y))
            // convert to Black and White value
            var grayPixel = Math.floor(rgbPixel.r * 0.3 + rgbPixel.g * 0.59 + rgbPixel.b * 0.11)
            imageDataInGray.push(grayPixel)
        }
    }

    // do Dither by using FloydSteinberg
    for(var i = 0; i < height; i++) {
        for(var j = 0; j < width; j++) {
            var ci = i*width + j;               // current buffer index
            var cc = imageDataInGray[ci];              // current color
            var rc = (cc < 128 ? 0 : 255);      // real (rounded) color
            var err = cc-rc;              // error amount
            imageDataInGray [ci] = rc;                  // saving real color
            if(j + 1 < width) imageDataInGray[ci + 1] += (err*7)>>4;  // if right neighbour exists
            if(i+1 ===  height) continue;   // if we are in the last line
            if(j  > 0) imageDataInGray[ci + width -1] += (err*3)>>4;  // bottom left neighbour
            imageDataInGray[ci + width] += (err*5)>>4;  // bottom neighbour
            if(j + 1 < width) imageDataInGray[ci + width + 1] += (err*1)>>4;  // bottom right neighbour
        }
    }
}

//------------------------------------------------------------------------------

function toGray(r, g, b) {
    var grayValue = Math.floor(r * 0.3 + g * 0.59 + b * 0.11)
    return grayValue;
}

//------------------------------------------------------------------------------

function toBW(r, g, b) {
    // first to gray
    var grayValue = Math.floor(r * 0.3 + g * 0.59 + b * 0.11)

    // then to black and white
    var bw = grayValue > 127 ? 0 : 1
    return bw;
}

//------------------------------------------------------------------------------

function bin2hex(b) {
    return b.match(/.{4}/g).reduce(function(acc, i) {
        return acc + parseInt(i, 2).toString(16);
    }, '')
}

//------------------------------------------------------------------------------
