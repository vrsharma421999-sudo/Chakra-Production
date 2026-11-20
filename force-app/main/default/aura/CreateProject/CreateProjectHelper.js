({
    loadPreview: function (component, recId) {
        var action = component.get('c.getProjectPreview');
        action.setParams({ recordId: recId });
        action.setCallback(this, function (response) {
            component.set('v.isLoading', false);
            if (response.getState() === 'SUCCESS') {
                var rows = response.getReturnValue();
                // Check if Chakr Marjak PO Verification - Added by Vanshika 20-Nov-2026
                var isChakr = false;
                if (rows && rows.length > 0 && rows[0].isChakrMarjak) {
                    isChakr = true;
                }
                component.set('v.isChakrMarjak', isChakr);
                rows.forEach(function (row) {
                    // Lock to Chakr_Marjak if Chakr Marjak, otherwise default to Inhouse - By Vanshika 20-Nov-2026
                    if (isChakr) {
                        row.recordType = 'Chakr_Marjak';
                    } else if (!row.recordType) {
                        row.recordType = 'Inhouse';
                    }
                });
                component.set('v.previewRows', rows);
            } else {
                this.showToast('Error', 'Failed to load project preview.', 'error');
            }
        });
        $A.enqueueAction(action);
    },

    showToast: function (title, message, type) {
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({ title: title, message: message, type: type });
        toastEvent.fire();
    }
})
