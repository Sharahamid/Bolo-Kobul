import $ from "jquery";

$(function () {
    $(document).ready(function () {
        // Add minus icon for collapse element which is open by default
        $(".collapse.show").each(function () {
            $(this).prev(".panel-heading").find(".fas").addClass("fa-caret-up").removeClass("fa-caret-down");
        });

        // Toggle plus minus icon on show hide of collapse element
        $(".collapse").on('show.bs.collapse', function () {
            $(this).prev(".panel-heading").find(".fas").removeClass("fa-caret-down").addClass("fa-caret-up");
        }).on('hide.bs.collapse', function () {
            $(this).prev(".panel-heading").find(".fas").removeClass("fa-caret-up").addClass("fa-caret-down");
        });


        $(".custom-alert").fadeTo(5000, 500).slideUp(500, function () {
            $(".custom-alert").slideUp(500);
        });

    });
});