import $ from "jquery";

$(function () {
    // TODO FIX

    $('#global_update_modal_sm').on('loaded',  function () {
        // do something here...
        checkchildrens('.js-have-children');
        console.log('loading mi');
    });
    $(document).on('click', ".js-have-children", function () {
        checkchildrens(this);
    });

    function checkchildrens(children) {
        console.log(children);
        if ($(children).prop('checked') == true) {
            $('.js-no-of-childrens').show();
        } else {
            $('.js-no-of-childrens').hide();
            $('.js-no-of-childrens').val('');
        }
    }
});