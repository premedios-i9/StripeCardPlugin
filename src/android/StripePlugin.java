package com.fidelidade.stripecardplugin;

import android.content.Intent;
import android.util.Log;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.stripe.android.Stripe;

public class StripePlugin extends CordovaPlugin {

    private Stripe stripe;
    private String publishableKey;
    private String clientSecret;

    private String TAG = StripePlugin.class.getSimpleName();
    private CallbackContext callbackContext;

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        publishableKey = Utils.getAPIKeyFromConfigXML(cordova.getContext(), "STRIPE_PUBLISHABLE_KEY");
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        this.callbackContext = callbackContext;

        if (action != null) {

            switch (Actions.getActionByName(action)) {
                case ADDPAYMENTCARD:
                    addPaymentCard(args);
                    break;
                case INVALID:
                    callbackContext.error(Actions.INVALID.getDescription());
                    break;
            }
        } else {
            Log.v(TAG, Actions.INVALID.getDescription());
            callbackContext.error(Actions.INVALID.getDescription());
            return false;
        }

        return true;
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent intent) {
        super.onActivityResult(requestCode, resultCode, intent);

        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put("LAST4", intent.getStringExtra("LAST4"));
            jsonObject.put("BRAND", intent.getStringExtra("BRAND"));
            jsonObject.put("EXPIRYDATE", intent.getStringExtra("EXPIRYDATE"));
            jsonObject.put("TOKEN", intent.getStringExtra("TOKEN"));
            jsonObject.put("ERRORMESSAGE", intent.getStringExtra("ERRORMESSAGE"));

            PluginResult pluginResult = new PluginResult(resultCode == 100 ? PluginResult.Status.OK : PluginResult.Status.ERROR, jsonObject);
            pluginResult.setKeepCallback(true);

            callbackContext.sendPluginResult(pluginResult);
        } catch (JSONException e) {
            e.printStackTrace();
            callbackContext.error(e.getMessage());
        }


    }

    private void openCardViewCordova(JSONArray args) {
        try {
            Intent addPaymentCardIntent = new Intent(cordova.getContext(), AddPaymentCardActivity.class);
            addPaymentCardIntent.putExtra("STRIPE_PUBLISHABLE_KEY", publishableKey);
            addPaymentCardIntent.putExtra("STRIPE_CLIENT_SECRET", args.get(0).toString());
            cordova.startActivityForResult((CordovaPlugin) this, addPaymentCardIntent, 100);
            PluginResult pluginResult = new PluginResult(PluginResult.Status.OK);
            pluginResult.setKeepCallback(true);
        } catch (JSONException e) {
            e.printStackTrace();
            Intent addPaymentCardIntent = new Intent(cordova.getContext(), AddPaymentCardActivity.class);
            addPaymentCardIntent.putExtra("STRIPE_PUBLISHABLE_KEY", publishableKey);
            cordova.startActivityForResult((CordovaPlugin) this, addPaymentCardIntent, 100);
        }
    }

    private enum Actions {

        ADDPAYMENTCARD("addPaymentCard", "Add payment card"),
        INVALID("", "Invalid or not found action!");

        private String action;
        private String description;

        Actions(String action, String description) {
            this.action = action;
            this.description = description;
        }

        public String getDescription() {
            return description;
        }

        public static Actions getActionByName(String action) {
            for (Actions a : Actions.values()) {
                if (a.action.equalsIgnoreCase(action)) {
                    return a;
                }
            }
            return INVALID;
        }
    }
}
