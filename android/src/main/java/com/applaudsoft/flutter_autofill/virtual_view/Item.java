package com.applaudsoft.flutter_autofill.virtual_view;

import android.graphics.Rect;
import android.os.Build;
import android.text.TextUtils;
import android.util.Log;
import android.view.autofill.AutofillValue;
import android.widget.EditText;
import android.widget.TextView;

import java.util.Arrays;

import static android.view.View.AUTOFILL_TYPE_DATE;
import static android.view.View.AUTOFILL_TYPE_TEXT;

public class Item<T> {
    private static final String TAG = "Item";
    final int id;
    final String idEntry;
    final boolean sensitiveValue;
    final String[] hints;
    final int type;
    private T value;
    boolean focused = false;
    boolean editable = true;
    Rect coordinates;
    private ValueWatcher<T> mListener;

    public interface ValueWatcher<R> {
        void onValueChanged(R value);
    }

    public Item(int id, String idEntry, Rect coordinates, String[] hints, int type, boolean editable, boolean sensitiveValue, ValueWatcher<T> listener) {
        this.coordinates = coordinates;
        this.id = id;
        this.idEntry = idEntry;
        this.sensitiveValue = sensitiveValue;
        this.editable = editable;
        this.hints = hints;
        this.type = type;
        this.mListener = listener;
    }

    @Override
    public String toString() {
        return id + "/" + idEntry + ": "
                + (value)
                + " (" + Util.getAutofillTypeAsString(type) + ")"
                + (editable ? " (editable)" : " (non-editable)")
                + (sensitiveValue ? " (sensitive)" : " (non-sensitive)")
                + (hints == null ? " (no hints)" : " ( " + Arrays.toString(hints) + ")");
    }

    String getClassName() {
        return editable ? EditText.class.getName() : TextView.class.getName();
    }

    AutofillValue getAutofillValue() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return null;
        }
        switch (type) {
            case AUTOFILL_TYPE_TEXT:
                String text = String.valueOf(value);
                return (TextUtils.getTrimmedLength(text) > 0)
                        ? AutofillValue.forText(text)
                        : null;
            case AUTOFILL_TYPE_DATE:
                if (value != null && value instanceof Long) {
                    return AutofillValue.forDate((Long) value);
                }
                return null;
            default:
                return null;
        }
    }

//    protected AccessibilityNodeInfo provideAccessibilityNodeInfo(View parent, Context context) {
//        final AccessibilityNodeInfo node = AccessibilityNodeInfo.obtain();
//        node.setSource(parent, id);
//        node.setPackageName(context.getPackageName());
//        node.setClassName(getClassName());
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2) {
//            node.setEditable(editable);
//            node.setViewIdResourceName(idEntry);
//        }
//        node.setVisibleToUser(true);
//        if (coordinates != null) {
//            node.setBoundsInScreen(coordinates);
//        }
//        if (TextUtils.getTrimmedLength(text) > 0) {
//            // TODO: Must checked trimmed length because input fields use 8 empty spaces to
//            // set width
//            node.setValue(text);
//        }
//        return node;
//    }


    public boolean isFocused() {
        return focused;
    }

    public void setFocused(boolean focused) {
        this.focused = focused;
    }


    public Rect getCoordinates() {
        return coordinates;
    }

    public void setCoordinates(Rect coordinates) {
        this.coordinates = coordinates;
    }

    void setValue(T value) {
        if (!editable) {
            Log.w(TAG, "Item for id " + id + " is not editable: " + this);
            return;
        }
        this.value = value;
        if (mListener != null) {
            mListener.onValueChanged(value);
        }
    }

}