import { LightningElement, api, wire, track } from 'lwc';
import getAssets from '@salesforce/apex/QuoteAssetController.getAssets';
import getServiceYearOptions from '@salesforce/apex/QuoteAssetController.getServiceYearOptions';
import saveQuoteLines from '@salesforce/apex/QuoteAssetController.saveQuoteLines';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class AddProductonQuote extends LightningElement {

    @api recordId; // Quote Id
    @track rows = [];
    wiredAssetResult;
    @track serviceYearOptions = [];


    
    @wire(getServiceYearOptions)
    wiredServiceYearOptions({ data, error }) {
        if (data) {
            console.log('Service Year Options loaded from Apex:', JSON.stringify(data));
            this.serviceYearOptions = data;
        } else if (error) {
            console.error('Error loading Service Year options from Apex:', error);
            this.showToast('Error', 'Failed to load Service Year options', 'error');
        }
    }

    /* =========================
       Fetch Assets from Apex
       ========================= */
    @wire(getAssets, { quoteId: '$recordId' })
    wiredAssets(result) {
        this.wiredAssetResult = result;
        const { data, error } = result;

        if (data) {
            console.log('Data from getAssets:', JSON.stringify(data));
            this.rows = data.map(row => {
                return {
                    ...row,
                    serviceYear: row.serviceYear ? String(row.serviceYear) : '',
                    disablePrice: !row.selected,
                    disableDiscount: !row.selected,

                    discount: row.discount || 0
                };
            });
        } else if (error) {
            console.error('Error in getAssets:', error);
            this.showToast('Error', 'Failed to load products', 'error');
        }
    }

    /* =========================
       Service Year Change
       ========================= */
    handleServiceYearChange(event) {
        const index = event.target.dataset.index;
        this.rows[index].serviceYear = event.target.value;
        this.rows = [...this.rows];
    }

    /* =========================
       Checkbox Selection
       ========================= */
    handleSelect(event) {
        const index = event.target.dataset.index;
        const isChecked = event.target.checked;

        this.rows[index].selected = isChecked;
        this.rows[index].disablePrice = !isChecked;
        //this.rows[index].discount = isChecked ? 0 : this.rows[index].discount;
        this.rows[index].disableDiscount = !isChecked;

        this.rows = [...this.rows];
    }

    /* =========================
       Price Change
       ========================= */
    handlePriceChange(event) {
        const index = event.target.dataset.index;
        this.rows[index].price = event.target.value;
        this.rows = [...this.rows];
    }

    handleDiscountChange(event) {
        const index = event.target.dataset.index;
        this.rows[index].discount=event.target.value;
        this.rows=[...this.rows];
    }
    /* =========================
       Save Selected Rows
       ========================= */
    handleSave() {
        const rowsToSave = this.rows.map(row => {
            return {
                assetId: row.assetId,
                productId: row.productId,
                productName: row.productName,
                quantity: 1, // Mandatory 1
                service: row.service,
                serviceYear: row.serviceYear,
                price: parseFloat(row.price) || 0,
                discount: parseFloat(row.discount) || 0,
                selected: row.selected
            };
        });

        if (!this.recordId) {
            this.showToast('Error', 'Quote Id not found', 'error');
            return;
        }

        saveQuoteLines({
            quoteId: this.recordId,
            rows: rowsToSave
        })
        .then(() => {
            this.showToast('Success', 'Quote Line Items updated successfully', 'success');
            return refreshApex(this.wiredAssetResult);
        })
        .then(() => {
            setTimeout(() => {
                window.location.reload();
            }, 1000);
            this.handleCancel();
        }).catch(error => {
    console.error('Full Error:', JSON.stringify(error));

    let message = 'Unexpected error';

    if (error.body) {

        // Field level validation error (your case)
        if (error.body.fieldErrors) {
            const fieldErrors = error.body.fieldErrors;
            const firstField = Object.keys(fieldErrors)[0];
            message = fieldErrors[firstField][0].message;
        }

        // Page errors
        else if (error.body.pageErrors && error.body.pageErrors.length > 0) {
            message = error.body.pageErrors[0].message;
        }

        // Apex thrown error
        else if (error.body.message) {
            message = error.body.message;
        }
    }

    this.showToast('Error', message, 'error');
});
        // .catch(error => {
        //     console.error('Error in saveQuoteLines:', error);
        //     let message = 'Unexpected error';

        //     // if (error.body && error.body.message) {
        //     //     message = error.body.message;
        //     // } else if (error.body?.pageErrors?.length) {
        //     //     message = error.body.pageErrors[0].message;
        //     // }
        //     if(error.body){
        //         //Validation rules / DML Error
        //         if(error.body.output && error.body.output.errors.length>0){
        //             message=error.body.output.errors[0].message;
        //         }
        //         else if(error.body.output && error.body.output.fieldErrors){
        //             const fieldErrors = error.body.output.fieldErrors;
        //             const firstField =  Object.keys(fieldErrors)[0];
        //             message = fieldErrors[firstField][0].message;
        //         }
        //         else if(error.body.message){
        //             message = error.body.message;
        //         }
        //     }
        //     this.showToast('Error', message, 'error');
        // });
    }

    /* =========================
       Cancel
       ========================= */
    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    /* =========================
       Toast Utility
       ========================= */
    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }
}