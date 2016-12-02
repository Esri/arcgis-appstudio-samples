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

