({
    doInit: function (component, event, helper) {
        var recId = component.get('v.recordId');

        // Step 1: Check if projects already exist
        var checkAction = component.get('c.getProjectRecord');
        checkAction.setParams({ recordId: recId });
        checkAction.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS') {
                var exists = response.getReturnValue();
                if (exists) {
                    component.set('v.projectsExist', true);
                    component.set('v.isLoading', false);
                } else {
                    // Step 2: Load preview data
                    helper.loadPreview(component, recId);
                }
            } else {
                component.set('v.isLoading', false);
                helper.showToast('Error', 'Failed to load data. Please try again.', 'error');
            }
        });
        $A.enqueueAction(checkAction);
    },

    handleCreate: function (component, event, helper) {
        var recId = component.get('v.recordId');
        var rows  = component.get('v.previewRows');

        component.set('v.isLoading', true);

        var action = component.get('c.createProjectRecord');
        action.setParams({
            recordId    : recId,
            projectRows : rows
        });
        action.setCallback(this, function (response) {
            component.set('v.isLoading', false);
            if (response.getState() === 'SUCCESS') {
                helper.showToast('Success', 'Project records created successfully.', 'success');
                $A.get('e.force:closeQuickAction').fire();
                $A.get('e.force:refreshView').fire();
            } else {
                var errors = response.getError();
                var msg = (errors && errors[0] && errors[0].message)
                    ? errors[0].message
                    : 'An error occurred while creating projects.';
                helper.showToast('Error', msg, 'error');
            }
        });
        $A.enqueueAction(action);
    },

    handleCancel: function (component, event, helper) {
        $A.get('e.force:closeQuickAction').fire();
    }
})