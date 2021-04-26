package com.fidelidade.stripecardplugin;

import android.content.Context;
import android.content.res.XmlResourceParser;

public class Utils {
    public static String getAPIKeyFromConfigXML(Context context, String keyName) {
        String config = "";
        int id = context.getResources().getIdentifier("config", "xml", context.getPackageName());
        if (id == 0) {
            return config;
        }

        XmlResourceParser xml = context.getResources().getXml(id);

        int eventType = -1;
        while (eventType != XmlResourceParser.END_DOCUMENT) {

            if (eventType == XmlResourceParser.START_TAG) {
                if (xml.getName().equals("preference")) {
                    String name = xml.getAttributeValue(null, "name");
                    String value = xml.getAttributeValue(null, "value");

                    if (name.equals(keyName) && value != null) {
                        config=value;
                    }
                }
            }

            try {
                eventType = xml.next();
            } catch (Exception e) {
                //PluginLogger.error(e, "Error parsing config file");
            }
        }

        return config;
    }
}
