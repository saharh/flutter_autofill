package com.applaudsoft.flutter_autofill.virtual_view;

import android.graphics.Rect;

public class TextItem extends Item<String> {
    public TextItem(int id, String idEntry, Rect coordinates, String[] hints, int type, boolean editable, boolean sensitiveValue, ValueWatcher<String> listener) {
        super(id, idEntry, coordinates, hints, type, editable, sensitiveValue, listener);
    }
}
