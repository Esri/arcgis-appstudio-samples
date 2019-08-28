import QtQuick 2.7
import "../Assets"

Item {
    id: iconGraphicsModule

    Sources {
        id: sources
    }

    function getMapPlaceIcon(type) {
        var category = type;
        if(category.includes("Food") ||
                category.includes("Burgers") ||
                category.includes("Restaurant")||
                category.includes("Pizza")) {
            return sources.restaurantMapIcon;
        } else if(category.includes("Hotel")) {
            return sources.hospitalMapIcon;
        } else if(category.includes("Library")) {
            return sources.libraryMapIcon;
        } else if(category.includes("Hospital")) {
            return sources.hospitalMapIcon;
        } else if(category.includes("Shop") || category.includes("Store")) {
            return sources.shopsMapIcon;
        } else if(category.includes("Gas Station")) {
            return sources.gasMapIcon;
        } else if(category.includes("Bank") || category.includes("ATM")) {
            return sources.atmMapIcon;
        } else if(category.includes("Cinema") || category.includes("Movie")) {
            return sources.cinemaMapIcon;
        } else {
            return sources.pinMapIcon;
        }
    }

    // Function to get proper icon corresponding to directionText
    function getRouteIcon(direction) {
        if(direction.includes("Start at")) {
            return sources.originBlackIcon;
        } else if(direction.includes("Finish at")) {
            return sources.pinBlackIcon;
        } else if(direction.includes("Turn right") || direction.includes("Make sharp right") || direction.includes("Bear right")) {
            return sources.turnRightIcon;
        } else if(direction.includes("Turn left") || direction.includes("Make sharp left") || direction.includes("Bear left")) {
            return sources.turnLeftIcon;
        } else if(direction.includes("Go north") || direction.includes("Continue")) {
            return sources.northIcon;
        } else if(direction.includes("Go south")) {
            return sources.southIcon;
        } else {
            return sources.navigationIcon;
        }
    }

    function getListPlaceIcon(type) {

            var category = type;
            if(category.includes("Food") ||
                    category.includes("Burgers") ||
                    category.includes("Restaurant")||
                    category.includes("Pizza")) {
                return sources.restaurantBlackIcon;
            } else if(category.includes("Hotel")) {
                return sources.hotelBlackIcon;
            } else if(category.includes("Library")) {
                return sources.libraryBlackIcon;
            } else if(category.includes("Hospital")) {
                return sources.hospitalBlackIcon;
            } else if(category.includes("Shop") || category.includes("Store")) {
                return sources.shopsBlackIcon;
            } else if(category.includes("Gas Station")) {
                return sources.gasBlackIcon;
            } else if(category.includes("Bank") || category.includes("ATM")) {
                return sources.atmBlackIcon;
            } else if(category.includes("Cinema") || category.includes("Movie")) {
                return sources.cinemaBlackIcon;
            } else {
                return sources.pinBlackIcon;
            }
        }
}
