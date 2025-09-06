import $ from "jquery";
import {isEmpty} from "@rails/webpacker/package/utils/helpers";

$(function () {
    $('body').tooltip({
        selector: '[data-toggle="tooltip"]',
        container: 'body',
    });

    $('body').on('show.bs.tooltip', function() {
        $('.tooltip').not(this).tooltip('hide');
    });

    $('body').popover({
        selector: '[data-toggle="popover"]',
        container: 'body',
        html: true,
        trigger: 'hover'
    });

    $(document).on('change', "#partner_preference_max_age, #partner_preference_min_age", function () {
        let max_value = $("#partner_preference_max_age").val();
        let min_value = $("#partner_preference_min_age").val();
        if (max_value < min_value) {
            $(".text-max-age").show();
            $("#partner_preference_max_age").val('');
        } else {
            $(".text-max-age").hide();
        }

    });

    $(document).on('change', "#partner_preference_max_height, #partner_preference_min_height, #partner_preference_max_inch, #partner_preference_min_inch", function () {
        let max_inch = $("#partner_preference_max_inch").val();
        let min_inch = $("#partner_preference_min_inch").val();
        let max_feet = $("#partner_preference_max_height").val();
        let min_feet = $("#partner_preference_min_height").val();

        if (max_feet < min_feet) {
            $(".text-max-height").show();
            $(".text-max-inch").hide();
        } else if (max_feet === min_feet && max_inch < min_inch) {
            $(".text-max-inch").show();
            $(".text-max-height").hide();
        } else {
            $(".text-max-height").hide();
            $(".text-max-inch").hide();
        }

        if (max_feet === '') {
            $(".text-max-height").hide();
            console.log('max height is empty');
        }
        else {
            console.log('max height is not empty');
        }
        if (max_inch === '') {
            $(".text-max-inch").hide();
        }
    });

    // this will disable right-click on all images
    $('body').on('contextmenu', 'img', function(e){ return false; });
});
