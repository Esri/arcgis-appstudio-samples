function niceScale(a) {
    return a > 999 && a <= 999999 ? a = Math.round(a / 1e3) + " K" : a > 999999 ? a = Math.round(a / 1e6) + " M" : a > 0 && a <= 999 && (a = Math.round(a) + " Ft");
}


//------------------------------------------------------------------------------

function isDefined(value) {
    return typeof(value) != "undefined";
}

//------------------------------------------------------------------------------

function hasValue(value) {
    return typeof(value) != "undefined" && value !== null;
}

//------------------------------------------------------------------------------

function ifString(value, defaultValue) {
    if (typeof(value) != "undefined" && value !== null) {
        return value.toString();
    } else if (defaultValue) {
        return defaultValue;
    } else {
        return "";
    }
}

//------------------------------------------------------------------------------

function niceDistance(distance) {
    if (distance < 0) {
        return "";
    }

    if (distance >= 1000) {
        return (Math.round(distance / 100) / 10).toString() + " km";
    } else {
        return Math.round(distance).toString() + " m";
    }
}

//------------------------------------------------------------------------------

function replaceVariables(text, attributes) {
    if (!text) {
        return "";
    }

    if (!attributes) {
        return "";
    }

    var keys = Object.keys(attributes);
    for (var i = 0; i < keys.length; i++) {
        var key = keys[i];
        text = text.replace("{" + key + "}", attributes[key]);
    }

    return text;
}

//------------------------------------------------------------------------------

function isLink(value) {
    if (!value)
    {
        return false;
    }

    return value.substr(0, 5) === "http:" || value.substr(0, 6) === "https:";
}

//------------------------------------------------------------------------------

function formattedFieldValue(fieldInfo, attributes, options) {
    var value = fieldValue(fieldInfo, attributes, options);

    if (!fieldInfo.format)
    {
        return value;
    }

    if (fieldInfo.format.dateFormat) {
        switch (fieldInfo.format.dateFormat) {
        case "shortDateShortTime" :
            value = new Date(Number(value)).toLocaleString();
            break;

        default:
            value = new Date(Number(value)).toLocaleString();
            break;
        }
    }

    return value;
}

//------------------------------------------------------------------------------

function fieldValue(fieldInfo, attributes, options) {
    var value = "";

    if (Object(attributes).hasOwnProperty(fieldInfo.fieldName))
    {
        value = attributes[fieldInfo.fieldName];
    } else if (Object(attributes).hasOwnProperty(fieldInfo.label)) {
        value = attributes[fieldInfo.label];
    }

    if (typeof(value) === 'undefined') {
        value = "";
    }

    /*
    if (typeof(value) === 'undefined') {
        if (fieldInfo.visible) {
            console.log("No match label:", fieldInfo.label, " or fieldName:", fieldInfo.fieldName, "valuetype=", typeof value, attributes[fieldInfo.fieldName]);
            console.log("fieldInfo=\r\n", JSON.stringify(fieldInfo, undefined, 2));
            console.log("attributes=\r\n", JSON.stringify(attributes, undefined, 2));

            return "No match label:'" + fieldInfo.label + "' fieldName='" + fieldInfo.fieldName + "'"
        } else {
            console.log("No match for fieldName:", fieldInfo.fieldName);

            return "";
        }
    }
    */

    if (value && isLink(value.toString())) {
        var linkText = value;
        if (options && options.linkText && options.linkText > "") {
            linkText = options.linkText;
        }

        value = "<a href='" + value + "'>" + linkText + "</a>";
    }

    return value;
}

//------------------------------------------------------------------------------

function createPopupInfo(attributes) {
    return {
        "title": null,
        "description": null,
        "fieldInfos": createFieldInfos(attributes),
        "mediaInfos": [] };
}

//------------------------------------------------------------------------------

function createFieldInfos(attributes) {
    var fieldInfos = [];

    if (!attributes) {
        return fieldInfos;
    }

    var keys = Object.keys(attributes);
    for (var i = 0; i < keys.length; i++) {
        var fieldInfo = {
            label: keys[i],
            fieldName: keys[i]
        };

        fieldInfos.push(fieldInfo);
    }

    console.log(JSON.stringify(fieldInfo, undefined, 2));

    return fieldInfos;
}

//------------------------------------------------------------------------------

function removeDuplicates(array) {
    return array.filter( function( item, index, inputArray ) {
        return inputArray.indexOf(item) === index;
    });
}

//------------------------------------------------------------------------------

