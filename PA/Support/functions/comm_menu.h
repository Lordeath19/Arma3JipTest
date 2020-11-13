class CfgCommunicationMenu
{
    class CARGO
    {
        text = "Cargo Drop"; // Text displayed in the menu and in a notification
        submenu = "#USER:CargodropsubMenu"; // Submenu opened upon activation
        icon = "";//"\a3\Ui_f\data\GUI\Cfg\CommunicationMenu\supplydrop_ca.paa"; // Icon displayed permanently next to the command menu
        cursor = "\a3\Ui_f\data\IGUI\Cfg\Cursors\iconCursorSupport_ca.paa"; // Custom cursor displayed when the item is selected
        enable = "1"; // Simple expression condition for enabling the item
    };

    class Transport
    {
        text = "Helicopter Airlift"; // Text displayed in the menu and in a notification
        submenu = "#USER:TransportsubMenu"; // Submenu opened upon activation (expression is ignored when submenu is not empty.)
        icon = "";//"\a3\Ui_f\data\GUI\Cfg\CommunicationMenu\transport_ca.paa"; // Icon displayed permanently next to the command menu
        cursor = "\a3\Ui_f\data\IGUI\Cfg\Cursors\iconCursorSupport_ca.paa"; // Custom cursor displayed when the item is selected
        enable = "1"; // Simple expression condition for enabling the item
    };
    class Artillery
    {
        text = "Artillery"; // Text displayed in the menu and in a notification
        submenu = "#USER:TransportsubMenu"; // Submenu opened upon activation (expression is ignored when submenu is not empty.)
        icon = "";//"\a3\Ui_f\data\GUI\Cfg\CommunicationMenu\transport_ca.paa"; // Icon displayed permanently next to the command menu
        cursor = "\a3\Ui_f\data\IGUI\Cfg\Cursors\iconCursorSupport_ca.paa"; // Custom cursor displayed when the item is selected
        enable = "1"; // Simple expression condition for enabling the item
    };
};