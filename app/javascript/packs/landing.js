import $ from "jquery";

$(function () {

    // first slider after header
    $(".bk-home-slider").slick({
        slidesToShow: 1,
        infinite: true,
        dots: true,
        autoplay: true,
        arrows: false
    });


    // Second slider for success story
    $(".bk-success-story-slider").slick({
        // normal options...
        infinite: false,

        // the magic
        responsive: [{

            breakpoint: 2000,
            settings: {
                slidesToShow: 3,
                infinite: true,
                // dots: true,
                autoplay: true,
            }

        }, {

            breakpoint: 600,
            settings: {
                slidesToShow: 1,
                infinite: true,
                // dots: true,
                autoplay: true
            }

        }, {

            breakpoint: 300,
            settings: "unslick" // destroys slick

        }]

    });
});