import QtQuick 2.7

ListModel {

    function sort (attr) {

    }

    function sortByStringAttribute (str, order) {
        if (!order) order = "desc"
        var orderInt = order === "desc" ? 1 : -1,
            comp = function (a, b) {
            return orderInt * (a[str].localeCompare(b[str]))
        }
        baseSort(comp)
    }

    function sortByNumberAttribute (num, order) {
        if (!order) order = "desc"
        var orderInt = order === "desc" ? 1 : -1,
            comp = function(a, b) {
            return orderInt * (a[num] - b[num])
        }
        baseSort(comp)
    }

    function baseSort (comp) {
        var arr = new Array(count)
        for (var i = 0; i < count; i++) {
            arr[i] = i
        }
        arr = arr.sort(function (a,b) { return comp(get(a), get(b)) })
        for (var j = 0; j < count; j++) {
            var k = arr[j]
            move(k, j, 1)
            arr = arr.map(function(e) { return e >= j && e < k ? e + 1 : e } )
        }
    }

    function getItemByAttributes (attrs) {
        // Only for objects with values that are strings, numbers, booleans
        // E.g. attrs = {"name": "Jake", "number": 1, "check": true}
        var attrKeys = []
        for (var k in attrs) attrKeys.push(k)
        for (var i=0; i<count; i++) {
            var item = get(i),
                allAttributesPresentInItem = true
            for (var j=0; j<attrKeys.length; j++) {
                var key = attrKeys[j]
                if (attrs[key] !== item[key] || typeof attrs[key] === "undefined" || typeof item[key] === "undefined") {
                    allAttributesPresentInItem = false
                    break
                }
            }
            if (allAttributesPresentInItem) return item
        }
    }

    function addIfUnique (item, uniqueKey) {
        var uniqueAttr = {}
        uniqueAttr[uniqueKey] = item[uniqueKey] //? item[uniqueKey] : null

        var itemCopyInModel = getItemByAttributes(uniqueAttr)

        if (typeof itemCopyInModel === "undefined" || itemCopyInModel === null) {
            append(item)
            //console.log("Adding new item!")
        }
    }

    function replaceUnique (item, uniqueKey) {

    }

}
