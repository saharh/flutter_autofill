package com.applaudsoft.flutter_autofill.virtual_view;

import android.annotation.TargetApi;
import android.content.Context;
import android.content.res.Resources;
import android.graphics.Rect;
import android.os.Build;
import android.util.AttributeSet;
import android.util.Log;
import android.util.SparseArray;
import android.view.View;
import android.view.ViewStructure;
import android.view.autofill.AutofillValue;

import java.util.Collection;
import java.util.HashMap;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import static com.applaudsoft.flutter_autofill.virtual_view.Util.bundleToString;

public class AutoFillDummyView extends View {
    private static final String TAG = "AutoFillDummyView";
    protected static final boolean DEBUG = true;
    protected static final boolean VERBOSE = false;
    private HashMap<String, Item> mVirtualViews = new HashMap<>();

    public AutoFillDummyView(Context context) {
        super(context);
    }

    public AutoFillDummyView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
    }

    public AutoFillDummyView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    public AutoFillDummyView(Context context, @Nullable AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
    }

    @Override
    public void onMeasure(int widthSpecs, int heightSpecs) {
        super.onMeasure(widthSpecs, heightSpecs);
        setMeasuredDimension(getScreenWidth(), getScreenHeight());
    }

    public static int getScreenWidth() {
        return Resources.getSystem().getDisplayMetrics().widthPixels;
    }

    public static int getScreenHeight() {
        return Resources.getSystem().getDisplayMetrics().heightPixels;
    }

    @Override
    public void onProvideAutofillVirtualStructure(ViewStructure structure, int flags) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return;
        }
        // Build a ViewStructure that will get passed to the AutofillService by the framework
        // when it is time to find autofill suggestions.
        structure.setClassName(getClass().getName());
//        int childrenSize = mVirtualViews.size();
        int childrenSize = 0;
        for (Item item : mVirtualViews.values()) {
            childrenSize += item.coordinates != null ? 1 : 0;
        }
        if (DEBUG) {
            Log.d(TAG, "onProvideAutofillVirtualStructure(): flags = " + flags + ", items = "
                    + childrenSize + ", extras: " + bundleToString(structure.getExtras()));
        }
        int index = structure.addChildCount(childrenSize);
        // Traverse through the view hierarchy, including virtual child views. For each view, we
        // need to set the relevant autofill metadata and add it to the ViewStructure.
        for (Item item : mVirtualViews.values()) {
            if (DEBUG) {
                Log.d(TAG, "Adding new child at index " + index + ": " + item);
            }
            Rect coords = item.coordinates;
            if (coords == null) {
                continue;
            }
            ViewStructure child = structure.newChild(index);
            child.setAutofillId(structure.getAutofillId(), item.id);
            child.setAutofillHints(item.hints);
            child.setAutofillType(item.type);
            child.setAutofillValue(item.getAutofillValue());
            child.setDataIsSensitive(!item.sensitiveValue);
            child.setFocused(item.focused);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                child.setImportantForAutofill(IMPORTANT_FOR_AUTOFILL_YES);
            }
            child.setVisibility(View.VISIBLE);
            child.setDimens(coords.left, coords.top, 0, 0, coords.width(), coords.height());
            child.setId(item.id, getContext().getPackageName(), null, item.idEntry);
            child.setClassName(item.getClassName());
            child.setDimens(coords.left, coords.top, 0, 0, coords.width(), coords.height());
            index++;
        }
    }

    @Override
    public void autofill(AutofillValue value) {
        super.autofill(value);
        Log.d("AutoFill", "autofill - value: " + value.toString());
    }

    @Override
    public void autofill(@NonNull SparseArray<AutofillValue> values) {
        super.autofill(values);
        Log.d("AutoFill", "autofill - values: " + values.toString());
        if (values.size() == 0) {
            return;
        }
//        DateFormat df = android.text.format.DateFormat.getDateFormat(getContext());
        for (int i = 0; i < values.size(); i++) {
            int id = values.keyAt(i);
            AutofillValue value = values.valueAt(i);
            Collection<Item> vals = mVirtualViews.values();
            Item item = null;
            for (Item val : vals) {
                if (val.id == id) {
                    item = val;
                    break;
                }
            }
            if (item == null) {
                Log.w(TAG, "No item for id " + id);
                continue;
            }

            if (!item.editable) {
                Log.w(TAG, "Trying to set value of non-editable item.");
//                showError(context.getString(R.string.message_autofill_readonly, item.text));
                continue;
            }

            // Check if the type was properly set by the autofill service
            if (DEBUG) {
                Log.d(TAG, "Validating " + i
                        + ": expectedType=" + Util.getAutofillTypeAsString(item.type)
                        + "(" + item.type + "), value=" + value);
            }
            boolean valid = false;
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                if (value.isText() && item.type == AUTOFILL_TYPE_TEXT) {
                    item.setValue(value.getTextValue());
                    valid = true;
                } else if (value.isDate() && item.type == AUTOFILL_TYPE_DATE) {
                    item.setValue(value.getDateValue());
//                    item.setValue(df.format(new Date(value.getDateValue())));
                    valid = true;
                } else {
                    Log.w(TAG, "Unsupported type: " + value);
                }
            }
            if (!valid) {
                Log.w(TAG, "Invalid value: " + value);
//                item.setValue("Invalid");
//                item.text = context.getString(R.string.message_autofill_invalid);
            }
        }
    }

    public void addItem(Item item) {
        mVirtualViews.put(item.idEntry, item);
    }

    public Item getItem(String idEntry) {
        return mVirtualViews.get(idEntry);
    }
}
