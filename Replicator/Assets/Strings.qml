import QtQuick 2.7

Item {
    readonly property string homepage_welcome: qsTr("Hello, welcome to")
    readonly property string homepage_app_description: qsTr("Copy your ArcGIS AppStudio apps from one organization to the other in just 3 easy steps!")
    readonly property string homepage_get_start: qsTr("GET STARTED")

    readonly property string step1_description: qsTr("Sign in to both organization accounts.")
    readonly property string sign_in: qsTr("SIGN IN")
    readonly property string source_account: qsTr("Source account")
    readonly property string dest_account: qsTr("Destination account")

    readonly property string select_account_type: qsTr("Select the account type:")
    readonly property string arcgis_enterprise_url: qsTr("ArcGIS Enterprise URL:")
    readonly property string arcgis_online: qsTr("ArcGIS Online")
    readonly property string arcgis_enterprise: qsTr("ArcGIS Enterprise")

    readonly property string step2_description: qsTr("Select the app you would like to copy.")
    readonly property string step2_showing: qsTr("Showing %L1 of %L2")
    readonly property string step2_myapps: qsTr("My apps")
    readonly property string step2_allapps: qsTr("All apps")

    readonly property string step3_description: qsTr("Does everything look right?")
    readonly property string source_app: qsTr("App")

    readonly property string step4_success: qsTr("Copy completed!")
    readonly property string step4_failed: qsTr("Copy failed.")
    readonly property string copy_another: qsTr("TRANSFER ANOTHER")
    readonly property string try_again: qsTr("TRY AGAIN")
    readonly property string done: qsTr("DONE")
    readonly property string share_app: qsTr("COPY URL")

    readonly property string step_no: qsTr("Step %1")
    readonly property string back: qsTr("BACK")
    readonly property string next: qsTr("NEXT")
    readonly property string confirm: qsTr("YES, COPY NOW")

    readonly property string just_now: qsTr("Just now")
    readonly property string single_minute: qsTr("1 minute ago")
    readonly property string multi_minutes: qsTr("%1 minutes ago")
    readonly property string single_hour: qsTr("1 hour ago")
    readonly property string multi_hours: qsTr("%1 hours ago")
    readonly property string single_day: qsTr("1 day ago")
    readonly property string multi_days: qsTr("%1 days ago")
    readonly property string single_week: qsTr("1 week ago")
    readonly property string multi_weeks: qsTr("%1 weeks ago")

    readonly property string action_1: qsTr("Fetching appinfo...")
    readonly property string action_2: qsTr("Downloading package...")
    readonly property string action_3: qsTr("Downloading thumbnail")
    readonly property string action_4: qsTr("Creating new item...")
    readonly property string action_5: qsTr("Uploading package...")
}
