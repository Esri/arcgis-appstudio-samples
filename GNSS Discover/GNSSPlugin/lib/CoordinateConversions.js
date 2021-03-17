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

.import QtQml 2.15 as QML
.import ArcGIS.AppFramework.Sql 1.0 as Sql

//------------------------------------------------------------------------------

var options = {
    coords: {
        shortPrecision: 3,
        longPrecision: 6,
        minutesPrecision: 6,
        secondsPrecision: 3,
        east: "E",
        west: "W",
        north: "N",
        south: "S"
    }
};

var kDefaultNumberLocale = Qt.locale("C");

//------------------------------------------------------------------------------

function escapeRegExp(text) {
    return text.replace(/([.*+?^=!:${}()|\[\]\/\\])/g, "\\$1");
}

//------------------------------------------------------------------------------

function replaceAll(string, find, replace) {
    //console.log("replaceAll string:", string, "find:", find, "replace:", replace);
    return string.replace(new RegExp(escapeRegExp(find), 'g'), replace);
}

//------------------------------------------------------------------------------

// dd       Decimal degrees - long
// d        Decimal degrees - short
// dmss     Degrees Minutes Seconds - long
// dms
// ddm      Degrees Decimal Minutes - long
// dm       Degrees Minutes - short
// mgrs     MGRS
// usng     USNG
// utmups   UTM/UPS

//--------------------------------------------------------------------------

function formatCoordinate(coordinate, coordinateFormat) {
    if (!coordinate.isValid) {
        return "--";
    }

    if (isLatLonFormat(coordinateFormat)) {
        return "%1 %2"
        .arg(formatLatitude(coordinate.latitude, coordinateFormat))
        .arg(formatLongitude(coordinate.longitude, coordinateFormat));
    } else {
        return formatGridCoordinate(coordinate, coordinateFormat);
    }
}

//------------------------------------------------------------------------------

function isLatLonFormat(coordinateFormat) {
    switch (coordinateFormat) {
    case "dd":
    case "d":
    case "dmss":
    case "dms":
    case "ddm":
    case "dmm":
    case "dm":
        return true;

    default:
        return false;
    }
}

//------------------------------------------------------------------------------

function formatLatitude(latitude, coordinateFormat) {
    switch (coordinateFormat) {
    case "dd":
        return dd(latitude, options.coords.north, options.coords.south, options.coords.longPrecision);

    case "d":
        return dd(latitude, options.coords.north, options.coords.south, options.coords.shortPrecision);

    case "dmss":
    default:
        return dms(latitude, options.coords.north, options.coords.south);

    case "ddm":
    case "dmm":
        return ddm(latitude, options.coords.north, options.coords.south);

    case "dm":
        return dm(latitude, options.coords.north, options.coords.south);
    }
}

function formatLongitude(longitude, coordinateFormat) {
    switch (coordinateFormat) {
    case "dd":
        return dd(longitude, options.coords.east, options.coords.west, options.coords.longPrecision);

    case "d":
        return dd(longitude, options.coords.east, options.coords.west, options.coords.shortPrecision);

    case "dmss":
    default:
        return dms(longitude, options.coords.east, options.coords.west);

    case "ddm":
    case "dmm":
        return ddm(longitude, options.coords.east, options.coords.west);

    case "dm":
        return dm(longitude, options.coords.east, options.coords.west);
    }
}

//------------------------------------------------------------------------------

function dd(value, pos, neg, precision) {
    var isNeg = value < 0;
    value = Math.abs(value);

    return value.toFixed(precision) + "°" + (isNeg ? neg : pos);
}

function dm(value, pos, neg) {
    var isNeg = value < 0;
    value = Math.abs(value);
    var d = Math.floor(value);
    value = (value - d) * 60;
    var m = Math.round(value);

    return d.toString() + "°" + m.toString() + "'" + (isNeg ? neg : pos);
}

function dms(value, pos, neg) {
    var isNeg = value < 0;
    value = Math.abs(value);
    var d = Math.floor(value);
    value = (value - d) * 60;
    var m = Math.floor(value);
    var s = (value - m) * 60;

    return d.toString() + "°" + m.toString() + "'" + s.toFixed(options.coords.secondsPrecision) + "\"" + (isNeg ? neg : pos);
}

function ddm(value, pos, neg) {
    var isNeg = value < 0;
    value = Math.abs(value);
    var d = Math.floor(value);
    var m = (value - d) * 60;

    return d.toString() + "°" + m.toFixed(options.coords.minutesPrecision) + "'" + (isNeg ? neg : pos);
}

//------------------------------------------------------------------------------

function formatGridCoordinate(coordinate, coordinateFormat) {
    switch (coordinateFormat) {
    case "mgrs":
        return formatMgrsCoordinate(coordinate);

    case "usng":
        return formatUsngCoordinate(coordinate);

    case "utm":
    case "utmups":
    case "ups":
        return formatUniversalCoordinate(coordinate);

    default:
        return "Unknown format %1".arg(coordinateFormat);
    }
}

//------------------------------------------------------------------------------

function formatMgrsCoordinate(coordinate) {
    var mgrs = Sql.Coordinate.convert(coordinate, "mgrs").mgrs;

    return mgrs.text;
}

//------------------------------------------------------------------------------

function formatUsngCoordinate(coordinate) {
    var options = {
        spaces: true,
        precision: 10
    }

    var mgrs = Sql.Coordinate.convert(coordinate, "mgrs", options).mgrs;

    return mgrs.text;
}

//------------------------------------------------------------------------------

function formatUniversalCoordinate(coordinate) {
    var universalGrid = Sql.Coordinate.convert(coordinate, "universalGrid").universalGrid;

    return "%1%2 %3E %4N"
    .arg(universalGrid.zone ? universalGrid.zone : "")
    .arg(universalGrid.band)
    .arg(Math.floor(universalGrid.easting).toString())
    .arg(Math.floor(universalGrid.northing).toString());
}

//------------------------------------------------------------------------------

function isNullOrUndefined(value) {
    return value === null || value === undefined;
}

//------------------------------------------------------------------------------
// Round number to nearest decimal places specified by precision

function round(number, precision) {
    if (!isFinite(number) && number !== null) {
        return number;
    }

    var factor = Math.pow(10, precision);

    return Math.round(number * factor) / factor;
}

//--------------------------------------------------------------------------

function getNumberLocale(locale) {
    return locale.zeroDigit !== "0"
            ? kDefaultNumberLocale
            : locale;
}

//--------------------------------------------------------------------------

function localeLengthSuffix(locale) {
    if (!locale) {
        locale = Qt.locale();
    }

    var suffixText = qsTr("m");

    switch (locale.measurementSystem) {
    case QML.Locale.MetricSystem:
    case QML.Locale.ImperialUKSystem:
        break;

    case QML.Locale.ImperialUSSystem:
    case QML.Locale.ImperialSystem:
        suffixText = qsTr("ft");
        break;
    }

    return suffixText;
}

//--------------------------------------------------------------------------

function fromLocaleLength(length, locale, precision) {
    if (!isFinite(length)) {
        return length;
    }

    if (!locale) {
        locale = Qt.locale();
    }

    if (isNullOrUndefined(precision)) {
        precision = 3;
    }

    switch (locale.measurementSystem) {
    case QML.Locale.MetricSystem:
    case QML.Locale.ImperialUKSystem:
        return round(length, precision);

    case QML.Locale.ImperialUSSystem:
    case QML.Locale.ImperialSystem:
        return round(length * 0.3048, precision);
    }
}

//--------------------------------------------------------------------------

function toLocaleLength(metres, locale, precision) {
    if (!isFinite(metres)) {
        return metres;
    }

    if (!locale) {
        locale = Qt.locale();
    }

    if (isNullOrUndefined(precision)) {
        precision = 3;
    }

    switch (locale.measurementSystem) {
    case QML.Locale.MetricSystem:
    case QML.Locale.ImperialUKSystem:
        return round(metres, precision);

    case QML.Locale.ImperialUSSystem:
    case QML.Locale.ImperialSystem:
        return round(metres / 0.3048, precision);
    }
}

//--------------------------------------------------------------------------

function toLocaleLengthString(metres, locale, precision, invalidText) {
    if (!isFinite(metres) || (Math.abs(metres) > 0 && Math.abs(metres) < 1e-9) || Math.abs(metres) > 1e9) {
        return invalidText ? invalidText : "";
    }

    if (!locale) {
        locale = Qt.locale();
    }

    if (isNullOrUndefined(precision)) {
        precision = 3;
    }

    switch (locale.measurementSystem) {
    case QML.Locale.MetricSystem:
    case QML.Locale.ImperialUKSystem:
        return qsTr("%1 m").arg(numberToLocaleString(locale, round(metres, precision)));

    case QML.Locale.ImperialUSSystem:
    case QML.Locale.ImperialSystem:
        return qsTr("%1 ft").arg(numberToLocaleString(locale, round(metres / 0.3048, precision)));
    }
}

//--------------------------------------------------------------------------

function toLocaleSpeedString(metresPerSecond, locale, precision, invalidText) {
    if (!isFinite(metresPerSecond) || Math.abs(metresPerSecond) < 1e-9 || Math.abs(metresPerSecond) > 1e9) {
        return invalidText ? invalidText : "";
    }

    if (!locale) {
        locale = Qt.locale();
    }

    if (isNullOrUndefined(precision)) {
        precision = 2;
    }

    switch (locale.measurementSystem) {
    case QML.Locale.MetricSystem:
        return qsTr("%1 km/h").arg(numberToLocaleString(locale, round(metresPerSecond * 3.6, precision)));

    case QML.Locale.ImperialUKSystem:
    case QML.Locale.ImperialUSSystem:
    case QML.Locale.ImperialSystem:
        return qsTr("%1 mph").arg(numberToLocaleString(locale, round(metresPerSecond * 2.23694, precision)));
    }
}

//--------------------------------------------------------------------------

function numberFromLocaleString(locale, text) {
    var value;

    try {
        value = Number.fromLocaleString(getNumberLocale(locale), replaceAll(text, getNumberLocale(locale).groupSeparator, ""));
    } catch (e) {
        value = Number.NaN;
    }

    return value;
}

//--------------------------------------------------------------------------

function numberToLocaleString(locale, value, precision, groupSeparators) {
    var text;

    if (!isFinite(precision)) {
        text = value.toString();

        precision = 0;
        var decimalPointIndex = text.indexOf(".");
        if (decimalPointIndex >= 0) {
            precision = text.length - decimalPointIndex - 1;
        }
    }

    text = value.toLocaleString(getNumberLocale(locale), "", precision);

    if (!groupSeparators) {
        text = replaceAll(text, locale.groupSeparator, "");
    }

    return text;
}

//------------------------------------------------------------------------------
