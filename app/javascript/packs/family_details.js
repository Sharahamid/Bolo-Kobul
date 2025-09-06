import $ from "jquery";

$(function () {
    $(document).on('change', '.js-relation', function () {
        if ($(this).val() == 'brother' || $(this).val() == 'sister') {
            $('.js-marital-status').show();
        } else {
            $('.js-marital-status').hide();
        }
    });
});