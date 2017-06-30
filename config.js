
{
	"license": [
		"| Copyright 2014 Esri",
		"|",
		"| Licensed under the Apache License, Version 2.0 (the 'License');",
		"| you may not use this file except in compliance with the License.",
		"| You may obtain a copy of the License at",
		"|",
		"|    http://www.apache.org/licenses/LICENSE-2.0",
		"|",
		"| Unless required by applicable law or agreed to in writing, software",
		"| distributed under the License is distributed on an 'AS IS' BASIS,",
		"| WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.",
		"| See the License for the specific language governing permissions and",
		"| limitations under the License."
	],

	"documentation": [
		"For help configuring this application, see:",
		"http://links.esri.com/localgovernment/help/MapsAndAppsGallery"
	],

	"values": {
		"group": "ef92fa750621462e9687de58579fd521",
		"appid": "",
		"oauthappid": "",
		"applicationName": "AppStudio Apps Showcase Gallery",
		"theme": "#8400a8",
		"defaultLayout": "grid",
		"sortField": "numViews",
		"sortOrder": "desc",
		"showRatings": false,
		"showViews": false,
		"displaySharingAttribute": false,
		"itemSearchDefaultValue": "",
		"enableAutoComplete": false,
		"searchString": "",
		"searchType": "",
		"showTagCloud": false,
		"tagCloudFontMinValue": 15,
		"tagCloudFontMaxValue": 20,
		"tagCloudFontUnits": "px",
		"showLicenseInfo": false,
		"showAttribution": false,
		"showComments": false,
		"mapViewer": "",
		"showOverviewMap": false,
		"showMapSearch": false,
		"zoomLevel": "12",
		"locatorDefaultAddress": "139 W Porter Ave Naperville IL 60540",
		"defaultLocatorSymbol": "/themes/images/redpushpin.png",
		"markupSymbolWidth": "35",
		"markupSymbolHeight": "35",
		"showBasemapGallery": false,
		"basemapGroupTitle": "",
		"basemapGroupOwner": "",
		"noThumbnail": "themes/images/thumbnailNotAvailable.png",
		"portalURL": "http://www.arcgis.com",
		"geometryService": "",
		"proxyUrl": "",
		"headerTextColor": "#fff",
		"bodyTextColor": "#515151"
	},
	"configurationSettings": [{
		"category": "<b>App Settings</b>",
		"fields": [{
			"type": "subcategory",
			"label": "App settings"
		}, {
			"type": "group",
			"label": "SELECT GROUP",
			"tooltip": "Group displayed in the application"
		}, {
			"label": "Application title",
			"fieldName": "applicationName",
			"type": "string",
			"tooltip": "Application title displayed in header"
		}, {
			"label": "Application logo",
			"fieldName": "applicationIcon",
			"type": "string",
			"tooltip": "Icon in top left corner of application. Icon should be 48px high."
		}]
	}, {
		"category": "<b>Gallery Settings</b>",
		"fields": [

			{
				"type": "subcategory",
				"label": "Gallery settings"
			}, {
				"label": "Default gallery layout",
				"fieldName": "defaultLayout",
				"type": "string",
				"options": [{
					"label": "Grid",
					"value": "grid"
				}, {
					"label": "List",
					"value": "list"
				}],
				"tooltip": "Default layout of gallery contents"
			}, {
				"label": "Sort gallery items by",
				"fieldName": "sortField",
				"type": "string",
				"options": [{
					"label": "Modified Date",
					"value": "modified"
				}, {
					"label": "Number of Views",
					"value": "numViews"
				}, {
					"label": "Name",
					"value": "title"
				}],
				"tooltip": "Default sort method for gallery contents"
			}, {
				"label": "Gallery items order",
				"fieldName": "sortOrder",
				"type": "string",
				"options": [{
					"label": "Descending",
					"value": "desc"
				}, {
					"label": "Ascending",
					"value": "asc"
				}],
				"tooltip": "Sorting order of gallery contents"
			}, {
				"label": "Show tag cloud for filtering gallery items",
				"fieldName": "showTagCloud",
				"type": "boolean",
				"tooltip": "Enable to show a tag cloud for filtering gallery content"
			}
		]
	}, {
		"category": "<b>Map Viewer Settings</b>",
		"fields": [{
			"type": "subcategory",
			"label": "Map viewer settings"
		}, {
			"label": "Map viewer",
			"fieldName": "mapViewer",
			"type": "string",
			"options": [{
				"label": "Simple Viewer",
				"value": "simple"
			}, {
				"label": "Map Viewer",
				"value": "arcgis"
			}],
			"tooltip": "Choose a viewer for opening maps"
		}, {
			"label": "Default search address",
			"fieldName": "locatorDefaultAddress",
			"type": "string",
			"tooltip": "Default address for the map search in the Simple Viewer"
		}, {
			"label": "Zoom level for selected search results",
			"fieldName": "zoomLevel",
			"type": "number",
			"tooltip": "Map zoom level for viewing selected features"
		}, {
			"label": "Basemap group",
			"fieldName": "basemapGroupTitle",
			"type": "string",
			"tooltip": "Name of a public group containing basemaps, or leave blank to use the organization's basemap group",
			"placeholder": "Default organization basemaps"
		}, {
			"label": "Basemap group owner",
			"fieldName": "basemapGroupOwner",
			"type": "string",
			"tooltip": "Username of basemap group owner",
			"placeholder": "Default organization basemaps"
		}]
	}, {
		"category": "<b>App color</b>",
		"fields": [{
			"type": "subcategory",
			"label": "App color"
		}, {
			"type": "paragraph",
			"value": "User can change the theme settings and choose different colors for header, body and button sections"
		}, {
			"label": "Header text color",
			"tooltip": "Set header text color",
			"type": "color",
			"sharedThemeProperty": "header.text",
			"fieldName": "headerTextColor"
		}, {
			"label": "Header background color",
			"fieldName": "theme",
			"type": "color",
			"tooltip": "Color of header bar and widget windows",
			"sharedThemeProperty": "header.background"
		}, {
			"label": "Body text color",
			"tooltip": "Set body text color",
			"type": "color",
			"sharedThemeProperty": "body.text",
			"fieldName": "bodyTextColor"
		}]
	}]

}
