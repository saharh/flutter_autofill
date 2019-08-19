package com.applaudsoft.flutter_autofill.virtual_view;

import android.graphics.Rect;

public class DateItem extends Item<Long> {
    public DateItem(int id, String idEntry, Rect coordinates, String[] hints, int type, boolean editable, boolean sensitiveValue, ValueWatcher<Long> listener) {
        super(id, idEntry, coordinates, hints, type, editable, sensitiveValue, listener);
    }
}
