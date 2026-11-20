({
    loadPreview: function (component, recId) {
        var action = component.get('c.getProjectPreview');
        action.setParams({ recordId: recId });
        action.setCallback(this, function (response) {
            component.set('v.isLoading', false);
            if (response.getState() === 'SUCCESS') {
                var rows = response.getReturnValue();
                // Set default recordType = Inhouse on each row
                rows.forEach(function (row) {
                    row.recordType = 'Inhouse';
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