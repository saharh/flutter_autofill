package com.applaudsoft.flutter_autofill;

import android.graphics.Rect;
import android.view.View;
import android.view.ViewGroup;
import android.view.autofill.AutofillManager;
import android.view.autofill.AutofillValue;

import com.applaudsoft.flutter_autofill.virtual_view.AutoFillDummyView;
import com.applaudsoft.flutter_autofill.virtual_view.DateItem;
import com.applaudsoft.flutter_autofill.virtual_view.Item;
import com.applaudsoft.flutter_autofill.virtual_view.TextItem;

import org.json.JSONException;
import org.json.JSONObject;

import java.nio.ByteBuffer;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import static android.view.View.AUTOFILL_TYPE_DATE;
import static android.view.View.AUTOFILL_TYPE_TEXT;

/**
 * FlutterAutofillPlugin
 */
public class FlutterAutofillPlugin implements MethodCallHandler {
    private static final String AF_CHANNEL = "AF_CHANNEL";
    private final Registrar registrar;
    private AutoFillDummyView dummyView;
    private AutofillManager afm;

    private FlutterAutofillPlugin(Registrar registrar) {
        this.registrar = registrar;
        init();
    }

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_autofill");
        channel.setMethodCallHandler(new FlutterAutofillPlugin(registrar));
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (call.method.equals("registerWidget")) {
            Map<String, ?> args = call.arguments();
            registerWidget(args);
            result.success(null);
        } else if (call.method.equals("updateWidgetCoordinates")) {
            Map<String, ?> args = call.arguments();
            boolean res = updateWidgetCoordinates(args);
            result.success(res);
        } else if (call.method.equals("updateWidgetValue")) {
            Map<String, ?> args = call.arguments();
            updateWidgetValue(args);
            result.success(null);
        } else if (call.method.equals("notifyFocus")) {
            Map<String, ?> args = call.arguments();
            notifyFocus(args);
            result.success(null);
        } else if (call.method.equals("cancel")) {
            handleCancel();
            result.success(null);
        } else if (call.method.equals("commit")) {
            handleCommit();
            result.success(null);
        } else {
            result.notImplemented();
        }
    }

    private void updateWidgetValue(Map<String, ?> args) {
        if (autoFillUnavailable()) {
            return;
        }
        final String idEntry = (String) args.get("id");
        Object value = args.get("value");
        int id = getVirtualIdForEntryId(idEntry);
        AutofillValue afValue;
        if (value instanceof Long) {
            afValue = AutofillValue.forDate((Long) value);
        } else {
            afValue = AutofillValue.forText(String.valueOf(value));
        }
        afm.notifyValueChanged(dummyView, id, afValue);
    }

    private void handleCancel() {
        if (autoFillUnavailable()) {
            return;
        }
        afm.cancel();
    }

    private void handleCommit() {
        if (autoFillUnavailable()) {
            return;
        }
        afm.commit();
    }

    private void init() {
        if (registrar.activity() == null) return;
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            View decorView = registrar.activity().getWindow().getDecorView();
            ViewGroup rootView = decorView.findViewById(android.R.id.content);
            afm = registrar.activity().getSystemService(AutofillManager.class);
            if (afm == null || !afm.isAutofillSupported()) {
                return;
            }
            dummyView = new AutoFillDummyView(registrar.context());
            dummyView.setImportantForAutofill(View.IMPORTANT_FOR_AUTOFILL_YES);
            rootView.addView(dummyView);
        }
    }

    private void notifyFocus(Map<String, ?> args) {
        if (autoFillUnavailable()) {
            return;
        }
        String idEntry = (String) args.get("id");
        int id = getVirtualIdForEntryId(idEntry);
        Boolean focused = (Boolean) args.get("focused");
        Item item = dummyView.getItem(idEntry);
        item.setFocused(focused);
        if (focused) {
            afm.notifyViewEntered(dummyView, id, item.getCoordinates());
        } else {
            afm.notifyViewExited(dummyView, id);
        }
    }

    private boolean autoFillUnavailable() {
        return afm == null || android.os.Build.VERSION.SDK_INT < android.os.Build.VERSION_CODES.O;
    }

    private boolean updateWidgetCoordinates(Map<String, ?> args) {
        if (autoFillUnavailable()) {
            return false;
        }
        String idEntry = (String) args.get("id");
        Item item = dummyView.getItem(idEntry);
        if (item == null) {
            return false;
        }
        Map<String, Double> coordinates = (Map<String, Double>) args.get("coordinates");
        Double left = coordinates.get("left");
        Double top = coordinates.get("top");
        Double right = coordinates.get("right");
        Double bottom = coordinates.get("bottom");
        item.setCoordinates(new Rect(left.intValue(), top.intValue(), right.intValue(), bottom.intValue()));
        return true;
    }

    private void registerWidget(Map<String, ?> args) {
        if (autoFillUnavailable()) {
            return;
        }
        final String idEntry = (String) args.get("id");
        int id = getVirtualIdForEntryId(idEntry);
        List<String> afHints = (List<String>) args.get("autofill_hints");
        String[] afHintsArr = new String[afHints.size()];
        afHints.toArray(afHintsArr);
        Integer afType = (Integer) args.get("autofill_type");
        Boolean editable = (Boolean) args.get("editable");
        Boolean sensitiveData = (Boolean) args.get("sensitive_data");

        afType = afType != null ? afType : AUTOFILL_TYPE_TEXT;
        editable = editable != null ? editable : true;
        sensitiveData = sensitiveData != null ? sensitiveData : true;

        Item item;
        if (afType == AUTOFILL_TYPE_DATE) {
            item = new DateItem(id, idEntry, null, afHintsArr, afType, editable, sensitiveData, new Item.ValueWatcher<Long>() {
                @Override
                public void onValueChanged(Long value) {
                    sendValueToDart(value, idEntry);
                }
            });
        } else {
            item = new TextItem(id, idEntry, null, afHintsArr, afType, editable, sensitiveData, new Item.ValueWatcher<String>() {
                @Override
                public void onValueChanged(String value) {
                    sendValueToDart(value, idEntry);
                }
            });
        }
        dummyView.addItem(item);
    }

    private void sendValueToDart(Object value, String idEntry) {
        JSONObject obj = new JSONObject();
        try {
            obj.put("id", idEntry);
            obj.put("value", value);
            sendEventToDart(obj);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private int getVirtualIdForEntryId(String idEntry) {
        return Math.abs(idEntry.hashCode());
    }

    private void sendEventToDart(final JSONObject params) {
        byte[] bytes = params.toString().getBytes();
        ByteBuffer message = ByteBuffer.allocateDirect(bytes.length);
        message.put(bytes);
        registrar.view().send(AF_CHANNEL, message, new BinaryMessenger.BinaryReply() {
            @Override
            public void reply(ByteBuffer byteBuffer) {
                //
            }
        });
    }
}
